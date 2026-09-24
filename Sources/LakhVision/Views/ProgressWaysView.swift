import SwiftUI

struct ProgressWaysView: View {
    @EnvironmentObject var store: GoalStore
    @State private var editAmount: String = ""

    var body: some View {
        let math = store.math

        ScrollView {
            VStack(spacing: 16) {
                hero(math: math)
                quickEdit
                waysGrid(math: math)
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
            Text("in 2 years · \(math.daysRemaining) days left")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                statBox(title: "Saved", value: INR.format(store.data.saved), color: .blue)
                statBox(title: "Progress", value: "\(math.percent)%", color: .purple)
                statBox(title: "Remaining", value: INR.format(math.remaining), color: .orange)
                statBox(title: "Daily need", value: INR.format(math.requiredDaily), color: .red)
            }
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

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.title3.bold()).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.1)))
    }

    private var quickEdit: some View {
        HStack(spacing: 8) {
            TextField("Saved amount (₹)", text: $editAmount)
                .textFieldStyle(.roundedBorder)
                .frame(width: 180)
                .onSubmit { applyEdit() }

            Button("Set") { applyEdit() }
            Button("+₹1,000") { store.addSaved(1000); editAmount = String(Int(store.data.saved)) }
            Button("+₹5,000") { store.addSaved(5000); editAmount = String(Int(store.data.saved)) }
            Button("+₹10,000") { store.addSaved(10000); editAmount = String(Int(store.data.saved)) }
            Button("+₹50,000") { store.addSaved(50000); editAmount = String(Int(store.data.saved)) }
            Button("Reset") {
                store.setSaved(0)
                editAmount = "0"
            }
            Spacer()
        }
    }

    private func applyEdit() {
        let cleaned = editAmount.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "₹", with: "")
        if let v = Double(cleaned) {
            store.setSaved(v)
        }
        editAmount = String(Int(store.data.saved))
        NotificationManager.shared.scheduleAll()
    }

    private func waysGrid(math: MoneyMath) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            RingWay(math: math)
            ThermometerWay(math: math)
            BarWay(math: math)
            SplitDaysWay(math: math)
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
                                .frame(width: geo.size.width * min(store.data.saved / m.amount, 1))
                        }
                    }
                    .frame(height: 14)
                    Text(store.data.saved >= m.amount ? "PASS" : "\(min(Int(store.data.saved / m.amount * 100), 999))%")
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
                 : "You are behind pace. Monthly need: \(INR.format(math.requiredMonthly))")
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
