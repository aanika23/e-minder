#ifndef DATABASE_H
#define DATABASE_H

#include <Arduino.h>
#include <Firebase_ESP_Client.h>
#include <set>

class Database {
public:
  void init();
  String requestOwnerID(String documentPath);
  std::set<String> requestSetRFID(String documentPath);

  bool registrationReady();
  void registeritem(String rfid);

  unsigned requestDetectionWindow(String ownerID); 

private:
  FirebaseAuth auth;
  FirebaseConfig config;
  FirebaseData fbdo; // Define Firebase Data object

  bool checkSchedule(String rfid);
};


#endif