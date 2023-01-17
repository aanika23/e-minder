#ifndef SOUND_H
#define SOUND_H

#include <melody_player.h>
#include <melody_factory.h>

#define SPEAKER_PIN 17

class Sound{
public:
    enum Songs {
        ALL_ITEMS,
        MISSING_ITEMS,
        START_BEEP
    };

    void play(Songs song);
};

#endif