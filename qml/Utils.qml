pragma Singleton
import QtQuick 6.4

QtObject {
    // Function to extract filename from a full path
    function getFileName(filePath) {
        if (!filePath) {
            return ""
        }
        // Find the last '/' and return the substring after it
        var lastSlash = filePath.lastIndexOf('/')
        if (lastSlash === -1) {
            return filePath // No slash found, return the whole string
        }
        return filePath.substring(lastSlash + 1)
    }

    function getIconForDevice(iconName) {
        switch (iconName) {
        case "audio-headset":
            return "headset"
        case "phone":
            return "smartphone"
        case "computer":
            return "computer"
        case "input-keyboard":
            return "keyboard"
        case "input-mouse":
            return "mouse"
        case "input-gaming":
            return "sports_esports"
        case "audio-card":
        case "audio-speakers":
            return "speaker"
        case "audio-headphones":
            return "headphones"
        default:
            return "bluetooth" // Default icon if empty or unknown
        }
    }
}
