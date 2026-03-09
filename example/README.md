# B Scheduler Example

This example demonstrates how to use the B Scheduler widget in a Flutter application.

## Overview

This example shows:
- Basic integration of BSchedulerView
- Custom repository pattern for data loading
- Mode switching UI controls
- Navigation controls (previous/today/next)

## Running the Example

```bash
flutter pub get
flutter run
```

## Full Code Example

```main.dart
import 'package:flutter/material.dart';
import 'package:b_scheduler/b_scheduler.dart';

// App entry point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Your custom repository
    final repository = SchedulerItemRepository();

    return MaterialApp(
      title: 'B Scheduler',
      home: SchedulerScreen(repository: repository),
    );
  }
}

class SchedulerScreen extends StatefulWidget {
  final SchedulerItemRepository repository;

  const SchedulerScreen({super.key, required this.repository});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {

  // Initialize controller
  late final BSchedulerViewController controller = BSchedulerViewController(
    onRangeChanged: (start, end) => widget.repository.getItems(from: start, to: end),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scheduler View
          BSchedulerView(
            controller: controller,
            onTapItem: (item) => print(item.title),
          ),

          // Desired Custom Widget
          SafeArea(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: ModeSelector(
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModeSelector extends StatelessWidget {
  final BSchedulerViewController controller;

  const ModeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // UI layout params
    final elevation = 4.0;
    final modeButtonWidth = 48.0;
    final screenButtonWidth = 36.0;
    final buttonHeight = 36.0;
    final buttonPadding = 5.0;

    return ValueListenableBuilder<BSchedulerMode>(
      valueListenable: controller.currentModeNotifier!,
      builder: (context, currentMode, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Material(
              elevation: elevation,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(buttonHeight / 2 + buttonPadding),
              ),
              // Logout button
              child: Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                      child: Container(
                        height: buttonHeight,
                        width: modeButtonWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(buttonHeight / 2),
                        ),
                        child: Icon(Icons.logout),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              elevation: elevation,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(buttonHeight / 2 + buttonPadding),
              ),
              // Mode buttons
              child: Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var mode in controller.availableModes)
                      InkWell(
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                        onTap: currentMode == mode ? null : () => controller.changeMode(mode),
                        child: Container(
                          height: buttonHeight,
                          width: modeButtonWidth,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: currentMode == mode
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(buttonHeight / 2),
                          ),
                          child: Icon(mode.icon),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Material(
              elevation: elevation,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(buttonHeight / 2 + buttonPadding),
              ),
              // Screen navigation buttons
              child: Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var mode in {
                      Icons.arrow_back_ios_new_rounded: controller.scrollToPrevScreen,
                      Icons.circle_rounded: controller.scrollToToday,
                      Icons.arrow_forward_ios_rounded: controller.scrollToNextScreen,
                    }.entries)
                      InkWell(
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                        onTap: mode.value,
                        child: Container(
                          height: buttonHeight,
                          width: screenButtonWidth,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(buttonHeight / 2),
                          ),
                          child: Icon(mode.key),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SchedulerItemRepository {
  // Fetch items for the current range
  Future<List<BSchedulerItem>> getItems({
    required DateTime from,
    required DateTime to
  }) {
    // Sample data
    return [
      BSchedulerItem(
        title: "Meeting",
        startTime: DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
        endTime: DateTime.now().copyWith(hour: 13, minute: 0, second: 0)
      ),
      BSchedulerItem(
        title: "Event A",
        startTime: DateTime.now().copyWith(hour: 13, minute: 0, second: 0),
        endTime: DateTime.now().copyWith(hour: 14, minute: 30, second: 0)
      ),
      BSchedulerItem(
        title: "Code Review",
        startTime: DateTime.now().copyWith(hour: 13, minute: 30, second: 0),
        endTime: DateTime.now().copyWith(hour: 14, minute: 00, second: 0)
      )
    ];
  }
}
```

## Key Features Demonstrated

1. **View Mode Switching**: Seamless transitions between day, week, and month views
2. **Custom Data Source**: Integration with a repository pattern
3. **Item Interaction**: Tap handling for scheduler items
4. **Navigation Controls**: Previous, today, and next screen navigation
5. **Responsive UI**: Custom overlay controls that work with the scheduler

## Further Customization

You can extend this example by:
- Implementing real API integration in the repository
- Adding item details dialog on tap
- Customizing the scheduler style with `BSchedulerStyle`
- Adding item creation/editing functionality
- Integrating with calendar services (Google Calendar, etc.)

For more information, see the main [README](../README.md).
