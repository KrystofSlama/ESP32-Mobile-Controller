# ESP32 Mobile Controller

Control your ESP32 through BLE and control whatever you can.
You can try it yourself, it is ready to go (sometimes :D) iRobot Roomba script. 
This repository currently focuses on an iOS application that connects
to an ESP32 running the bundled firmware, but the codebase is evolving toward a
more generic controller experience with a simplified, robot-agnostic
interface.

## Features

- 📱 **Native iOS app** for sending drive, vacuum, and dock commands to a
  Roomba through BLE.
- 🤖 **ESP32 firmware** that translates mobile commands into Roomba Serial
  Command Interface (SCI) messages.
- 🧰 **Extensible architecture** preparing for future robot types and a
  streamlined control interface.

## What next

-  **Test new roombas**
-  **Recieving data from roomba** to show stats about a battery, etc.
-  **New robots/apliances support**
-  **Major redesing** to make controls more generic, not roomba specific
-  **Controller support**
  
## Repository structure

| Path | Description |
| --- | --- |
| `App/` | Folder for apps (iOS/Android). |
| `App/iOS/` | Xcode project for the iOS controller application. |
| `ESP32/` | Folder for scripts. |
| `ESP32/Roomba/` | Arduino sketch (`ESPScript.ino`) and reference material for the Roomba firmware. |

## Installation & setup

### iOS application

1. Install the latest versions of **Xcode** and the **iOS SDK** on macOS.
2. Clone this repository:
   ```bash
   git clone https://github.com/<your-org>/ESP32-Mobile-Controller.git
   cd ESP32-Mobile-Controller
   ```
3. Open the project file located at `App/iOS/Esp32 Controller/Esp32 Controller.xcodeproj` in
   Xcode.
4. Update the bundle identifier and signing team under *Signing & Capabilities*
   to match your Apple Developer account.
5. Build and run the app on a physical device (recommended) or simulator.

### ESP32 firmware

Each ESP32 script should have README file for wiring scheme and needed set-up

   
## Contributing

1. Fork the repository and create a feature branch.
2. Follow the platform-specific setup instructions above.
3. Make changes accompanied by documentation and tests when applicable.
4. Submit a pull request describing your changes, test coverage, and any
   hardware considerations.

Please open an issue to discuss major changes, new robot integrations, or
questions about the evolving interface.

## Roadmap

- Simplify the mobile UI for a device-agnostic control flow.
- Expand the ESP32 firmware to cover additional robot models (e.g., Foomba).
- Add continuous integration for automated build and test pipelines.

## License

This project is licensed under the [MIT License](LICENSE).
