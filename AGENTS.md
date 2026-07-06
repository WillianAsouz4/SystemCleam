# Repository Guidelines

## Project Structure & Module Organization
This is a new macOS SwiftUI app managed through Xcode. The main source file is `Untitled Project/MyApp/ContentView.swift`, which currently contains the app entry point, menu bar UI, views, and simple models. Built output appears under `Untitled Project/Products/MyApp.app`; do not edit built products manually.

As the app grows, keep source files under `Untitled Project/MyApp/` and split large files by responsibility, for example `CleanupScanner.swift`, `StorageStatus.swift`, or `CleanupItemRow.swift`. No test or asset directories are currently present.

## Build, Test, and Development Commands
Use Xcode as the source of truth for building and running.

- Build: Xcode Product > Build.
- Run: Xcode Product > Run to launch the menu bar app.
- Stop: Xcode Product > Stop to quit the current run.

When available, use the Xcode build tool to validate changes instead of compiling individual Swift files manually.

## Coding Style & Naming Conventions
Use Swift with 4-space indentation. Name types with `PascalCase`, such as `ContentView` or `StorageStatus`. Name properties and methods with `camelCase`, such as `storageStatus` or `refreshStorageStatus()`.

Prefer SwiftUI patterns: small `View` structs, `@State private var` for local UI state, `let` for constants, and private helper methods for view actions. Avoid force unwrapping. Keep imports limited to frameworks used by the file.

## Testing Guidelines
No test target exists yet. For future logic, use the Swift Testing framework for unit tests and XCUIAutomation for UI flows. Name tests by behavior, for example `scansUserCacheDirectories()` or `movesSelectedItemsToTrash()`.

For now, validate every change by building in Xcode and manually checking that the menu bar app opens and responds correctly.

## Commit & Pull Request Guidelines
This project has no established Git history yet. Use short, imperative commit messages, for example `Add cleanup scanner` or `Update menu bar UI`.

Pull requests should include a clear summary, testing performed, screenshots for UI changes, and notes about any macOS permissions or file-system behavior.
