#include <sstream>
#include "reader.h"

Reader::Reader() {
    Serial.begin(115200);
}

void Reader::startReadMultitag() {
    // start multi-tag inventory command
    // <[2]header> <address> <len> <cmd> <sub cmd> <Q> <[2]num_loop> <[2]CheckSum?>
    // AA AA FF 08 C1 02 01 00 00 13 B3 
    // AA AA FF 08 C1 02 02 00 00 4A E3 

    Serial.write(0xAA);
    Serial.write(0xAA);
    Serial.write(0xFF);   

    Serial.write(0x08);
    Serial.write(0xC1);
    Serial.write(0x02); // Algorithm 
    Serial.write(0x02); // Q (2^2 = 4)
    Serial.write(0x00); // num_loops[1]
    Serial.write(0x00); // num_loops[0]

    Serial.write(0x4A);
    Serial.write(0xE3);
}

void Reader::stopReadMultitag() {
    // stop multi-tag inventory command
    // <[2]header> <address> <len> <cmd> <sub cmd> <[2]CheckSum?>
    // AA AA FF 05 C0 00 B3 F7 

    Serial.write(0xAA);
    Serial.write(0xAA);
    Serial.write(0xFF);    

    Serial.write(0x05);
    Serial.write(0xC0);
    Serial.write(0x00);    

    Serial.write(0xB3);
    Serial.write(0xF7);
}

int Reader::addDetectedRFIDs(std::set<String>& rfid_set) {
    String rfid;
    int newlyAddedRfids = 0;

    while (readOneRFIID(rfid)) {
        auto ret = rfid_set.insert(rfid);
        if (ret.second) {
            newlyAddedRfids++;
            // printf("added to set\n");
        } else {
            // printf("already exists\n");
        }
    }
    return newlyAddedRfids;
}

bool Reader::getScannedRFID(String& rfid) {
    // start multi-tag inventory command
    // <[2]header> <address> <len> <cmd> <sub cmd> <Q> <[2]num_loop> <[2]CheckSum?>
    // AA AA FF 08 C1 02 00 00 01 34 A2 
    // AA AA FF 08 C1 02 00 00 04 64 07 
    // AA AA FF 08 C1 02 00 00 09 B5 AA

    stopReadMultitag();
    delay(500);

    // clear buffer
    while(Serial.available()) Serial.read();

    // send command to read 1 tag for a single loop
    // should return the closest rfid

    Serial.write(0xAA);
    Serial.write(0xAA);
    Serial.write(0xFF);   

    Serial.write(0x08);
    Serial.write(0xC1);
    Serial.write(0x02); // Algorithm 
    Serial.write(0x00); // Q (2^0 = 1)
    Serial.write(0x00); // num_loops[1]
    Serial.write(0x04); // num_loops[0]

    Serial.write(0x64);
    Serial.write(0x07);
    delay(1000);

    bool returnVal = readOneRFIID(rfid);

    startReadMultitag();

    return returnVal;
}


bool Reader::readOneRFIID(String& rfid) {
    // Example successful detection response
    // AA AA FF                             - header + address
    // 18                                   - packet length (RFID responses are always in packets of size 0x18)
    // C1 02 00                             - <CMDH> <CMDL> <Status>
    // D1                                   - RSSI (Received Signal Strength Indicator) - how strong is the received signal
    // 30 00                                - PC (Protocol Control) - determines the length of the RFID
    // 00 00 E6 02 B4 08 8C AD C2 1D 60 00  - RFID
    // B0 C2                                - CRC
    // 03                                   - ANT (the antena number that detected the tag)
    // E9 EA                                - CheckSum? 

    char len = 0;
    while (Serial.available()) {
        // printf("*");

        if (Serial.read() == 0xAA) {
            Serial.read(); // 0xAA
            Serial.read(); // 0xFF

            len = Serial.read(); // Packet Length
            if (len == 0x18) break;
        }
    }

    if (len != 0x18) return false;

    Serial.read(); // CMDH
    Serial.read(); // CMDL
    Serial.read(); // Status
    Serial.read(); // RSSI
    Serial.read(); // PC[1]
    Serial.read(); // PC[0]
    
    char rfid_bytes[12];
    Serial.readBytes(rfid_bytes, 12);

    char rfid_chars[25];
    for(int i = 0; i < 12; i++) {
        sprintf(&rfid_chars[i*2], "%02x", rfid_bytes[i]);
    }
    rfid_chars[24] = 0;
    // printf("\ndetected RFID = %s\n", rfid_chars);

    rfid = String(rfid_chars);
    return true;
}