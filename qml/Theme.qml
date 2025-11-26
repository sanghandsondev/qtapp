pragma Singleton
import QtQuick 6.4
import com.company.settings 1.0

QtObject {
    readonly property SettingsManager settingsManager: SettingsManager { id: _settingsManager }

    // Dark mode setting
    property alias isDark: _settingsManager.isDark
    function toggle() {
        _settingsManager.isDark = !_settingsManager.isDark
    }

    // Time format setting
    property alias is24HourFormat: _settingsManager.is24HourFormat
    function toggleTimeFormat() {
        _settingsManager.is24HourFormat = !_settingsManager.is24HourFormat
    }

    // Sound Touch setting
    property alias soundTouchEnabled: _settingsManager.soundTouchEnabled
    function toggleSoundTouch() {
        _settingsManager.soundTouchEnabled = !_settingsManager.soundTouchEnabled
    }

    // Volume setting (0-5 levels)
    property alias volumeLevel: _settingsManager.volumeLevel
    function setVolumeLevel(level) {
        if (level >= 0 && level <= 5) {
            _settingsManager.volumeLevel = level
        }
    }
    readonly property real volume: _settingsManager.volumeLevel / 5.0

    // Define colors based on the theme
    readonly property color primaryBg: isDark ? "#111827" : "#f9fafb"      // Main background
    readonly property color secondaryBg: isDark ? "#1f2937" : "#f3f4f6"    // Sidebar, etc.
    readonly property color tertiaryBg: isDark ? "#374151" : "#e5e7eb"     // Buttons, selected items
    readonly property color primaryText: isDark ? "#e5e7eb" : "#1f2937"    // Main text
    readonly property color secondaryText: isDark ? "#9ca3af" : "#6b7280"   // Subtitles, descriptions
    readonly property color separator: isDark ? "#374151" : "#d1d5db"       // Separator lines
    readonly property color icon: isDark ? "#e5e7eb" : "#4b5563"
    readonly property color iconSubtle: isDark ? "#cbd5e1" : "#6b7280"
    readonly property color buttonBorder: isDark ? "#4b5563" : "#d1d5db"
    readonly property color toggleOn: primaryText
    readonly property color toggleOff: isDark ? "#6b7280" : "#9ca3af"
    readonly property color bannerBg: isDark ? "#374151" : "#e5e7eb"
    readonly property color accent: isDark ? "#ef4444" : "#dc2626" // Red
    readonly property color accentSubtle: isDark ? "#991b1b" : "#fca5a5" // Lighter/darker red for borders
    readonly property color success: isDark ? "#22c55e" : "#16a34a" // Green for success states
}
