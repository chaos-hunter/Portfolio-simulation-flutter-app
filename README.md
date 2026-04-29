# ProInvestor Stock Simulation

ProInvestor is a cross-platform real-time stock simulation and wealth projection application. Originally developed as a web app, it has been completely rebuilt using **Flutter** to provide a seamless, native experience across Windows laptops and Android/iOS smartphones. 

It allows users to track live stock prices, simulate paper trading with a virtual wallet, and project future investment growth over time.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)

## 🚀 Features

### 1. Real-Time Stock Dashboard
- Search for any stock symbol (e.g., AAPL, NVDA, TSLA).
- View live real-time prices using direct connections to Yahoo Finance APIs.

### 2. Paper Trading Simulator
- **Virtual Wallet**: Start with a virtual balance and deposit funds as needed.
- **Buy & Sell**: Execute buy orders and partial sell orders instantly.
- **Portfolio Tracking**: Track your current holdings and total asset value.
- **Persistence**: Your simulation data, cash, and portfolio are securely saved directly to your device storage (so it persists even after closing the app).

### 3. Investment Projection Engine
- **Growth Calculator**: Visualize how your investment could compound and grow over time.
- **Smart Auto-Fill**: Automatically imports your current portfolio holding value as the starting principal.
- **Interactive Charts**: Interactive graphical projections rendered natively.

## 🛠️ Technology Stack
- **Framework**: [Flutter](https://flutter.dev/) (Cross-Platform Mobile & Desktop)
- **State Management**: `provider` + `shared_preferences`
- **Visualization**: `fl_chart` for compound growth line graphs
- **Data Fetching**: `yahoo_finance_data_reader`
- **Design System**: Custom dark glassmorphism theme with vibrant blue accents

## 💻 Running Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Running in Development
1. Clone the repository and navigate into it:
   ```bash
   git clone <repository-url>
   cd proinvestor-sim
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on your local machine (Desktop or connected Mobile device):
   ```bash
   flutter run
   ```

---

## 📦 Compiling the Application

Because this app is built with Flutter, you can compile it into standalone, production-ready applications for your devices.

### Compile for Windows (.exe)
To create a standalone application for Windows computers:
```bash
flutter build windows
```
*Your compiled executable will be saved in `build\windows\runner\Release\`.* You can compress this folder into a `.zip` and share it with other Windows users.

### Compile for Android (.apk)
To create an installation file for Android smartphones:
```bash
flutter build apk
```
*Your compiled APK will be saved in `build\app\outputs\flutter-apk\app-release.apk`.* You can transfer this file to your phone and tap it to install the app.

### Compile for iOS
*(Requires a macOS computer with Xcode installed)*
```bash
flutter build ios
```
Open the generated `ios/Runner.xcworkspace` in Xcode to sign and deploy the application to your iPhone.

## 📁 Project Structure
- `lib/main.dart`: App entry point and Provider initialization.
- `lib/screens/`: Main page layouts (e.g., Dashboard).
- `lib/widgets/`: Modular, reusable UI components (StockCard, PortfolioSummary, etc.).
- `lib/providers/`: State management logic for the wallet and portfolio interactions.
- `lib/theme.dart`: Global styling, color palettes, and glassmorphism definitions.

## 🤝 Contributing
Feel free to open issues or submit pull requests if you have ideas for improvements or new features!
