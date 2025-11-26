pragma Singleton
import QtQuick 6.4
import QtMultimedia 6.4
import com.company.style 1.0

QtObject {
    id: soundManager

    // https://doc.qt.io/qt-6/qsoundeffect.html
    property SoundEffect touchSound: SoundEffect {
        source: "qrc:/assets/sounds/touch_2.mp3"
        // muted: !Theme.soundTouchEnabled // Mute if the setting is disabled
        volume: Theme.volume
    }

    // Play sound effect for touch interactions
    function playTouch() {
        if (!Theme.soundTouchEnabled) {
            return
        }

        if (touchSound.status === SoundEffect.Error) {
            console.error("SoundEffect Warning:", touchSound.errorString)
        } 
        else if (touchSound.status === SoundEffect.Ready) {
            touchSound.play()
        } 
        else {
            console.warn("Touch sound is not ready to play. Status:", touchSound.status)
        }
    }
}
