# LeeShare

A Flutter-based file-sharing app for Windows that uses WiFi as a medium. Allows devices on the same network to share files with custom names.

## Features

- **WiFi-based file sharing**: Share files between devices connected to the same WiFi network.
- **Device naming**: Each device can have a custom name for easy identification.
- **Cross-platform**: Built with Flutter, supporting Windows, with potential for other platforms.
- **Simple UI**: Intuitive interface for selecting files and discovering nearby devices.
- **Permissions handled**: All necessary permissions are requested on installation.

## Getting Started

### Prerequisites

- Flutter SDK (>=3.22.0)
- Dart SDK (>=3.5.0)
- Windows development environment (Visual Studio with Windows 10/11 SDK)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Joelodufu/leeshare.git
   cd leeshare
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d windows
   ```

### Building for Windows

To create a release build:

```bash
flutter build windows
```

The built executable will be located in `build/windows/runner/Release`.

## How It Works

The app uses the `lan_sharing` package to establish a local network server and client. Devices on the same WiFi network can discover each other via mDNS (Bonjour) and exchange files over TCP sockets.

### Permissions

On Windows, the app will request:
- Network access (for WiFi communication)
- File system access (to read and write shared files)

All permissions are requested during installation (via the Windows installer).

## GitHub Actions

This repository includes a GitHub Actions workflow that automatically builds the Windows app and packages it as a downloadable artifact. The workflow triggers on pushes to the `main` branch and on pull requests.

To download the latest build artifact, go to the **Actions** tab, select the latest workflow run, and download the `windows-build` artifact.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
