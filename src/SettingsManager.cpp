#include "SettingsManager.hpp"

// Initialize static constants
const QString SettingsManager::KEY_IS_DARK = "theme/isDark";
const QString SettingsManager::KEY_IS_24_HOUR_FORMAT = "theme/is24HourFormat";
const QString SettingsManager::KEY_SOUND_TOUCH_ENABLED = "theme/soundTouchEnabled";
const QString SettingsManager::KEY_VOLUME_LEVEL = "theme/volumeLevel";
const QString SettingsManager::KEY_BLUETOOTH_ENABLED = "system/bluetoothEnabled";
const QString SettingsManager::KEY_AUDIO_OUTPUT_DEVICE = "sound/audioOutputDevice";
const QString SettingsManager::KEY_BRIGHTNESS_LEVEL = "theme/brightnessLevel";

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

qreal SettingsManager::getVolumeLevel() const
{
    // Default to 0.8 (which corresponds to level 4 out of 5)
    return m_settings.value(KEY_VOLUME_LEVEL, 0.8).toReal();
}

bool SettingsManager::getBluetoothEnabled() const
{
    // Default to false for Bluetooth
    return m_settings.value(KEY_BLUETOOTH_ENABLED, false).toBool();
}

QString SettingsManager::getAudioOutputDevice() const
{
    // Default to an empty string, SoundManager will use the system default
    return m_settings.value(KEY_AUDIO_OUTPUT_DEVICE, "").toString();
}

qreal SettingsManager::getBrightnessLevel() const
{
    // Default to 1.0 (100% brightness)
    return m_settings.value(KEY_BRIGHTNESS_LEVEL, 1.0).toReal();
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

void SettingsManager::setVolumeLevel(qreal volumeLevel)
{
    // Clamp the value between 0.0 and 1.0
    volumeLevel = qBound(0.0, volumeLevel, 1.0);
    if (getVolumeLevel() != volumeLevel) {
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

void SettingsManager::setAudioOutputDevice(const QString &audioOutputDevice)
{
    if (getAudioOutputDevice() != audioOutputDevice) {
        m_settings.setValue(KEY_AUDIO_OUTPUT_DEVICE, audioOutputDevice);
        emit onAudioOutputDeviceChanged();
    }
}

void SettingsManager::setBrightnessLevel(qreal brightnessLevel)
{
    // Clamp the value between 0.1 and 1.0 to prevent screen from being completely black
    brightnessLevel = qBound(0.1, brightnessLevel, 1.0);
    if (getBrightnessLevel() != brightnessLevel) {
        m_settings.setValue(KEY_BRIGHTNESS_LEVEL, brightnessLevel);
        emit onBrightnessLevelChanged();
    }
}
