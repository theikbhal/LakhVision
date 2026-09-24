import SwiftUI

struct ProgressWaysView: View {
    @EnvironmentObject var store: GoalStore
    @State private var editAmount: String = ""

    var body: some View {
        let math = store.math

        ScrollView {
            VStack(spacing: 16) {
                hero(math: math)
                forecast(math: math)
                quickEdit
                waysGrid(math: math)
                extraWays(math: math)
                ladder(math: math)
                paceCard(math: math)
            }
            .padding()
        }
        .onAppear { editAmount = String(Int(store.data.saved)) }
    }

    private func hero(math: MoneyMath) -> some View {
        VStack(spacing: 8) {
            Text("GOAL TARGET")
                .font(.caption)
                .foregroundColor(.secondary)
                .tracking(3)
            Text(INR.format(store.data.target))
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundColor(.green)
            Text("in 2 years · \(math.daysRemaining) days left · streak \(store.data.streak)d")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                statBox(title: "Saved", value: INR.format(store.data.saved), color: .blue)
                statBox(title: "Progress", value: "\(math.percent)%", color: .purple)
                statBox(title: "Remaining", value: INR.format(math.remaining), color: .orange)
                statBox(title: "Daily need", value: INR.format(math.requiredDaily), color: .red)
                statBox(title: "Weekly need", value: INR.format(math.requiredWeekly), color: .teal)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule()
                        .fill(
                            LinearGradient(colors: [.mint, .green],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * math.progress)
                        .animation(.spring(duration: 0.5), value: math.progress)
                }
            }
            .frame(height: 18)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.5), lineWidth: 2)
                )
        )
    }

    private func forecast(math: MoneyMath) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Forecast", systemImage: "calendar.badge.clock")
                    .font(.headline)
                if let finish = math.projectedFinish {
                    Text("At current pace you finish " + finish.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                    Text(math.isOnTrackToFinish
                         ? "On track to beat the deadline."
                         : "Behind — need \(INR.format(math.requiredDaily))/day to finish on time.")
                        .font(.caption)
                        .foregroundColor(math.isOnTrackToFinish ? .green : .red)
                } else {
                    Text("Add savings to generate a forecast.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Best streak").font(.caption2).foregroundColor(.secondary)
                Text("\(store.data.bestStreak)d").font(.title.bold()).foregroundColor(.orange)
                Text("Visit daily to grow it").font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.callout.bold()).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.1)))
    }

    private var quickEdit: some View {
        HStack(spacing: 8) {
            TextField("Saved amount (₹)", text: $editAmount)
                .textFieldStyle(.roundedBorder)
                .frame(width: 170)
                .onSubmit { applyEdit() }

            Button("Set") { applyEdit() }
            Button("+₹1,000") { bump(1000) }
            Button("+₹5,000") { bump(5000) }
            Button("+₹10,000") { bump(10000) }
            Button("+₹50,000") { bump(50000) }
            Button("Reset") {
                store.setSaved(0)
                editAmount = "0"
            }
            Spacer()
        }
    }

    private func bump(_ n: Double) {
        store.addSaved(n)
        editAmount = String(Int(store.data.saved))
    }

    private func applyEdit() {
        let cleaned = editAmount.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "₹", with: "")
        if let v = Double(cleaned) {
            store.setSaved(v)
        }
        editAmount = String(Int(store.data.saved))
    }

    private func waysGrid(math: MoneyMath) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            RingWay(math: math)
            ThermometerWay(math: math)
            BarWay(math: math)
            SplitDaysWay(math: math)
        }
    }

    private func extraWays(math: MoneyMath) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            BlocksWay(math: math)
            GullakWay(math: math)
            BricksWay(math: math)
        }
    }

    private func ladder(math: MoneyMath) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Pass Marks", systemImage: "flag.checkered")
                .font(.headline)
            ForEach(math.milestones, id: \.pct) { m in
                HStack {
                    Text(m.label)
                        .font(.subheadline.bold())
                        .frame(width: 80, alignment: .leading)
                    Text(INR.format(m.amount))
                        .font(.subheadline)
                        .frame(width: 100, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.2))
                            Capsule()
                                .fill(store.data.saved >= m.amount ? Color.green : Color.yellow)
                                .frame(width: geo.size.width * min(store.data.saved / max(m.amount, 1), 1))
                                .animation(.spring(duration: 0.4), value: store.data.saved)
                        }
                    }
                    .frame(height: 14)
                    Text(store.data.saved >= m.amount ? "PASS" : "\(min(Int(store.data.saved / max(m.amount, 1) * 100), 999))%")
                        .font(.caption.bold())
                        .foregroundColor(store.data.saved >= m.amount ? .green : .orange)
                        .frame(width: 48, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }

    private func paceCard(math: MoneyMath) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Pace vs Time", systemImage: "speedometer")
                .font(.headline)
            HStack {
                statBox(title: "Elapsed time", value: "\(math.daysElapsed)/\(math.daysTotal)d", color: .blue)
                statBox(title: "Should have saved", value: INR.format(math.requiredForPace), color: .gray)
                statBox(title: "Actual saved", value: INR.format(math.saved), color: .green)
                statBox(
                    title: math.isAhead ? "Ahead" : "Behind",
                    value: INR.format(abs(math.paceDelta)),
                    color: math.isAhead ? .green : .red
                )
            }
            Text(math.isAhead
                 ? "You are ahead of the 2-year pace. Keep the streak."
                 : "Behind pace · month need \(INR.format(math.requiredMonthly)) · week need \(INR.format(math.requiredWeekly))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct RingWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(spacing: 8) {
            Text("Way 1 · Ring").font(.caption).foregroundColor(.secondary)
            ZStack {
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: math.progress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: math.progress)
                VStack {
                    Text("\(math.percent)%").font(.title.bold())
                    Text("of goal").font(.caption2).foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            Text(INR.format(math.saved)).font(.caption.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct ThermometerWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(spacing: 8) {
            Text("Way 2 · Thermometer").font(.caption).foregroundColor(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange, .yellow, .green],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: geo.size.height * math.progress)
                        .animation(.spring(duration: 0.5), value: math.progress)
                }
            }
            .frame(width: 70, height: 130)
            Text("\(math.percent)% heat").font(.caption.bold())
            Text("Target " + INR.compact(math.target)).font(.caption2).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct BarWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Way 3 · Money Bar").font(.caption).foregroundColor(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: geo.size.width * math.progress)
                        .animation(.spring(duration: 0.5), value: math.progress)
                }
            }
            .frame(height: 22)
            HStack {
                Text(INR.format(math.saved)).font(.caption.bold())
                Spacer()
                Text(INR.format(math.target)).font(.caption).foregroundColor(.secondary)
            }
            Text("Need \(INR.format(math.remaining)) more").font(.caption).foregroundColor(.orange)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct SplitDaysWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Way 4 · Days Split").font(.caption).foregroundColor(.secondary)
            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.teal)
                        .frame(width: max(geo.size.width * (Double(math.daysElapsed) / Double(math.daysTotal)) - 1, 0))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(height: 20)
            HStack {
                Text("\(math.daysElapsed) days used").font(.caption)
                Spacer()
                Text("\(math.daysRemaining) left").font(.caption).foregroundColor(.secondary)
            }
            Text("Deadline " + math.end.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct BlocksWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(spacing: 8) {
            Text("Way 5 · 100 Blocks").font(.caption).foregroundColor(.secondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 10), spacing: 3) {
                ForEach(0..<100, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < math.percent ? Color.green : Color.gray.opacity(0.25))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            Text("1 block = 1% = \(INR.format(math.target / 100))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct GullakWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(spacing: 8) {
            Text("Way 6 · Gullak").font(.caption).foregroundColor(.secondary)
            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(Color.brown.opacity(0.25))
                    .frame(width: 110, height: 100)
                Ellipse()
                    .fill(
                        LinearGradient(colors: [.orange, .brown],
                                       startPoint: .bottom, endPoint: .top)
                    )
                    .frame(width: 100, height: 90 * math.progress)
                    .animation(.spring(duration: 0.6), value: math.progress)
                Capsule()
                    .fill(Color.black.opacity(0.55))
                    .frame(width: 36, height: 6)
                    .offset(y: -46)
            }
            .frame(height: 110)
            .clipped()
            Text("\(math.percent)% full").font(.caption.bold())
            Text(INR.format(math.saved)).font(.caption2).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}

struct BricksWay: View {
    let math: MoneyMath

    var body: some View {
        VStack(spacing: 8) {
            Text("Way 7 · Cash Bricks").font(.caption).foregroundColor(.secondary)
            let totalBricks = 20
            let filled = min(Int(math.progress * Double(totalBricks)), totalBricks)
            VStack(spacing: 3) {
                ForEach((0..<totalBricks).reversed(), id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < filled ? Color.green.opacity(0.85) : Color.gray.opacity(0.25))
                        .frame(height: 8)
                        .overlay(alignment: .trailing) {
                            if i == 19 || i == 14 || i == 9 || i == 4 {
                                Text(INR.format(Double(i + 1) * math.target / 20))
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundColor(i < filled ? .white : .secondary)
                                    .padding(.trailing, 2)
                            }
                        }
                }
            }
            Text("1 brick = \(INR.format(math.target / 20))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
    }
}
