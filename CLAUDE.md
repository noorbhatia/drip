# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build from command line
xcodebuild -project drip.xcodeproj -scheme drip -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build and run tests (when tests are added)
xcodebuild -project drip.xcodeproj -scheme drip -destination 'platform=iOS Simulator,name=iPhone 16' test

# Clean build
xcodebuild -project drip.xcodeproj -scheme drip clean
```

Alternatively, open `drip.xcodeproj` in Xcode and use Cmd+B to build, Cmd+R to run.

## Architecture

This is an iOS SwiftUI wardrobe/outfit management app targeting iOS 26.2+ (iPhone and iPad).

### Project Structure

```
drip/
├── dripApp.swift          # Entry point, SwiftData ModelContainer setup
├── Extensions/
│   ├── Color+Extensions.swift   # Color luminance, contrast, hex helpers
│   ├── Date+Extensions.swift    # Date formatting and calendar helpers
│   ├── Month+Extensions.swift   # Month display utilities
│   └── UIImage+Extensions.swift # Dominant color extraction, resizing
├── Models/                # SwiftData models and enums
│   ├── CalendarData.swift # Calendar outfit planning data
│   ├── ClothingItem.swift # @Model with image storage, category, color, tags
│   ├── Outfit.swift       # @Model with ClothingItem relationships, logs
│   ├── OutfitLog.swift    # @Model for planned/worn events (calendar integration)
│   ├── Category.swift     # ClothingCategory enum (tops, bottoms, etc.)
│   ├── ScrollInfo.swift   # Scroll state tracking
│   ├── WardrobeColor.swift
│   └── Occasion.swift     # Occasion enum (casual, work, formal, etc.)
├── Views/
│   ├── MainTabView.swift  # Tab navigation (Home, Closet) + FAB
│   ├── Home/
│   │   ├── HomeView.swift             # Main home tab with sections
│   │   ├── OutfitSuggestionCard.swift # Hero card with gradient overlay
│   │   └── RecentOutfitsSection.swift # Recent outfits + OutfitCard component
│   ├── Calendar/          # Outfit calendar planning
│   │   ├── CalendarView.swift         # Monthly calendar grid
│   │   ├── CalendarDayCell.swift      # Individual day cell
│   │   ├── DayDetailView.swift        # Day detail/outfit assignment
│   │   └── OutfitPickerSheet.swift    # Outfit selection for calendar
│   ├── Closet/            # ClosetView, grid, filters, add/detail views
│   ├── OutfitBuilder/
│   │   ├── OutfitBuilderView.swift    # Outfit creation flow
│   │   ├── OutfitEditorView.swift     # Outfit editor wrapper
│   │   ├── EditorView.swift           # Canvas-based editor
│   │   ├── EditorData.swift           # Editor state model
│   │   ├── ClothingPickerView.swift
│   │   ├── BackgroundColorPicker.swift
│   │   └── SaveOutfitView.swift
│   └── Components/        # Reusable: GlassCard, CategoryPill, FAB, EmptyState
├── Services/
│   ├── WardrobeService.swift          # SwiftData CRUD, queries, @Observable
│   ├── OutfitSuggestionService.swift  # Outfit suggestion logic
│   └── ClothingImportActor.swift      # @ModelActor for background bulk import
└── Utilities/
    ├── Constants.swift        # Layout, animation, canvas, and string constants
    ├── PreviewData.swift      # In-memory ModelContainer for previews
    ├── BackgroundRemover.swift # Vision framework background removal
    ├── CameraView.swift       # Camera integration
    └── RippleEffect.swift     # Disabled (shader removed, code commented out)
```

### Key Patterns

- **SwiftData**: Models use `@Model` macro. Enums stored as raw strings (`categoryRawValue`) with computed property wrappers. Images use `@Attribute(.externalStorage)`.
- **Services**: `@Observable` classes injected via environment. `WardrobeService` wraps `ModelContext` for data operations.
- **@ModelActor**: `ClothingImportActor` uses `@ModelActor` for background-thread SwiftData operations (bulk clothing import).
- **Vision Framework**: `BackgroundRemover` uses `VNGenerateForegroundInstanceMaskRequest` for clothing image background removal.
- **Extensions**: `UIImage+Extensions` for dominant color extraction; `Color+Extensions` for luminance, contrast ratio, and hex helpers.
- **Previews**: Use `PreviewData.previewContainer` for in-memory SwiftData in `#Preview` blocks.
- **Concurrency**: Swift 5.0 strict concurrency with `@MainActor` default isolation.

### SwiftData Schema

```swift
// Registered in dripApp.swift
Schema([ClothingItem.self, Outfit.self, OutfitLog.self])
```

`ClothingItem` ↔ `Outfit` have a many-to-many relationship via `@Relationship(inverse:)`.
`Outfit` → `OutfitLog` is a one-to-many relationship with cascade delete.

- `Outfit.previewImageData` uses `@Attribute(.externalStorage)` for outfit preview images.
- `OutfitLog` tracks planned and worn events per outfit (supports multiple dates per outfit).
- `Outfit.lastWornDate`, `Outfit.wearCount`, `ClothingItem.wearCount`, `ClothingItem.lastWornDate` are computed from `OutfitLog` entries.

## Symbol Inspection (`monocle` cli)

- Treat the `monocle` cli as your **default tool** for Swift symbol info.
  Whenever you need the definition file, signature, parameters, or doc comment for any Swift symbol (type, class, struct, enum, method, property, etc.), call `monocle` rather than guessing or doing project-wide searches.
- List checked-out SwiftPM dependencies (so you can open and read external packages): `monocle packages --json`
- Resolve the symbol at a specific location: `monocle inspect --file <path> --line <line> --column <column> --json`
- Line and column values are **1-based**, not 0-based; the column must point inside the identifier
- Search workspace symbols by name when you only know the identifier: `monocle symbol --query "TypeOrMember" --limit 5 --json`.
  - `--limit` caps the number of results (default 5).
  - `--enrich` fetches signature, documentation, and the precise definition location for each match.
  - `--exact` returns only exact symbol name matches.
  - `--scope project|package|all` limits results by source.
  - `--prefer project|package|none` biases ranking.
  - `--context-lines N` includes N lines of context around the definition (default 2).
- Use `monocle` especially for symbols involved in errors/warnings or coming from external package dependencies.

## Environment

- Xcode 26+ (iOS 26.2 SDK)
- `monocle` CLI must be running (used for symbol inspection — see below)
- No SPM dependencies — pure Apple frameworks
