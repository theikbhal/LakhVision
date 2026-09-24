import Foundation
import SwiftUI

struct HistoryPoint: Codable, Identifiable {
    var id: Date { date }
    var date: Date
    var amount: Double
}

struct GoalData: Codable {
    var target: Double = 2_000_000
    var saved: Double = 0
    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
    var whyText: String = "Wife set this goal. No job for the last 4 years. No income from self-earning."
    var city: String = "Tirupati, Andhra Pradesh"

    var carPrice: Double = 800_000
    var housePrice: Double = 5_000_000
    var goldPerGram: Double = 12_000
    var farmlandPerAcre: Double = 2_500_000
    var tractorPrice: Double = 650_000
    var autoPrice: Double = 350_000

    var dailyReminder: Bool = true
    var dailyHour: Int = 9
    var weeklyReminder: Bool = true
    var monthlyReminder: Bool = true

    var history: [HistoryPoint] = []
    var visitDates: [String] = []
    var lastVisitDay: String = ""
    var streak: Int = 0
    var bestStreak: Int = 0
    var milestonePassed: Int = 0

    enum CodingKeys: String, CodingKey {
        case target, saved, startDate, endDate, whyText, city
        case carPrice, housePrice, goldPerGram, farmlandPerAcre, tractorPrice, autoPrice
        case dailyReminder, dailyHour, weeklyReminder, monthlyReminder
        case history, visitDates, lastVisitDay, streak, bestStreak, milestonePassed
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        target = try c.decodeIfPresent(Double.self, forKey: .target) ?? 2_000_000
        saved = try c.decodeIfPresent(Double.self, forKey: .saved) ?? 0
        startDate = try c.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        endDate = try c.decodeIfPresent(Date.self, forKey: .endDate)
            ?? (Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date())
        whyText = try c.decodeIfPresent(String.self, forKey: .whyText)
            ?? "Wife set this goal. No job for the last 4 years. No income from self-earning."
        city = try c.decodeIfPresent(String.self, forKey: .city) ?? "Tirupati, Andhra Pradesh"
        carPrice = try c.decodeIfPresent(Double.self, forKey: .carPrice) ?? 800_000
        housePrice = try c.decodeIfPresent(Double.self, forKey: .housePrice) ?? 5_000_000
        goldPerGram = try c.decodeIfPresent(Double.self, forKey: .goldPerGram) ?? 12_000
        farmlandPerAcre = try c.decodeIfPresent(Double.self, forKey: .farmlandPerAcre) ?? 2_500_000
        tractorPrice = try c.decodeIfPresent(Double.self, forKey: .tractorPrice) ?? 650_000
        autoPrice = try c.decodeIfPresent(Double.self, forKey: .autoPrice) ?? 350_000
        dailyReminder = try c.decodeIfPresent(Bool.self, forKey: .dailyReminder) ?? true
        dailyHour = try c.decodeIfPresent(Int.self, forKey: .dailyHour) ?? 9
        weeklyReminder = try c.decodeIfPresent(Bool.self, forKey: .weeklyReminder) ?? true
        monthlyReminder = try c.decodeIfPresent(Bool.self, forKey: .monthlyReminder) ?? true
        history = try c.decodeIfPresent([HistoryPoint].self, forKey: .history) ?? []
        visitDates = try c.decodeIfPresent([String].self, forKey: .visitDates) ?? []
        lastVisitDay = try c.decodeIfPresent(String.self, forKey: .lastVisitDay) ?? ""
        streak = try c.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        bestStreak = try c.decodeIfPresent(Int.self, forKey: .bestStreak) ?? 0
        milestonePassed = try c.decodeIfPresent(Int.self, forKey: .milestonePassed) ?? 0
    }
}

struct MoneyMath {
    let target: Double
    let saved: Double
    let start: Date
    let end: Date

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(max(saved / target, 0), 1)
    }

    var percent: Int { Int((progress * 100).rounded()) }
    var remaining: Double { max(target - saved, 0) }

    var daysTotal: Int {
        let cal = Calendar.current
        let a = cal.startOfDay(for: start)
        let b = cal.startOfDay(for: end)
        return max(cal.dateComponents([.day], from: a, to: b).day ?? 0, 1)
    }

    var daysElapsed: Int {
        let cal = Calendar.current
        let a = cal.startOfDay(for: start)
        let now = cal.startOfDay(for: Date())
        return max(cal.dateComponents([.day], from: a, to: now).day ?? 0, 0)
    }

    var daysRemaining: Int { max(daysTotal - daysElapsed, 0) }

    var requiredForPace: Double {
        target * (Double(daysElapsed) / Double(daysTotal))
    }

    var paceDelta: Double { saved - requiredForPace }
    var isAhead: Bool { paceDelta >= 0 }

    var requiredDaily: Double {
        daysRemaining > 0 ? remaining / Double(daysRemaining) : remaining
    }

    var requiredWeekly: Double { requiredDaily * 7 }

    var requiredMonthly: Double {
        let months = max(Double(daysRemaining) / 30.44, 1)
        return remaining / months
    }

    var projectedFinish: Date? {
        guard daysElapsed > 0, saved > 0 else { return nil }
        if saved >= target { return Date() }
        let rate = saved / Double(daysElapsed)
        guard rate > 0 else { return nil }
        let daysNeeded = remaining / rate
        return Calendar.current.date(byAdding: .day, value: Int(daysNeeded.rounded()), to: Date())
    }

    var isOnTrackToFinish: Bool {
        guard let finish = projectedFinish else { return false }
        return finish <= end
    }

    var milestones: [(label: String, amount: Double, pct: Int)] {
        [
            ("Pass 25%", target * 0.25, 25),
            ("Pass 50%", target * 0.50, 50),
            ("Pass 75%", target * 0.75, 75),
            ("GOAL", target, 100)
        ]
    }

    func idealAmount(on date: Date) -> Double {
        let cal = Calendar.current
        let a = cal.startOfDay(for: start)
        let b = cal.startOfDay(for: end)
        let d = cal.startOfDay(for: date)
        let total = max(cal.dateComponents([.day], from: a, to: b).day ?? 1, 1)
        let elapsed = cal.dateComponents([.day], from: a, to: d).day ?? 0
        return target * min(max(Double(elapsed) / Double(total), 0), 1)
    }
}

struct ThingItem: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let price: Double
    let detail: String
    let unit: String
    let qty: Double
    let isEmoji: Bool
    let savedLine: String
    let goalLine: String
}

enum DayStamp {
    static let fmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func string(_ date: Date) -> String { fmt.string(from: date) }
}

@MainActor
final class GoalStore: ObservableObject {
    @Published var data: GoalData {
        didSet { save() }
    }

    nonisolated static let saveURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".lakhvision/goal.json")

    private var suppressMilestone = false

    init() {
        if let raw = try? Data(contentsOf: Self.saveURL),
           let decoded = try? JSONDecoder().decode(GoalData.self, from: raw) {
            data = decoded
        } else {
            data = GoalData()
        }
        save()
        recordVisit()
        recordHistory()
    }

    var math: MoneyMath {
        MoneyMath(target: data.target, saved: data.saved, start: data.startDate, end: data.endDate)
    }

    func save() {
        do {
            try FileManager.default.createDirectory(
                at: Self.saveURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try JSONEncoder().encode(data).write(to: Self.saveURL, options: .atomic)
        } catch {
            print("Save failed: \(error)")
        }
        updateDockBadge()
    }

    func updateDockBadge() {
        DispatchQueue.main.async {
            let pct = self.math.percent
            NSApp.dockTile.badgeLabel = pct > 0 ? "\(pct)" : nil
            NSApp.dockTile.display()
        }
    }

    func addSaved(_ amount: Double) {
        data.saved = max(data.saved + amount, 0)
        afterMoneyChange()
    }

    func setSaved(_ amount: Double) {
        data.saved = max(amount, 0)
        afterMoneyChange()
    }

    private func afterMoneyChange() {
        recordHistory()
        checkMilestones()
        NotificationManager.shared.scheduleAll()
    }

    func recordVisit() {
        let today = DayStamp.string(Date())
        guard data.lastVisitDay != today else { return }

        let yesterday = DayStamp.string(
            Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        )
        data.streak = (data.lastVisitDay == yesterday) ? data.streak + 1 : 1
        data.bestStreak = max(data.bestStreak, data.streak)
        data.lastVisitDay = today
        if !data.visitDates.contains(today) {
            data.visitDates.append(today)
        }
        if data.visitDates.count > 800 {
            data.visitDates.removeFirst(data.visitDates.count - 730)
        }
        save()
    }

    func recordHistory() {
        let today = Calendar.current.startOfDay(for: Date())
        if let idx = data.history.lastIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            data.history[idx].amount = data.saved
        } else {
            data.history.append(HistoryPoint(date: today, amount: data.saved))
        }
        if data.history.count > 2000 {
            data.history.removeFirst(data.history.count - 1500)
        }
    }

    func checkMilestones() {
        guard !suppressMilestone else { return }
        let p = math.percent
        for t in [25, 50, 75, 100] where p >= t && data.milestonePassed < t {
            suppressMilestone = true
            data.milestonePassed = t
            suppressMilestone = false
            NotificationManager.shared.sendImmediate(
                title: "Milestone passed · \(t)%",
                body: t == 100
                    ? "₹20L GOAL REACHED. Incredible."
                    : "\(INR.format(data.saved)) saved · pass mark \(t)% cleared. Keep going."
            )
        }
    }

    func recordVisitAndNotify() {
        recordVisit()
    }

    func things() -> [ThingItem] {
        let city = data.city
        let grams = data.goldPerGram > 0 ? data.saved / data.goldPerGram : 0
        let goalGrams = data.goldPerGram > 0 ? data.target / data.goldPerGram : 0
        let sovereigns = grams / 8
        let goalSovereigns = goalGrams / 8
        let guntas = data.farmlandPerAcre > 0 ? (data.saved / data.farmlandPerAcre) * 40 : 0
        let goalGuntas = data.farmlandPerAcre > 0 ? (data.target / data.farmlandPerAcre) * 40 : 0

        func pct(_ price: Double) -> Int {
            guard price > 0 else { return 0 }
            return min(Int((data.saved / price * 100).rounded()), 9999)
        }

        return [
            ThingItem(
                name: "Car", symbol: "car.side.fill", price: data.carPrice,
                detail: "Personal car in \(city)", unit: "car", qty: 1, isEmoji: false,
                savedLine: "\(pct(data.carPrice))% of price from saved",
                goalLine: String(format: "At ₹20L: %.1f cars", data.target / max(data.carPrice, 1))
            ),
            ThingItem(
                name: "House", symbol: "house.fill", price: data.housePrice,
                detail: "Home budget in \(city)", unit: "house", qty: 1, isEmoji: false,
                savedLine: "\(pct(data.housePrice))% of price from saved",
                goalLine: String(format: "At ₹20L: %.0f%% of house", data.target / max(data.housePrice, 1) * 100)
            ),
            ThingItem(
                name: "Gold", symbol: "circle.hexagongrid.fill", price: data.goldPerGram,
                detail: "24k ₹\(Int(data.goldPerGram))/g · 1 sovereign = 8g", unit: "grams", qty: 1, isEmoji: false,
                savedLine: String(format: "%.1fg · %.1f sovereigns", grams, sovereigns),
                goalLine: String(format: "At ₹20L: %.0fg · %.0f sovereigns", goalGrams, goalSovereigns)
            ),
            ThingItem(
                name: "Farmland", symbol: "leaf.fill", price: data.farmlandPerAcre,
                detail: "Acre near \(city) · 1 acre = 40 guntas", unit: "acre", qty: 1, isEmoji: false,
                savedLine: String(format: "%.2f acre · %.0f guntas",
                                  data.saved / max(data.farmlandPerAcre, 1), guntas),
                goalLine: String(format: "At ₹20L: %.2f acre · %.0f guntas",
                                 data.target / max(data.farmlandPerAcre, 1), goalGuntas)
            ),
            ThingItem(
                name: "Tractor", symbol: "tractor", price: data.tractorPrice,
                detail: "New tractor for farm work", unit: "tractor", qty: 1, isEmoji: true,
                savedLine: "\(pct(data.tractorPrice))% of price from saved",
                goalLine: String(format: "At ₹20L: %.1f tractors", data.target / max(data.tractorPrice, 1))
            ),
            ThingItem(
                name: "Auto", symbol: "auto", price: data.autoPrice,
                detail: "Auto-rickshaw for income", unit: "auto", qty: 1, isEmoji: true,
                savedLine: "\(pct(data.autoPrice))% of price from saved",
                goalLine: String(format: "At ₹20L: %.1f autos", data.target / max(data.autoPrice, 1))
            )
        ]
    }
}

enum INR {
    static func format(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_IN")
        f.maximumFractionDigits = 0
        let s = f.string(from: NSNumber(value: amount)) ?? "0"
        return "₹\(s)"
    }

    static func compact(_ amount: Double) -> String {
        if amount >= 10_000_000 {
            return String(format: "₹%.1f Cr", amount / 10_000_000)
        }
        if amount >= 100_000 {
            let lakhs = amount / 100_000
            if lakhs == lakhs.rounded() {
                return "₹\(Int(lakhs))L"
            }
            return String(format: "₹%.1fL", lakhs)
        }
        if amount >= 1_000 {
            return "₹\(Int(amount / 1_000))k"
        }
        return "₹\(Int(amount))"
    }
}
