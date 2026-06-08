# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "购买" / "premium" / "one-time purchase" → In-App Purchase (StoreKit 2, non-consumable)
- "URL import" / "network" / "fetch" → Outgoing Network Connections
- "CoreData" / "local storage" → Local Persistence (no capability needed)
- No iCloud sync, no HealthKit, no Location, no Watch, no Camera, no Push Notifications

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| In-App Purchase | Configured | StoreKit 2 in code (PurchaseService.swift) |
| Outgoing Network | Configured | URLSession in code (RecipeImportService.swift) |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| In-App Purchase Product | Pending | 1. Open App Store Connect → ScaleChef app → In-App Purchases → Create non-consumable product with ID "com.zzoutuo.ScaleChef.premium" priced at $3.99 |

## No Configuration Needed
- iCloud / CloudKit — App is offline-first, no sync
- HealthKit — Not a health app
- Location Services — No location features
- Apple Watch — No watch companion
- Camera / Photo Library — No camera/photo features
- Push Notifications — No notification features
- Background Modes — No background processing
- Siri — No Siri integration

## Verification
- Build succeeded after configuration: Yes
- All entitlements correct: Yes (no special entitlements needed beyond defaults)
