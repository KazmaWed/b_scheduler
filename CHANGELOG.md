## 0.0.5

* FEAT: Add `addListener` and `removeListener` methods to `BSchedulerViewController`

## 0.0.4

* **BREAKING**: Simplify `BSchedulerDetailItemBuilder` typedef signature
  - Removed `BSchedulerStyle style` and `int alpha` parameters
  - New signature: `Widget Function(BuildContext context, BSchedulerItem item, VoidCallback onTap)`

## 0.0.3

* FEAT: Add customizable `detailItemBuilder` parameter

## 0.0.2

* FIX: Improve loading indicator behavior

## 0.0.1

* Initial release with multiple view modes (day, week, month)
* Pinch-to-zoom gestures for seamless mode transitions
* Infinite scrolling across all view modes
* Customizable styling and data sources
* Example implementation with Google Calendar integration
