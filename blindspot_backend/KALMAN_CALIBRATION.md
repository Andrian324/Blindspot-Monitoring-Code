# Kalman Filter Calibration Guide

## Overview
Sistem sekarang menggunakan **Kalman Filter** untuk 3 parameter:
- **X Position** (posX) - Horizontal position
- **Y Distance** (distance) - Vertical distance
- **Angle** - Calculated angle

Kalman Filter lebih stabil dan mudah dikalibrasi dibanding EMA.

---

## Kalman Filter Parameters

### Struktur:
```cpp
struct KalmanFilter {
    float state;            // Nilai yang diestimasi
    float covariance;       // Error estimasi
    float processNoise;     // Q - kepercayaan ke model
    float measurementNoise; // R - kepercayaan ke sensor
};
```

### Current Settings:
```cpp
kalmanX = {0, 1.0, 0.01, 0.5}       // Q=0.01, R=0.5
kalmanY = {0, 1.0, 0.005, 0.3}      // Q=0.005, R=0.3
kalmanAngle = {0, 1.0, 0.002, 0.1}  // Q=0.002, R=0.1
```

---

## How to Calibrate

### Understanding Parameters:
- **processNoise (Q)**: Seberapa banyak model bisa berubah
  - Rendah (0.001): Asumsi data sangat stabil, lambat adapt
  - Tinggi (0.1): Asumsi data sering berubah, cepat adapt (tapi noisy)
  
- **measurementNoise (R)**: Seberapa banyak sensor bisa berubah
  - Rendah (0.1): Sensor sangat dipercaya, output responsif
  - Tinggi (1.0): Sensor tidak dipercaya, output smooth

### Tuning Steps:

#### **1. Jika hasil TERLALU SMOOTH (lambat response):**
   Naikkan `processNoise` atau turunkan `measurementNoise`
   
   ```cpp
   // Lebih responsif
   kalmanX = {0, 1.0, 0.02, 0.3};      // Q↑, R↓
   kalmanY = {0, 1.0, 0.01, 0.2};
   kalmanAngle = {0, 1.0, 0.005, 0.05};
   ```

#### **2. Jika hasil TERLALU NOISY (jitter):**
   Turunkan `processNoise` atau naikkan `measurementNoise`
   
   ```cpp
   // Lebih smooth
   kalmanX = {0, 1.0, 0.005, 0.8};     // Q↓, R↑
   kalmanY = {0, 1.0, 0.002, 0.5};
   kalmanAngle = {0, 1.0, 0.001, 0.2};
   ```

#### **3. Jika HANYA 1 PARAMETER noise (misal X noisy tapi Y OK):**
   Tuning hanya parameter tersebut:
   
   ```cpp
   // X lebih smooth
   kalmanX = {0, 1.0, 0.005, 0.8};
   // Y tetap
   kalmanY = {0, 1.0, 0.005, 0.3};
   ```

---

## Tuning Strategy

### Test 1: Statis (Kendaraan Diam, Objek 1m dari tengah)
```
Serial Monitor Output:
  Jarak: 1.00m | PosX: 100mm | Angle: 5.7°
  
Cek: Apakah nilai berfluktuasi?
  - Jika ±1mm, ±0.1° → Filter OK
  - Jika ±5mm, ±0.5° → Naikkan R (smooth)
```

### Test 2: Slow Movement (Kendaraan statik, Objek gerak lambat)
```
Gerakkan objek perlahan dari 0.5m menjadi 2.0m:

Cek response time:
  - Jika terlalu lambat (>500ms) → Naikkan Q
  - Jika terlalu cepat (<100ms) → Turunkan Q
```

### Test 3: Fast Movement (Simulasi left/right)
```
Gerakkan objek cepat dari -15° ke +15°:

Cek:
  - Tidak ada lag → Q bagus
  - Smooth tanpa flipping → R bagus
```

---

## Quick Reference: Tuning Table

| Problem | X-Position | Y-Distance | Angle |
|---------|-----------|-----------|-------|
| Too smooth (slow) | Q↑ 0.02 | Q↑ 0.01 | Q↑ 0.005 |
| Too noisy (jitter) | R↑ 0.8 | R↑ 0.5 | R↑ 0.2 |
| Left/Right unstable | R↑ 1.0 | - | R↑ 0.3 |
| Center flipping | R↑ 0.7 | Q↓ 0.003 | Q↓ 0.001 |

---

## Where to Change

File: `src/main.cpp` (Lines 28-30)

```cpp
KalmanFilter kalmanX = {0, 1.0, 0.01, 0.5};      // Line 28
KalmanFilter kalmanY = {0, 1.0, 0.005, 0.3};     // Line 29
KalmanFilter kalmanAngle = {0, 1.0, 0.002, 0.1}; // Line 30
```

Format: `{initialState, initialCovariance, processNoise, measurementNoise}`

---

## Example Calibrations

### For Smooth/Stable System (Default):
```cpp
kalmanX = {0, 1.0, 0.01, 0.5};
kalmanY = {0, 1.0, 0.005, 0.3};
kalmanAngle = {0, 1.0, 0.002, 0.1};
```

### For Responsive/Fast System:
```cpp
kalmanX = {0, 1.0, 0.03, 0.2};
kalmanY = {0, 1.0, 0.015, 0.15};
kalmanAngle = {0, 1.0, 0.008, 0.05};
```

### For Ultra-Stable System:
```cpp
kalmanX = {0, 1.0, 0.005, 1.0};
kalmanY = {0, 1.0, 0.002, 0.8};
kalmanAngle = {0, 1.0, 0.001, 0.3};
```

---

## Testing Checklist

- [ ] Upload firmware dengan Kalman Filter
- [ ] Test statis: Cek fluktuasi posX (target ±1mm)
- [ ] Test slow movement: Cek response time
- [ ] Test left/right detection: Cek stability
- [ ] Adjust Q/R values berdasarkan hasil
- [ ] Retest sampai satisfied

---

## Notes

1. Kalman Filter lebih akurat dibanding EMA karena mempertimbangkan uncertainty
2. Setiap sensor berbeda → kemungkinan perlu fine-tuning
3. Perubahan Q/R hanya perlu di line 28-30, compile ulang
4. Nilai processNoise (Q) biasanya lebih kecil dari measurementNoise (R)

