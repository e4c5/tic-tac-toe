import Combine
import Foundation

enum Player: String, CaseIterable {
    case x = "X"
    case o = "O"

    var opponent: Player { self == .x ? .o : .x }
}

enum GameOutcome: Equatable {
    case win(Player, line: [Int])
    case draw
}

enum GameMode: String, CaseIterable, Identifiable {
    case twoPlayer = "2 Players"
    case vsComputer = "vs Computer"

    var id: String { rawValue }
}

struct Board: Equatable {
    static let winningLines: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6],
    ]

    private(set) var cells: [Player?] = Array(repeating: nil, count: 9)

    subscript(index: Int) -> Player? { cells[index] }

    var emptyIndices: [Int] { cells.indices.filter { cells[$0] == nil } }

    var outcome: GameOutcome? {
        for line in Self.winningLines {
            if let p = cells[line[0]], cells[line[1]] == p, cells[line[2]] == p {
                return .win(p, line: line)
            }
        }
        return emptyIndices.isEmpty ? .draw : nil
    }

    mutating func place(_ player: Player, at index: Int) -> Bool {
        guard cells.indices.contains(index), cells[index] == nil else { return false }
        cells[index] = player
        return true
    }
}

enum AI {
    /// Returns the optimal move for `player` using minimax, or nil if the game is over.
    static func bestMove(on board: Board, for player: Player) -> Int? {
        guard board.outcome == nil else { return nil }
        var best: (index: Int, score: Int)?
        for index in board.emptyIndices {
            var next = board
            _ = next.place(player, at: index)
            let score = -negamax(next, toMove: player.opponent, depth: 1)
            if best == nil || score > best!.score {
                best = (index, score)
            }
        }
        return best?.index
    }

    private static func negamax(_ board: Board, toMove player: Player, depth: Int) -> Int {
        switch board.outcome {
        case .win(let winner, _):
            return winner == player ? 10 - depth : depth - 10
        case .draw:
            return 0
        case nil:
            var best = Int.min
            for index in board.emptyIndices {
                var next = board
                _ = next.place(player, at: index)
                best = max(best, -negamax(next, toMove: player.opponent, depth: depth + 1))
            }
            return best
        }
    }
}

@MainActor
final class GameModel: ObservableObject {
    @Published private(set) var board = Board()
    @Published private(set) var currentPlayer: Player = .x
    @Published private(set) var scores: [Player: Int] = [.x: 0, .o: 0]
    @Published private(set) var draws = 0
    @Published var mode: GameMode = .twoPlayer {
        didSet { newGame() }
    }

    let computerPlayer: Player = .o

    var outcome: GameOutcome? { board.outcome }

    var isComputerTurn: Bool {
        mode == .vsComputer && currentPlayer == computerPlayer && outcome == nil
    }

    var statusText: String {
        switch outcome {
        case .win(let p, _): return "\(p.rawValue) wins!"
        case .draw: return "It's a draw."
        case nil: return isComputerTurn ? "Computer is thinking…" : "\(currentPlayer.rawValue)'s turn"
        }
    }

    func isWinningCell(_ index: Int) -> Bool {
        if case .win(_, let line) = outcome { return line.contains(index) }
        return false
    }

    func play(at index: Int) {
        guard !isComputerTurn else { return }
        makeMove(at: index)
        if isComputerTurn {
            let work = DispatchWorkItem { [weak self] in
                self?.playComputerMove()
            }
            pendingComputerMove = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
        }
    }

    private var pendingComputerMove: DispatchWorkItem?

    func playComputerMove() {
        guard isComputerTurn, let index = AI.bestMove(on: board, for: computerPlayer) else { return }
        makeMove(at: index)
    }

    func newGame() {
        pendingComputerMove?.cancel()
        pendingComputerMove = nil
        board = Board()
        currentPlayer = .x
    }

    func resetScores() {
        scores = [.x: 0, .o: 0]
        draws = 0
        newGame()
    }

    private func makeMove(at index: Int) {
        guard outcome == nil, board.place(currentPlayer, at: index) else { return }
        switch outcome {
        case .win(let p, _): scores[p, default: 0] += 1
        case .draw: draws += 1
        case nil: currentPlayer = currentPlayer.opponent
        }
    }
}
