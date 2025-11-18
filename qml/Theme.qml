pragma Singleton
import QtQuick 6.4

QtObject {
    property bool isDark: true

    function toggle() {
        isDark = !isDark
    }

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
    readonly property color accent: isDark ? "#3b82f6" : "#2563eb" // Blue for primary actions
}
