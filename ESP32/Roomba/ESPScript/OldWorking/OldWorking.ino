#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID           "12345678-1234-5678-1234-56789abcdef0"
#define CHARACTERISTIC_UUID    "abcdef01-1234-5678-1234-56789abcdef0"

#define ROOMBA_TX 17
#define ROOMBA_RX 16
#define DETECT_PIN 15  // optional pin to reset/wake Roomba

void sendDriveCommand(int velocity, int radius) {
  Serial.print("🚗 Sending Roomba drive → velocity: ");
  Serial.print(velocity);
  Serial.print("  radius: ");
  Serial.println(radius);

  Serial1.write(137);
  Serial1.write((velocity >> 8) & 0xFF);
  Serial1.write(velocity & 0xFF);
  Serial1.write((radius >> 8) & 0xFF);
  Serial1.write(radius & 0xFF);
}

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();
    Serial.print("📩 Received: ");
    Serial.println(value);

    // Expect format: V:<velocity> R:<radius>
    if (value.startsWith("V:")) {
      int vIndex = value.indexOf("V:");
      int rIndex = value.indexOf("R:");

      if (vIndex == -1 || rIndex == -1) {
        Serial.println("❌ Invalid format");
        return;
      }

      // Extract substrings
      String vPart = value.substring(vIndex + 2, rIndex - 1);
      String rPart = value.substring(rIndex + 2);

      int velocity = vPart.toInt();
      int radius = rPart.toInt();

      Serial.print("✅ Parsed → V: "); Serial.print(velocity);
      Serial.print(" R: "); Serial.println(radius);

      sendDriveCommand(velocity, radius);
    };
    // Expect commands => C:
    if (value.startsWith("C:")) {
      String byteStr = value.substring(2);
      byteStr.trim();

      int byteVal = byteStr.toInt();
      Serial.print("📤 Sending byte: ");
      Serial.println(byteVal);

      Serial1.write(byteVal);
    }
  }
};


void setup() {
  Serial.begin(115200);
  Serial1.begin(115200, SERIAL_8N1, ROOMBA_RX, ROOMBA_TX);

  delay(1000);
  Serial.println("💡 Sending Start + Control (Safe)...");
  Serial1.write(128); delay(20);  // START -> Passive
  Serial1.write(130); delay(20);  // CONTROL -> Safe 

  Serial1.write(140);
  Serial1.write(0);
  Serial1.write(8);           // 8 notes
  uint8_t notes[] = {76,16, 76,16, 0,16, 76,16, 0,16, 72,16, 76,16, 79,16};
  for (int i=0;i<sizeof(notes);i++) Serial1.write(notes[i]);
  delay(20);
  Serial1.write(141); 
  Serial1.write(0);

  // BLE setup
  BLEDevice::init("ESP32Roomba");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );

  pCharacteristic->setCallbacks(new MyCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->start();

  Serial.println("🚀 BLE Ready — connect and send joystick data");
}

void loop() {
  // no loop logic needed
}
