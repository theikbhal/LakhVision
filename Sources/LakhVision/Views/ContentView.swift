import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: GoalStore
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            ProgressWaysView()
                .tabItem { Label("Goal Ways", systemImage: "chart.bar.fill") }
                .tag(0)

            NotesView()
                .tabItem { Label("Notes", systemImage: "banknote.fill") }
                .tag(1)

            ThingsView()
                .tabItem { Label("Things", systemImage: "cart.fill") }
                .tag(2)

            WhyView()
                .tabItem { Label("Why", systemImage: "heart.fill") }
                .tag(3)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
        .padding(8)
    }
}
