import SwiftUI

struct NoteDenomination: Identifiable {
    let id = UUID()
    let value: Int
    let color: Color
    let tint: Color
}

struct NotesView: View {
    @EnvironmentObject var store: GoalStore

    private let dens: [NoteDenomination] = [
        NoteDenomination(value: 500, color: Color(red: 0.55, green: 0.55, blue: 0.55), tint: .white),
        NoteDenomination(value: 200, color: Color(red: 0.95, green: 0.70, blue: 0.15), tint: .black),
        NoteDenomination(value: 100, color: Color(red: 0.72, green: 0.62, blue: 0.82), tint: .black)
    ]

    var body: some View {
        let math = store.math

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Visualize with Currency Notes")
                    .font(.title2.bold())
                Text("How your saved amount and ₹20L goal look in ₹500 · ₹200 · ₹100 notes.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ForEach(dens) { d in
                    NoteSection(
                        den: d,
                        savedCount: Int(store.data.saved) / d.value,
                        targetCount: Int(store.data.target) / d.value
                    )
                }

                mixSection(math: math)
            }
            .padding()
        }
    }

    private func mixSection(math: MoneyMath) -> some View {
        let amount = Int(store.data.saved)
        let n500 = amount / 500
        let n200 = (amount % 500) / 200
        let n100 = (amount % 100)
        let t500 = Int(store.data.target) / 500

        return VStack(alignment: .leading, spacing: 10) {
            Text("Optimal Mix of Saved Cash")
                .font(.headline)
            HStack(spacing: 12) {
                mixBox(count: n500, value: 500, color: dens[0].color)
                mixBox(count: n200, value: 200, color: dens[1].color)
                mixBox(count: n100, value: 100, color: dens[2].color)
            }
            Text("Goal needs \(t500) × ₹500 notes (or \(Int(store.data.target)/200) × ₹200, or \(Int(store.data.target)/100) × ₹100).")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }

    private func mixBox(count: Int, value: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            BanknoteShape(value: value, color: color)
                .frame(width: 90, height: 42)
            Text("\(count)")
                .font(.title3.bold())
            Text("× ₹\(value)").font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.12)))
    }
}

struct NoteSection: View {
    let den: NoteDenomination
    let savedCount: Int
    let targetCount: Int

    private var cols: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 6), count: 6) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("₹\(den.value) Notes")
                    .font(.headline)
                Spacer()
                Text("Saved \(savedCount) / Goal \(targetCount)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: cols, spacing: 6) {
                ForEach(0..<min(targetCount, 18), id: \.self) { i in
                    let has = i < savedCount
                    BanknoteShape(value: den.value, color: den.color)
                        .opacity(has ? 1 : 0.25)
                        .overlay(alignment: .center) {
                            if !has {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                }
            }

            if targetCount > 18 {
                Text("+ \(targetCount - 18) more notes at goal · each cell shown is 1 note (sample of \(targetCount))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if savedCount > 0 {
                let pct = targetCount > 0 ? min(Double(savedCount) / Double(targetCount), 1) : 0
                ProgressView(value: pct)
                    .tint(den.color)
                Text("\(Int(pct * 100))% of the ₹\(den.value)-note stack you need")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("No ₹\(den.value) notes counted yet — add savings in Goal Ways.")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct BanknoteShape: View {
    let value: Int
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(color)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black.opacity(0.25), lineWidth: 1)
            )
            .overlay(
                VStack(spacing: 1) {
                    Text("₹\(value)")
                        .font(.caption.bold())
                    Text("LAKHS")
                        .font(.system(size: 6, weight: .medium))
                        .opacity(0.7)
                }
                .foregroundColor(value == 500 ? .white : .black)
            )
            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}
