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
        if (!device || !device.description || !device.id) {
            return 0
        }

        const idStr = String(device.id)
        const desc = device.description.toLowerCase()

        // Highest priority: Bluetooth devices
        if (idStr.includes("bluez") || idStr.includes("bluetooth")) {
            return 3
        }
        // Medium priority: Analog output (headphones/speakers jack)
        if (idStr.includes("headphones") || idStr.includes("analog") || idStr.includes("mailbox")) {
            return 2
        }
        // Low priority: HDMI
        if (idStr.includes("hdmi")) {
            return 1
        }
        // Lowest priority for anything else
        return 0
    }

    // Function to get a suitable icon for an audio output device.
    function getIconForAudioDevice(device) {
        if (!device || !device.description || !device.id) {
            return "speaker" // Default icon
        }

        const idStr = String(device.id)
        const desc = device.description.toLowerCase()

        if (idStr.includes("bluez") || idStr.includes("bluetooth")) {
            return "bluetooth"
        }
        if (idStr.includes("hdmi")) {
            return "tv"
        }
        // Default for analog, speakers, etc.
        return "speaker"
    }

    // Kiểm tra danh sách device có bluetooth device không
    function hasBluetoothDevice(devices) {
        if (!devices || devices.length === 0)
            return false
        for (var i = 0; i < devices.length; i++) {
            var idStr = String(devices[i].id)
            if (idStr.includes("bluez") || idStr.includes("bluetooth")) {
                return true
            }
        }
        return false
    }

    // Function to format the datetime string for call history
    function formatHistoryTime(datetimeStr) {
        if (!datetimeStr) return ""

        // oFono format is like "2024-05-21T10:30:00Z"
        const callDate = new Date(datetimeStr)
        if (isNaN(callDate.getTime())) {
            return datetimeStr // Return original string if parsing fails
        }

        const now = new Date()
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        const yesterday = new Date(today)
        yesterday.setDate(today.getDate() - 1)

        // Normalize callDate to the start of its day for comparison
        const callDay = new Date(callDate.getFullYear(), callDate.getMonth(), callDate.getDate())

        if (callDay.getTime() === today.getTime()) {
            // Today: Format as time
            return callDate.toLocaleTimeString(Qt.locale(),
                                                Theme.is24HourFormat ? "hh:mm" : "h:mm AP")
        } else if (callDay.getTime() === yesterday.getTime()) {
            // Yesterday
            return "Yesterday"
        } else {
            const diffTime = today.getTime() - callDay.getTime()
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

            if (diffDays > 1 && diffDays <= 6) {
                // Within the last week (2-6 days ago)
                return diffDays + " days ago"
            } else {
                // Older than a week: Format as "Month Day"
                return callDate.toLocaleDateString(Qt.locale(), "MMMM d")
            }
        }
    }
}
