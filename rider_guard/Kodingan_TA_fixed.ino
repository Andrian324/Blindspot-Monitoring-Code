#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h> // WAJIB: Untuk menangani descriptor GATT

// --- KONFIGURASI UUID BLE ---
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// --- PIN HARDWARE ---
const int fsr_pins[] = {32, 34, 35, 33};
const int BUZZER_PIN = 12;

// --- VARIABEL LOGIKA ---
const float threshold_presence = 3.0;
unsigned long waktu_mulai = 0;
bool status_kehadiran = false;
bool level1_done = false, level2_done = false, level3_done = false;

// --- VARIABEL DETEKSI GELISAH ---
float b_lama[4] = {0, 0, 0, 0};
int counter_gelisah = 0;
unsigned long waktu_cek_gelisah = 0;

// --- VARIABEL BLUETOOTH ---
unsigned long waktu_last_ble = 0;
BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

// --- CALLBACK KONEKSI BLUETOOTH ---
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("\n>>> App Connected!");
    };
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("\n>>> App Disconnected! Mencari ulang...");
      // Memulai ulang advertising agar bisa diconnect kembali
      pServer->getAdvertising()->start();
    }
};

void triggerBuzzer(int repeat, int duration) {
  for(int i=0; i<repeat; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(duration);
    digitalWrite(BUZZER_PIN, LOW);
    if (repeat > 1) delay(150);
  }
}

void setup() {
  Serial.begin(115200);
  for(int i=0; i<4; i++) pinMode(fsr_pins[i], INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // --- INISIALISASI BLE ---
  BLEDevice::init("FatigueMonitor_ESP32");  // Nama perangkat yang jelas
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Perbaikan: Tambahkan properti Read, Notify, dan Write
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_WRITE
                    );

  // PERBAIKAN KRITIKAL: Menambahkan Descriptor 2902
  // Ini yang memungkinkan browser (PWA) untuk me-listen/subscribe data notify
  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  // PERBAIKAN: Konfigurasi advertising untuk kompatibilitas Android/iOS
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);  // Penting untuk iOS dan Android
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);

  // PERBAIKAN: Atur interval advertising lebih cepat untuk Android
  pAdvertising->setAdvertisementInterval(100);  // 100ms interval

  // PERBAIKAN: Tambahkan manufacturer data untuk membantu discovery
  uint8_t manufacturerData[4] = {0xFF, 0xFF, 0x02, 0x00};  // Custom manufacturer data
  pAdvertising->setManufacturerData(std::string((char*)manufacturerData, 4));

  BLEDevice::startAdvertising();

  Serial.println("======================================");
  Serial.println("   SISTEM FINAL TA: JOK PINTAR 4.0    ");
  Serial.println("   BLE Ready with enhanced advertising ");
  Serial.println("======================================");
}

void loop() {
  float b[4];
  int sensor_aktif = 0;
  float total_beban = 0;

  for(int i=0; i<4; i++) {
    b[i] = (float)analogRead(fsr_pins[i]) * (20.0 / 4095.0);
    if (b[i] >= threshold_presence) sensor_aktif++;
    total_beban += b[i];
  }

  if (sensor_aktif >= 2) {
    if (!status_kehadiran) {
      status_kehadiran = true;
      waktu_mulai = millis();
      level1_done = level2_done = level3_done = false;
      counter_gelisah = 0;
      Serial.println("\n>>> PENGENDARA TERDETEKSI");
    }

    long durasi = (millis() - waktu_mulai) / 1000;

    // Serial Display
    Serial.print("S1:"); Serial.print(b[0], 1);
    Serial.print(" S2:"); Serial.print(b[1], 1);
    Serial.print(" S3:"); Serial.print(b[2], 1);
    Serial.print(" S4:"); Serial.print(b[3], 1);
    Serial.print(" | D:"); Serial.print(durasi);
    Serial.print("s | G:"); Serial.print(counter_gelisah);

    // Deteksi Gelisah
    if (millis() - waktu_cek_gelisah > 800) {
      bool ada_pergerakan = false;
      for(int i=0; i<4; i++) {
        if (abs(b[i] - b_lama[i]) > 0.8) ada_pergerakan = true;
        b_lama[i] = b[i];
      }
      if (ada_pergerakan) {
        counter_gelisah++;
        Serial.print(" -> JIGGLE!");
      }
      waktu_cek_gelisah = millis();
    }

    if (counter_gelisah >= 3) {
      Serial.print(" [!] ALERT: GELISAH!");
      if (deviceConnected) {
        pCharacteristic->setValue("ALERT: GELISAH");
        pCharacteristic->notify();
      }
      triggerBuzzer(5, 100);
      counter_gelisah = 0;
    }

    // Time-based Alerts
    if (durasi >= 10 && !level1_done) {
      triggerBuzzer(3, 500);
      level1_done = true;
    }
    if (durasi >= 15 && !level2_done) {
      triggerBuzzer(5, 1000);
      level2_done = true;
    }
    if (durasi >= 30 && !level3_done) {
      digitalWrite(BUZZER_PIN, HIGH); delay(3000); digitalWrite(BUZZER_PIN, LOW);
      level3_done = true;
    }

    // Kirim Data Periodik (Setiap 2 detik untuk respon lebih cepat)
    if (millis() - waktu_last_ble > 2000) {
      if (deviceConnected) {
        String data = "D:" + String(durasi) + ",B:" + String(total_beban/4, 1);

        // PERBAIKAN: Kirim dengan panjang eksplisit untuk menghindari null bytes
        pCharacteristic->setValue((uint8_t*)data.c_str(), data.length());
        pCharacteristic->notify();

        Serial.println(" | BLE: " + data);
      }
      waktu_last_ble = millis();
    }
    Serial.println();

  } else {
    if (status_kehadiran) {
      status_kehadiran = false;
      Serial.println("\n>>> STATUS: STANDBY (TIMER RESET)");
      digitalWrite(BUZZER_PIN, LOW);
    }
  }
  delay(150);
}