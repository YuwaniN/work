import SwiftUI

@main
struct PlayHubApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeTab()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                StatsTab()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }

                MapTab()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }

                SettingsTab()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
    }
}
