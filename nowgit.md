# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | ScaleChef |
| **Git URL** | git@github.com:asunnyboy861/ScaleChef.git |
| **Repo URL** | https://github.com/asunnyboy861/ScaleChef |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | Enabled (from `/docs` folder via GitHub Actions) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/ScaleChef/ | Live |
| Support / FAQ | https://asunnyboy861.github.io/ScaleChef/support.html | Live |
| Privacy Policy | https://asunnyboy861.github.io/ScaleChef/privacy.html | Live |
| Terms of Use | https://asunnyboy861.github.io/ScaleChef/terms.html | Live |

## App Store Connect Links

| Item | URL |
|------|-----|
| App Record | https://appstoreconnect.apple.com/apps (search ScaleChef) |
| IAP Product | com.zzoutuo.ScaleChef.premium ($3.99 Non-Consumable) |

## Repository Structure

```
ScaleChef/
├── ScaleChef/                         # iOS App Source Code
│   ├── ScaleChef.xcodeproj/           # Xcode Project
│   └── ScaleChef/                     # Swift Source Files
│       ├── App/                       # App entry point
│       ├── Core/
│       │   ├── Engine/                # ScalingEngine, RecipeParser, FractionFormatter, PanCalculator
│       │   ├── Models/                # Recipe, Ingredient, ScaledRecipe, CoreData entities
│       │   ├── Services/              # PurchaseService, StorageService, RecipeImportService, ShareService
│       │   └── DesignSystem/          # SCColor, SCFont, SCSpace, SCComponent
│       ├── Features/
│       │   ├── Home/                  # HomeView, HomeViewModel
│       │   ├── Scale/                 # ScaleView, ScaleViewModel, SmartAdjustmentCard
│       │   ├── PanCalculator/         # PanCalculatorView, PanCalculatorViewModel
│       │   ├── BakersPercent/         # BakersPercentView, BakersPercentViewModel
│       │   ├── Import/                # URLImportView, URLImportViewModel
│       │   ├── Paywall/               # PaywallView, PaywallViewModel
│       │   └── Settings/              # SettingsView
│       └── Shared/                    # Extensions, Constants
├── docs/                              # Policy Pages (GitHub Pages source)
│   ├── index.html                     # Landing page (app intro + App Store link)
│   ├── support.html                   # Support / FAQ page
│   ├── privacy.html                   # Privacy Policy
│   └── terms.html                     # Terms of Use
├── .github/workflows/
│   └── deploy-pages.yml               # GitHub Pages deployment workflow
├── .gitignore
├── us.md                              # English development guide
├── price.md                           # Pricing configuration
├── capabilities.md                    # App capabilities
├── icon.md                            # App icon info
├── checklist.md                       # Launch checklist
└── nowgit.md                          # This file
```

## Deployment History

| Date | Action | Result |
|------|--------|--------|
| 2026-06-18 | GitHub Pages enabled (source: main/docs, build_type: workflow) | Success |
| 2026-06-18 | Policy pages deployed via GitHub Actions | Success |
| 2026-06-18 | Code pushed with bug fixes and feature improvements | Success |
