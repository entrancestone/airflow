# CalSnap

CalSnap is an iOS 17+ SwiftUI application that helps people capture meals, estimate nutrition, and stay on track with a personalised calorie target.

## Requirements

* Xcode 15+
* iOS 17 SDK

## Project Structure

```
CalSnap/
 ├─ CalSnap/                # Application sources
 │   ├─ Models/             # SwiftData models & enums
 │   ├─ UseCases/           # Domain logic (BMR, TDEE, logging, summaries)
 │   ├─ Services/           # Nutrition & food recognition providers
 │   ├─ UI/                 # SwiftUI screens
 │   ├─ Persistence/        # SwiftData container helpers
 │   ├─ Health/             # Optional HealthKit integration
 │   ├─ Utilities/          # Shared helpers
 │   └─ Resources/          # Plists & secrets samples
 └─ CalSnapTests/           # XCTest targets
```

## Feature Flags

* `HEALTHKITINTEGRATION`: enable HealthKit export of daily dietary energy. Disabled by default. Set this flag in the project build settings (Other Swift Flags) to compile the HealthKit pathway.

## Secrets

1. Duplicate `Resources/Secrets.sample.plist` to `Resources/Secrets.plist`.
2. Populate with the credentials for the remote nutrition provider (e.g. USDA FDC or Edamam). This file is not committed and should be added to your personal git ignore if storing credentials locally.

## Swapping Nutrition Providers

`DIContainer` resolves a `NutritionAPI`. In Debug builds the `MockNutritionAPI` is used and ships with deterministic data for offline demos. To integrate a real provider:

1. Implement `RemoteNutritionAPI` by wiring up the desired REST service.
2. Supply credentials via `Secrets.plist` and load them inside `RemoteNutritionAPI`.
3. Build the app using a non-Debug configuration (e.g. Release) or adjust the preprocessor directives in `DIContainer` to inject the remote implementation.

## Testing

Unit tests live in `CalSnapTests/`. They cover TDEE/BMR calculations, meal-slot detection, daily roll-ups, advice messaging, and the mock nutrition estimator. Run them in Xcode with **Product → Test** or using `xcodebuild test -scheme CalSnap -destination 'platform=iOS Simulator,name=iPhone 15'` once the scheme is configured.
