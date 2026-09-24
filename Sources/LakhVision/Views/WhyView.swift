import SwiftUI

struct WhyView: View {
    @EnvironmentObject var store: GoalStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Why This Goal Exists")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text(store.data.whyText)
                        .font(.title3)
                        .lineSpacing(6)

                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Wife set this goal", systemImage: "person.2.fill")
                        Label("No job for the last 4 years", systemImage: "briefcase")
                        Label("No income from self-earning", systemImage: "indianrupeesign.circle")
                        Label("Living in \(store.data.city)", systemImage: "mappin.and.ellipse")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.35), lineWidth: 1.5)
                        )
                )

                let math = store.math
                VStack(alignment: .leading, spacing: 8) {
                    Text("What winning looks like")
                        .font(.headline)
                    Text("Reach \(INR.format(store.data.target)) in 2 years — prove the goal-setter right, end the 4-year job gap with real self-earning, and unlock car / house / gold / farmland / tractor / auto options.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    HStack {
                        chip("\(math.daysRemaining) days left")
                        chip("\(math.percent)% done")
                        chip("Daily need \(INR.format(math.requiredDaily))")
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(NSColor.controlBackgroundColor)))

                Text("Edit this text in Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    private func chip(_ s: String) -> some View {
        Text(s)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.green.opacity(0.15)))
            .foregroundColor(.green)
    }
}
