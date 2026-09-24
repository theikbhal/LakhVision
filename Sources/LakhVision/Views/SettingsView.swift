import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: GoalStore

    var body: some View {
        Form {
            Section("Goal") {
                numberField("Target ₹", value: $store.data.target)
                numberField("Saved ₹", value: $store.data.saved)
                DatePicker("Start date", selection: $store.data.startDate, displayedComponents: .date)
                DatePicker("End date (2 years)", selection: $store.data.endDate, displayedComponents: .date)
                TextField("City", text: $store.data.city)
            }

            Section("Why (motivation text)") {
                TextEditor(text: $store.data.whyText)
                    .frame(minHeight: 80)
            }

            Section("Things prices (Tirupati defaults)") {
                numberField("Car ₹", value: $store.data.carPrice)
                numberField("House ₹", value: $store.data.housePrice)
                numberField("Gold ₹ / gram", value: $store.data.goldPerGram)
                LabeledContent("Gold sovereign (8g)",
                               value: INR.format(store.data.goldPerGram * 8))
                numberField("Farmland ₹ / acre", value: $store.data.farmlandPerAcre)
                LabeledContent("1 acre = guntas", value: "40")
                numberField("Tractor ₹", value: $store.data.tractorPrice)
                numberField("Auto ₹", value: $store.data.autoPrice)
            }

            Section("Push notifications") {
                Toggle("Daily visit reminder", isOn: $store.data.dailyReminder)
                Picker("Daily hour", selection: $store.data.dailyHour) {
                    ForEach(6..<22, id: \.self) { h in
                        Text(String(format: "%02d:00", h)).tag(h)
                    }
                }
                Toggle("Weekly check (Sunday 10:00) — minimum weekly", isOn: $store.data.weeklyReminder)
                Toggle("Monthly check (1st, 11:00) — worst case once a month", isOn: $store.data.monthlyReminder)
                HStack {
                    Button("Apply & Reschedule") {
                        NotificationManager.shared.requestAuthorization()
                        NotificationManager.shared.scheduleAll()
                    }
                    Button("Send Test Now") {
                        NotificationManager.shared.sendImmediate(
                            title: "LakhVision Test",
                            body: "Daily · weekly · monthly reminders configured."
                        )
                    }
                }
            }

            Section("Streak & history") {
                LabeledContent("Current streak", value: "\(store.data.streak) days")
                LabeledContent("Best streak", value: "\(store.data.bestStreak) days")
                LabeledContent("History snapshots", value: "\(store.data.history.count)")
                LabeledContent("Milestone passed", value: "\(store.data.milestonePassed)%")
                Button("Clear history & streak", role: .destructive) {
                    store.data.history = []
                    store.data.visitDates = []
                    store.data.streak = 0
                    store.data.bestStreak = 0
                    store.data.lastVisitDay = ""
                    store.data.milestonePassed = 0
                }
            }

            Section("Data") {
                LabeledContent("Saved file", value: GoalStore.saveURL.path)
                Button("Reset saved to ₹0", role: .destructive) {
                    store.setSaved(0)
                }
            }
        }
        .formStyle(.grouped)
        .padding(4)
        .onChange(of: store.data.dailyReminder) { _ in NotificationManager.shared.scheduleAll() }
        .onChange(of: store.data.weeklyReminder) { _ in NotificationManager.shared.scheduleAll() }
        .onChange(of: store.data.monthlyReminder) { _ in NotificationManager.shared.scheduleAll() }
        .onChange(of: store.data.dailyHour) { _ in NotificationManager.shared.scheduleAll() }
    }

    private func numberField(_ label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            TextField("", value: value, format: .number.grouping(.automatic))
                .textFieldStyle(.roundedBorder)
                .frame(width: 160)
        }
    }
}
