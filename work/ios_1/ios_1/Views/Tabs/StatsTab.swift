import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var viewModel = StatsVM()

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Totals
                Section {
                    LabeledContent("Total Games", value: "\(viewModel.totalGamesPlayed)")
                    LabeledContent("Total Score", value: "\(viewModel.sessions.reduce(0) { $0 + $1.score })")
                } header: {
                    Label("Overview", systemImage: "number.circle")
                }

                // MARK: - Personal Bests
                Section {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        HStack {
                            Image(systemName: mode.symbolName)
                                .foregroundStyle(.tint)
                                .frame(width: 24)
                            Text(mode.displayName)
                            Spacer()
                            Text("\(viewModel.personalBest(for: mode))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label("Personal Bests", systemImage: "trophy")
                }

                // MARK: - Bar Chart
                if !viewModel.sessions.isEmpty {
                    Section {
                        Chart(viewModel.sessions) { session in
                            BarMark(
                                x: .value("Game", session.mode.displayName),
                                y: .value("Score", session.score)
                            )
                            .foregroundStyle(by: .value("Mode", session.mode.displayName))
                        }
                        .chartLegend(.hidden)
                        .frame(height: 200)
                    } header: {
                        Label("Score Chart", systemImage: "chart.bar.fill")
                    }
                }

                // MARK: - Recent Games
                if !viewModel.recentSessions.isEmpty {
                    Section {
                        ForEach(viewModel.recentSessions) { session in
                            HStack {
                                Image(systemName: session.mode.symbolName)
                                    .foregroundStyle(.tint)
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text(session.mode.displayName)
                                        .font(.headline)
                                    Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(session.score)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                        }
                    } header: {
                        Label("Recent Games", systemImage: "clock")
                    }
                }
            }
            .navigationTitle("Stats")
        }
        .onAppear {
            viewModel.load()
        }
    }
}

#Preview {
    StatsTab()
}
