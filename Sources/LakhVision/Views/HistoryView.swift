import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var store: GoalStore

    struct SeriesPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let series: String
    }

    struct MonthBucket: Identifiable {
        let id = UUID()
        let label: String
        let amount: Double
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("History & Streak")
                    .font(.title2.bold())

                streakCard
                trajectoryChart
                monthlyLevelChart
                visitGrid

                Text("A snapshot is saved when you update the amount. Dashed Ideal line = linear pace to target.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            stat(title: "current streak", value: "\(store.data.streak)", suffix: "d", color: .orange)
            stat(title: "best streak", value: "\(store.data.bestStreak)", suffix: "d", color: .purple)
            stat(title: "snapshots", value: "\(store.data.history.count)", suffix: "", color: .blue)
            stat(title: "visited today",
                 value: visitedToday ? "YES" : "NO",
                 suffix: "",
                 color: visitedToday ? .green : .red)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }

    private func stat(title: String, value: String, suffix: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value + suffix)
                .font(.system(size: title == "visited today" ? 22 : 32, weight: .heavy, design: .rounded))
                .foregroundColor(color)
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var visitedToday: Bool {
        store.data.lastVisitDay == DayStamp.string(Date())
    }

    private var seriesPoints: [SeriesPoint] {
        var out: [SeriesPoint] = []
        for p in store.data.history {
            out.append(SeriesPoint(date: p.date, value: p.amount, series: "Saved"))
        }
        guard let first = store.data.history.first else { return out }
        var d = Calendar.current.startOfDay(for: first.date)
        let last = max(Calendar.current.startOfDay(for: Date()),
                       Calendar.current.startOfDay(for: store.data.endDate))
        var guardCount = 0
        while d <= last && guardCount < 1500 {
            out.append(SeriesPoint(date: d, value: store.math.idealAmount(on: d), series: "Ideal"))
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
            guardCount += 1
        }
        return out
    }

    private var trajectoryChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Trajectory vs Ideal", systemImage: "chart.xyaxis.line")
                .font(.headline)

            if store.data.history.count < 2 {
                Text("Not enough data yet. Update saved amount on different days to see the curve.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 160)
            } else {
                Chart(seriesPoints) { p in
                    LineMark(
                        x: .value("Date", p.date),
                        y: .value("₹", p.value)
                    )
                    .foregroundStyle(by: .value("Series", p.series))
                    .lineStyle(StrokeStyle(
                        lineWidth: p.series == "Saved" ? 2.5 : 1.5,
                        dash: p.series == "Ideal" ? [5, 4] : []
                    ))
                    if p.series == "Saved" {
                        PointMark(
                            x: .value("Date", p.date),
                            y: .value("₹", p.value)
                        )
                        .foregroundStyle(Color.green)
                        .symbolSize(18)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
                }
                .chartLegend(position: .bottom)
                .frame(height: 220)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(NSColor.textBackgroundColor)))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }

    private var monthBuckets: [MonthBucket] {
        let cal = Calendar.current
        var totals: [String: [Date: Double]] = [:]

        for p in store.data.history {
            let comps = cal.dateComponents([.year, .month], from: p.date)
            guard let monthStart = cal.date(from: comps) else { continue }
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM yy"
            let key = fmt.string(from: monthStart)
            totals[key, default: [:]][cal.startOfDay(for: p.date)] = p.amount
        }

        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yy"
        return totals.map { key, days in
            let lastDate = days.keys.max() ?? Date()
            return MonthBucket(label: key, amount: days[lastDate] ?? 0)
        }
        .sorted { a, b in
            let f = DateFormatter()
            f.dateFormat = "MMM yy"
            return (f.date(from: a.label) ?? .distantPast) < (f.date(from: b.label) ?? .distantPast)
        }
        .suffix(12)
        .map { $0 }
    }

    private var monthlyLevelChart: some View {
        let buckets = monthBuckets
        return VStack(alignment: .leading, spacing: 8) {
            Label("Savings level by month", systemImage: "chart.bar.fill")
                .font(.headline)
            if buckets.isEmpty {
                Text("No history yet.").font(.caption).foregroundColor(.secondary)
            } else {
                Chart(buckets) { b in
                    BarMark(
                        x: .value("Month", b.label),
                        y: .value("₹", b.amount)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
                .frame(height: 160)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(NSColor.textBackgroundColor)))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }

    private var visitGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Daily visits (last 28 days)", systemImage: "calendar")
                .font(.headline)
            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            let visits = Set(store.data.visitDates)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(0..<28, id: \.self) { i in
                    let day = cal.date(byAdding: .day, value: -(27 - i), to: today) ?? today
                    let key = DayStamp.string(day)
                    let hit = visits.contains(key) || key == store.data.lastVisitDay
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hit ? Color.green : Color.gray.opacity(0.25))
                        .frame(height: 32)
                        .overlay(
                            Text("\(cal.component(.day, from: day))")
                                .font(.caption2.bold())
                                .foregroundColor(hit ? .white : .secondary)
                        )
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}
