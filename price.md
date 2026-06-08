# Pricing Configuration

## Monetization Model: Freemium + One-Time Purchase (Non-Consumable IAP)

## Free Tier (Forever Free — Lead Magnet)
- Basic recipe scaling (multiply/divide)
- Paste & parse recipes
- Unit conversion (US ↔ Metric)
- Save up to 10 recipes locally
- Fraction display

## Premium Tier — One-Time Purchase
- **Reference Name**: ScaleChef Premium
- **Product ID**: `com.zzoutuo.ScaleChef.premium`
- **Price**: $3.99 (one-time, forever)
- **Display Name**: ScaleChef Premium
- **Description**: Unlock smart scaling, pan calculator & more

### Premium Features Unlocked
- Smart adjustments (baking powder, eggs, spices, yeast)
- Pan size calculator (round/square/rectangle/loaf)
- Baker's percentage mode
- URL recipe import
- Unlimited recipe storage
- Print & PDF export
- Future feature updates

## Why One-Time Purchase (Not Subscription)
- No API costs — all computation is local
- No server costs — all data stored locally
- Recipe app subscription fatigue is real (ReciMe $60/yr = user anger)
- One-time purchase builds trust and word-of-mouth
- $3.99 = less than a latte — impulse purchase territory
- Paprika proved one-time $4.99 works for recipe tools

## App Store Connect Pricing
- **App Price**: Free (freemium model)
- **IAP Price Tier**: Tier 4 = $3.99
- **IAP Type**: Non-Consumable

## Policy Pages Required
- Support Page: Yes
- Privacy Policy: Yes
- Terms of Use: Yes (required for IAP apps per App Store Review Guideline 3.1.2)

## Apple IAP Compliance Checklist
- [x] Non-consumable purchase clearly described
- [x] Restore purchases functionality implemented
- [x] Free tier provides real value (basic scaling works without paying)
- [x] Premium features clearly listed in paywall
- [x] No dark patterns — user can dismiss paywall and continue using free features
- [x] Terms of Use link included in paywall view
- [x] Privacy Policy link included in paywall view
