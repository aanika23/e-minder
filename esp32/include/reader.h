#ifndef READER_H
#define READER_H

#include <Arduino.h>
#include <set>

class Reader{
public:        
    Reader();
    // starts reading loop
    // 2^Q: max num of tags detected per read signal
    // num_loops: number of read signals before stopping (0 = infinite)
    void startReadMultitag();

    // stops an infinite read loop
    void stopReadMultitag();

    // adds all detected rfids to the rfidSet
    // returns the number of newly added rfids
    int addDetectedRFIDs(std::set<String>& rfid_set);

    // gets the closest tag to the biggest reader
    // used for scan-to-register functionality
    bool getScannedRFID(String& rfid);

private:
    bool readOneRFIID(String& rfid);
};


#endif