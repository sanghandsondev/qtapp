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

    // Function to determine the priority of an audio output device.
    // Higher number = higher priority.
    function getAudioDevicePriority(device) {
        if (!device || !device.description) {
            return 0
        }
        const desc = device.description.toLowerCase()

        // Highest priority: Bluetooth devices
        if (desc.includes("bluez") || desc.includes("bluetooth")) {
            return 3
        }
        // Medium priority: Analog output (headphones/speakers jack)
        if (desc.includes("headphones") || desc.includes("analog") || desc.includes("bcm2835")) {
            return 2
        }
        // Low priority: HDMI
        if (desc.includes("hdmi")) {
            return 1
        }
        // Lowest priority for anything else
        return 0
    }

    // Function to get a suitable icon for an audio output device.
    function getIconForAudioDevice(device) {
        if (!device || !device.description) {
            return "speaker" // Default icon
        }
        const desc = device.description.toLowerCase()

        if (desc.includes("bluez") || desc.includes("bluetooth")) {
            return "headset"
        }
        if (desc.includes("headphones")) {
            return "headphones"
        }
        if (desc.includes("hdmi")) {
            return "tv"
        }
        // Default for analog, speakers, etc.
        return "speaker"
    }
}
