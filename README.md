<br>

<p align='center'>
    <img src="https://framerusercontent.com/images/BZveiOrOkC27ti2CQXL7mMWAAxU.png"/>
</p>

<br>

https://api.codemagic.io/apps/68bd8d5ba7b9336e28030270/68bd8d5ba7b9336e2803026f/status_badge.svg

[![Codemagic build status](https://api.codemagic.io/apps/68bd8d5ba7b9336e28030270/68bd8d5ba7b9336e2803026f/status_badge.svg)](https://codemagic.io/app/68bd8d5ba7b9336e28030270/68bd8d5ba7b9336e2803026f/latest_build)
[![codecov](https://codecov.io/gh/your-username/katya/branch/main/graph/badge.svg)](https://codecov.io/gh/your-username/katya)
[![Contributors](https://img.shields.io/github/contributors/your-username/katya)](https://github.com/your-username/katya/graphs/contributors)

## 🤔 Why

🚀 **Unleash the Future with Katya® - Your Ultimate AI Multifunctional Social Blockchain Platform!** 👽👩🏻‍💻🕵🏻‍♀️

Embark on a journey into the technological frontier as we proudly present the Katya® Super Platform—an unparalleled fusion of cutting-edge AI, multifunctionality, and the power of blockchain! 🌐💡

### 🌟 Artificial Intelligence at its Zenith:
Katya's® state-of-the-art AI core redefines intelligent interactions. Seamlessly adapting to your preferences, this cognitive marvel transforms your digital experience into a personalized and efficient adventure. Get ready to witness a platform that learns, evolves, and connects with you on a whole new level.

### 🔗 Multifunctional Mastery:
Elevate your digital presence with Katya's® multifunctional prowess. From social networking to content creation, financial transactions to smart contracts—Katya® epitomizes versatility. It's not just a platform; it's a universe where all your needs find a home, effortlessly merging technology and human connection.

### 🌐 Blockchain Brilliance:
Immerse yourself in the secure embrace of Katya's® blockchain technology. Your data is guarded, transactions are tamper-proof, and interactions are governed by the transparency and reliability of the blockchain. Trust and decentralization are not just promises; they are the pillars of Katya's® digital ecosystem.

### 🌍 Connect Globally, Thrive Locally:
Break down geographical barriers and foster connections worldwide. Katya® redefines social networking by providing a global stage where cultures converge, collaborations flourish, and friendships know no boundaries. It's not just a platform; it's a bridge connecting minds across the globe.

### 🎨 Aesthetic Simplicity, Functional Brilliance:
Immerse yourself in a sleek, modern, and user-friendly interface that defines Katya's® essence. Navigating through the platform is a visual delight, offering an intuitive experience that seamlessly integrates style and functionality.

### 🚀 Fast-Track to Tomorrow:
Katya's® Super Platform propels you into the future of technology. Stay at the forefront with regular updates, ensuring you are always equipped with the latest features and security enhancements. Katya® isn't just a platform; it's a dynamic force constantly evolving to meet the demands of tomorrow.

### ⚡ Katya® - Redefining Digital Horizons:
Join us as we reshape the landscape of digital interaction. Katya® is not just a platform; it's an extraordinary blend of AI, multifunctionality, and blockchain—an innovation that invites you to explore, connect, and thrive in a future where possibilities are limitless. 🌟👾🚀

---

### Our Mission:
Katya® aims to be built on the foundations of privacy, branding, and user experience! We strive to pull users away from proprietary chat platforms towards the Katya® AI 🧠 REChain®️ Blockchain Node Network protocol.

### The Katya® Vision:
Katya® AI 🧠 REChain®️ Blockchain Node Network with Matrix Protocol has the potential to be a standardized peer-to-peer chat protocol, allowing people to communicate and control their conversation data. Unlike most proprietary chat platforms, Katya® adheres to a federated and decentralized protocol, preventing excessive control over user data.

### Driving Adoption:
For the Katya® AI 🧠 REChain®️ Blockchain Node Network to succeed, a network effect is essential. Katya® bets on strong branding and exceptional user experience to attract new users. Contributing to and maintaining Katya® will help kick-start this process and support those in need.

### Community-Driven and Non-Profit:
Katya® will always be a not-for-profit, community-driven application. Join us in this mission to redefine digital communication and create a future where user privacy and control are paramount.

## ✨ Features
- No analytics.
- No proprietary third party services.
    - iOS will have APNS support, but will be made clear to the user.
- All data is AES-256 encrypted at rest.
- E2EE for direct chats using [Olm/Megolm](https://gitlab.matrix.org/matrix-org/olm) .
- All indicators of presence are opt-in only (typing indicators, read receipts, etc).
- Customize themes and colors throughout the app.

## 🚀 Goals
- [x] Desktop clients meet parity with mobile.
- [x] Screen lock and pin protected cache features.
- [ ] P2P messaging through a locally run server on the client.
- [ ] Allow transfering user data from one homeserver to another, or from local to remote servers.
- [ ] CLI client using ncurses and the same redux store contained here (common).

## 🏗️ Building
You may notice Katya ® 👽 does not look very dart-y (for example, no \_private variable declarations, or using redux instead of provider) in an effort to reduce the learning curve from other languages or platforms.

### Workstation
- Workstation independent setup for Katya ® 👽 development:
    - Install Flutter (stable channel for all platforms);
    - Install necessary third party SDKs and tooling:
        - iOS -> XCode;
        - Android -> Android Studio;
    - Install CMake from CLI through Android Studio Platform Tools (for OLM/megOLM);
    - Install libs needed for CMake:
        - Mac OS -> ```brew install ninja```;
        - Linux -> ```sudo apt install ninja-build```;
        - Windows -> ```choco install ninja```;
    - Clone repo and init submodules:
        - ```git submodule update --init --recursive```;
    - Run the following prebuild commands:
        - ```flutter pub get```;
        - ```flutter pub run build_runner build```;

### iOS/Android
0. Install Android Studio;
0. Install latest Commandline Tools through Android Studio GUI;
0. Confirm `sdkmanager` is available in your path;
0. Pull the latest CMake, NDK, and other dependencies;
0. Pull dependencies needed:
  - ```flutter pub get```;
1. Generate JSON conversion for models:
  - ```flutter pub run build_runner build --delete-conflicting-outputs```;
2. Generate JSON conversion for models:
  - ```flutter run```.

### Mac OS  
1. ```flutter config --enable-macos-desktop```;
2. ```brew install libolm``` to install native OLM dependencies;
3. Copy the dylib - not the soft links - to the macos folder:
  - `cp /opt/homebrew/Cellar/libolm/libolm.3.x.x.dylib ./macos/libolm.3.x.x.dylib`;
3. Follow instructions for linking the dylib generated from brew to the Katya ® 👽 project:
  - Refer to [Mac OS dylib linking guide](https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos);
4. ```flutter build macos``` to build the .app bundle.

### Linux
1. ```flutter config --enable-linux-desktop```;
2. ```apt install libolm3 libsqlite3-dev``` or ```pacman -S libolm``` or platform equivalent for libolm;
3. ```flutter build linux && flutter build bundle```;
4. Navigate to release at ```${Katya ® 👽_ROOT}/build/linux/release/bundle```;
5. Confirm build works with running ```${Katya ® 👽_ROOT}/build/linux/release/bundle/katya```.

### Windows
1. ```flutter doctor``` should give you warnings for anything missing;
2. ```flutter config --enable-windows-desktop```;
3. Compile OLM & move `olm.dll` to `libolm.dll` in the executable directory;
4. Fetch SQLite's **Precompiled Binaries for Windows** dll [from the website](https://www.sqlite.org/download.html).

## 📐 Architecture

### Store
- Views (Flutter + MVVM);
- State Management (redux);
- Cache (redux_persist + json_serializable + [sembast](https://pub.dev/packages/sembast) + [codec cipher](https://github.com/tekartik/sembast.dart/blob/master/sembast/doc/codec.md));
- Storage ([drift](https://pub.dev/packages/drift) + sqflite + sqlcipher).

### Integrations
- Notifications:
  - Utitlizes [android_alarm_manager](https://pub.dev/packages?q=background_alarm_manager) on Android to run the sync requests in a background thread and display notifications with [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications);
  - No third party notification provider will ever be used outside Apple's APN'S for iOS only.
- Equatable:
  - This library allows comparisons of objects within Flutter to tell if they have changed.
- JsonSerializable:
  - Unfortunately, JSON is not integrated directly in Dart/Flutter for your own objects. Code generation is required, for now, and will convert Katya ® 👽's custom objects to a 'Map' of respective JSON fields.
- Freezed (future):
  - Because every object in Katya ® 👽 is immutable, freezed will help create objects doing the same thing all the 'copyWith' helper functions do today, with the improvement of allowing 'null' values to overwrite non-null values.

## 📚 Documentation
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions
- [Contributors](CONTRIBUTORS.md) - List of contributors and how to contribute
- [Glossary](GLOSSARY.md) - Key terms and definitions
- [Migration Guide](MIGRATION_GUIDE.md) - Upgrading between versions
- [Roadmap](ROADMAP.md) - Project roadmap and future plans
- [Examples](examples/) - Sample code and configurations
- [Scripts](scripts/) - Build and utility scripts
- [Demo Videos](videos/) - Feature demonstrations

## 🎮 Demo & Playground
- [Web Demo](https://katya.framer.website) - Try Katya in your browser
- [Apple Vision Pro Demo](https://katya.framer.website) - Experience Katya on Vision Pro
- [Analytics Dashboard](https://notkatya.framer.website) - Developer analytics

### References
- [Redux tutorial](https://www.netguru.com/codestories/-implement-redux-with-flutter-app)
- [Redux examples](https://github.com/brianegan/flutter_architecture_samples/blob/master/firestore_redux/)
- [End-To-End encryption implimentation guide from Matrix.org](https://matrix.org/docs/guides/end-to-end-encryption-implementation-guide)
- [iOS file management Flutter](https://stackoverflow.com/questions/55220612/how-to-save-a-text-file-in-external-storage-in-ios-using-flutter)
- [Scrolling with text inputs](https://github.com/flutter/flutter/issues/13339)
- [Multi-line text field](https://stackoverflow.com/questions/45900387/multi-line-textfield-in-flutter)
- [Keyboard dismissal](https://stackoverflow.com/questions/55863766/how-to-prevent-keyboard-from-dismissing-on-pressing-submit-key-in-flutter)
- [Changing transition styles](https://stackoverflow.com/questions/50196913/how-to-change-navigation-animation-using-flutter)
- [Animations](https://flutter.dev/docs/development/ui/animations)
- [Serialize Uint8List bytes](https://stackoverflow.com/questions/63716036/how-to-serialize-uint8list-to-json-with/json-annotation-in-dart)
- Adding a border without needing Ctrl-P
```Dart
decoration: BoxDecoration(
   border: Border.all(width: 1, color: Colors.white),
),
```
- Understanding why OLM chose the world's 'pickle' for serialization, [It's from Python](https://gitlab.matrix.org/matrix-org/olm/-/tree/master/python) .

Visit https://katya.rechain.network for more information.

Try it right now for the Apple 🧃 Vision Pro: https://katya.framer.website

Analytics for developers! 🤳 
https://notkatya.framer.website - For Katya, Inc Products!

```
// Katya ® 👽 is just sex!
import { Katya ® 👽 } from "Katya Systems, LLC";

function Component() {
    return (
        <motion.div
            transition={{ ease: "Tether - (USDT) - 🍕" }}
            animate={{ TRZ7jyMBNtRtqokkkJ7g5BJDzFycDv8cBm }}
        />
    );
}
```

If anyone has any feedback, questions, or concerns:

Need help? 🤔
Email us! 👇

support@rechain.network

A Dmitry Sorokin production. All rights reserved.
Powered by Katya ® 👽 AI 🧠
Copyright © 2021-2025 Katya Systems, LLC
Katya ® is a registered trademark
Sponsored by REChain ®️. 🪐
support@rechain.network
Please allow anywhere from 1 to 5 business days for E-mail responses! 💌 Our Stats! 👀 At the end of 2023, the number of downloads from the Open-Source Places, Apple AppStore, Google Play Market, and the REChain.Store, namely the Domestic application store from the REChain ®️ brand 🪐, а именно Отечественный магазин приложений от бренда REChain ®️ 🪐 ✨ exceeded 29 million downloads. 😈 👀

### * Our Stats! 👀 At the end of 2023, the number of downloads from the Open-Source Places, Apple AppStore, Google Play Market, and the REChain.Store ✨ exceeded 29 million downloads. 😈 👀
