pragma Singleton
import QtQuick 6.4
import QtMultimedia 6.4
import com.company.style 1.0

// https://doc.qt.io/qt-6/qsoundeffect.html

QtObject {
    id: soundManager

    property var mediaDevices: MediaDevices {}

    // Find the audio device based on the description stored in settings
    function findAudioDevice(description) {
        if (!description) {
            return mediaDevices.defaultAudioOutput
        }
        for (var i = 0; i < mediaDevices.audioOutputs.length; i++) {
            if (mediaDevices.audioOutputs[i].description === description) {
                return mediaDevices.audioOutputs[i]
            }
        }
        // If not found, return the default device
        console.warn("Audio output device not found:", description, "Falling back to default.")
        return mediaDevices.defaultAudioOutput
    }

    property var audioOutput: AudioOutput {
        volume: Theme.volume
        // Set initial device from settings
        device: findAudioDevice(Theme.audioOutputDevice)
    }

    // When the setting changes, update the device on the AudioOutput
    property var connections: Connections {
        target: Theme
        function onAudioOutputDeviceChanged() {
            soundManager.audioOutput.device = findAudioDevice(Theme.audioOutputDevice)
            console.log("Global audio output device changed to:", soundManager.audioOutput.device.description)
        }
    }
    
    property var mediaPlayer: MediaPlayer {
        // source: "file://" + Qt.resolvedUrl("../assets/sounds/touch_2.mp3")
        source: isPiBuild ? "file:///home/pi/sangank/QtApp/assets/sounds/touch_2.mp3"
            : "file:///home/sang/sangank/qtapp/assets/sounds/touch_2.mp3"
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
