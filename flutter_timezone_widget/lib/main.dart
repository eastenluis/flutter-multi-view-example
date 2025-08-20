import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:ui_web' as ui_web;
import 'dart:js_interop';

extension type InitialViewData(JSObject _) implements JSObject {
  external String get timezone;
}
void main() {
  tz.initializeTimeZones();
  runWidget(const MultiViewApp());
}

class MultiViewApp extends StatefulWidget {
  const MultiViewApp({super.key});

  @override
  State<MultiViewApp> createState() => _MultiViewAppState();
}

class _MultiViewAppState extends State<MultiViewApp> with WidgetsBindingObserver {
  Map<Object, Widget> _views = <Object, Widget>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateViews();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateViews();
  }

  void _updateViews() {
    final Map<Object, Widget> newViews = <Object, Widget>{};
    for (final view in WidgetsBinding.instance.platformDispatcher.views) {
      final Widget viewWidget = _views[view.viewId] ?? _createViewWidget(view);
      newViews[view.viewId] = viewWidget;
    }
    setState(() {
      _views = newViews;
    });
  }

  Widget _createViewWidget(view) {
    print('Creating view with ID: ${view.viewId}');
    
    // Get timezone from view's initial data, or use default
    String timezone = 'America/New_York';
    try {
      // Access the initial data passed from JavaScript
      final jsData = ui_web.views.getInitialData(view.viewId);
      if (jsData != null) {
        final initialData = jsData as InitialViewData;
        if (initialData.timezone.isNotEmpty) {
          timezone = initialData.timezone;
          print('Got timezone from initialData: $timezone');
        }
      }
    } catch (e) {
      print('Error accessing initial data: $e, using default timezone');
    }
    
    print('View ${view.viewId} using timezone: $timezone');
    
    return View(
      view: view,
      child: MaterialApp(
        title: 'Timezone Clock Widget',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: TimezoneClockWidget(timezone: timezone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewCollection(views: _views.values.toList(growable: false));
  }
}

class TimezoneClockWidget extends StatefulWidget {
  const TimezoneClockWidget({
    super.key,
    this.timezone = 'America/New_York',
  });

  final String timezone;

  @override
  State<TimezoneClockWidget> createState() => _TimezoneClockWidgetState();
}

class _TimezoneClockWidgetState extends State<TimezoneClockWidget> {
  Timer? _timer;
  tz.TZDateTime? _currentTime;
  tz.Location? _location;

  @override
  void initState() {
    super.initState();
    _initializeTimezone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimezone() {
    try {
      _location = tz.getLocation(widget.timezone);
      _updateTime();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          _updateTime();
        }
      });
    } catch (e) {
      print('Error initializing timezone ${widget.timezone}: $e');
      // Fallback to default timezone
      _location = tz.getLocation('America/New_York');
      _updateTime();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          _updateTime();
        }
      });
    }
  }

  void _updateTime() {
    if (_location != null && mounted) {
      setState(() {
        _currentTime = tz.TZDateTime.now(_location!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTime == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timezoneFormat = DateFormat('z');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeFormat.format(_currentTime!),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(_currentTime!),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timezoneFormat.format(_currentTime!),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}