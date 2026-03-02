import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:b_scheduler/b_scheduler.dart';

import 'package:example/repositories/scheduler_item_repository.dart';

class SchedulerScreen extends StatefulWidget {
  final bool debugView;
  final VoidCallback onLogoutTapped;
  final SchedulerItemRepository repository;

  const SchedulerScreen({
    super.key,
    this.debugView = false,
    required this.onLogoutTapped,
    required this.repository,
  });

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {

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
          // スケジューラ本体
          BSchedulerView(
            controller: controller,
            debugView: widget.debugView,
            onTapItem: (item) => print(item.title),
          ),

          // モード選択ボタン
          SafeArea(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: ModeSelector(controller: controller, onLogoutTapped: widget.onLogoutTapped),
            ),
          ),
        ],
      ),
    );
  }
}

/// モード選択ボタン・画面スクロールボタンウィジェット
class ModeSelector extends StatelessWidget {
  final BSchedulerViewController controller;
  final VoidCallback onLogoutTapped;

  const ModeSelector({super.key, required this.controller, required this.onLogoutTapped});

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                      onTap: onLogoutTapped,
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
