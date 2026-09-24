import SwiftUI

struct NoteDenomination: Identifiable {
    let id = UUID()
    let value: Int
    let color: Color
}

struct NotesView: View {
    @EnvironmentObject var store: GoalStore

    private let dens: [NoteDenomination] = [
        NoteDenomination(value: 500, color: Color(red: 0.55, green: 0.55, blue: 0.55)),
        NoteDenomination(value: 200, color: Color(red: 0.95, green: 0.70, blue: 0.15)),
        NoteDenomination(value: 100, color: Color(red: 0.72, green: 0.62, blue: 0.82))
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Visualize with Currency Notes")
                    .font(.title2.bold())
                Text("Saved amount and ₹20L goal in ₹500 · ₹200 · ₹100 notes — counts, stacks, bundles, weight.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                weightCard

                ForEach(dens) { d in
                    NoteSection(
                        den: d,
                        savedCount: Int(store.data.saved) / d.value,
                        targetCount: Int(store.data.target) / d.value
                    )
                }

                mixSection
            }
            .padding()
        }
    }

    private var weightCard: some View {
        let notes500 = Int(store.data.saved) / 500
        let goal500 = Int(store.data.target) / 500
        let weightKg = Double(notes500) * 0.001
        let goalKg = Double(goal500) * 0.001

        return HStack(spacing: 12) {
            weightBox(title: "Saved cash weight (₹500 notes)",
                      value: String(format: "%.2f kg", weightKg),
                      sub: "\(notes500) notes · ≈\(notes500)g", color: .blue)
            weightBox(title: "Goal in ₹500 notes",
                      value: String(format: "%.1f kg", goalKg),
                      sub: "\(goal500) notes", color: .green)
            weightBox(title: "1 bundle of 100 × ₹500",
                      value: INR.format(50_000),
                      sub: "≈100g per bundle", color: .orange)
            weightBox(title: "Optimal mix value",
                      value: INR.format(store.data.saved),
                      sub: "same cash, fewest notes", color: .purple)
        }
    }

    private func weightBox(title: String, value: String, sub: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.title3.bold()).foregroundColor(color)
            Text(sub).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.1)))
    }

    private var mixSection: some View {
        let amount = Int(store.data.saved)
        let n500 = amount / 500
        let n200 = (amount % 500) / 200
        let n100 = (amount % 100)
        let t500 = Int(store.data.target) / 500
        let t200 = Int(store.data.target) / 200
        let t100 = Int(store.data.target) / 100

        return VStack(alignment: .leading, spacing: 10) {
            Text("Optimal Mix of Saved Cash")
                .font(.headline)
            HStack(spacing: 12) {
                mixBox(count: n500, value: 500, color: dens[0].color)
                mixBox(count: n200, value: 200, color: dens[1].color)
                mixBox(count: n100, value: 100, color: dens[2].color)
            }
            Text("Goal stacks: \(t500) × ₹500 · \(t200) × ₹200 · \(t100) × ₹100")
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
                .frame(width: 96, height: 44)
            Text("\(count)")
                .font(.title3.bold())
            Text("× ₹\(value)").font(.caption2).foregroundColor(.secondary)
            if value == 500 {
                Text(String(format: "%.1f bundles of 100", Double(count) / 100.0))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
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
                Text("Showing 18 of \(targetCount) goal notes · each tile = 1 note")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if den.value == 500 {
                Text(String(format: "Bundles: %.1f saved / %.0f goal (100 notes = 1 bundle = ₹50,000)",
                            Double(savedCount) / 100.0,
                            Double(targetCount) / 100.0))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if savedCount > 0 {
                let pct = targetCount > 0 ? min(Double(savedCount) / Double(targetCount), 1) : 0
                ProgressView(value: pct)
                    .tint(den.color)
                Text("\(Int(pct * 100))% of the ₹\(den.value)-note stack · value \(INR.format(Double(savedCount) * Double(den.value)))")
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
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                VStack(spacing: 1) {
                    Text("₹\(value)")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                    Text("RESERVE BANK OF INDIA")
                        .font(.system(size: 4.5, weight: .semibold))
                        .opacity(0.75)
                    Text("GUARANTEED BY THE CENTRAL GOVERNMENT")
                        .font(.system(size: 3.5, weight: .medium))
                        .opacity(0.55)
                }
                .foregroundColor(value == 500 ? .white : .black)
                .multilineTextAlignment(.center)
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 10, height: 10)
                    .padding(3)
            }
            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}
