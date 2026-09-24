import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: GoalStore
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            ProgressWaysView()
                .tabItem { Label("Goal Ways", systemImage: "chart.bar.fill") }
                .tag(0)

            HistoryView()
                .tabItem { Label("History", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(1)

            NotesView()
                .tabItem { Label("Notes", systemImage: "banknote.fill") }
                .tag(2)

            ThingsView()
                .tabItem { Label("Things", systemImage: "cart.fill") }
                .tag(3)

            WhyView()
                .tabItem { Label("Why", systemImage: "heart.fill") }
                .tag(4)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(5)
        }
        .padding(8)
        .onAppear {
            store.recordVisit()
        }
    }
}
