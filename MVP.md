# Drip — MVP Progress Tracker

This document tracks what's built, what's next, and maps features to the user stories and research priorities from [RESEARCH.md](RESEARCH.md).

*Last updated: March 15, 2026*

---

## Current State (What's Built)

### Models
- [x] `ClothingItem` — name, image, category, color, brand, notes, tags, isFavorite, price, wearCount, lastWornDate
- [x] `Outfit` — name, occasion, notes, isFavorite, wearCount, lastWornDate, previewImageData, plannedDates, wornDates
- [x] `OutfitLog` — date, type (planned/worn), outfit relationship (supports calendar integration)
- [x] `Brand` — @Model with unique name, icon, clothingItems relationship (25 defaults)
- [x] Many-to-many `ClothingItem ↔ Outfit` relationship
- [x] `ClothingCategory` enum (10 types)
- [x] `WardrobeColor` @Model class (17 colors, seeded at launch)
- [x] `Occasion` @Model class (9 types, seeded at launch)

### Core CRUD
- [x] Add clothing item (camera or photo picker)
- [x] Background removal on import
- [x] Bulk import with auto background removal
- [x] Delete clothing item (with confirmation)
- [x] Favorite/unfavorite items and outfits
- [x] Search items by name, brand, tags
- [x] Filter by category (pill UI)
- [x] Edit existing clothing item (inline editing in ClothingDetailView: color, category, brand, price, rename)

### Outfit Builder (3-step flow)
- [x] Step 1: Select items (grid with multi-select, category filter, search)
- [x] Step 2: Canvas arrangement (PaperKit — drag, resize, rotate, draw, background color)
- [x] Step 3: Save (name, occasion, notes, canvas export as preview image)

### Home Screen (8 sections)
- [x] Today's Pick hero card (least recently worn outfit)
- [x] Outfit groups by occasion (top 4 occasions with counts)
- [x] "Plan Your Week" CTA banner (links to outfit builder)
- [x] Wardrobe Insights (total items, total outfits, worn %)
- [x] Recently Worn (horizontal scroll, "Wore Today" checkmark per outfit)
- [x] Rediscover (unworn items, oldest first)
- [x] Category collections (top 3 categories)
- [x] Recently Added (last 10 items)

### Navigation & Components
- [x] Two tabs: Home, Closet
- [x] GlassCard, CategoryPill, EmptyStateView, ClothingItemCard, ClothingGridView
- [x] Liquid Glass on controls/nav only (HIG iOS 26 compliant)

---

## MVP Roadmap

### P0: Quick Wins — Highest Impact, Lowest Effort

> *These close critical gaps and directly drive daily retention.*

#### 1. Edit Existing Items
**Status:** Complete
**Why:** Core CRUD gap — users can add and delete but can't fix a wrong category or update a brand name.

- [x] Inline editing in ClothingDetailView (color picker, category picker, brand picker, price field)
- [x] Rename item via modal dialog
- [x] Save changes to existing `ClothingItem` in-place

**User Story:**
> *As a user, I want to tap an item and edit its name, category, color, brand, tags, or notes so I can fix mistakes without deleting and re-adding.*

---

#### 2. "Wore Today" Quick Logging
**Status:** Partially built (inline on outfit cards in Recently Worn section)
**Why:** 1-2 tap wear logging is the #1 retention mechanic. A Stylebook power user logged 2,700 outfits — this feature keeps people coming back daily.

- [x] `markAsWorn()` on Outfit model (increments count + updates date on outfit and all items)
- [x] Inline "Wore Today" button on outfit cards in Recently Worn section
- [ ] Standalone "Wore Today" flow — pick outfit from full list, confirm, done
- [ ] "Wore Today" accessible from Home (e.g. prominent button or section)
- [ ] Quick-log an ad-hoc outfit (select items without building a full canvas outfit)

**User Story:**
> *As a user, I want to log what I'm wearing today in 1-2 taps — even if it's not a saved outfit — so I can track my wardrobe usage effortlessly.*

---

#### 3. Wire Smart Hero Card
**Status:** Partially built (shows least recently worn outfit)
**Why:** A daily outfit suggestion drives 3.7x weekly opens (Alta data). Current logic is naive — just picks the least recently worn outfit.

- [x] Hero card UI with gradient overlay, occasion badge, item count
- [ ] Factor in occasion (workday vs. weekend)
- [ ] Factor in recently worn items (avoid repeats within N days)
- [ ] Rotate suggestion if user dismisses or refreshes
- [ ] "Wear This" button that logs the outfit

**User Story:**
> *As a user, I want a smart daily outfit suggestion on my home screen so I spend less time deciding what to wear.*

---

### P1: Core Features — Strongly Validated

> *These are what power users expect. They drive long-term retention and wardrobe utilization.*

#### 4. Wardrobe Analytics Screen
**Status:** Inline stats only (3 numbers in HomeView's "Wardrobe Insights" section)
**Why:** "My favorite part of the app is all the style stats!" — power users stay for analytics. Indyx users are angry analytics are paywalled.

- [x] Basic stats: total items, total outfits, worn %
- [ ] Dedicated analytics tab or screen
- [ ] Most worn items (top 5-10)
- [ ] Least worn / never worn items
- [ ] Outfits per occasion breakdown
- [ ] Category distribution (pie/bar chart)
- [ ] Wear frequency over time (weekly/monthly trend)
- [ ] Wardrobe utilization % with improvement tracking

**User Story:**
> *As a user, I want a stats screen showing my most/least worn items, category breakdown, and usage trends so I can make smarter decisions about my wardrobe.*

---

#### 5. Rediscover Forgotten Items
**Status:** Partially built (Rediscover section in HomeView shows unworn items)
**Why:** Users go from 30% → 69% wardrobe utilization with tracking. Surfacing forgotten items is a core value prop.

- [x] "Rediscover" section showing items with wearCount == 0
- [ ] Include items not worn in 30+ days (not just zero-wear)
- [ ] "Style This" action → open outfit builder with item pre-selected
- [ ] Notification/nudge for forgotten items (future)

**User Story:**
> *As a user, I want the app to remind me about clothes I haven't worn in a while so I can get more value from my whole wardrobe.*

---

#### 6. Outfit Calendar
**Status:** Complete (month view with plan/worn tracking)
**Why:** Every competitor has an outfit calendar. Table-stakes feature.

- [x] "Plan Your Week" CTA in HomeView
- [x] Calendar view showing outfits planned/worn per day (blue/green dot indicators)
- [x] Assign outfits to future dates (OutfitPickerSheet)
- [x] View past outfit history by date (DayDetailView)
- [x] "Mark as Worn" button for planned outfits
- [ ] Week-at-a-glance view

**User Story:**
> *As a user, I want to plan outfits for upcoming days and see what I wore on past days so I don't repeat looks and can plan ahead.*

---

#### 7. Cost-Per-Wear Tracking
**Status:** Partially built (price field exists, no cost-per-wear computation yet)
**Why:** Users find it "oddly satisfying." Reveals hidden value and exposes wardrobe regrets.

- [x] Add `price: Decimal?` field to `ClothingItem`
- [x] Price input on ClothingDetailView (currency formatted)
- [ ] Computed `costPerWear` property: price ÷ wearCount
- [ ] Display cost-per-wear on ClothingDetailView
- [ ] Sort/filter by cost-per-wear in analytics
- [ ] "Best Value" / "Worst Value" insights

**User Story:**
> *As a user, I want to track what I paid for items and see the cost-per-wear so I can understand the real value of my purchases.*

---

### P2: Differentiation — Validated, Higher Effort

> *These separate Drip from competitors. Build after P0-P1 are solid.*

#### 8. Weather Integration
**Status:** Not started
**Why:** Highest-priority Phase 2 feature. Every top-rated app (Alta, Cladwell, Acloset) uses it.

- [ ] Integrate WeatherKit for local forecast
- [ ] Show today's weather on Home screen
- [ ] Factor temperature/conditions into outfit suggestions
- [ ] Tag items by weather suitability (optional)

**User Story:**
> *As a user, I want outfit suggestions that consider today's weather so I dress appropriately without checking a separate weather app.*

---

#### 9. Smart Outfit Suggestions (Rule-Based)
**Status:** Placeholder service exists (OutfitSuggestionService returns static text)
**Why:** Start rule-based, NOT AI. Bad AI destroys trust (Closetly, Cladwell prove this).

- [x] OutfitSuggestionService scaffold
- [ ] Rule: match category balance (top + bottom, or dress)
- [ ] Rule: avoid items worn in last N days
- [ ] Rule: match occasion context
- [ ] Rule: color harmony (complementary/analogous)
- [ ] Fallback: surface least-worn items

**User Story:**
> *As a user, I want the app to suggest complete outfits from my wardrobe that make sense stylistically so I can discover new combinations.*

---

#### 10. Occasion-Based Suggestion Filtering
**Status:** Occasion data exists on Outfit model; suggestion service doesn't use it
**Why:** Users want to ask "what should I wear to work?" vs. "what should I wear on a date?"

- [x] Occasion @Model class (9 types) on Outfit model
- [ ] Filter suggestions by selected occasion
- [ ] Home screen occasion quick-select (e.g. "I'm going to…")
- [ ] Learn occasion patterns from wear history

**User Story:**
> *As a user, I want to pick an occasion and get outfit suggestions tailored to it so I always look right for the context.*

---

### P3: Delight Features

> *Nice-to-haves that add polish. Build when core is rock-solid.*

- [ ] Repair/cleaning flags on items ("needs dry cleaning", "button missing")
- [ ] Duplicate/copy outfit (wear same base, swap accessories)
- [ ] Layering preview in outfit builder canvas
- [ ] Size/fit tracking per item

### P4: Growth Features

> *Post-MVP — drive sharing, community, and monetization.*

- [ ] Share outfit as image (export canvas)
- [ ] Community feed
- [ ] Brand integration / resale value tracking
- [ ] Cloud backup / multi-device sync

---

## Priority Matrix

| # | Feature | Impact | Effort | Priority | Status |
|---|---------|--------|--------|----------|--------|
| 1 | Edit existing items | High | Low | **P0** | **Complete** |
| 2 | "Wore Today" quick logging | High | Low | **P0** | Partial |
| 3 | Wire smart hero card | High | Low | **P0** | Partial |
| 4 | Wardrobe analytics screen | High | Medium | **P1** | Inline only |
| 5 | Rediscover forgotten items | High | Low | **P1** | Partial |
| 6 | Outfit calendar | High | Medium | **P1** | **Complete** |
| 7 | Cost-per-wear tracking | High | Medium | **P1** | Partial |
| 8 | Weather integration | High | Medium | **P2** | Not started |
| 9 | Smart suggestions (rule-based) | High | Medium | **P2** | Placeholder |
| 10 | Occasion filtering | Medium | Low | **P2** | Data exists |

---

## Model Changes Needed

| Field | Model | Priority | Notes |
|-------|-------|----------|-------|
| ~~`price: Decimal?`~~ | ~~ClothingItem~~ | ~~P1~~ | **Done** — added as `price: Decimal?` |
| ~~`OutfitLog` model~~ | ~~New model~~ | ~~P1~~ | **Done** — tracks planned/worn events per outfit |
| `purchaseDate: Date?` | ClothingItem | P1 | Optional, enriches analytics |
| `weatherSuitability: [String]?` | ClothingItem | P2 | Optional weather tags |

---

## Key Metrics (from Research)

| Metric | Target | Driver |
|--------|--------|--------|
| Onboarding completion | >70% finish uploading 10+ items | Fast bg removal, bulk import |
| Weekly active use | 3-4x/week | Daily suggestion, wear logging |
| Wardrobe utilization | 50%+ (vs 20-30% avg) | Rediscover, analytics, nudges |
| 30-day retention | >40% | Calendar, stats, cost-per-wear |
