import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: GoalStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let math = store.math

        VStack(alignment: .leading, spacing: 8) {
            Text("LakhVision · ₹20L in 2 Years")
                .font(.headline)

            HStack {
                Text("Saved")
                Spacer()
                Text(INR.format(store.data.saved)).bold()
            }
            HStack {
                Text("Target")
                Spacer()
                Text(INR.format(store.data.target))
            }
            HStack {
                Text("Progress")
                Spacer()
                Text("\(math.percent)%").bold()
            }
            HStack {
                Text("Days left")
                Spacer()
                Text("\(math.daysRemaining)")
            }
            HStack {
                Text(math.isAhead ? "Pace" : "Behind pace")
                Spacer()
                Text(INR.format(abs(math.paceDelta)))
                    .foregroundColor(math.isAhead ? .green : .red)
            }

            Divider()

            Button("Open LakhVision") {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut("o")

            Button("Quick +₹1,000") {
                store.addSaved(1000)
            }

            Button("Send Test Notification") {
                NotificationManager.shared.sendImmediate(
                    title: "LakhVision",
                    body: "Daily · Weekly · Monthly reminders are on."
                )
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(12)
        .frame(width: 280)
    }
}
