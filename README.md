# Tic-Tac-Toe

A simple native macOS tic-tac-toe game written in SwiftUI.

- 2-player local mode, or play against an unbeatable computer (minimax)
- Score tally for X, O and draws
- `⌘N` new game, `⇧⌘R` reset scores

## Requirements

- macOS 14+
- Xcode 16+

## Build & run

Open `TicTacToe.xcodeproj` in Xcode and press `⌘R`, or from the command line:

```sh
xcodebuild -project TicTacToe.xcodeproj -scheme TicTacToe -derivedDataPath build build
open build/Build/Products/Debug/TicTacToe.app
```

## Tests

```sh
xcodebuild -project TicTacToe.xcodeproj -scheme TicTacToe -destination 'platform=macOS' test
```

## Project file

`TicTacToe.xcodeproj` is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). After adding or removing files, regenerate it:

```sh
xcodegen generate
```
