# Rent and Bill Calculator

A modern Flutter application for calculating and managing monthly rent and utility bills. The app features a clean UI, modular architecture, and persistent dark mode support.

## Features

- **Rent & Utility Calculation**: Input rent, advance, due, gas, electricity, service charge, utility bill, and custom fields. Instantly calculate total bill.
- **History Tracking**: View and share the last 10 calculations from the history tab.
- **Dark Mode**: Toggle dark/light mode from the sidebar. Theme preference is saved and restored on app restart.
- **Validation**: All calculation fields accept only whole numbers. Phone field accepts only digits.
- **Invoice Preview & Sharing**: Preview invoice details and share or copy them easily.
- **Modular Code Structure**: Organized into core, features, and widgets for maintainability.

## Folder Structure

```text
lib/
  main.dart            # Entry point
  app.dart             # App setup and theming
  core/
    theme.dart         # Theme and persistence logic
  features/
    home/
      home_controller.dart  # State management
      home_screen.dart      # Main UI and navigation
      widgets/
        bill_form.dart      # Bill input form
        bill_history_dialog.dart # History dialog
```

## Getting Started

1. Install dependencies:

   ```sh
   flutter pub get
   ```

2. Run the app:

   ```sh
   flutter run
   ```

3. Build release APK:

   ```sh
   flutter build apk --release
   ```

## Persistent Dark Mode

The app uses `shared_preferences` to save the user's theme choice. When dark mode is enabled, it remains active after closing and reopening the app.

## License

This project is for educational and personal use.

## branch update

Step 1: Prune remote-tracking branches

Run this in VS Code’s terminal:
git fetch --prune

If you want to delete all local branches that no longer exist on remote:
git fetch -p
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d

👉 If you want to force delete them:

git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
