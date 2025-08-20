# Flutter Timezone Widget - Multi-View Project

## Project Context
This is a Flutter web application that displays timezone-aware clocks, specifically designed for multi-view embedded mode. It allows Flutter widgets to be embedded multiple times within existing React or other web applications.

## Key Architecture Decisions

### Multi-View Implementation
- Uses `runWidget()` instead of `runApp()` in `lib/main.dart` to enable multi-view mode
- Implements `MultiViewApp` wrapper that manages multiple Flutter views
- Uses `WidgetsBindingObserver` to track view lifecycle changes

### Timezone Widget
- Built with `timezone` package for accurate timezone handling
- Updates every second using `Timer.periodic`
- Defaults to `America/New_York` but supports any IANA timezone
- Clean, minimal UI suitable for embedding (no app bar or navigation)

### Web Configuration
- Custom `web/flutter_bootstrap.js` provides readable multi-view setup
- Exposes `window.FlutterMultiView` API for easy embedding
- Fires `flutter-multi-view-ready` event when initialized
- Loads both `flutter.js` and custom bootstrap in correct order

## File Structure
```
lib/main.dart                 # Flutter app with timezone widget + multi-view support
web/index.html               # Main HTML with flutter.js + bootstrap loading
web/flutter_bootstrap.js     # Readable multi-view configuration script
web/embed_example.html       # Demo page showing multiple widget embedding
build/web/                   # Built output ready for deployment
```

## Dependencies
- `timezone: ^0.9.4` - Timezone data and calculations
- `intl: ^0.19.0` - Date/time formatting

## Build Commands
- `flutter build web` - Build for production
- `cd build/web && python3 -m http.server 8000` - Serve locally

## Integration Notes
For React integration:
1. Copy `build/web/` files to React app's `public/`
2. Load `flutter.js` and `flutter_bootstrap.js` scripts
3. Use `window.FlutterMultiView.addView(element, config)` to embed widgets
4. Listen for `flutter-multi-view-ready` event before adding views

## Current State
All planned features are implemented and tested. The project is ready for:
- Integration into React applications
- Deployment to web servers
- Extension with additional timezone features
- Customization of widget appearance