# ScaleChef - iOS Development Guide

## Executive Summary

**ScaleChef** is a smart recipe scaling and baking calculator app for iOS that goes beyond simple multiplication. It intelligently adjusts leavening agents (baking powder/soda scale sub-linearly), handles fractional eggs with gram conversions, provides area-based pan size scaling, and offers baker's percentage mode — all in an offline-first, one-time-purchase package.

**Target Audience**: Home cooks and bakers in the US who need to scale recipes accurately. 64% of US adults meal prep (IFIC 2025), ~15M active home bakers.

**Key Differentiators**:
1. **Baking-aware scaling** — Leavening agents scale at factor^0.8, not linearly. Yeast at factor^0.7. Spices at factor^0.85.
2. **Smart egg handling** — Rounds to nearest 0.5, shows gram equivalents (1.5 eggs = 75g beaten egg).
3. **Pan size calculator** — Area-based scaling (9" round → 6" round = 0.44x, not 0.67x).
4. **Baker's percentage mode** — Hydration calculation for bread bakers.
5. **URL recipe import** — Extract recipes from web pages using SwiftSoup.
6. **Offline-first** — All computation local, no account required.
7. **One-time purchase** — $3.99, no subscription fatigue.

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Paprika** ($4.99) | Meal planning, pantry tracking, offline access | Simple multiply-only scaling, no baking intelligence, no pan calculator | Smart baking-aware scaling + pan calculator at lower price |
| **Honeydew** (Free/$5.99/mo) | AI scaling, Instacart sync, USDA nutrition | Requires subscription, no offline, no pan calculator, no baker's % | Offline-first + one-time purchase + baker's % mode |
| **Bake-u-lator** (Free+IAP) | Yield calculator, nutrition, iCloud sync, camera scan | No smart leavening adjustment, no baker's %, no URL import | Smart adjustments + URL import + baker's % |
| **Leaven: Baker's %** (Free+IAP) | Baker's percentage, iCloud sync, markdown export | Bread-only focus, no general scaling, no pan calculator, no URL import | General + baking scaling + pan calculator + URL import |
| **My Kitchen Calculator** ($1.99) | Recipe converter, 250+ ingredient unit conversion, fraction output | Simple multiply only, no smart adjustments, no pan calculator | Smart adjustments + pan calculator + URL import |
| **Flavorish** (Free/$4.99/mo) | AI-driven scaling, social media imports, PDF export | Subscription required, no offline, no pan calculator | Offline + one-time purchase + pan calculator |

**Market Gap Confirmed**: No iOS app combines intelligent baking-aware scaling + pan size calculator + baker's percentage + URL recipe import + offline-first + one-time purchase.

## Feature Inventory

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Recipe Paste & Parse | 1. Open app → 2. Tap "Paste Recipe Here" → 3. Paste/type recipe text → 4. Auto-parse ingredients + servings | Recipe text (multiline), servings number | RecipeParser: regex-based ingredient extraction, serving detection, category classification | ParsedRecipe (name, servings, ingredients[], category, instructions[]) | CoreData Recipe entity | All ingredients parsed with qty/unit/name; servings auto-detected; category (baking/cooking) assigned |
| 2 | Smart Scaling | 1. On Scale screen → 2. Change desired servings or tap quick-scale button → 3. See instant scaled results | Original servings (Int), desired servings (Int) or scale factor (Double) | ScalingEngine: type-aware scaling (leavening^0.8, yeast^0.7, spice^0.85, egg rounding, unit promotion) | ScaledIngredient[] with adjustmentType, notes | In-memory (transient until save) | Baking powder at 1.5x not 2x when doubling; eggs rounded to 0.5; tsp→tbsp→cup promotion |
| 3 | Quick Scale Buttons | 1. On Scale screen → 2. Tap ½×/1×/1.5×/2×/3× button → 3. Instant result | Scale factor (0.5, 1.0, 1.5, 2.0, 3.0) | Same ScalingEngine pipeline | Same ScaledIngredient[] | In-memory | Each button applies correct factor; smart adjustments still apply |
| 4 | Smart Adjustments Display | 1. After scaling → 2. Smart adjustment card auto-appears when relevant | ScaledIngredient[] with adjustmentType != .linear | Filter non-linear adjustments, format notes | SmartAdjustmentCard: yellow-highlighted list | None (view-only) | Shows only when adjustments exist; baking powder note says "not 2×"; egg note shows gram equivalent |
| 5 | Pan Size Calculator | 1. On Scale screen → 2. Tap "Pan Size" tab → 3. Select original pan shape+size → 4. Select new pan shape+size → 5. See area ratio → 6. Tap "Apply to Recipe" | PanShape (round/square/rectangle/loaf), dimensions (Double) | PanCalculator: area calculation (πr² for round, l×w for rectangle), ratio = newArea/originalArea | Scale factor (Double), area display (sq in) | None (applied to current scale) | 9" round → 6" round = 0.44x; rectangle 9×13 → 8×8 = 0.55x |
| 6 | Baker's Percentage Mode | 1. On Scale screen → 2. Toggle "Baker's %" → 3. See all ingredients as % of flour weight → 4. Adjust hydration → 5. All recalculate | Flour weight (Double), ingredient weights | Calculate each ingredient as (weight / flourWeight) × 100; hydration = water% + liquid% | Ingredient percentages[], hydration% | None (view-only mode) | Flour always 100%; hydration updates when water changes; all %s recalculate on any change |
| 7 | URL Recipe Import | 1. On Home screen → 2. Tap "Import from URL" → 3. Paste URL → 4. App fetches & parses → 5. Review parsed recipe | URL string | RecipeImportService: URLSession fetch → SwiftSoup HTML parse → extract Recipe Schema JSON → fallback to heuristic parsing | ParsedRecipe | CoreData Recipe entity (on save) | Successfully imports from major recipe sites; falls back to manual paste on failure |
| 8 | Recipe Storage | 1. On Scale screen → 2. Tap "Save" → 3. Recipe saved to local storage | ParsedRecipe + scale settings | StorageService: CoreData save with Recipe/Ingredient entities | Confirmation toast | CoreData Recipe entity | Recipe appears in Home "Recent Recipes"; persists across app launches |
| 9 | Unit Conversion | 1. On any ingredient row → 2. Tap unit → 3. Toggle US/Metric | Ingredient quantity + unit | UnitConverter: lookup conversion factor from UnitDatabase | Converted quantity + new unit | None (in-place conversion) | 1 cup flour → 120g; 350°F → 175°C; 1 tbsp → 3 tsp |
| 10 | Share/Export | 1. On Scale screen → 2. Tap "Share" → 3. Choose format (text/PDF) | ScaledRecipe data | ShareService: format as text or PDF | Share sheet with formatted recipe | None | Text export includes original + scaled; PDF is formatted for printing |
| 11 | Fraction Display | Automatic — all scaled quantities displayed as kitchen-friendly fractions | Double quantity | FractionFormatter: find closest fraction (½, ¼, ¾, ⅓, ⅔, etc.) | Formatted string ("1½ cups", "¾ tsp") | None | 0.5 → "½"; 1.5 → "1½"; 0.333 → "⅓"; 2.25 → "2¼" |
| 12 | Settings | 1. Tap gear icon → 2. View/toggle preferences | User selections | UserDefaults persistence | Settings state | UserDefaults | Default unit system (US/Metric); screen stay-awake toggle; about/version info |
| 13 | Paywall / Premium | 1. User taps premium feature → 2. Paywall sheet appears → 3. One-time purchase $3.99 | StoreKit 2 transaction | StoreKit 2 purchase flow | Premium unlocked state | StoreKit receipt + UserDefaults | Free tier: basic scaling + 10 recipes; Premium: smart adjustments + pan calc + baker's % + URL import + unlimited + export |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Recipe Paste & Parse | Serving detection | Auto-detect "serves 4", "servings: 6", "makes 12", "yields 8" from text | Automatic on paste |
| 1.2 | Recipe Paste & Parse | Category detection | Detect baking vs cooking based on ingredients (flour + leavening = baking) | Automatic on parse |
| 1.3 | Recipe Paste & Parse | Unparsed ingredient highlight | Ingredients that fail to parse shown in yellow, user can edit | Yellow highlight + tap to edit |
| 2.1 | Smart Scaling | Leavening sub-linear | Baking powder/soda scale at factor^0.8 (≤2x) or 1.75^doublings (>2x) | Automatic |
| 2.2 | Smart Scaling | Yeast sub-linear | Yeast scales at factor^0.7 | Automatic |
| 2.3 | Smart Scaling | Egg rounding | Round to nearest 0.5; show gram equivalent for fractions (1.5 eggs = 75g) | Automatic |
| 2.4 | Smart Scaling | Spice sub-linear | Spices scale at factor^0.85 with "season gradually" note | Automatic |
| 2.5 | Smart Scaling | Unit promotion | 3+ tsp → tbsp; 16+ tbsp → cup; 16+ oz → lb | Automatic |
| 2.6 | Smart Scaling | Extreme scaling warning | >4× scaling shows "Consider splitting into batches" | Alert banner |
| 5.1 | Pan Size Calculator | Round pan | Input: diameter → area = π(d/2)² | Picker + number input |
| 5.2 | Pan Size Calculator | Square pan | Input: side length → area = side² | Picker + number input |
| 5.3 | Pan Size Calculator | Rectangle pan | Input: length × width → area = l×w | Picker + two number inputs |
| 5.4 | Pan Size Calculator | Loaf pan | Input: length × width → volume = l×w×3" (standard height) | Picker + two number inputs |
| 7.1 | URL Import | Recipe Schema extraction | Parse JSON-LD Recipe schema from HTML | Automatic on fetch |
| 7.2 | URL Import | Heuristic fallback | If no schema, use SwiftSoup to find ingredient lists by CSS patterns | Automatic fallback |
| 8.1 | Recipe Storage | Recent recipes display | Show last 5 saved recipes as horizontal scroll cards on Home | Horizontal scroll |
| 8.2 | Recipe Storage | Swipe actions | Swipe left on recipe card → delete; swipe right → share | Swipe gesture |
| 8.3 | Recipe Storage | Free tier limit | Free users limited to 10 saved recipes; premium = unlimited | Paywall trigger on 11th save |
| 12.1 | Settings | Screen stay-awake | Toggle to keep screen on during cooking (UIApplication.shared.isIdleTimerDisabled) | Toggle switch |
| 12.2 | Settings | Default unit system | Choose US (cups/tbsp) or Metric (g/ml) as default display | Segmented control |
| 12.3 | Settings | Premium restore | Restore purchases button for reinstall scenarios | Button tap |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Parsed recipe feeds scaling | Recipe Paste & Parse (#1) | Smart Scaling (#2) | ParsedRecipe object | After successful parse |
| Scale factor from pan | Pan Size Calculator (#5) | Smart Scaling (#2) | Double scale factor | After "Apply to Recipe" tap |
| Scaled recipe to storage | Smart Scaling (#2) | Recipe Storage (#8) | ScaledRecipe + original | On "Save" tap |
| Parsed recipe from URL | URL Import (#7) | Recipe Paste & Parse (#1) | ParsedRecipe | After successful URL fetch+parse |
| Premium check on features | Paywall (#13) | Pan Calculator (#5), Baker's % (#6), URL Import (#7), Storage (#8), Share (#10) | isPremium Bool | On feature access attempt |
| Unit conversion in scaling | Unit Conversion (#9) | Smart Scaling (#2) | Converted quantity+unit | On unit tap in ingredient row |
| Fraction display in scaling | Fraction Display (#11) | Smart Scaling (#2) | Formatted string | On every scaled quantity render |

## Apple Design Guidelines Compliance

- **HIG Layout**: Content-first layout with minimal navigation (3-tab bar: Home, Scale, Settings). Essential info (scaled ingredients) given most space.
- **HIG Controls**: Stepper for serving count (kitchen-friendly, one-thumb). Large touch targets (44×44pt minimum).
- **HIG Typography**: System fonts (SF Pro) with Dynamic Type support. Kitchen use = large readable text.
- **HIG Color**: Warm palette (orange primary #E8722A, green secondary #2D6A4F) — appetite-stimulating, not clinical.
- **HIG Dark Mode**: Full support with semantic colors. Auto-switches with system setting.
- **HIG Accessibility**: VoiceOver labels on all controls, high contrast support, Dynamic Type.
- **HIG Haptics**: UIImpactFeedbackGenerator on scaling changes for tactile confirmation.
- **HIG Sheets**: Pan Calculator uses bottom sheet (not full screen) for quick access.
- **App Store Review 3.1.2**: One-time purchase with clear paywall. Free tier provides real value. Premium features clearly listed.
- **App Store Review 2.1**: No account required. App fully functional offline. URL import is only network feature.

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (screen stay-awake only)
- **Architecture**: MVVM with @Observable (Swift Observation framework, not ObservableObject)
- **Data**: CoreData (Recipe, Ingredient entities) + UserDefaults (settings, premium state)
- **Networking**: URLSession (URL import only — single network feature)
- **HTML Parsing**: SwiftSoup (recipe extraction from web pages)
- **Payments**: StoreKit 2 (one-time non-consumable purchase)
- **Charts**: Swift Charts (baker's percentage visualization)
- **Min Deployment**: iOS 17.0 (@Observable, latest SwiftUI features)
- **All scaling math uses Double** — never Float. Precision matters for baking.
- **Protocol-based services** — Every service has a protocol + mock for testing
- **Zero force unwraps** — All optionals handled with guard/let or nil coalescing
- **Offline-first** — All core features work without network

## Module Structure

```
ScaleChef/
├── App/
│   ├── ScaleChefApp.swift          # @main entry
│   └── AppDelegate.swift
├── Core/
│   ├── Engine/
│   │   ├── ScalingEngine.swift      # Core IP — smart scaling with type-aware rules
│   │   ├── RecipeParser.swift       # Regex-based ingredient parsing
│   │   ├── FractionFormatter.swift  # Kitchen-friendly fraction display
│   │   ├── UnitConverter.swift      # US↔Metric conversion
│   │   └── PanCalculator.swift      # Area-based pan scaling
│   ├── Models/
│   │   ├── Recipe.swift
│   │   ├── Ingredient.swift
│   │   └── ScaledRecipe.swift
│   ├── Services/
│   │   ├── RecipeImportService.swift  # URL→Recipe via SwiftSoup
│   │   ├── StorageService.swift       # CoreData wrapper
│   │   ├── ShareService.swift         # PDF/Text export
│   │   └── PurchaseService.swift      # StoreKit 2 wrapper
│   └── DesignSystem/
│       ├── SCColor.swift              # Color palette
│       ├── SCFont.swift               # Typography
│       ├── SCSpace.swift              # 8pt grid spacing
│       └── SCComponent.swift          # Reusable components
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Scale/
│   │   ├── ScaleView.swift            # Main scaling screen
│   │   ├── ScaleViewModel.swift
│   │   ├── SmartAdjustmentCard.swift
│   │   └── IngredientRow.swift
│   ├── PanCalculator/
│   │   ├── PanCalculatorView.swift
│   │   └── PanCalculatorViewModel.swift
│   ├── BakersPercent/
│   │   ├── BakersPercentView.swift
│   │   └── BakersPercentViewModel.swift
│   ├── Import/
│   │   ├── URLImportView.swift
│   │   └── URLImportViewModel.swift
│   ├── Paywall/
│   │   ├── PaywallView.swift
│   │   └── PaywallViewModel.swift
│   └── Settings/
│       └── SettingsView.swift
├── Shared/
│   ├── Extensions/
│   │   ├── Double+Kitchen.swift
│   │   ├── String+Parsing.swift
│   │   └── View+Modifiers.swift
│   └── Constants/
│       ├── UnitDatabase.swift         # Conversion factors
│       └── IngredientClassification.swift
└── ScaleChefTests/
    ├── ScalingEngineTests.swift
    ├── RecipeParserTests.swift
    ├── FractionFormatterTests.swift
    └── PanCalculatorTests.swift
```

## Data Flow Diagram

### Feature 1: Recipe Paste & Parse
```
User Input: Paste/type recipe text
    │
    ▼
HomeViewModel.handlePastedText(_ text: String)
    │
    ▼
RecipeParser.parse(_ text: String) → ParsedRecipe
    ├── detectServings() → Int (regex patterns)
    ├── parseIngredientLine() → Ingredient? (regex extraction)
    ├── detectCategory() → RecipeCategory (ingredient keywords)
    └── isSectionHeader() → Bool
    │
    ▼
ParsedRecipe (name, originalServings, ingredients[], category, instructions[])
    │
    ▼
Navigate to ScaleView with ParsedRecipe
    │
    ▼
Display: Recipe name, servings, ingredient list
```

### Feature 2: Smart Scaling
```
User Input: Change desired servings (stepper) or tap quick-scale button
    │
    ▼
ScaleViewModel.scaleRecipe(to desiredServings: Int)
    │
    ▼
ScalingEngine.scaleRecipe(recipe: ParsedRecipe, factor: Double) → ScaledRecipe
    ├── For each ingredient:
    │   ├── classifyIngredient(name) → IngredientType
    │   ├── scaleIngredient(ingredient, factor, category) → ScaledIngredient
    │   │   ├── .standard/.fat → linear (factor × qty)
    │   │   ├── .leavening → sub-linear (factor^0.8 or 1.75^doublings)
    │   │   ├── .yeast → sub-linear (factor^0.7)
    │   │   ├── .egg → rounded (nearest 0.5 + gram note)
    │   │   ├── .spice → sub-linear (factor^0.85 + "season gradually")
    │   │   └── .acid → mild sub-linear (factor^0.9)
    │   └── promoteUnit(qty, unit) → (newQty, newUnit, promoted)
    │
    ▼
ScaledRecipe (originalServings, desiredServings, scaledIngredients[], scaleFactor)
    │
    ▼
Display: Scaled ingredient list with FractionFormatter
    ├── SmartAdjustmentCard (if any non-linear adjustments)
    └── IngredientRow (original → scaled with fraction display)
```

### Feature 5: Pan Size Calculator
```
User Input: Select original pan (shape + dimensions), select new pan (shape + dimensions)
    │
    ▼
PanCalculatorViewModel.calculateRatio()
    │
    ▼
PanCalculator.panScaleFactor(originalShape, dims, newShape, dims) → Double
    ├── calculateArea(.round, diameter) → π(d/2)²
    ├── calculateArea(.square, side) → side²
    ├── calculateArea(.rectangle, l, w) → l × w
    └── calculateArea(.loafPan, l, w) → l × w × 3.0
    │
    ▼
Scale factor = newArea / originalArea
    │
    ▼
User taps "Apply to Recipe"
    │
    ▼
ScaleViewModel.applyPanScaleFactor(factor)
    │
    ▼
Re-run ScalingEngine with pan-derived factor
    │
    ▼
Display: Updated scaled ingredients
```

### Feature 6: Baker's Percentage Mode
```
User Input: Toggle "Baker's %" mode, adjust flour weight or hydration
    │
    ▼
BakersPercentViewModel.calculatePercentages()
    │
    ▼
For each ingredient: percentage = (weight / flourWeight) × 100
    ├── flourWeight is always 100%
    ├── hydration = sum of liquid percentages
    └── Adjusting hydration → recalculate water weight
    │
    ▼
Display: Swift Charts bar chart + ingredient percentage list
```

### Feature 7: URL Recipe Import
```
User Input: Paste URL → Tap "Import"
    │
    ▼
URLImportViewModel.importFromURL(_ urlString: String)
    │
    ▼
RecipeImportService.fetchAndParse(url: URL)
    ├── URLSession.shared.dataTask → HTML string
    ├── Try JSON-LD Recipe Schema extraction
    │   └── SwiftSoup.select("script[type='application/ld+json']")
    ├── Fallback: SwiftSoup heuristic parsing
    │   └── Find ingredient lists by CSS class patterns
    └── Parse extracted text with RecipeParser
    │
    ▼
ParsedRecipe (or error → show manual paste fallback)
    │
    ▼
Navigate to ScaleView with ParsedRecipe
```

### Feature 8: Recipe Storage
```
User Input: Tap "Save" on Scale screen
    │
    ▼
ScaleViewModel.saveRecipe()
    │
    ▼
StorageService.save(recipe: ParsedRecipe, scaleSettings: ScaleSettings)
    ├── CoreData context.save()
    │   ├── Recipe entity (name, servings, category, date)
    │   └── Ingredient entities (qty, unit, name, originalLine)
    │
    ▼
Confirmation toast: "Recipe Saved"
    │
    ▼
Home screen: Recipe appears in "Recent Recipes" horizontal scroll
```

### Feature 13: Paywall / Premium
```
User Input: Tap premium feature (pan calc, baker's %, URL import, save 11th recipe, export)
    │
    ▼
Feature access check: PurchaseService.isPremium
    │
    ├── isPremium == true → Proceed to feature
    │
    └── isPremium == false → Show PaywallView
        │
        ▼
    PaywallView: Feature list + "Unlock for $3.99" button
        │
        ▼
    PurchaseService.purchase()
        │
        ▼
    StoreKit 2: Product.purchase()
        │
        ▼
    On success: Update isPremium → UserDefaults + observe transaction
        │
        ▼
    Proceed to feature
```

## Implementation Flow

1. Create Xcode project with SwiftUI, CoreData, iOS 17.0 target
2. Implement DesignSystem (SCColor, SCFont, SCSpace, SCComponent)
3. Implement Core/Engine (ScalingEngine, RecipeParser, FractionFormatter, UnitConverter, PanCalculator)
4. Implement Core/Models (Recipe, Ingredient, ScaledRecipe with IngredientType enum)
5. Implement Core/Services (StorageService with CoreData, RecipeImportService, ShareService, PurchaseService)
6. Implement Features/Home (HomeView + HomeViewModel with paste, recent recipes, URL import entry)
7. Implement Features/Scale (ScaleView + ScaleViewModel + SmartAdjustmentCard + IngredientRow)
8. Implement Features/PanCalculator (PanCalculatorView + ViewModel as bottom sheet)
9. Implement Features/BakersPercent (BakersPercentView + ViewModel with Swift Charts)
10. Implement Features/Import (URLImportView + URLImportViewModel)
11. Implement Features/Paywall (PaywallView + PaywallViewModel with StoreKit 2)
12. Implement Features/Settings (SettingsView with unit system, stay-awake, restore purchases)
13. Write unit tests for ScalingEngine, RecipeParser, FractionFormatter, PanCalculator
14. UI polish, dark mode, Dynamic Type, VoiceOver, haptics

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: #E8722A (Warm Orange — appetite-stimulating)
  - Secondary: #2D6A4F (Forest Green — fresh, natural)
  - Background: #FFFBF5 (Warm White — kitchen-warm, not clinical)
  - Surface: #FFFFFF (Pure White — cards, sheets)
  - Text Primary: #1A1A2E (Near Black — readable)
  - Text Secondary: #6B7280 (Gray — subtle)
  - Warning: #F59E0B (Amber — smart adjustment highlights)
  - Error: #EF4444 (Red — invalid input)
  - Success: #10B981 (Green — saved, confirmed)

- **Typography**: Apple system fonts (SF Pro). Large Title 34pt Bold, Title 1 28pt Bold, Title 2 22pt Semibold, Headline 17pt Semibold, Body 17pt Regular, Caption 12pt Regular.

- **Layout**: 8pt grid system. xs=4pt, sm=8pt, md=16pt, lg=24pt, xl=32pt. Cards with 12pt corner radius, subtle shadow.

- **Navigation**: 3-tab bar (Home, Scale, Settings). Minimal header. Bottom sheet for pan calculator.

- **Interactions**: Stepper for servings (one-thumb friendly). Large touch targets (44×44pt min). Haptic feedback on scaling changes. Swipe actions on recipe cards (delete, share). Screen stay-awake option.

- **Dark Mode**: Full support with semantic colors. Auto-switch with system.

- **Dynamic Type**: Respects user font size settings.

- **iPad**: Landscape-optimized with sidebar navigation.

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/Swift
- All scaling math uses Double, never Float
- Protocol-based services with mock implementations
- MVVM with @Observable (not ObservableObject)
- Zero force unwraps — guard/let or nil coalescing
- CoreData for persistence, UserDefaults for settings
- Offline-first — all core features work without network
- Accessibility: Dynamic type, VoiceOver labels, high contrast

## Build & Deployment Checklist

1. Xcode project configured with iOS 17.0 minimum, Swift 5.9
2. CoreData model with Recipe and Ingredient entities
3. StoreKit 2 capability enabled for one-time purchase
4. App icon generated and configured
5. Info.plist: URL schemes, screen stay-awake key
6. Archive and validate for App Store submission
7. App Store Connect: metadata, screenshots, pricing ($3.99)
8. Privacy policy and support URLs deployed (GitHub Pages)
9. Test on iPhone and iPad simulators
10. Submit for review

## Reference Projects for Secondary Development

| Project | What to Reuse | URL |
|---------|--------------|-----|
| SourdoughPro | MVVM architecture, DesignSystem, Baker's % math, RevenueCat wiring, Mock services | https://github.com/beckettech/SourdoughPro |
| Whisker | Recipe scaling UI patterns, unit conversion engine, SwiftSoup HTML parsing | https://github.com/vheeno/Whisker |
| ShipSwift | SWPaywall (StoreKit 2), SWChart, SWComponent, SWAnimation | https://github.com/signerlabs/ShipSwift |
| Tandoor Recipes | Advanced unit/ingredient aliasing, recipe schema | https://tandoor.dev |
