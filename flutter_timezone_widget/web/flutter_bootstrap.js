/**
 * Flutter Multi-View Bootstrap Script
 * 
 * This script configures Flutter to run in multi-view embedded mode,
 * allowing multiple Flutter widgets to be embedded in different parts
 * of the host web application.
 */

{{flutter_js}}
{{flutter_build_config}}

// Wait for the default Flutter loader to be available
window.addEventListener('load', function() {
  // Check if Flutter loader is available
  if (!window._flutter || !window._flutter.loader) {
    console.error('Flutter loader not available. Make sure flutter.js is loaded first.');
    return;
  }

  // Initialize Flutter with multi-view configuration
  window._flutter.loader.load({
    onEntrypointLoaded: async function(engineInitializer) {
      console.log('Flutter entrypoint loaded, initializing multi-view mode...');
      
      // Store the initializer globally for multi-view access
      window._flutterEngineInitializer = engineInitializer;
      
      try {
        // Initialize the engine for multi-view mode
        const engine = await engineInitializer.initializeEngine({
          multiViewEnabled: true
        });
        
        console.log('Flutter multi-view engine initialized successfully');
        
        // Run the app to get the app runner
        const app = await engine.runApp();
        
        // Store the app globally for multi-view management
        window._flutterApp = app;
        
        // Expose helper methods for managing Flutter views
        window.FlutterMultiView = {
          /**
           * Add a Flutter view to a specific DOM element
           * @param {HTMLElement} hostElement - The DOM element to render Flutter into
           * @param {Object} config - Configuration for the view (optional)
           * @returns {Promise} Promise that resolves when the view is added
           */
          addView: function(hostElement, config = {}) {
            if (!hostElement) {
              throw new Error('Host element is required');
            }
            
            console.log('Adding Flutter view to element:', hostElement);
            
            return app.addView({
              hostElement: hostElement,
              initialRoute: config.initialRoute || '/',
              ...config
            });
          },
          
          /**
           * Remove a Flutter view
           * @param {string} viewId - The ID of the view to remove
           */
          removeView: function(viewId) {
            console.log('Removing Flutter view with ID:', viewId);
            return app.removeView(viewId);
          },
          
          /**
           * Check if Flutter multi-view is ready
           * @returns {boolean} True if ready, false otherwise
           */
          isReady: function() {
            return !!window._flutterApp;
          }
        };
        
        // Dispatch a custom event to notify that Flutter multi-view is ready
        window.dispatchEvent(new CustomEvent('flutter-multi-view-ready', {
          detail: { app: app }
        }));
        
        console.log('Flutter multi-view mode is ready! Use window.FlutterMultiView.addView() to embed widgets.');
      } catch (error) {
        console.error('Failed to initialize Flutter multi-view engine:', error);
      }
    }
  });
});