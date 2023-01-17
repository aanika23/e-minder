#include <Arduino.h>
#include <WiFi.h>
#include <set>
#include <EEPROM.h>
#include "wireless.h"
#include "private.h"
#include "reader.h"
#include "sound.h"
#include "database.h"
#include "time.h"
#include "memory.h"
#include "ble.h"

static Database database;
static Wireless* wireless = new Wireless();
static Reader reader;
static Sound sound;
static BLE ble;

std::set<String> detectedRfidSet;
std::set<String> registeredRfidSet;

int numTagsDetected;
unsigned long firstScanMillis;
unsigned long sleepInterval = 200;
unsigned long detectionWindow = 1000; // time before the alarm sounds (ms)

bool userIdentified = false;

void setup() {
  // Turn on Serial Monitoring
  Serial.begin(115200);
  Serial.println("e-minder booted...\n");

  pinMode(5, OUTPUT);

  // Load EEPROM
  if (!EEPROM.begin(EEPROM_SIZE)) {
    Serial.println("Waiting for EEPROM...\n");
    delay(1000);
  }

  Serial.print("EEPROM enabled...");
  Serial.println();

  // Start broadcasting BLE
  ble.init(wireless);

  // Connect to wifi
  wireless->init();

  // Connect to database
  database.init();

  // Initialize time
  configTime(-28800, 3600, "pool.ntp.org");

  printf("\r\nStarting RFID Tag Detection...\n");
  reader.startReadMultitag();
}

void loop () {
  delay(sleepInterval);

  if (database.registrationReady()) {
    printf("SCAN TO REGISTER\n");
    String scannedRfid;
    if (reader.getScannedRFID(scannedRfid)) {
      database.registeritem(scannedRfid);
    } else {
      printf("NO TAG FOUND\n");
    }
  }

  int numTagsDetected = reader.addDetectedRFIDs(detectedRfidSet);
  printf("\n%d new rfids added to the set\ncurrent set:\n", numTagsDetected);
  for (auto rfid: detectedRfidSet) {
    printf("%s\n", rfid.c_str());
  }

  if (!userIdentified) {
    // Identify User //
    firstScanMillis = millis();

    for (auto detectedRfid: detectedRfidSet) {
      // Find the user ID corresponding to the scanned RFID tag
      String ownerID = database.requestOwnerID("items/" + detectedRfid);
      if(ownerID.isEmpty()) continue;

      // Find all RFID tags belonging to the user
      printf("\nUser Identified!\nFetching registered items...\n");
      registeredRfidSet = database.requestSetRFID("users/" + ownerID + "/items");

      if(registeredRfidSet.empty()){
        printf("ERROR: Something is wrong, %s should own %s!\n", ownerID.c_str(), detectedRfid.c_str());
        continue;
      }

      // Get user defined detection window
      detectionWindow = database.requestDetectionWindow(ownerID);
      if (detectionWindow) {
        printf("Detection window retrieved: %d\n\n", detectionWindow);      
      } else {
        detectionWindow = 1500;
        printf("Detection window not found\nSetting detection window to %d\n\n", detectionWindow);      
      }

      // Found an RFID that is owned by a user
      userIdentified = true;
      break;
    }

    if(!userIdentified) {
      printf("No users own any of the detected tags\n");
      detectedRfidSet.clear();
      return;
    }
  }

  // Check whether all registered rfids are detected ///
  // std::includes() can be used to determine if one set is a subset of another
  if (std::includes(detectedRfidSet.begin(), detectedRfidSet.end(),
                    registeredRfidSet.begin(), registeredRfidSet.end())) {
    // All registered items detected
    printf("All items found!\n");
    // sound.play(sound.ALL_ITEMS); 
    digitalWrite(5, HIGH);
    delay(2000);
    digitalWrite(5, LOW);

    userIdentified = false;
    detectedRfidSet.clear();
    printf("\r\nStarting RFID Tag Detection...\n");
    return;
  }

  printf("millis=%ld, end=%ld\n", millis(), firstScanMillis + detectionWindow);
  if (millis() > firstScanMillis + detectionWindow) {
    // Some registered items not detected within the detection window //
    printf("\r\nDetection window elapsed\n");
    sound.play(sound.MISSING_ITEMS);
    delay(2000);

    userIdentified = false;
    detectedRfidSet.clear();
    printf("\r\nStarting RFID Tag Detection...\n");
  }
}