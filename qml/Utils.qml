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
}
