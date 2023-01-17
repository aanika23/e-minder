#include "database.h"
#include <addons/TokenHelper.h>
#include "private.h"
#include "time.h"

void Database::init(){

    /* Assign the api key (required) */
    config.api_key = API_KEY; // found in private.h

    /* Assign the user sign in credentials */
    auth.user.email = USER_EMAIL; // found in private.h
    auth.user.password = USER_PASSWORD; // found in private.h

    /* Assign the callback function for the long running token generation task */
    config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

    printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

    // Limit the size of response payload to be collected in FirebaseData
    fbdo.setResponseSize(2048);

    Firebase.begin(&config, &auth);

    Firebase.reconnectWiFi(true);
    
}

// spaces in document path should be encoded as %20  (e.g. "a b c/d e f" -> "a%20b%20c/d%20e%20f")
String Database::requestOwnerID(String documentPath){
    String ownerID = "";
    String rfid = documentPath.substring(documentPath.lastIndexOf("/")+1);

    printf("\nIdentifying user - RFID: %s\n", rfid.c_str());

    if (Firebase.ready()) {
      if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str())) {
        FirebaseJson itemJson(fbdo.payload().c_str());
        FirebaseJsonData ownerData;
        itemJson.get(ownerData, "fields/owner/stringValue");
        ownerID = ownerData.to<String>();
      } else {
        printf("Failed to retrieve item info - ");
        printf("%s\n", fbdo.errorReason().c_str());
      }
    }

    if (ownerID.isEmpty()) {
      printf("No user owns: %s\n", rfid.c_str());
    } else {
      printf("User ID: %s\n", ownerID.c_str());
    }
    return ownerID;
}

// spaces in document path should be encoded as %20  (e.g. "a b c/d e f" -> "a%20b%20c/d%20e%20f")
std::set<String> Database::requestSetRFID(String documentPath) {
  std::set<String> registeredRfidSet;

  if (Firebase.ready()) {
      if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str())) {
        FirebaseJson itemsJson(fbdo.payload().c_str()); // JSON object of all user items

        FirebaseJsonData result;
        itemsJson.get(result, "documents");

        FirebaseJsonArray itemJsonArray;
        result.get<FirebaseJsonArray>(itemJsonArray); // an array of the indiviual items in JSON format

        // Loop through the JSON objects of items and extract the RFIDs into a separate set
        for (size_t i = 0; i < itemJsonArray.size(); i++) {
          // Call get with FirebaseJsonData to parse the array at defined index i
          itemJsonArray.get(result, i);

          // The RFID name will need to be parsed as it is in this format:
          // "name": "projects/e-minder-cb1fb/databases/(default)/documents/users/0fEHBNqSavTGRttOdXmfd6NgVPw1/items/hs7373hfj9396hsa"
          FirebaseJson itemJson(result.stringValue.c_str());
          itemJson.get(result, "name");
          String rfid = result.to<String>().substring(result.to<String>().lastIndexOf("/")+1);

          // Check if within schedule
          if (checkSchedule(rfid)) {
            registeredRfidSet.insert(rfid);
          }
        }

        printf("All registered RFIDs retreived:\n");
        for (String rfid : registeredRfidSet) {
          printf("%s\n", rfid.c_str());
        }
      }
      else {
        printf("Failed to retrieve item list - ");
        printf("%s\n", fbdo.errorReason().c_str());
      }
  }

  return registeredRfidSet;
}

bool Database::registrationReady() {
  bool registrationReady = false;

  if (Firebase.ready()) {
    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", "registration/taginfo")) {
      FirebaseJson taginfoJson(fbdo.payload().c_str());
      FirebaseJsonData readyData;

      // get ready bool
      taginfoJson.get(readyData, "fields/ready/booleanValue");
      registrationReady = readyData.to<bool>();

      if (registrationReady) {
        // reset ready field to false
        taginfoJson.set("fields/ready/booleanValue", "false");
        bool success = Firebase.Firestore.patchDocument(
          &fbdo, FIREBASE_PROJECT_ID, "", "registration/taginfo", taginfoJson.raw(), "ready"
        );
        if (!success) printf("%s\n", fbdo.errorReason().c_str());
      }
    } else {
      printf("Failed to retrieve item info - ");
      printf("%s\n", fbdo.errorReason().c_str());
    }
  }
  return registrationReady;
}

void Database::registeritem(String rfid) {
  if (Firebase.ready()) {
    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", "registration/taginfo")) {
      bool success;
      FirebaseJson taginfoJson(fbdo.payload().c_str());

      // add item to items list
      taginfoJson.remove("name");
      taginfoJson.remove("fields/ready");
      success = Firebase.Firestore.createDocument(
        &fbdo, FIREBASE_PROJECT_ID, "", ("items/"+rfid).c_str(), taginfoJson.raw()
      );
      if (!success) printf("%s\n", fbdo.errorReason().c_str());

      // add item to user items
      FirebaseJsonData ownerData;
      taginfoJson.get(ownerData, "fields/owner/stringValue");

      taginfoJson.remove("fields/days");
      taginfoJson.remove("fields/from");
      taginfoJson.remove("fields/to");
      taginfoJson.remove("fields/owner");

      success = Firebase.Firestore.createDocument(
        &fbdo, FIREBASE_PROJECT_ID, "", ("users/"+ownerData.to<String>()+"/items/"+rfid).c_str(), taginfoJson.raw()
      );
      if (!success) printf("%s\n", fbdo.errorReason().c_str());

    } else {
      printf("Failed to retrieve item info - ");
      printf("%s\n", fbdo.errorReason().c_str());
    }
  }
}

unsigned Database::requestDetectionWindow(String ownerID) {
  unsigned detectionWindow = 0;

  if (Firebase.ready()) {
    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", ("users/" + ownerID).c_str())) {
      FirebaseJson userJson(fbdo.payload().c_str()); // JSON object of user document

      FirebaseJsonData windowData;
      userJson.get(windowData, "fields/window/intValue");
      return windowData.to<unsigned>();
    } else {
      printf("Failed to retrieve item info - ");
      printf("%s\n", fbdo.errorReason().c_str());
      return 0;
    }
  }
  return 0;
}

bool Database::checkSchedule(String rfid) {
  if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", ("items/" + rfid).c_str())) {
    FirebaseJson itemJson(fbdo.payload().c_str());
    FirebaseJsonData daysData;
    FirebaseJsonData fromData;
    FirebaseJsonData toData;
    itemJson.get(daysData, "fields/days/stringValue");
    itemJson.get(fromData, "fields/from/stringValue");
    itemJson.get(toData, "fields/to/stringValue");
    String days = daysData.to<String>();
    String from = fromData.to<String>();
    String to = toData.to<String>();

    struct tm timeinfo;
    if(!getLocalTime(&timeinfo)){
      printf("ERROR: Failed to obtain time\n");
      return false;
    }

    // check day of the week
    printf("DAYS: %s, DAYS SINCE SUNDAY: %d\n", days.c_str(), timeinfo.tm_wday);
    if (days.indexOf("n") == -1 && timeinfo.tm_wday == 0) return false;
    if (days.indexOf("m") == -1 && timeinfo.tm_wday == 1) return false;
    if (days.indexOf("t") == -1 && timeinfo.tm_wday == 2) return false;
    if (days.indexOf("w") == -1 && timeinfo.tm_wday == 3) return false;
    if (days.indexOf("h") == -1 && timeinfo.tm_wday == 4) return false;
    if (days.indexOf("f") == -1 && timeinfo.tm_wday == 5) return false;
    if (days.indexOf("s") == -1 && timeinfo.tm_wday == 6) return false;

    // check time of the day
    int from_hr = from.substring(0, 2).toInt();
    int from_min = from.substring(2, 4).toInt();
    int to_hr = to.substring(0, 2).toInt();
    int to_min = to.substring(2, 4).toInt();
    printf("FROM: %d:%d TO: %d:%d, TIME: %d:%d\n", from_hr, from_min, to_hr, to_min, timeinfo.tm_hour, timeinfo.tm_min);

    if (from_hr == to_hr && from_min == to_min) return true; // all day

    if (timeinfo.tm_hour < from_hr) return false;
    if (timeinfo.tm_hour == from_hr && timeinfo.tm_min < from_min) return false;
    if (timeinfo.tm_hour > to_hr) return false;
    if (timeinfo.tm_hour == to_hr && timeinfo.tm_min > to_min) return false;

    return true;
  } else {
    printf("Failed to retrieve item info - ");
    printf("%s\n", fbdo.errorReason().c_str());
    return false;   
  }
}