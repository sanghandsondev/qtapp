#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include <QVariant>
#include <QtQml/qqml.h>

class SettingsManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT     // QML_ELEMENT để đăng ký class này cho QML

    // Properties for QML binding
    Q_PROPERTY(bool isDark READ isDark WRITE setIsDark NOTIFY isDarkChanged)
    Q_PROPERTY(bool is24HourFormat READ is24HourFormat WRITE setIs24HourFormat NOTIFY is24HourFormatChanged)
    Q_PROPERTY(bool soundTouchEnabled READ soundTouchEnabled WRITE setSoundTouchEnabled NOTIFY soundTouchEnabledChanged)
    Q_PROPERTY(int volumeLevel READ volumeLevel WRITE setVolumeLevel NOTIFY volumeLevelChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    // Generic getters/setters (can be kept for other settings)
    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    // Specific getters for properties
    bool isDark() const;
    bool is24HourFormat() const;
    bool soundTouchEnabled() const;
    int volumeLevel() const;

public slots:
    // Specific setters for properties
    void setIsDark(bool isDark);
    void setIs24HourFormat(bool is24HourFormat);
    void setSoundTouchEnabled(bool soundTouchEnabled);
    void setVolumeLevel(int volumeLevel);

signals:
    void isDarkChanged();
    void is24HourFormatChanged();
    void soundTouchEnabledChanged();
    void volumeLevelChanged();

private:
    QSettings m_settings;
};

#endif // SETTINGSMANAGER_H
