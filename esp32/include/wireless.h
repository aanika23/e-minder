#ifndef WIRELESS_H
#define WIRELESS_H

#include <Arduino.h>
#include <WiFi.h>
#include "memory.h"

class Wireless {

  public:

    void init();
    void setSSID(String ssid, int address);
    void setPASS(String ssid_pass, int address);
    void setBLEConnected(bool status);

  private:
    void setCredential(String data, int address);
    bool changedSSID = false;
    bool changedPASS = false;
    bool isBLEConnected;
};

#endif
