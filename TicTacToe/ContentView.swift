import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var game: GameModel

    var body: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $game.mode) {
                ForEach(GameMode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Text(game.statusText)
                .font(.title2.weight(.semibold))
                .accessibilityIdentifier("status")

            BoardView()

            HStack(spacing: 24) {
                ScoreLabel(title: "X", value: game.scores[.x] ?? 0)
                ScoreLabel(title: "Draws", value: game.draws)
                ScoreLabel(title: game.mode == .vsComputer ? "O (CPU)" : "O", value: game.scores[.o] ?? 0)
            }

            HStack {
                Button("New Game") { game.newGame() }
                    .keyboardShortcut(.defaultAction)
                Button("Reset Scores") { game.resetScores() }
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}

private struct BoardView: View {
    @EnvironmentObject private var game: GameModel

    var body: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(0..<3) { row in
                GridRow {
                    ForEach(0..<3) { col in
                        CellView(index: row * 3 + col)
                    }
                }
            }
        }
    }
}

private struct CellView: View {
    @EnvironmentObject private var game: GameModel
    let index: Int

    var body: some View {
        let player = game.board[index]
        Button {
            game.play(at: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(game.isWinningCell(index) ? Color.green.opacity(0.35) : Color.secondary.opacity(0.15))
                Text(player?.rawValue ?? "")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(player == .x ? Color.blue : Color.orange)
            }
            .frame(width: 96, height: 96)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cell \(index + 1), \(player?.rawValue ?? "empty")")
    }
}

private struct ScoreLabel: View {
    let title: String
    let value: Int

    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3.monospacedDigit())
        }
    }
}

#Preview {
    ContentView().environmentObject(GameModel())
}
