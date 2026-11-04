import SwiftUI

@main
struct TicTacToeApp: App {
    @StateObject private var game = GameModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Game") { game.newGame() }
                    .keyboardShortcut("n")
                Button("Reset Scores") { game.resetScores() }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }
}
