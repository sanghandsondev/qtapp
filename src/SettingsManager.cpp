#include "SettingsManager.hpp"

// Initialize static constants
const QString SettingsManager::KEY_IS_DARK = "theme/isDark";
const QString SettingsManager::KEY_IS_24_HOUR_FORMAT = "theme/is24HourFormat";
const QString SettingsManager::KEY_SOUND_TOUCH_ENABLED = "theme/soundTouchEnabled";
const QString SettingsManager::KEY_VOLUME_LEVEL = "theme/volumeLevel";
const QString SettingsManager::KEY_BLUETOOTH_ENABLED = "system/bluetoothEnabled";

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent), m_settings("MyCompany", "QtApp") // Tên tổ chức và tên ứng dụng
{
    qDebug() << "SettingsManager initialized. Settings file:" << m_settings.fileName();
}

// -- Specific getters for properties --

bool SettingsManager::getIsDark() const
{
    return m_settings.value(KEY_IS_DARK, true).toBool();
}

bool SettingsManager::getIs24HourFormat() const
{
    return m_settings.value(KEY_IS_24_HOUR_FORMAT, true).toBool();
}

bool SettingsManager::getSoundTouchEnabled() const
{
    return m_settings.value(KEY_SOUND_TOUCH_ENABLED, true).toBool();
}

int SettingsManager::getVolumeLevel() const
{
    return m_settings.value(KEY_VOLUME_LEVEL, 4).toInt();
}

bool SettingsManager::getBluetoothEnabled() const
{
    // Default to false for Bluetooth
    return m_settings.value(KEY_BLUETOOTH_ENABLED, false).toBool();
}

// -- Specific setters for properties --

void SettingsManager::setIsDark(bool isDark)
{
    if (getIsDark() != isDark) {
        m_settings.setValue(KEY_IS_DARK, isDark);
        emit onIsDarkChanged();       
    }
}

void SettingsManager::setIs24HourFormat(bool is24HourFormat)
{
    if (getIs24HourFormat() != is24HourFormat) {
        m_settings.setValue(KEY_IS_24_HOUR_FORMAT, is24HourFormat);
        emit onIs24HourFormatChanged();
    }
}

void SettingsManager::setSoundTouchEnabled(bool soundTouchEnabled)
{
    if (getSoundTouchEnabled() != soundTouchEnabled) {
        m_settings.setValue(KEY_SOUND_TOUCH_ENABLED, soundTouchEnabled);
        emit onSoundTouchEnabledChanged();
    }
}

void SettingsManager::setVolumeLevel(int volumeLevel)
{
    if (volumeLevel >= 0 && volumeLevel <= 5 && getVolumeLevel() != volumeLevel) {
        m_settings.setValue(KEY_VOLUME_LEVEL, volumeLevel);
        emit onVolumeLevelChanged();
    }
}

void SettingsManager::setBluetoothEnabled(bool bluetoothEnabled)
{
    if (getBluetoothEnabled() != bluetoothEnabled) {
        m_settings.setValue(KEY_BLUETOOTH_ENABLED, bluetoothEnabled);
        emit onBluetoothEnabledChanged();
    }
}
