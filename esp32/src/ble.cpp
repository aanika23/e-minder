#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "wireless.h"
#include "memory.h"
#include "ble.h"

#define BLE_SERVICE_ID "70af50b6-c909-48cd-8154-948d2f989426"
#define SERVICE_UUID "715200cc-f5df-49cd-9dcc-d232762fae77"
#define UUID_SSID "986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba"
#define UUID_PASS "5d0b68f5-d336-4ed3-ae75-0d09a4dc56a7"

bool deviceConnected = false;
BLECharacteristic *BLE_characteristic = NULL;
static Wireless* wireless;
static bool new_ssid = false;
static bool new_pass = false;

class connectionCallbacks : public BLEServerCallbacks
{
    void onConnect(BLEServer *MyServer)
    {
        deviceConnected = true;
        BLEDevice::startAdvertising();
        wireless->setBLEConnected(true);
    };

    void onDisconnect(BLEServer *MyServer)
    {
        deviceConnected = false;
        wireless->setBLEConnected(false);
    }
};

class ssidCallbacks : public BLECharacteristicCallbacks
{
    void onWrite(BLECharacteristic *BLE_characteristic)
    {
        std::string value = BLE_characteristic->getValue();

        if (value.length() > 0)
        {
            Serial.print("BLE Recived SSID: ");
            Serial.println(value.c_str());
            wireless->setSSID(value.c_str(), SSID_ADDRESS);
            new_ssid = true;
            if (new_ssid && new_pass) {
                delay(300);
                exit(0);
            }
        }
    }
};

class passCallbacks : public BLECharacteristicCallbacks
{
    void onWrite(BLECharacteristic *BLE_characteristic)
    {
        std::string value = BLE_characteristic->getValue();

        if (value.length() > 0) {
            Serial.print("BLE Recived Password: ");
            Serial.println(value.c_str());
            wireless->setPASS(value.c_str(), SSID_PASS_ADDRESS);
            new_pass = true;
            if (new_ssid && new_pass)
            {
                delay(300);
                exit(0);
            }
        }
    }
};

void BLE::init(Wireless *_wireless) {

  wireless = _wireless;

  // Create BLE Server
  BLEDevice::init("e-minder");
  BLEServer *BLE_server = BLEDevice::createServer();
  BLE_server->setCallbacks(new connectionCallbacks());
  BLEService *BLE_service = BLE_server->createService(SERVICE_UUID); //  A random ID has been selected

  Serial.print("BLE enabled...");
  Serial.println();

  // Create a BLE Characteristic
  BLE_characteristic = BLE_service->createCharacteristic(
      UUID_SSID,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY |
          BLECharacteristic::PROPERTY_INDICATE);

  BLE_characteristic->setCallbacks(new ssidCallbacks());
  BLE_characteristic->addDescriptor(new BLE2902());

  // Create a BLE Characteristic
  BLE_characteristic = BLE_service->createCharacteristic(
      UUID_PASS,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY |
          BLECharacteristic::PROPERTY_INDICATE);

  BLE_characteristic->setCallbacks(new passCallbacks());
  BLE_characteristic->addDescriptor(new BLE2902());

  // Start BLE Server
  BLE_service->start();
  BLEAdvertising *BLE_advertising = BLEDevice::getAdvertising();
  BLE_advertising->addServiceUUID(SERVICE_UUID);
  BLE_advertising->setScanResponse(false);

  BLE_advertising->setMinPreferred(0x0);
  BLEDevice::startAdvertising();
}