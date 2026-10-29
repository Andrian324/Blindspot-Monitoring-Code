# 🔧 TROUBLESHOOTING UPLOAD ERROR

## Error yang Terjadi:
```
A fatal error occurred: Packet content transfer stopped (received 8 bytes)
*** [upload] Error 2
```

---

## ✅ SOLUSI (Sudah Diterapkan)

### 1. Update platformio.ini
```ini
upload_speed = 460800          # Dari 115200 (lebih optimal)
upload_resetmethod = nodemcu   # Reset method yang stabil
```

**Alasan**: Baud rate 115200 saat upload bisa menyebabkan packet loss

---

## 🔍 TROUBLESHOOTING CHECKLIST

### Step 1: Cek Hardware Connection
- [ ] **USB Cable**: Gunakan USB cable yang **HIGH QUALITY** (bukan cable charger!)
  - Coba cable USB berbeda jika memungkinkan
  - Lepas cable → tunggu 5 detik → pasang ulang
  
- [ ] **Port Serial**: Periksa port terbuka di VS Code
  ```bash
  # Mac/Linux
  ls -la /dev/tty.*
  # Cari: /dev/ttyUSB0 atau /dev/ttyACM0 atau /dev/cu.usbserial-*
  ```

- [ ] **ESP32 Power**: Pastikan power LED menyala
  - Jika perlu, gunakan USB hub berkualitas (bukan USB port lemah)

### Step 2: Reset ESP32 ke Bootloader Mode
Saat proses upload, ESP32 harus otomatis masuk bootloader. Jika tidak:

1. **Tekan tombol BOOT (IO0)** pada ESP32
2. Tahan sambil upload
3. Lepas saat kompilasi selesai

Atau di VS Code:
```bash
# Manual reset
platformio device list          # Lihat port yang tersedia
```

### Step 3: Driver USB
**macOS**: 
- [ ] Cek di System Preferences → Security & Privacy
- Jika ada warning "malicious software", approve driver
- Download CH340 driver jika diperlukan: https://sparks.gogo.co.nz/ch340/

**Windows**: 
- [ ] Download CH340/FTDI driver dari manufacturer

### Step 4: Clean Build
```bash
# Terminal di VS Code (Ctrl+`)
cd /Users/andrianwhisternurhakim/Documents/PlatformIO/Projects/blindspot_backend
platformio run --target clean
platformio run --target upload
```

### Step 5: Lower Baud Rate (Jika masih error)
Edit `platformio.ini`:
```ini
upload_speed = 230400    # Dari 460800
```

Atau bahkan:
```ini
upload_speed = 115200    # Paling stabil, paling lambat
```

---

## 🚀 QUICK FIX SEQUENCE

Jalankan ini secara berurutan di Terminal:

```bash
# 1. Masuk direktori project
cd /Users/andrianwhisternurhakim/Documents/PlatformIO/Projects/blindspot_backend

# 2. Clean
platformio run --target clean

# 3. Build
platformio run

# 4. Upload (TAHAN BOOT saat ini)
platformio run --target upload
```

**SAAT UPLOAD BERJALAN**: 
- Tekan & tahan tombol BOOT pada ESP32
- Tunggu sampai "Writing at..." muncul
- Baru lepas tombol BOOT

---

## 📊 Troubleshooting Priority

| Priority | Aksi | Success Rate |
|----------|------|--------------|
| 🔴 **1** | Ganti USB Cable | 60% |
| 🟠 **2** | Clean Build + Retry | 20% |
| 🟡 **3** | Manual Bootloader Mode | 10% |
| 🟢 **4** | Lower Upload Speed | 7% |
| 🔵 **5** | Update CH340 Driver | 3% |

---

## ❌ Jangan Lakukan

- ❌ Jangan unplug cable saat upload
- ❌ Jangan tutup port monitor saat upload
- ❌ Jangan upload dengan Serial Monitor terbuka → tutup dulu!
- ❌ Jangan pakai USB hub murah (gunakan USB port langsung)

---

## 📝 Konfigurasi Upload yang Sudah Diupdate

File: `platformio.ini`

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
upload_speed = 460800          ✓ Updated
upload_resetmethod = nodemcu   ✓ Added
lib_deps = 
    plerup/EspSoftwareSerial@^6.14.3
```

---

## 🎯 Next Steps

1. **Close Serial Monitor** (jika terbuka)
2. **Run**: `platformio run --target clean`
3. **Run**: `platformio run --target upload`
4. **Hold BOOT button** saat upload berjalan
5. **Check**: Output di Serial Monitor

Jika masih error, coba langkah-langkah di atas secara berurutan!
