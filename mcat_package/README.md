# 🧠 mCAT – Mobile Cognitive Assessment Tool

**mCAT** is a smartphone-based battery for cognitive assessment, designed to evaluate cognitive abilities and mental health through a series of short interactive tasks.  
This Flutter project follows a modular architecture inspired by the [CARP Research Platform](https://github.com/cph-cachet/carp.sensing-flutter), where each cognitive task (Face Task, Word Task, etc.) is implemented as a reusable Flutter package.

---

## 🚀 Features

- 📱 Cross-platform (Android & iOS) Flutter application
- 🧩 Modular architecture using a `package + example` structure
- 🧠 Cognitive tasks implemented as independent feature modules:
  - Face Task (emotion recognition)
  - Word Task (verbal memory – in progress)
  - Letter Number Task
  - Organizational Task
  - Word Recall Task
  - Coding Task
- 🎨 Consistent design system with reusable widgets (header bar, step indicator, buttons)
- 🔊 Audio and microphone integration (for tasks requiring speech)
- ☁️ Firebase-ready (Firestore for saving task data, Auth for anonymous users)
- 🧰 Inspired by **CARP**'s structure and best practices for research-driven apps

---

## 🧱 Project Structure

mcat/
├─ packages/
│ └─ mcat_package/
│ ├─ lib/
│ │ ├─ mcat_package.dart # Library entry point
│ │ └─ src/
│ │ ├─ domain/ # Core models and entities
│ │ │ └─ models/
│ │ │ ├─ mcat_task.dart
│ │ │ └─ emotion.dart
│ │ ├─ ui/ # Screens and shared widgets
│ │ │ ├─ screens/
│ │ │ │ ├─ intro_screen.dart
│ │ │ │ ├─ face_task/
│ │ │ │ │ ├─ face_task_intro_screen.dart
│ │ │ │ │ ├─ face_task_practice_screen.dart
│ │ │ │ │ ├─ face_task_assessment_screen.dart
│ │ │ │ │ └─ face_task_result_screen.dart
│ │ │ └─ widgets/
│ │ │ ├─ primary_button.dart
│ │ │ ├─ header_bar.dart
│ │ │ └─ step_indicator.dart
│ │ └─ utils/
│ └─ pubspec.yaml
└─ example/
├─ lib/
│ ├─ main.dart
│ ├─ routes.dart
│ └─ firebase_options.dart (after FlutterFire setup)
├─ assets/
│ └─ images/
│ ├─ carp_logo.png
│ ├─ logo.png
│ ├─ face_1.png
│ └─ face_2.png
└─ pubspec.yaml

yaml
Copy code

---

## 🧩 Architecture Overview

The **mCAT** app uses a *package-based modular design*:
- `mcat_package` → reusable library that defines all UI components, domain models, and cognitive task flows.
- `example` → the actual app that imports and uses the package.

This separation ensures easy testing, reusability, and potential publication of `mcat_package` as a standalone research SDK.

---

## ⚙️ Installation & Setup

### 1️⃣ Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/mcat.git
cd mcat
2️⃣ Install dependencies
bash
Copy code
flutter pub get
cd packages/mcat_package && flutter pub get && cd ../../example && flutter pub get
3️⃣ Add assets in example/pubspec.yaml
yaml
Copy code
flutter:
  uses-material-design: true
  assets:
    - assets/images/carp_logo.png
    - assets/images/logo.png
    - assets/images/face_1.png
    - assets/images/face_2.png
4️⃣ (Optional) Configure Firebase
Install the FlutterFire CLI if not already done:

bash
Copy code
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
This will generate firebase_options.dart inside the example/lib/ folder.

5️⃣ Run the app
bash
Copy code
flutter run
🎮 Current Task Flow
Screen	Description
Intro Screen	Shows mCAT logo and transitions to instructions
Instructions Screen	Displays pre-test preparation info
Face Task	Emotion recognition practice and assessment rounds
Results Screen	Shows score and progress
(More tasks to come)	Word, Recall, Organizational, Coding, etc.

🧰 Shared Widgets
Widget	Description
PrimaryButton	Styled blue action button used across all screens
HeaderBar	Top AppBar with CARP logo, title, and optional step indicator
StepIndicator	Circular numbered progress bubbles
McatTask	Base model for all cognitive tasks

🧪 Development Notes
Each cognitive task follows the same pattern:
Intro → Practice → Assessment → Result

Use AnimatedSwitcher and AnimationController for transitions.

Use SpeechToText, PermissionHandler, and AudioPlayers for future microphone/audio tasks.

Firebase data model (to be added):

json
Copy code
{
  "userId": "anon123",
  "taskId": "face_task",
  "score": 8,
  "total": 10,
  "timestamp": "2025-10-29T12:00:00Z"
}
🧑‍💻 Contributing
Fork the repo and create a feature branch.

Follow the existing architecture and naming conventions.

Submit a pull request with a clear description of your feature or fix.

📜 License
This project is part of the DTU MSc Thesis on cognitive mobile assessment.
You are free to reuse the architecture and components for research and educational purposes with attribution.

scss
Copy code
© 2025 Technical University of Denmark (DTU)
Developed by [Mohammad Lummim Sarker]
Supervisors: [Jakob E. Bardram]
💬 Acknowledgments
CARP Research Platform for architectural inspiration

FlutterFire for Firebase integration

Flutter Team for the open-source SDK

🧩 Next Steps (Roadmap)
 Implement Word Task (audio + speech recognition)

 Add Firebase Cloud Firestore result sync

 Implement dark mode support

 Add unit tests for task logic

 Publish mcat_package to a private pub registry or GitHub Packages
