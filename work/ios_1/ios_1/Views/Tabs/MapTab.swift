import SwiftUI
import MapKit

struct MapTab: View {
    @StateObject private var viewModel = StatsVM()
    @State private var selectedSession: GameSession?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Game Locations",
                        systemImage: "map",
                        description: Text("Play a game to see it on the map.")
                    )
                } else {
                    Map(position: $cameraPosition) {
                        ForEach(viewModel.sessions) { session in
                            let coord = session.coordinate
                            Annotation(session.mode.displayName, coordinate: coord) {
                                Button {
                                    selectedSession = session
                                } label: {
                                    Image(systemName: session.mode.symbolName)
                                        .padding(6)
                                        .background(session.mode.accentColor)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Map")
            .onAppear {
                viewModel.load()
            }
            .sheet(item: $selectedSession) { session in
                sessionDetail(session)
                    .presentationDetents([.height(220)])
            }
        }
    }

    private func sessionDetail(_ session: GameSession) -> some View {
        VStack(spacing: 12) {
            Label(session.mode.displayName, systemImage: session.mode.symbolName)
                .font(.title2)
                .foregroundStyle(session.mode.accentColor)

            Text("Score: \(session.score)")
                .font(.title)
                .fontWeight(.bold)

            Text(session.timestamp, style: .date)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    MapTab()
}
