# ScaleChef - Manual Configuration Checklist

After downloading the app, you must manually configure the following items to make ScaleChef fully functional.

## 1. In-App Purchase Product (CRITICAL)

| Item | Details |
|------|---------|
| **Product ID** | `com.zzoutuo.ScaleChef.premium` |
| **Type** | Non-consumable |
| **Price** | $3.99 |
| **Reference Name** | ScaleChef Premium |
| **Display Name** | ScaleChef Premium |

**Steps:**
1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. Select ScaleChef app
3. Go to Monetization → In-App Purchases
4. Click "+" to create new
5. Select "Non-consumable"
6. Enter Reference Name: `ScaleChef Premium`
7. Enter Product ID: `com.zzoutuo.ScaleChef.premium`
8. Set Price: $3.99
9. Add display name and description for all localizations
10. Submit for review (must be approved before app goes live)

## 2. App Store Connect App Record

| Item | Details |
|------|---------|
| **App Name** | ScaleChef |
| **Bundle ID** | com.zzoutuo.ScaleChef |
| **Primary Language** | English |
| **Category** | Food & Drink |
| **Subcategory** | — |
| **Content Rights** | No |

**Steps:**
1. Open App Store Connect → My Apps → "+"
2. Fill in the above details
3. Upload screenshots (6.7" iPhone, 5.5" iPhone, 12.9" iPad)
4. Copy metadata from `keytext.md`
5. Upload app build via Xcode Organizer

## 3. App Store Screenshots (Required)

You need screenshots for these device sizes:
- **6.7" iPhone** (iPhone 15 Pro Max / iPhone 16 Pro Max) — 1290x2796 or 2796x1290
- **5.5" iPhone** (iPhone 8 Plus) — 1242x2208 or 2208x1242
- **12.9" iPad** (iPad Pro) — 2048x2732 or 2732x2048

## 4. Signing & Capabilities (Xcode)

| Item | Status |
|------|--------|
| Team | JP4TN5PTS3 (auto) |
| Bundle Identifier | com.zzoutuo.ScaleChef |
| Signing | Automatic |
| In-App Purchase capability | Must add in Xcode |

**Steps to add IAP capability:**
1. Open ScaleChef.xcodeproj in Xcode
2. Select ScaleChef target → Signing & Capabilities
3. Click "+ Capability"
4. Add "In-App Purchase"
5. This creates the .entitlements file automatically

## 5. GitHub Pages Verification

| URL | Purpose |
|-----|---------|
| https://asunnyboy861.github.io/ScaleChef/privacy | Privacy Policy |
| https://asunnyboy861.github.io/ScaleChef/terms | Terms of Use |
| https://asunnyboy861.github.io/ScaleChef/ | Support/FAQ |

**Verify:** Open each URL in a browser to confirm they load correctly.

## 6. App Review Information

| Item | Value |
|------|-------|
| Contact Email | iocompile67692@gmail.com |
| Review Notes | "This is a recipe scaling calculator. Free tier allows basic scaling. Premium unlocks smart baking adjustments, pan calculator, and baker's percentage mode. No account required." |
| Demo Account | Not needed (no login) |

## Summary

| # | Task | Priority | Time |
|---|------|----------|------|
| 1 | Create IAP product in App Store Connect | CRITICAL | 5 min |
| 2 | Create App Record in App Store Connect | CRITICAL | 10 min |
| 3 | Take and upload screenshots | Required | 15 min |
| 4 | Add In-App Purchase capability in Xcode | CRITICAL | 2 min |
| 5 | Verify GitHub Pages URLs | Recommended | 2 min |
| 6 | Fill review information | Required | 5 min |
