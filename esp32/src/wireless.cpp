#include "wireless.h"
#include "private.h"
#include <EEPROM.h>

void Wireless::init() {

  Serial.print("Wifi enabled...");
  Serial.println();

  setBLEConnected(false);

  String SSID;
  String SSID_PASS;

  Serial.print("Connecting to SSID: ");
  for (int i = SSID_ADDRESS; i < SSID_ADDRESS + SSID_SIZE; i++)
    SSID += char(EEPROM.read(i));

  for (int i = SSID_PASS_ADDRESS; i < SSID_PASS_ADDRESS + SSID_PASS_SIZE; i++)
    SSID_PASS += char(EEPROM.read(i));

  Serial.print(SSID.c_str());
  Serial.println();
  Serial.print("PASS: ");
  Serial.print(SSID_PASS.c_str());
  Serial.println();

  WiFi.begin(SSID.c_str(), SSID_PASS.c_str());

  int count = 0;
  while (WiFi.status() != WL_CONNECTED){

    if (count&2) digitalWrite(5, HIGH);
    else digitalWrite(5, LOW);

    if(isBLEConnected) {
      Serial.println("BLE Connected");
      count = 0;
    }
    else if(count > 50 && !isBLEConnected) {
      exit(0);
    }else {
      Serial.print(".");
    }
    delay(300);

    count++;
  }
    
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
}

void Wireless::setCredential(String data, int address)
{
  int length = data.length();

  for (int i = 0; i < length; i++)
  {
    EEPROM.write(address, data[i]);
    address += 1;
  }

  EEPROM.write(address, '\0');
  EEPROM.commit();
}

void Wireless::setSSID(String ssid, int address) {
  this->setCredential(ssid, address);
}

void Wireless::setPASS(String ssid_pass, int address) {
  this->setCredential(ssid_pass, address);
}

void Wireless::setBLEConnected(bool status) {
  isBLEConnected = status;
  Serial.printf("BLE Connection = %d\n", isBLEConnected);
}