# Flutter Timezone Widget - Multi-View Example

A Flutter web application that displays timezone-aware clocks, configured for multi-view embedded mode. This allows the Flutter widgets to be embedded into existing React or other web applications.

## Features

- **Timezone-aware clock widget** - Displays current time for any timezone
- **Multi-view embedding** - Can be embedded multiple times in the same page
- **Real-time updates** - Updates every second
- **Clean, minimal UI** - Designed for embedding in other applications
- **Configurable timezones** - Supports any IANA timezone identifier

## Project Structure

```
lib/
  main.dart                 # Main Flutter application with multi-view support
web/
  index.html               # Main HTML file (loads flutter.js and custom bootstrap)
  flutter_bootstrap.js     # Custom readable multi-view configuration script
  embed_example.html       # Demo page showing how to embed multiple widgets
build/web/                 # Built web application (ready for deployment)
```

## Quick Start

1. **Build the project:**
   ```bash
   flutter build web
   ```

2. **Serve the built files:**
   ```bash
   cd build/web
   python3 -m http.server 8147
   ```

3. **View the demo:**
   - Main app: http://localhost:8147
   - Embedding demo: http://localhost:8147/embed_example.html

## How to Embed in Your React App

### 1. Copy the built Flutter files

Copy these files from `build/web/` to your React app's `public/` directory:
- `flutter.js`
- `flutter_bootstrap.js` 
- `main.dart.js`
- `canvaskit/` folder
- `assets/` folder

### 2. Add Flutter scripts to your HTML

```html
<script src="/flutter.js" defer></script>
<script src="/flutter_bootstrap.js" defer></script>
```

### 3. Use in your React components

```jsx
import React, { useEffect, useRef } from 'react';

function TimezoneWidget({ timezone = 'America/New_York' }) {
  const containerRef = useRef(null);

  useEffect(() => {
    const addWidget = () => {
      if (window.FlutterMultiView && window.FlutterMultiView.isReady()) {
        window.FlutterMultiView.addView(containerRef.current, {
          initialRoute: '/' + timezone
        });
      }
    };

    // Listen for Flutter ready event
    window.addEventListener('flutter-multi-view-ready', addWidget);
    
    // Try immediately in case Flutter is already ready
    addWidget();

    return () => {
      window.removeEventListener('flutter-multi-view-ready', addWidget);
    };
  }, [timezone]);

  return (
    <div 
      ref={containerRef} 
      style={{ width: '300px', height: '200px', border: '1px solid #ccc' }}
    >
      Loading timezone widget...
    </div>
  );
}

export default TimezoneWidget;
```

### 4. Use multiple widgets

```jsx
function App() {
  return (
    <div>
      <h1>My React App with Flutter Widgets</h1>
      <div style={{ display: 'flex', gap: '20px' }}>
        <TimezoneWidget timezone="America/New_York" />
        <TimezoneWidget timezone="Europe/London" />
        <TimezoneWidget timezone="Asia/Tokyo" />
      </div>
    </div>
  );
}
```

## Available Timezones

The widget supports any IANA timezone identifier, such as:
- `America/New_York` (EST/EDT)
- `America/Los_Angeles` (PST/PDT)  
- `Europe/London` (GMT/BST)
- `Asia/Tokyo` (JST)
- `Australia/Sydney` (AEDT/AEST)
- And many more...

## API Reference

### window.FlutterMultiView

Global object available after Flutter initializes.

#### Methods

- `addView(hostElement, config)` - Add a Flutter widget to a DOM element
  - `hostElement`: DOM element to render into
  - `config.initialRoute`: Route to pass to Flutter (optional, defaults to '/')

- `removeView(viewId)` - Remove a Flutter widget (placeholder)

- `isReady()` - Check if Flutter multi-view is ready

#### Events

- `flutter-multi-view-ready` - Fired when Flutter multi-view is initialized

## Development

To modify the timezone widget:

1. Edit `lib/main.dart`
2. Run `flutter build web`
3. Test with `embed_example.html`

The custom multi-view bootstrap is in `web/flutter_bootstrap.js` and is human-readable for easy modification.

## Notes

- The widget defaults to `America/New_York` timezone if none specified
- Updates every second for real-time display
- Handles timezone transitions (DST) automatically
- Built for embedding, so no navigation chrome or app bar
