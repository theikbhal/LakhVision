import Foundation
import SwiftUI

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

    var requiredMonthly: Double {
        let months = max(Double(daysRemaining) / 30.44, 1)
        return remaining / months
    }

    var milestones: [(label: String, amount: Double, pct: Int)] {
        [
            ("Pass 25%", target * 0.25, 25),
            ("Pass 50%", target * 0.50, 50),
            ("Pass 75%", target * 0.75, 75),
            ("GOAL", target, 100)
        ]
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
}

@MainActor
final class GoalStore: ObservableObject {
    @Published var data: GoalData {
        didSet { save() }
    }

    nonisolated static let saveURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".lakhvision/goal.json")

    init() {
        if let raw = try? Data(contentsOf: Self.saveURL),
           let decoded = try? JSONDecoder().decode(GoalData.self, from: raw) {
            data = decoded
        } else {
            data = GoalData()
        }
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
    }

    func addSaved(_ amount: Double) {
        data.saved = max(data.saved + amount, 0)
    }

    func setSaved(_ amount: Double) {
        data.saved = max(amount, 0)
    }

    func things() -> [ThingItem] {
        [
            ThingItem(name: "Car", symbol: "car.side.fill", price: data.carPrice,
                      detail: "Personal car in \(data.city)", unit: "car", qty: 1, isEmoji: false),
            ThingItem(name: "House", symbol: "house.fill", price: data.housePrice,
                      detail: "Home budget in \(data.city)", unit: "house", qty: 1, isEmoji: false),
            ThingItem(name: "Gold", symbol: "circle.hexagongrid.fill", price: data.goldPerGram,
                      detail: "24k rate ₹\(Int(data.goldPerGram))/gram", unit: "grams", qty: 1, isEmoji: false),
            ThingItem(name: "Farmland", symbol: "leaf.fill", price: data.farmlandPerAcre,
                      detail: "Acre near \(data.city)", unit: "acre", qty: 1, isEmoji: false),
            ThingItem(name: "Tractor", symbol: "tractor", price: data.tractorPrice,
                      detail: "New tractor for farm work", unit: "tractor", qty: 1, isEmoji: true),
            ThingItem(name: "Auto", symbol: "auto", price: data.autoPrice,
                      detail: "Auto-rickshaw for income", unit: "auto", qty: 1, isEmoji: true)
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
