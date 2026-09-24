import SwiftUI

struct ThingsView: View {
    @EnvironmentObject var store: GoalStore

    var body: some View {
        let math = store.math
        let things = store.things()
        let cols = [GridItem(.adaptive(minimum: 280), spacing: 12)]

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Visualize Anything")
                    .font(.title2.bold())
                Text("Car · House · Gold · Farmland · Tractor · Auto — Tirupati prices editable in Settings. Saved vs each price, and what ₹20L unlocks.")
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
        guard thing.price > 0 else { return 0 }
        return min(saved / thing.price, 1)
    }

    private var affordableAtGoal: Double {
        guard thing.price > 0 else { return 0 }
        return math.target / thing.price
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
                Text(INR.format(thing.price))
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
            }

            ProgressView(value: progress)
                .tint(progress >= 1 ? .green : .blue)

            HStack {
                Text("\(Int(progress * 100))% of price from saved")
                    .font(.caption)
                Spacer()
                Text(progress >= 1 ? "AFFORDABLE NOW" : "Gap \(INR.format(max(thing.price - saved, 0)))")
                    .font(.caption.bold())
                    .foregroundColor(progress >= 1 ? .green : .red)
            }

            Divider()

            HStack {
                Text("At ₹20L goal:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if thing.unit == "grams" || thing.unit == "acre" {
                    Text("\(Int(affordableAtGoal)) \(thing.unit)")
                        .font(.caption.bold())
                } else if affordableAtGoal >= 1 {
                    Text("\(Int(affordableAtGoal)) \(thing.unit)s")
                        .font(.caption.bold())
                } else {
                    Text("\(Int(progress * 100))% of 1 \(thing.unit)")
                        .font(.caption.bold())
                }
            }

            if math.target > thing.price && thing.unit != "grams" && thing.unit != "acre" {
                Text("₹20L covers \(String(format: "%.1f", affordableAtGoal))× this price.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progress >= 1 ? Color.green.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
    }
}
