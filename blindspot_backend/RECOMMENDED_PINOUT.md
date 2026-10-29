# ⚙️ REKOMENDASI PORT YANG BENAR - LD2450 & LD2451

## ESP32 UART Mapping (Tersedia 3 UART)

| UART | Default RX | Default TX | Fleksibel? | Notes |
|------|-----------|-----------|-----------|-------|
| **UART0** | GPIO3 | GPIO1 | ✗ | Reserved untuk Serial Monitor |
| **UART1** | GPIO9 | GPIO10 | ✓ | **BEST UNTUK LD2450** |
| **UART2** | GPIO16 | GPIO17 | ✓ | **BEST UNTUK LD2451** |

---

## ⭐ REKOMENDASI TERBAIK (DIPILIH)

```
┌─────────────────────────────────────────────────────┐
│ LD2450 (RADAR POSISI - Jarak)                       │
├─────────────────────────────────────────────────────┤
│ Sensor RX ──► ESP32 GPIO9 (UART1 RX)               │
│ Sensor TX ──► ESP32 GPIO10 (UART1 TX)              │
│ GND ────────► ESP32 GND                             │
│ 5V ─────────► ESP32 5V (via USB/Power)             │
│ Baudrate: 256000 bps                                │
│ HardwareSerial: Serial1 atau UART1                  │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ LD2451 (RADAR KECEPATAN - Speed)                    │
├─────────────────────────────────────────────────────┤
│ Sensor RX ──► ESP32 GPIO16 (UART2 RX)              │
│ Sensor TX ──► ESP32 GPIO17 (UART2 TX)              │
│ GND ────────► ESP32 GND (SHARED)                    │
│ 5V ─────────► ESP32 5V (SHARED)                     │
│ Baudrate: 256000 bps                                │
│ HardwareSerial: Serial2 atau UART2                  │
└─────────────────────────────────────────────────────┘
```

---

## 📝 KODE YANG BENAR (UPDATE)

```cpp
// ===== SETTING SERIAL RADAR =====
HardwareSerial radarPos(1);    // UART1 - LD2450 (Posisi)
HardwareSerial radarSpd(2);    // UART2 - LD2451 (Kecepatan)

void setup() {
  Serial.begin(115200);         // UART0 - Monitor serial
  
  // LD2450 on UART1
  radarPos.begin(256000, SERIAL_8N1, 9, 10);
  
  // LD2451 on UART2
  radarSpd.begin(256000, SERIAL_8N1, 16, 17);
  
  // ... rest of setup
}
```

---

## ❌ JANGAN GUNAKAN (Konfigurasi Sebelumnya)

```cpp
// ❌ SALAH - Port 18/19 tidak ada di ESP32 DevKit standard
radarPos.begin(256000, SERIAL_8N1, 18, 19);  // TIDAK SUPPORT!

// ❌ SALAH - Port 26/27 tidak semua ESP32 support
radarSpd.begin(256000, SERIAL_8N1, 26, 27);  // TIDAK KONSISTEN!
```

---

## 🔍 PENJELASAN MASALAH

### Mengapa output tidak sesuai skenario sebelumnya?

1. **Port 18, 19, 26, 27** → Tidak standar/tidak support di semua ESP32 model
   - Sensor mungkin tidak baca data sama sekali
   - Parser state machine tidak pernah match frame

2. **Baudrate 256000 vs 115200** → Timing issue
   - Jika UART tidak benar-benar configured, baudrate tidak sync
   - Data corruption terjadi

3. **HardwareSerial(2) vs HardwareSerial(1)** → Mismapping
   - Saat UART port tidak match dengan hardware, data tidak diterima

---

## ✅ CHECKING KONEKSI

### Hardware Checklist:
- [ ] Sensor RX terhubung ke ESP32 GPIO9
- [ ] Sensor TX terhubung ke ESP32 GPIO10
- [ ] Sensor RX terhubung ke ESP32 GPIO16
- [ ] Sensor TX terhubung ke ESP32 GPIO17
- [ ] GND SEMUA sensor & ESP32 connected
- [ ] Power 5V ke sensor sudah stabil (jangan dari GPIO!)

### Software Checklist:
- [ ] Update baudrate di `radarPos.begin()` & `radarSpd.begin()`
- [ ] Pastikan pin RX/TX sesuai dengan tabel di atas
- [ ] Recompile & upload ulang

---

## 📊 EXPECTED OUTPUT SETELAH FIX

```
╔════════════════════════════════════════════╗
║ 📊 DUAL RADAR FUSION STATUS               ║
╠════════════════════════════════════════════╣
║ LD2450 [✓] Jarak: 1.23m | Pos.X: -150mm   ║
║ LD2451 [✓] Jarak: 0.85m | Speed: 1500     ║
╠════════════════════════════════════════════╣
║ 🚨 HAZARD LEVELS (0=Aman, 1=Waspada, 2=Bahaya)
║    KIRI: 2 | KANAN: 0                    ║
║    Kalman State: P=5.20, x_est=850mm     ║
╚════════════════════════════════════════════╝
```

---

## 🚀 QUICK FIX

Ganti di `setup()`:

```cpp
// SEBELUM (SALAH):
radarPos.begin(256000, SERIAL_8N1, 18, 19);
radarSpd.begin(256000, SERIAL_8N1, 26, 27);

// SESUDAH (BENAR):
radarPos.begin(256000, SERIAL_8N1, 9, 10);    // UART1
radarSpd.begin(256000, SERIAL_8N1, 16, 17);   // UART2
```

Ganti deklarasi:

```cpp
// SEBELUM:
HardwareSerial radarPos(2);
HardwareSerial radarSpd(1);

// SESUDAH:
HardwareSerial radarPos(1);    // UART1
HardwareSerial radarSpd(2);    // UART2
```

---

## 📌 CATATAN PENTING

- **GPIO 6-11** = Reserved untuk SPI Flash (jangan pakai!)
- **GPIO 34-39** = Input only (tidak ada output)
- **GPIO 0, 2, 4, 5, 12, 13, 14, 15** = Aman untuk digunakan
- **GPIO 9, 10, 16, 17** = Optimal untuk UART1 & UART2

Rekomendasi sudah disesuaikan dengan datasheet LD2450/LD2451 standard!
