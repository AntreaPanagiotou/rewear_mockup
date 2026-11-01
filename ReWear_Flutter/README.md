# ReWear the Unexpected — Refined UI

A refreshed Flutter interactive mobile mockup. Original matching and dataset preserved; improved typography, lighter iconography, a redesigned welcome hero, cleaner result cards and unified visual treatment.

## How to run in your existing Flutter project

Copy `lib/main.dart`, `assets/data/recommendations.json`, and `pubspec.yaml` to the equivalent paths in your project (back up the old files first). The web folder is optional if your project already has one.

```powershell
flutter pub get
flutter run -d edge
```

For a new Flutter project, run `flutter create --project-name rewear_unexpected rewear_unexpected` first, then copy the folders and files from this package into it.

The recommendations are illustrative and rule-ranked, not outputs of a trained ML model. This package has not been runtime-tested in Flutter in this environment.
