[![Codemagic build status](https://api.codemagic.io/apps/6934eea0ca9bdb997fbfb5d0/6934eea0ca9bdb997fbfb5cf/status_badge.svg)](https://codemagic.io/app/6934eea0ca9bdb997fbfb5d0/6934eea0ca9bdb997fbfb5cf/latest_build)

# Fresh Track 🥗

A modern Flutter application for tracking food items in your fridge, managing expiration dates, and reducing food waste. Fresh Track helps you stay organized, save money, and make better use of your groceries.

## 📱 Features

### Core Functionality
- **Food Inventory Management**: Add, edit, and remove food items with detailed information
- **Expiration Tracking**: Visual color-coded status indicators for expiration dates
  - 🔴 Red: Expired items
  - 🟠 Orange: Expiring soon (within 3 days)
  - 🟢 Green: Fresh items
- **Smart Search**: Quickly find items by name
- **Category Filtering**: Filter items by category (All, Produce, Dairy, Meat, Expiring)
- **Item Details**: View comprehensive information including:
  - Purchase date
  - Expiration date
  - Quantity and unit
  - Category and subcategory
  - Custom notes
  - Freshness progress indicator

### User Experience
- **Welcome Screen**: Onboarding experience for first-time users
- **Demo Data**: Import sample data to explore the app
- **Modern UI**: Clean, intuitive Material Design 3 interface
- **Cross-Platform**: Works on iOS, Android, Web, macOS, Linux, and Windows

## 🎯 Use Cases

- **Reduce Food Waste**: Never forget about items in your fridge
- **Save Money**: Plan meals based on what you have before it expires
- **Stay Organized**: Keep track of your entire food inventory in one place
- **Smart Shopping**: Know what you have before going to the store

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- For mobile development: Android Studio / Xcode
- For web development: Chrome browser

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/keltonpsilva/fresh_track.git
   cd fresh_track
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

   Or run on a specific platform:
   ```bash
   flutter run -d chrome          # Web
   flutter run -d ios             # iOS Simulator
   flutter run -d android         # Android Emulator
   ```

## 📁 Project Structure

```
lib/
├── features/
│   ├── add-item/          # Add new food items
│   ├── dashboard/         # Main screen with item list
│   ├── edit-item/         # Edit existing items
│   ├── item-details/      # Detailed item view
│   └── welcome/           # Onboarding screen
├── shared/
│   ├── models/            # Data models (FoodItem)
│   └── services/          # Business logic and data services
└── main.dart              # App entry point
```

## 🛠️ Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **SQLite (sqflite)**: Local database for data persistence
- **Material Design 3**: Modern UI components
- **Shared Preferences**: App settings storage

## 📊 Data Model

Each food item includes:
- Name
- Category (Produce, Dairy, Meat, Beverages, Snacks, Frozen, Other)
- Subcategory
- Purchase date
- Expiration date
- Quantity and unit
- Custom notes
- Visual status indicators (color and icon)

## 🎨 Key Screens

### Dashboard
- Main view showing all food items
- Search bar for quick filtering
- Category filter chips
- Color-coded item cards with expiration status
- Floating action button to add new items

### Add Item
- Form to add new food items
- Category selection
- Date pickers for purchase and expiration dates
- Quantity selector
- Optional notes field

### Item Details
- Comprehensive item information
- Freshness progress bar
- Edit and delete actions
- Mark as consumed functionality

### Welcome Screen
- Onboarding slides explaining app features
- Option to import demo data
- Smooth navigation to main app

## 🔧 Configuration

The app uses SQLite for local storage. On first launch, it can import demo data from `assets/food_items.db` to help you explore the features.

## 📝 Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is private and not intended for public distribution.

## 👤 Author

**Kelton Silva**
- GitHub: [@keltonpsilva](https://github.com/keltonpsilva)

---

Made with ❤️ using Flutter
