import SwiftUI

@main
struct LakhVisionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = GoalStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 980, minHeight: 660)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1120, height: 740)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
        } label: {
            let pct = store.data.target > 0
                ? Int((store.data.saved / store.data.target * 100).rounded())
                : 0
            Text("\(INR.compact(store.data.saved)) · \(pct)%")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.scheduleAll()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
