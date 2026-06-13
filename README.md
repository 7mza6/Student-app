# Student-App


This repository contains a cross-platform Flutter application designed for user management. It provides functionalities for user registration and login, with data persisted locally using an SQLite database. The application also features internationalization support for English and Arabic.

## Features

-   **User Authentication**: Includes separate pages for user registration and login.
-   **Local Data Storage**: Utilizes the `sqflite` package to store user credentials (username, password, email, phone) on the device.
-   **Internationalization (i18n)**: Supports both English and Arabic languages. Users can switch languages directly within the app's UI.
-   **Form Validation**: Implements input validation for registration and login fields to ensure data integrity.
-   **Cross-Platform**: Built with Flutter, allowing it to run on Android, iOS, Web, Windows, macOS, and Linux from a single codebase.

## Technical Overview

The application is built using the Flutter framework and the Dart programming language.

*   **Database**: `sqflite` is used for creating and managing a local SQLite database. `DataBase.dart` contains all the logic for CRUD (Create, Read, Update, Delete) operations on user data.
*   **Data Model**: The user data structure is defined in the `user.dart` model class.
*   **UI and State Management**: The UI is composed of several stateful widgets:
    *   `LoginPage.dart`: Provides the interface for users to log in.
    *   `RegestPage.dart`: Provides the interface for new users to register.
    *   A custom `ShowDialog` widget in `Reusable.dart` is used for displaying messages to the user.
*   **Localization**: The app uses `flutter_localizations` and `.arb` files (`lib/l10n/`) to manage multi-language text for a seamless user experience in both English and Arabic.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

You need to have the Flutter SDK installed on your machine. For instructions, please see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/7mza6/student-app.git
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd student-app
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

### Running the Application

1.  Make sure you have a device connected or an emulator running.
2.  Run the following command to start the application:
    ```sh
    flutter run
