#include "sound.h"

void Sound::play(Songs song) {

    MelodyPlayer player(SPEAKER_PIN);
    Melody melody;

    if (song == ALL_ITEMS)
    {
        printf("SOUND: All registered items detected!\n");
        String notes[] = { "C1", "C3", "C5", "SILENCE", "SILENCE", "C5", "C3", "C1" };
        melody = MelodyFactory.load("All Items", 250, notes, 8);
    }
    if (song == START_BEEP)
    {
        printf("SOUND: All registered items detected!\n");
        String notes[] = { "C1" };
        melody = MelodyFactory.load("Start Beep", 250, notes, 1);
    }
    else if(song == MISSING_ITEMS) {
        printf("SOUND: User is missing items\n");
        String notes[] = { "AS1", "AS6", "AS1", "AS6", "AS1", "AS6", "AS1", "AS6" };
        melody = MelodyFactory.load("Missing Items", 100, notes, 8);
    }  else {
        return;
    }
    player.play(melody);
    
}