#include "SettingsManager.hpp"

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent), m_settings("MyCompany", "QtApp") // Tên tổ chức và tên ứng dụng
{
    qDebug() << "SettingsManager initialized. Settings file:" << m_settings.fileName();
}

// QVariant SettingsManager::value(const QString &key, const QVariant &defaultValue) const
// {
//     QVariant val = m_settings.value(key, defaultValue);
//     qDebug() << "SettingsManager READ:" << key << "- Value:" << val;
//     return val;
// }

// void SettingsManager::setValue(const QString &key, const QVariant &value)
// {
//     if (m_settings.value(key) != value) {
//         m_settings.setValue(key, value);
//         qDebug() << "SettingsManager WRITE:" << key << "=" << value;
//     }
// }

// -- Specific getters for properties --

bool SettingsManager::getIsDark() const
{
    return m_settings.value("theme/isDark", true).toBool();
}

bool SettingsManager::getIs24HourFormat() const
{
    return m_settings.value("theme/is24HourFormat", true).toBool();
}

bool SettingsManager::getSoundTouchEnabled() const
{
    return m_settings.value("theme/soundTouchEnabled", true).toBool();
}

int SettingsManager::getVolumeLevel() const
{
    return m_settings.value("theme/volumeLevel", 4).toInt();
}

// -- Specific setters for properties --

void SettingsManager::setIsDark(bool isDark)
{
    if (this->getIsDark() != isDark) {
        m_settings.setValue("theme/isDark", isDark);
        emit onIsDarkChanged();       
    }
}

void SettingsManager::setIs24HourFormat(bool is24HourFormat)
{
    if (this->getIs24HourFormat() != is24HourFormat) {
        m_settings.setValue("theme/is24HourFormat", is24HourFormat);
        emit onIs24HourFormatChanged();
    }
}

void SettingsManager::setSoundTouchEnabled(bool soundTouchEnabled)
{
    if (this->getSoundTouchEnabled() != soundTouchEnabled) {
        m_settings.setValue("theme/soundTouchEnabled", soundTouchEnabled);
        emit onSoundTouchEnabledChanged();
    }
}

void SettingsManager::setVolumeLevel(int volumeLevel)
{
    if (volumeLevel >= 0 && volumeLevel <= 5 && this->getVolumeLevel() != volumeLevel) {
        m_settings.setValue("theme/volumeLevel", volumeLevel);
        emit onVolumeLevelChanged();
    }
}
