# Robinhood OAuth Token Logger - iOS

A Flutter iOS app that captures OAuth tokens from Robinhood's authentication flow using WebView.

## Prerequisites

You need these installed on your MacBook:

- Xcode (latest version from App Store)
- Flutter (`brew install flutter`)
- CocoaPods (`sudo gem install cocoapods`)

## Setup & Run

1. **Install**

```bash
flutter pub get
cd ios && pod install && cd ..
```

2. **Setup iOS Simulator**

```bash
# Open Simulator
open -a Simulator

# If Simulator isn't working:
killall Simulator
open -a Simulator
```

3. **Install iOS Runtime**

- Open Xcode
- Go to Xcode → Settings → Platforms
- Download iOS 17.5 (or latest) runtime

4. **Run the App**

```bash
flutter run
```

## Troubleshooting

If you get build errors, try:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Common Issues

**Simulator Won't Open:**

```bash
xcrun simctl erase all
killall Simulator
open -a Simulator
```

**Missing iOS Runtime:**

- Open Xcode → Settings → Platforms
- Download required iOS runtime

**Xcode Path Issues:**

```bash
sudo xcode-select --reset
sudo xcodebuild -license accept
```

## View Token Logs

To see captured tokens:

```bash
flutter logs
```
