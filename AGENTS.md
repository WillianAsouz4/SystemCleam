# Repository Guidelines

## Project Structure & Module Organization
This is a macOS SwiftUI menu bar app managed through Xcode. Source lives under `SystemCleam/`, split by responsibility: `MyApp.swift` (entry point), `ContentView.swift` (main layout), `Models/` (`CleanupModels.swift`, `StorageStatus.swift`), `Services/` (`CleanupScanner.swift`), and `Views/` (`AppColors.swift`, `CleanupCategorySection.swift`, `CleanupItemRow.swift`, `SegmentedProgressBar.swift`, `StorageStatusPanel.swift`). Do not edit built products manually.

As the app grows, keep new source files under `SystemCleam/` in the folder matching their responsibility. No test or asset directories are currently present.

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
Use short, imperative commit messages, for example `Add cleanup scanner` or `Update menu bar UI`.

Pull requests should include a clear summary, testing performed, screenshots for UI changes, and notes about any macOS permissions or file-system behavior.
