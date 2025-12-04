pragma Singleton
import QtQuick 6.4
import QtMultimedia 6.4
import com.company.style 1.0
import com.company.utils 1.0

// https://doc.qt.io/qt-6/qsoundeffect.html

QtObject {
    id: soundManager

    // ---------------------- Audio Output Device Management ----------------------

    // Lưu trạng thái: trước đó đã từng có bluetooth device chưa
    property bool hadBluetoothDevice: false

    property var mediaDevices: MediaDevices {
        onAudioOutputsChanged: {
            console.log("Audio outputs changed. Re-evaluating best device.")
            console.log("Available audio output devices:")
            for (var i = 0; i < mediaDevices.audioOutputs.length; i++) {
                console.log("name:", mediaDevices.audioOutputs[i].description, 
                        ", id:", mediaDevices.audioOutputs[i].id, ",", 
                        "isDefault:", mediaDevices.audioOutputs[i].isDefault)
            }
            selectBestAudioDevice()
        }
    }

    property var audioOutput: AudioOutput {
        volume: Theme.volume
        // Set initial device from settings
        device: findAudioDevice(Theme.audioOutputDevice)
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

    // Select the best audio output device based on priority
    function selectBestAudioDevice() {
        var outputs = mediaDevices.audioOutputs
        if (outputs.length === 0) {
            Theme.setAudioOutputDevice(mediaDevices.defaultAudioOutput.description)
            hadBluetoothDevice = false
            return
        }

        var hasBluetooth = Utils.hasBluetoothDevice(outputs)
        // Nếu vừa xuất hiện bluetooth (trước đó chưa có)
        if (hasBluetooth && !hadBluetoothDevice) {
            for (var i = 0; i < outputs.length; ++i) {
                var d = outputs[i]
                var idStr = String(d.id)
                if (idStr.includes("bluez") || idStr.includes("bluetooth")) {
                    Theme.setAudioOutputDevice(d.description)
                    hadBluetoothDevice = true
                    return
                }
            }
        }
        hadBluetoothDevice = hasBluetooth

        // Nếu thiết bị hiện tại vẫn còn thì giữ nguyên
        for (var i = 0; i < outputs.length; ++i) {
            if (outputs[i].description === Theme.audioOutputDevice)
                return
        }

        // Nếu không còn, chọn thiết bị ưu tiên nhất
        var best = outputs[0]
        var maxP = Utils.getAudioDevicePriority(best)
        for (var i = 1; i < outputs.length; ++i) {
            var p = Utils.getAudioDevicePriority(outputs[i])
            if (p > maxP) {
                best = outputs[i]
                maxP = p
            }
        }
        Theme.setAudioOutputDevice(best.description)
    }

    // When the setting changes, update the device on the AudioOutput
    property var connections: Connections {
        target: Theme
        function onAudioOutputDeviceChanged() {
            soundManager.audioOutput.device = findAudioDevice(Theme.audioOutputDevice)
            console.log("Global audio output device changed to:", soundManager.audioOutput.device.description)
        }
    }

    Component.onCompleted: {
        // On startup, perform an initial selection of the best device.
        // A short delay ensures that MediaDevices has had time to populate.
        Qt.callLater(selectBestAudioDevice)
    }

    // ---------------------- Sound Effects ----------------------
    
    property var mediaPlayer: MediaPlayer {
        // source: "file://" + Qt.resolvedUrl("../assets/sounds/touch_2.mp3")
        source: isPiBuild ? "file:///home/pi/sangank/QtApp/assets/sounds/touch_2.wav"
            : "file:///home/sang/sangank/qtapp/assets/sounds/touch_2.wav"
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
        if (mediaPlayer.playbackState !== MediaPlayer.StoppedState)
            mediaPlayer.stop()
        mediaPlayer.position = 0
        mediaPlayer.play()
    }
}
