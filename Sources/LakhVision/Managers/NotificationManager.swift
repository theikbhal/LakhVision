import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleAll()
                }
            }
        }
    }

    func scheduleAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard let data = try? JSONDecoder().decode(
            GoalData.self,
            from: Data(contentsOf: GoalStore.saveURL)
        ) else {
            scheduleDefaults()
            return
        }

        let math = MoneyMath(target: data.target, saved: data.saved, start: data.startDate, end: data.endDate)

        if data.dailyReminder {
            let content = UNMutableNotificationContent()
            content.title = "LakhVision — Daily Visit"
            var body = "\(math.daysRemaining) days left · \(math.percent)% done · \(INR.format(math.remaining)) to go."
            if data.streak > 1 {
                body += " Streak \(data.streak) days."
            }
            body += " Open the app today."
            content.body = body
            content.sound = .default
            content.userInfo = ["deepLink": "main"]
            var dc = DateComponents()
            dc.hour = data.dailyHour
            dc.minute = 0
            center.add(UNNotificationRequest(
                identifier: "lakhvision-daily",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            ))
        }

        if data.weeklyReminder {
            let content = UNMutableNotificationContent()
            content.title = "LakhVision — Weekly Minimum Check"
            content.body = "Weekly check: \(INR.format(data.saved)) of \(INR.format(data.target)) · \(math.percent)%. Weekly need \(INR.format(math.requiredWeekly))."
            content.sound = .default
            var dc = DateComponents()
            dc.weekday = 1
            dc.hour = 10
            dc.minute = 0
            center.add(UNNotificationRequest(
                identifier: "lakhvision-weekly",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            ))
        }

        if data.monthlyReminder {
            let content = UNMutableNotificationContent()
            content.title = "LakhVision — Monthly Check (Worst Case)"
            content.body = "Month-once fallback if you missed daily & weekly. \(math.percent)% of ₹20L · streak \(data.streak)."
            content.sound = .default
            var dc = DateComponents()
            dc.day = 1
            dc.hour = 11
            dc.minute = 0
            center.add(UNNotificationRequest(
                identifier: "lakhvision-monthly",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            ))
        }
    }

    private func scheduleDefaults() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "LakhVision — Daily Visit"
        content.body = "Open LakhVision and update your ₹20L goal progress."
        content.sound = .default
        var dc = DateComponents()
        dc.hour = 9
        dc.minute = 0
        center.add(UNNotificationRequest(
            identifier: "lakhvision-daily",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        ))
    }

    func sendImmediate(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "lakhvision-\(UUID().uuidString)", content: content, trigger: nil)
        )
    }
}
