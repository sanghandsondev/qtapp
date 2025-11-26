#include "SettingsManager.h"
#include <QDebug>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent), m_settings("MyCompany", "QtApp") // Tên tổ chức và tên ứng dụng
{
    qDebug() << "SettingsManager initialized. Settings file:" << m_settings.fileName();
}

QVariant SettingsManager::value(const QString &key, const QVariant &defaultValue) const
{
    QVariant val = m_settings.value(key, defaultValue);
    qDebug() << "SettingsManager READ:" << key << "- Value:" << val;
    return val;
}

void SettingsManager::setValue(const QString &key, const QVariant &value)
{
    if (m_settings.value(key) != value) {
        m_settings.setValue(key, value);
        qDebug() << "SettingsManager WRITE:" << key << "=" << value;
    }
}

// --- Implementation for new properties ---

bool SettingsManager::isDark() const
{
    return m_settings.value("theme/isDark", true).toBool();
}

void SettingsManager::setIsDark(bool isDark)
{
    if (this->isDark() != isDark) {
        m_settings.setValue("theme/isDark", isDark);
        emit isDarkChanged();
    }
}

bool SettingsManager::is24HourFormat() const
{
    return m_settings.value("theme/is24HourFormat", false).toBool();
}

void SettingsManager::setIs24HourFormat(bool is24HourFormat)
{
    if (this->is24HourFormat() != is24HourFormat) {
        m_settings.setValue("theme/is24HourFormat", is24HourFormat);
        emit is24HourFormatChanged();
    }
}

bool SettingsManager::soundTouchEnabled() const
{
    return m_settings.value("theme/soundTouchEnabled", true).toBool();
}

void SettingsManager::setSoundTouchEnabled(bool soundTouchEnabled)
{
    if (this->soundTouchEnabled() != soundTouchEnabled) {
        m_settings.setValue("theme/soundTouchEnabled", soundTouchEnabled);
        emit soundTouchEnabledChanged();
    }
}

int SettingsManager::volumeLevel() const
{
    return m_settings.value("theme/volumeLevel", 5).toInt();
}

void SettingsManager::setVolumeLevel(int volumeLevel)
{
    if (volumeLevel >= 0 && volumeLevel <= 5 && this->volumeLevel() != volumeLevel) {
        m_settings.setValue("theme/volumeLevel", volumeLevel);
        emit volumeLevelChanged();
    }
}
