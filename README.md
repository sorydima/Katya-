<br>

<p align='center'>
    <img src="https://katya.wtf/_next/static/images/katyaplatform.png"/>
</p>

<br>

## 🤔 Why

**Katya ® 👽 aims to be built on the foundations of privacy, branding, and user experience!** 
<br>In an effort to pull others away from proprietary chat platforms to the Katya ® 👽 AI 🧠 REChain 🪐 Blockchain Node Network protocol.

Katya ® 👽 AI 🧠 REChain 🪐 Blockchain Node Network with Matrix Protocol has the potential to be a standardized peer-to-peer chat protocol, [and in a way already is,](https://matrix.org/blog/2020/06/02/introducing-p-2-p-matrix) that allows people to communicate and control their conversation data. Email has been standardized in this way for a long time. For example, someone using Outlook can still email someone using Gmail. Most popular proprietary chat platforms do not adhere to a federated or decentralized protocol, and as a result have too much control over users data.

If the goal for the Katya ® 👽 AI 🧠 REChain 🪐 Blockchain Node Network is adoption, a network effect is required for this paradigm shift. Katya ® 👽 makes the bet that the best way to attract new users is through strong branding and user experience. I hope that contributing and maintaining Katya ® 👽 will help kick start this process and help those in need. 

Katya ® 👽 will always be a not for profit, community driven application.

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
- [Serialize Uint8List bytes](https://stackoverflow.com/questions/63716036/how-to-serialize-uint8list-to-json-with-json-annotation-in-dart)
- Adding a border without needing Ctrl-P
```Dart
decoration: BoxDecoration(
   border: Border.all(width: 1, color: Colors.white),
),
```
- Understanding why OLM chose the world's 'pickle' for serialization, [It's from Python](https://gitlab.matrix.org/matrix-org/olm/-/tree/master/python) .

If anyone has any feedback, questions, or concerns:

Need help? 🤔
Email us! 👇

* hr@rechain.email
* p2p@rechain.email
* pr@rechain.email
* sorydima@rechain.email
* support@rechain.email

A Dmitry Sorokin production. All rights reserved.
Powered by Katya AI. 👽
Copyright © 2021-2023 Katya Systems, LLC
Katya ® is a registered trademark
Sponsored by REChain. 🪐
hr@rechain.email
p2p@rechain.email
pr@rechain.email
sorydima@rechain.email
support@rechain.email
Please allow anywhere from 1 to 5 business days for E-mail responses! 💌

### * At the end of 2021, the number of downloads in the AppStore, Mac AppStore, Google Play Market, and REChain.Store exceeded 13 million downloads. 😈
