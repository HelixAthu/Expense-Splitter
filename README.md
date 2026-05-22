<h1 align="center">💸 Expense Splitter</h1>

<p align="center">
  A modern Flutter app to track shared expenses and calculate who owes whom.<br>
  Perfect for trips, dinners, roommates, and group spending.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" />
  <img src="https://img.shields.io/badge/Material%203-UI-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/SharedPreferences-Local%20Storage-green?style=for-the-badge" />
</p>

---

<h2>✨ Features</h2>

<ul>
  <li>➕ Add expenses with amount, payer, participants, and description</li>
  <li>📋 View all expenses in a clean card-based interface</li>
  <li>⚖️ Automatically split costs among participants</li>
  <li>💰 Live balance calculations</li>
  <li>🔄 Suggested settlements to simplify payments</li>
  <li>🌙 Dark and Light theme support</li>
  <li>💾 Persistent local storage using SharedPreferences</li>
  <li>⚙️ Settings screen for theme switching and clearing data</li>
</ul>

---

<h2>🖼️ App Screens</h2>

<ul>
  <li>
    <b>Expenses Screen</b>
    <ul>
      <li>Add and manage expenses</li>
      <li>View participant chips and split details</li>
    </ul>
  </li>

  <li>
    <b>Summary Screen</b>
    <ul>
      <li>View balances for all participants</li>
      <li>See settlement suggestions instantly</li>
    </ul>
  </li>

  <li>
    <b>Settings Screen</b>
    <ul>
      <li>Toggle dark/light mode</li>
      <li>Clear stored expense data</li>
    </ul>
  </li>
</ul>

---

<h2>🚀 Getting Started</h2>

<h3>Prerequisites</h3>

<ul>
  <li>Flutter SDK</li>
  <li>Dart SDK</li>
  <li>Android Studio or VS Code</li>
  <li>Android/iOS Emulator or Physical Device</li>
</ul>

<h3>Installation</h3>

```bash
git clone https://github.com/your-username/expense-splitter.git
cd expense-splitter
flutter pub get
flutter run
````

---

<h2>📂 Project Structure</h2>

```text
lib/
│
├── main.dart
│
├── models/
│   └── expense.dart
│
├── views/
│   ├── expenses_view.dart
│   ├── summary_view.dart
│   └── settings_view.dart
│
└── widgets/
    ├── add_expense_sheet.dart
    └── expense_card.dart
```

---

<h2>🧠 Example Flow</h2>

<ol>
  <li>Alice pays <b>$90</b> for groceries.</li>
  <li>Participants: Alice, Bob, Charlie.</li>
  <li>The app splits the amount equally.</li>
</ol>

<h3>Split Calculation</h3>

<ul>
  <li>Total Expense: <b>$90</b></li>
  <li>Each Person Pays: <b>$30</b></li>
</ul>

<h3>Balances</h3>

<ul>
  <li>🟢 Alice: +$60</li>
  <li>🔴 Bob: -$30</li>
  <li>🔴 Charlie: -$30</li>
</ul>

<h3>Suggested Settlements</h3>

<ul>
  <li>Bob → Alice : <b>$30</b></li>
  <li>Charlie → Alice : <b>$30</b></li>
</ul>

---

<h2>🎨 Tech Stack</h2>

<ul>
  <li><b>Flutter</b> for cross-platform app development</li>
  <li><b>Dart</b> programming language</li>
  <li><b>Material 3</b> modern UI design</li>
  <li><b>SharedPreferences</b> for persistent local storage</li>
</ul>

---

<h2 align="center">🙌 Built with Flutter</h2>

<p align="center">
  Designed to make shared expense tracking simple, clean, and easy to manage.
</p>
```
