import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushVM()
    @AppStorage("quizRushHighScore") private var highScore = 0
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading questions…")
                    .font(.title3)

            case .failed:
                errorView

            case .loaded:
                if viewModel.isFinished {
                    resultsView
                } else {
                    quizContent
                }
            }
        }
        .padding()
        .navigationTitle("Quiz Rush")
        .animation(.easeInOut, value: viewModel.isFinished)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Loading / Error

    private var errorView: some View {
        VStack(spacing: 15) {
            Text("Couldn't load questions")
                .font(.title2)
                .foregroundColor(.red)

            Text("Check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Retry") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Quiz in progress

    private var quizContent: some View {
        VStack(spacing: 25) {
            HStack {
                Text("\(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.headline)
                Spacer()
                Text("Streak: \(viewModel.streak)")
                    .font(.headline)
            }

            Text("Score: \(viewModel.score)")
                .font(.title)

            if let question = viewModel.currentQuestion {
                Text(question.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(flashColor)
                    .cornerRadius(16)
                    .offset(x: shakeOffset)

                VStack(spacing: 12) {
                    ForEach(question.answers, id: \.self) { answer in
                        Button {
                            answerTapped(answer)
                        } label: {
                            Text(answer)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(spacing: 15) {
            Text("Quiz Complete!")
                .font(.largeTitle)
                .foregroundColor(.green)

            Text("Final Score: \(viewModel.score)")
                .font(.title2)
                .fontWeight(.bold)

            Text("High Score: \(highScore)")
                .font(.title3)

            ShareLink(item: "I just scored \(viewModel.score) on Quiz Rush — beat that! ❓") {
                Label("Share Score", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)

            Button("Play Again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            if viewModel.score > highScore {
                highScore = viewModel.score
            }
        }
    }

    // MARK: - Polish

    private var flashColor: Color {
        switch viewModel.lastAnswerWasCorrect {
        case .some(true): return Color.green.opacity(0.3)
        case .some(false): return Color.red.opacity(0.3)
        case .none: return Color.gray.opacity(0.1)
        }
    }

    private func answerTapped(_ answer: String) {
        viewModel.submitAnswer(answer)

        guard viewModel.lastAnswerWasCorrect == false else { return }

        withAnimation(.easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            shakeOffset = 0
        }
    }
}

#Preview {
    NavigationStack { QuizRushView() }
}
