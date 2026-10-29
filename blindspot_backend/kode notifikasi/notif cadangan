#include <esp_now.h>
#include <WiFi.h>
#include <esp_wifi.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// ===== PIN DEFINITION =====
const int LED_L_R = 32; const int LED_L_G = 33; const int LED_L_B = 18;
const int LED_R_R = 27; const int LED_R_G = 26; const int LED_R_B = 25;
const int BUZZER  = 19;

// ===== BLE CONFIGURATION =====
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

// ===== BLE CALLBACKS =====
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("\n>>> App Connected!");
    };
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("\n>>> App Disconnected! Mencari ulang...");
      pServer->getAdvertising()->start();
    }
};

unsigned long previousMillis = 0;
int buzzerState = LOW;
int beepInterval = 0;

// Struktur harus sama persis dengan Pengirim
typedef struct struct_message {
  float distance;
  float posX;
  float speed;
  uint8_t hazardLevelL;
  uint8_t hazardLevelR;
} struct_message;

struct_message incomingData;

void setLED(String side, String color) {
  int r = LOW, g = LOW, b = LOW;
  if (color == "BAHAYA")       { r = HIGH; g = LOW; b = LOW; }
  else if (color == "WASPADA") { r = LOW; g = LOW; b = HIGH; }
  else if (color == "AMAN")    { r = LOW; g = HIGH; b = LOW; }
  else { r = LOW; g = LOW; b = LOW; }

  if (side == "L" || side == "ALL") {
    digitalWrite(LED_L_R, r); digitalWrite(LED_L_G, g); digitalWrite(LED_L_B, b);
  }
  if (side == "R" || side == "ALL") {
    digitalWrite(LED_R_R, r); digitalWrite(LED_R_G, g); digitalWrite(LED_R_B, b);
  }
}

void startupDebug() {
  setLED("ALL", "BAHAYA"); digitalWrite(BUZZER, HIGH); delay(500);
  setLED("ALL", "WASPADA"); digitalWrite(BUZZER, LOW); delay(500);
  setLED("ALL", "AMAN"); delay(500);
  setLED("ALL", "OFF");
}

// === FUNGSI EKSEKUSI SAAT DATA MASUK (ESP-NOW) ===
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingDataPtr, int len) {
  memcpy(&incomingData, incomingDataPtr, sizeof(incomingData));

  // Konversi Angka (0,1,2) kembali ke Teks Perintah LED
  String statusL = (incomingData.hazardLevelL == 2) ? "BAHAYA" : ((incomingData.hazardLevelL == 1) ? "WASPADA" : "AMAN");
  String statusR = (incomingData.hazardLevelR == 2) ? "BAHAYA" : ((incomingData.hazardLevelR == 1) ? "WASPADA" : "AMAN");

  // Eksekusi Lampu Kiri dan Kanan Sesuai Sisi
  setLED("L", statusL);
  setLED("R", statusR);

  // Eksekusi Buzzer
  if (incomingData.hazardLevelL == 2 || incomingData.hazardLevelR == 2) {
      beepInterval = 100;
  } else if (incomingData.hazardLevelL == 1 || incomingData.hazardLevelR == 1) {
      beepInterval = 400;
  } else {
      beepInterval = 0;
      buzzerState = LOW;
      digitalWrite(BUZZER, LOW);
  }
}

void setup() {
  Serial.begin(115200);

  pinMode(LED_L_R, OUTPUT); pinMode(LED_L_G, OUTPUT); pinMode(LED_L_B, OUTPUT);
  pinMode(LED_R_R, OUTPUT); pinMode(LED_R_G, OUTPUT); pinMode(LED_R_B, OUTPUT);
  pinMode(BUZZER, OUTPUT);

  startupDebug();

  // --- INISIALISASI BLE ---
  BLEDevice::init("BlindSpotMonitor_ESP32");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_WRITE
                    );

  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();

  Serial.println("BLE Ready with Descriptor 2902");

  WiFi.mode(WIFI_STA);
  esp_wifi_set_channel(1, WIFI_SECOND_CHAN_NONE); // Kunci Channel 1

  if (esp_now_init() != ESP_OK) {
    Serial.println("Error inisialisasi ESP-NOW");
    return;
  }

  esp_now_register_recv_cb(OnDataRecv);
  Serial.println("--- SISTEM BLIND SPOT NOTIFIKASI AKTIF ---");
}

void loop() {
  // Handle Buzzer
  if (beepInterval > 0) {
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= beepInterval) {
      previousMillis = currentMillis;
      buzzerState = !buzzerState;
      digitalWrite(BUZZER, buzzerState);
    }
  }

  // Kirim data via BLE setiap 200ms jika connected
  static unsigned long lastBLSend = 0;
  if (millis() - lastBLSend > 200) {
    lastBLSend = millis();

    if (deviceConnected) {
      String jsonString = "{\"dist\":";
      jsonString += String(incomingData.distance, 2);
      jsonString += ", \"posX\":";
      jsonString += String(incomingData.posX, 0);
      jsonString += ", \"spd\":";
      jsonString += String(incomingData.speed, 2);
      jsonString += ", \"hL\":";
      jsonString += String(incomingData.hazardLevelL);
      jsonString += ", \"hR\":";
      jsonString += String(incomingData.hazardLevelR);
      jsonString += "}";

      pCharacteristic->setValue(jsonString.c_str());
      pCharacteristic->notify();
    }
  }
}