pragma Singleton
import QtQuick 6.4
import QtMultimedia 6.4
import com.company.style 1.0

// https://doc.qt.io/qt-6/qsoundeffect.html

QtObject {
    id: soundManager

    property var mediaDevices: MediaDevices {}

    property var audioOutput: AudioOutput {
        volume: Theme.volume
        device: soundManager.mediaDevices.defaultAudioOutput
    }
    
    property var mediaPlayer: MediaPlayer {
        source: "file:///home/pi/sangank/QtApp/assets/sounds/touch_2.mp3"
        audioOutput: soundManager.audioOutput
        onErrorChanged: {
            console.error("MediaPlayer Error:", mediaPlayer.errorString)
        }
    }

    // Play sound effect for touch interactions
    function playTouch() {
        if (!Theme.soundTouchEnabled) {
            return
        }

        // console.log("mediaPlayer.source: ", mediaPlayer.source)
        // console.log("mediaPlayer.mediaStatus: ", mediaPlayer.mediaStatus)
        mediaPlayer.play()
    }
}
