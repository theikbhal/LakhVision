import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: GoalStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let math = store.math

        VStack(alignment: .leading, spacing: 8) {
            Text("LakhVision · ₹20L in 2 Years")
                .font(.headline)

            ProgressView(value: math.progress)
                .tint(.green)

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
                Text("Daily / Week need")
                Spacer()
                Text("\(INR.compact(math.requiredDaily)) / \(INR.compact(math.requiredWeekly))")
            }
            HStack {
                Text(math.isAhead ? "Pace ahead" : "Pace behind")
                Spacer()
                Text(INR.format(abs(math.paceDelta)))
                    .foregroundColor(math.isAhead ? .green : .red)
            }
            HStack {
                Text("Streak / Best")
                Spacer()
                Text("\(store.data.streak)d / \(store.data.bestStreak)d")
                    .foregroundColor(.orange)
            }

            Divider()

            Button("Open LakhVision") {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut("o")

            Menu("Quick add") {
                Button("+₹500") { store.addSaved(500) }
                Button("+₹1,000") { store.addSaved(1000) }
                Button("+₹2,000") { store.addSaved(2000) }
                Button("+₹5,000") { store.addSaved(5000) }
                Button("+₹10,000") { store.addSaved(10000) }
                Button("+₹50,000") { store.addSaved(50000) }
                Divider()
                Button("Custom…") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }

            Button("Log visit (streak)") {
                store.recordVisit()
            }

            Button("Send Test Notification") {
                NotificationManager.shared.sendImmediate(
                    title: "LakhVision",
                    body: "Daily · weekly · monthly reminders are on."
                )
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(12)
        .frame(width: 300)
    }
}
