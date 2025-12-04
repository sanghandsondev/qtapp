pragma Singleton
import QtQuick 6.4
import QtMultimedia 6.4
import com.company.style 1.0
import com.company.utils 1.0

// https://doc.qt.io/qt-6/qsoundeffect.html

QtObject {
    id: soundManager

    property var mediaDevices: MediaDevices {
        onAudioOutputsChanged: {
            console.log("Audio outputs changed. Re-evaluating best device.")
            // Check if the currently selected device is still available.
            var currentDeviceStillExists = false
            for (var i = 0; i < mediaDevices.audioOutputs.length; i++) {
                if (mediaDevices.audioOutputs[i].description === Theme.audioOutputDevice) {
                    currentDeviceStillExists = true
                    break
                }
            }

            // If the current device is gone (e.g., BT disconnected), or if no device was set,
            // find and set the new best one.
            if (!currentDeviceStillExists) {
                console.log("Current audio device is not available. Selecting a new best device.")
                selectBestAudioDevice()
            }
        }
    }

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

    // Function to find and set the best available audio device based on priority.
    function selectBestAudioDevice() {
        var bestDevice = mediaDevices.defaultAudioOutput
        var maxPriority = -1

        if (mediaDevices.audioOutputs.length === 0) {
            console.log("No audio output devices found. Using default.")
            Theme.setAudioOutputDevice(bestDevice.description)
            return
        }

        for (var i = 0; i < mediaDevices.audioOutputs.length; i++) {
            var device = mediaDevices.audioOutputs[i]
            var priority = Utils.getAudioDevicePriority(device)
            if (priority > maxPriority) {
                maxPriority = priority
                bestDevice = device
            }
        }

        console.log("Selected best audio device:", bestDevice.description, "with priority:", maxPriority)
        Theme.setAudioOutputDevice(bestDevice.description)
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

    Component.onCompleted: {
        // On startup, perform an initial selection of the best device.
        // A short delay ensures that MediaDevices has had time to populate.
        Qt.callLater(selectBestAudioDevice)
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
