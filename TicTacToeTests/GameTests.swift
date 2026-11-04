import XCTest
@testable import TicTacToe

final class BoardTests: XCTestCase {
    private func board(_ moves: [(Player, Int)]) -> Board {
        var b = Board()
        for (p, i) in moves { XCTAssertTrue(b.place(p, at: i)) }
        return b
    }

    func testRowWin() {
        let b = board([(.x, 0), (.o, 3), (.x, 1), (.o, 4), (.x, 2)])
        XCTAssertEqual(b.outcome, .win(.x, line: [0, 1, 2]))
    }

    func testDiagonalWin() {
        let b = board([(.o, 2), (.x, 0), (.o, 4), (.x, 1), (.o, 6)])
        XCTAssertEqual(b.outcome, .win(.o, line: [2, 4, 6]))
    }

    func testDraw() {
        // X O X / X O O / O X X
        let b = board([(.x, 0), (.o, 1), (.x, 2), (.o, 4), (.x, 3), (.o, 5), (.x, 7), (.o, 6), (.x, 8)])
        XCTAssertEqual(b.outcome, .draw)
    }

    func testCannotPlaceOnOccupiedCell() {
        var b = Board()
        XCTAssertTrue(b.place(.x, at: 4))
        XCTAssertFalse(b.place(.o, at: 4))
        XCTAssertFalse(b.place(.o, at: 9))
    }
}

final class AITests: XCTestCase {
    func testTakesWinningMove() {
        var b = Board()
        [(Player.o, 0), (.x, 3), (.o, 1), (.x, 4)].forEach { _ = b.place($0.0, at: $0.1) }
        XCTAssertEqual(AI.bestMove(on: b, for: .o), 2)
    }

    func testBlocksOpponent() {
        var b = Board()
        [(Player.x, 0), (.o, 4), (.x, 1)].forEach { _ = b.place($0.0, at: $0.1) }
        XCTAssertEqual(AI.bestMove(on: b, for: .o), 2)
    }

    func testPerfectPlayAlwaysDraws() {
        var b = Board()
        var player = Player.x
        while b.outcome == nil {
            let move = AI.bestMove(on: b, for: player)!
            _ = b.place(player, at: move)
            player = player.opponent
        }
        XCTAssertEqual(b.outcome, .draw)
    }
}

@MainActor
final class GameModelTests: XCTestCase {
    func testScoreUpdatesOnWin() {
        let game = GameModel()
        [0, 3, 1, 4, 2].forEach(game.play(at:))
        XCTAssertEqual(game.outcome, .win(.x, line: [0, 1, 2]))
        XCTAssertEqual(game.scores[.x], 1)
        game.play(at: 5)
        XCTAssertNil(game.board[5], "No moves after game over")
        game.newGame()
        XCTAssertNil(game.outcome)
        XCTAssertEqual(game.scores[.x], 1)
    }

    func testComputerRespondsInVsComputerMode() {
        let game = GameModel()
        game.mode = .vsComputer
        game.play(at: 0)
        XCTAssertTrue(game.isComputerTurn)
        game.playComputerMove()
        XCTAssertEqual(game.currentPlayer, .x)
        XCTAssertEqual(game.board.emptyIndices.count, 7)
    }
}
