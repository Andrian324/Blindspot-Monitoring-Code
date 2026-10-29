# Panduan Instalasi Rider Guard

## Perubahan Terbaru: Blindspot Sekarang Cross-Platform! 🎉

Blindspot telah diperbarui untuk menggunakan **Bluetooth Low Energy (BLE)** alih-alih Bluetooth Classic. Ini berarti:

✅ **Blindspot sekarang bekerja di semua platform**: Android, iOS, dan macOS
✅ **Sama seperti Fatigue**: Menggunakan teknologi BLE yang modern dan hemat energi
✅ **Lebih baik**: Lebih responsif dan stabil di semua perangkat

⚠️ **PENTING**: Pastikan perangkat hardware Blindspot Anda mendukung **BLE (Bluetooth Low Energy)**. Jika hanya mendukung Bluetooth Classic lama, Anda perlu update firmware perangkat atau ganti hardware.

---

## Instalasi di Android

### Prerequisites
- Android Studio atau Flutter CLI terinstall
- Android SDK minimal API level 21 (Android 5.0)
- USB debugging diaktifkan di perangkat Android

### Cara 1: Build & Install via USB (Recommended)
1. **Hubungkan perangkat Android** ke komputer via USB cable
2. **Pastikan USB debugging aktif**:
   - Buka Settings > About Phone
   - Tap "Build Number" 7 kali hingga "Developer Options" muncul
   - Buka Developer Options > Enable "USB Debugging"

3. **Verify koneksi device**:
   ```bash
   flutter devices
   ```
   Perangkat Anda harusnya muncul di list

4. **Install aplikasi**:
   ```bash
   flutter run
   ```
   Atau untuk development dengan hot reload (setelah build pertama):
   ```bash
   flutter run  # akan otomatis hot reload saat code berubah
   ```

### Cara 2: Build APK (untuk distribute/backup)
1. **Build APK**:
   ```bash
   flutter build apk --release
   ```
   File APK akan tersimpan di:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Transfer ke perangkat Android**:
   - Copy file APK ke perangkat
   - Tap file untuk install
   - Atau gunakan Android Studio Device File Explorer

3. **Alternative: Direct Install**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### Cara 3: Debug APK
```bash
flutter build apk --debug
flutter install  # atau adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## Instalasi di iOS

### Prerequisites
- Mac dengan Xcode terinstall
- iOS 12 atau lebih tinggi
- Perangkat iPhone/iPad atau iOS Simulator

### Cara 1: Run di iOS Simulator
```bash
flutter run -d 'iPhone' # atau copy device name dari flutter devices
```

### Cara 2: Run di Physical Device
1. **Setup Certificate** (hanya pertama kali):
   ```bash
   open ios/Runner.xcworkspace
   ```
   Di Xcode:
   - Select "Runner" di sidebar
   - Pilih tab "Signing & Capabilities"
   - Pilih Team Anda di dropdown

2. **Hubungkan iPhone** ke Mac via USB

3. **Verify device koneksi**:
   ```bash
   flutter devices
   ```

4. **Install & Run**:
   ```bash
   flutter run
   ```

### Cara 3: Build IPA untuk Distribution
```bash
flutter build ipa --release
```
Output: `build/ios/ipa/Runner.ipa`

---

## Instalasi di macOS

```bash
flutter run -d macos
```

---

## Cara Menggunakan Blindspot di Aplikasi

### 1. Pastikan Perangkat Bluetooth Disiapkan
- Pastikan perangkat Blindspot **dinyalakan**
- Pastikan perangkat dalam **jangkauan Bluetooth** (biasanya ~10 meter)
- Pastikan perangkat mendukung **BLE (Bluetooth Low Energy)**

### 2. Buka Aplikasi Rider Guard
1. Tap menu "Blindspot Monitor"
2. Tap tombol "Hubungkan" (Connect button)
3. Aplikasi akan **scan** perangkat BLE yang tersedia

### 3. Pilih Perangkat
- Pilih perangkat Blindspot dari list
- Aplikasi akan **otomatis terhubung**
- Status berubah menjadi "Connected" jika berhasil

### 4. Monitor Blind Spot
- Lihat visualisasi radar live
- Data akan tersimpan di Firebase
- Alert ditampilkan untuk hazard detection

---

## Troubleshooting

### "Tidak ada perangkat ditemukan"
- **Solusi**: Pastikan perangkat dinyalakan dan dalam jangkauan
- Tap tombol "Refresh" di sheet untuk scan ulang
- Periksa apakah perangkat support BLE

### "Tidak dapat terhubung"
- **Solusi**: 
  - Matikan perangkat Blindspot, tunggu 3 detik, nyalakan lagi
  - Bersihkan cache aplikasi: Settings > Apps > Rider Guard > Clear Cache
  - Restart aplikasi

### "Bluetooth permission denied"
- **Android**: Settings > Apps > Rider Guard > Permissions > Enable Bluetooth & Location
- **iOS**: Settings > Rider Guard > Bluetooth > Allow

### "Build APK error: Unresolved reference: ext"
- Error pada gradle.kts syntax
- **Solusi sementara**: Gunakan `flutter run` untuk development
- Untuk APK production, hubungi tim developer

### "NDK did not have a source.properties file"
- NDK corrupted atau incomplete download
- **Solusi**: Delete NDK dan biarkan Gradle re-download
  ```bash
  rm -rf ~/Library/Android/sdk/ndk/28.2.13676358
  flutter run  # akan auto-download NDK yang benar
  ```

---

## UUID Configuration untuk Custom Hardware

Jika Anda menggunakan perangkat Blindspot custom, update UUIDs di:
```dart
// File: lib/configure/services/bluetooth_service.dart
// Class: BlindspotBleService

static const String _serviceUuid = 'YOUR_SERVICE_UUID';
static const String _charUuid = 'YOUR_CHARACTERISTIC_UUID';
```

Ganti dengan UUID perangkat Anda (dapat ditemukan di dokumentasi hardware).

---

## Fitur Blindspot yang Sekarang Tersedia di Semua Platform

- 📱 **iOS**: ✅ Fully supported
- 🍎 **macOS**: ✅ Fully supported  
- 🤖 **Android**: ✅ Fully supported

---

## Questions?
Hubungi tim developer untuk bantuan setup atau troubleshooting lebih lanjut.
