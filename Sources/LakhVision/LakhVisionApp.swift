import SwiftUI
import UserNotifications

@main
struct LakhVisionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = GoalStore()

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 980, minHeight: 660)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                    store.recordVisit()
                    store.updateDockBadge()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1140, height: 760)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
        } label: {
            let pct = store.data.target > 0
                ? Int((store.data.saved / store.data.target * 100).rounded())
                : 0
            if store.data.streak > 1 {
                Text("\(INR.compact(store.data.saved)) · \(pct)% · \(store.data.streak)d")
            } else {
                Text("\(INR.compact(store.data.saved)) · \(pct)%")
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.scheduleAll()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            NSApp.windows.first { $0.identifier?.rawValue.contains("main") == true || $0.title.contains("LakhVision") }?
                .makeKeyAndOrderFront(nil)
            for w in NSApp.windows where w.isVisible {
                w.makeKeyAndOrderFront(nil)
                return true
            }
            sender.windows.first?.makeKeyAndOrderFront(nil)
        }
        return true
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            for w in NSApp.windows {
                if w.isVisible {
                    w.makeKeyAndOrderFront(nil)
                }
            }
            if NSApp.windows.allSatisfy({ !$0.isVisible }) {
                NSApp.sendAction(#selector(NSApplication.arrangeInFront(_:)), to: nil, from: nil)
            }
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
        completionHandler()
    }
}
