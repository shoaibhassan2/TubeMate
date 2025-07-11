# TubeMate - Your All-in-One Media Companion

![App Logo/Banner - Optional, consider adding one later]
<!-- You can add a screenshot or a GIF of your app here for visual appeal. -->
<!-- Example: <p align="center"><img src="path/to/your/screenshot.png" alt="TubeMate App Screenshot" width="auto"></p> -->

TubeMate is a powerful and intuitive Android application designed to simplify your media experience. From seamless video and music downloads to a convenient WhatsApp Status Saver and a quick SIM data lookup tool, TubeMate brings essential utilities into one clean, user-friendly interface.

## ✨ Features

*   **🌐 Universal Downloader:** Effortlessly download videos and music from various online platforms by simply pasting their links. (Note: Specific platform support and legal use depend on external service terms and local regulations).
*   **🎵 Background Playback:** Enjoy your downloaded audio in the background while you use other apps.
*   **🚀 Fast & Efficient:** Optimized for quick performance and smooth operation.
*   **💡 Intelligent Theme System:** Switches between beautiful Light and Dark themes based on system preferences or user selection.
*   **📱 WhatsApp Status Saver:** View, save, and manage your friends' WhatsApp statuses (both images and videos) directly to your device's gallery. No more asking for status shares!
*   **🇵🇰 Pak SIM Data Lookup:** Quickly retrieve essential SIM data information (like Name, CNIC, Address, Provider) for Pakistani mobile numbers. (Note: This feature uses a dummy data lookup for demonstration; real implementation would require a backend service).
*   **🌊 Dynamic UI:** Features a modern, wave-inspired background for an aesthetically pleasing experience.
*   **⚙️ In-App Settings:** Customize app themes and access other utility features directly from the settings.

## 📸 Screenshots

<!-- After you install the app on a device/emulator, take some good screenshots and add them here. -->
<!-- Example: -->
<!-- <p align="center"> -->
<!--   <img src="screenshots/screenshot_home.png" width="30%" alt="Home Screen"> -->
<!--   <img src="screenshots/screenshot_status_saver.png" width="30%" alt="WhatsApp Status Saver"> -->
<!--   <img src="screenshots/screenshot_settings.png" width="30%" alt="Settings Screen"> -->
<!-- </p> -->

## 🛠️ Technologies Used

*   **Flutter:** The UI framework for building beautiful, natively compiled applications from a single codebase.
*   **Dart:** The client-optimized language for fast apps on any platform.
*   **`font_awesome_flutter`**: For beautiful, scalable icons.
*   **`shared_preferences`**: For persisting user preferences like theme mode.
*   **`http` & `html`**: For web requests and HTML parsing (used in Pak SIM Data lookup).
*   **`permission_handler`**: For robust runtime permission requests (e.g., storage access).
*   **`video_thumbnail`**: For generating thumbnails from video files for status previews.
*   **`path_provider`**: For accessing device file system paths.
*   **`video_player`**: For playing video statuses within the app.
*   **`flutter_image_gallery_saver` (v0.0.2):** For saving images and videos to the device's public gallery. (Note: Due to compatibility, this specific older version is used, and its behavior on newer Android versions may vary due to Scoped Storage).

## 🚀 Getting Started

Follow these instructions to set up and run the TubeMate app locally.

### Prerequisites

*   **Flutter SDK:** [Install Flutter](https://flutter.dev/docs/get-started/install) (version used during development can be checked with `flutter --version`).
*   **Android Studio / VS Code:** With Flutter and Dart plugins installed.
*   **Android Device / Emulator:** For running the app.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/shoaibhassan2/TubeMate.git
    cd TubeMate
    ```

2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

### Running the App

1.  Connect an Android device or start an Android emulator.
2.  Run the app:
    ```bash
    flutter run
    ```
    For a release build:
    ```bash
    flutter build apk --release --target-platform android-arm64
    ```

## ⚠️ Important Notes on File Access

The WhatsApp Status Saver and Gallery Save functionalities rely on direct file system access.
*   **Android 10 (API 29) & Below:** `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` (with `requestLegacyExternalStorage="true"`) generally allow access.
*   **Android 11 (API 30) & Above (Scoped Storage):**
    *   Accessing directories like WhatsApp's `.Statuses` folder (`/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses`) or saving directly to the public gallery (`/sdcard/Pictures`, `/sdcard/Movies`) is heavily restricted.
    *   The `MANAGE_EXTERNAL_STORAGE` permission ("Allow management of all files") is used in this app to attempt broader access. **Users must manually grant this permission from app settings.**
    *   **Google Play Store Policy:** Apps using `MANAGE_EXTERNAL_STORAGE` are subject to strict review and may be rejected unless it's for a core app function (e.g., file managers, backup tools). A status saver *might* qualify, but expect scrutiny.
    *   The `flutter_image_gallery_saver` (v0.0.2) plugin is used for saving, but its compatibility with modern Android versions and Scoped Storage may be limited.

## 🤝 Contribution

Feel free to fork the repository, open issues, and submit pull requests.

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

## 🙏 Credits

*   Developed By: Shoaib Hassan
*   Special Thanks to the SHKA team
