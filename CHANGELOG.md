## 0.2.0

### Changed
* **BREAKING:** Increased minimum Flutter SDK constraint to `3.24.0` and Dart SDK to `3.5.0` resolving build failures on earlier versions. This alignment is required for framework APIs used in the package:

    - `hitTestBehavior` in `Scrollable` was added in [Flutter 3.24.0](https://docs.flutter.dev/release/release-notes/release-notes-3.24.0) ([#146403](https://github.com/flutter/flutter/pull/146403)).

    - `calculateLeadingGarbage` and `calculateTrailingGarbage` were introduced in [Flutter 3.22.0](https://docs.flutter.dev/release/release-notes/release-notes-3.22.0) ([#143884](https://github.com/flutter/flutter/pull/143884)).

* Add some screenshots.

## 0.1.2

* Fixed images in README.md not displaying.

## 0.1.1

* Add `screenshots` field to `pubspec.yaml`.

## 0.1.0

* Initial release.
* Minimum supported SDK version: Flutter 3.13/Dart 3.1.
