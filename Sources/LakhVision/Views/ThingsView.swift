import SwiftUI

struct ThingsView: View {
    @EnvironmentObject var store: GoalStore

    var body: some View {
        let math = store.math
        let things = store.things()
        let cols = [GridItem(.adaptive(minimum: 300), spacing: 12)]

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Visualize Anything")
                    .font(.title2.bold())
                Text("Car · House · Gold (sovereigns) · Farmland (acres/guntas) · Tractor · Auto — Tirupati defaults, editable in Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(things) { thing in
                        ThingCard(thing: thing, math: math, saved: store.data.saved)
                    }
                }
            }
            .padding()
        }
    }
}

struct ThingCard: View {
    let thing: ThingItem
    let math: MoneyMath
    let saved: Double

    private var progress: Double {
        if thing.unit == "grams" || thing.unit == "acre" {
            return thing.price > 0 ? min(math.progress, 1) : 0
        }
        guard thing.price > 0 else { return 0 }
        return min(saved / thing.price, 1)
    }

    private var isAffordable: Bool {
        if thing.unit == "grams" || thing.unit == "acre" {
            return math.progress >= 1
        }
        return progress >= 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Group {
                    if thing.isEmoji {
                        Text(thing.symbol == "tractor" ? "🚜" : "🛺")
                            .font(.title)
                    } else {
                        Image(systemName: thing.symbol)
                            .font(.title)
                            .foregroundColor(.green)
                    }
                }
                .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(thing.name).font(.headline)
                    Text(thing.detail).font(.caption2).foregroundColor(.secondary)
                }
                Spacer()
                if thing.unit == "grams" {
                    Text("₹\(Int(thing.price))/g")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                } else if thing.unit == "acre" {
                    Text(INR.format(thing.price) + "/acre")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                } else {
                    Text(INR.format(thing.price))
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                }
            }

            ProgressView(value: progress)
                .tint(isAffordable ? .green : .blue)

            HStack {
                Text(thing.savedLine)
                    .font(.caption)
                Spacer()
                Text(isAffordable ? "AFFORDABLE AT GOAL" : gapLabel)
                    .font(.caption.bold())
                    .foregroundColor(isAffordable ? .green : .red)
            }

            Divider()

            HStack {
                Text(thing.goalLine)
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                Spacer()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isAffordable ? Color.green.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
    }

    private var gapLabel: String {
        if thing.unit == "grams" {
            let needGrams = max(math.target - saved, 0) / max(thing.price, 1)
            let needSov = needGrams / 8
            return "Gap \(String(format: "%.0fg", needGrams)) (\(String(format: "%.1f", needSov)) sov)"
        }
        if thing.unit == "acre" {
            let needAcres = max(math.target - saved, 0) / max(thing.price, 1)
            return "Gap \(String(format: "%.0f", needAcres * thing.price)) to 1 acre"
        }
        return "Gap \(INR.format(max(thing.price - saved, 0)))"
    }
}
