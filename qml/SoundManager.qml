pragma Singleton
import QtQuick 6.4
import QtMultimedia 6.4
import com.company.style 1.0

QtObject {
    id: soundManager

    property SoundEffect touchSound: SoundEffect {
        source: "qrc:/assets/sounds/touch_2.mp3"
        muted: !Theme.soundTouchEnabled // Tắt tiếng nếu setting bị vô hiệu hóa
    }

    // Hàm để phát âm thanh khi chạm
    function playTouch() {
        // 1. Check if sound is enabled in the theme settings first
        if (!Theme.soundTouchEnabled) {
            return // Do nothing if sounds are disabled
        }

        // 2. Proceed with playing the sound if enabled
        if (touchSound.status === SoundEffect.Error) {
            console.error("SoundEffect Error:", touchSound.errorString)
        } else if (touchSound.status === SoundEffect.Ready) {
            touchSound.play()
        } else {
            // Optional: Log if the sound is not ready (e.g., still loading)
            console.warn("Touch sound is not ready to play. Status:", touchSound.status)
        }
    }
}
