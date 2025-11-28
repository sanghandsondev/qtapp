#ifndef SETTINGS_MANAGER_HPP
#define SETTINGS_MANAGER_HPP

#include <QObject>
#include <QSettings>
#include <QVariant>
#include <QtQml/qqml.h>

class SettingsManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT     // QML_ELEMENT để đăng ký class này cho QML

    // Properties for QML binding
    // Q_PROPERTY (type name READ getter WRITE setter NOTIFY signal)
    Q_PROPERTY(bool isDark READ getIsDark WRITE setIsDark NOTIFY onIsDarkChanged)
    Q_PROPERTY(bool is24HourFormat READ getIs24HourFormat WRITE setIs24HourFormat NOTIFY onIs24HourFormatChanged)
    Q_PROPERTY(bool soundTouchEnabled READ getSoundTouchEnabled WRITE setSoundTouchEnabled NOTIFY onSoundTouchEnabledChanged)
    Q_PROPERTY(int volumeLevel READ getVolumeLevel WRITE setVolumeLevel NOTIFY onVolumeLevelChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    // Generic getters/setters (can be kept for other settings)
    // Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    // Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    // Specific getters for properties
    bool getIsDark() const;
    bool getIs24HourFormat() const;
    bool getSoundTouchEnabled() const;
    int getVolumeLevel() const;

public slots:
    // Specific setters for properties
    void setIsDark(bool isDark);
    void setIs24HourFormat(bool is24HourFormat);
    void setSoundTouchEnabled(bool soundTouchEnabled);
    void setVolumeLevel(int volumeLevel);

signals:
    // Phát tín hiệu thay đổi, QML sẽ nhận biết và cập nhật giao diện
    void onIsDarkChanged();
    void onIs24HourFormatChanged();
    void onSoundTouchEnabledChanged();
    void onVolumeLevelChanged();

private:
    QSettings m_settings;

    // Define keys as constants to avoid typos and for easier management
    static const QString KEY_IS_DARK;
    static const QString KEY_IS_24_HOUR_FORMAT;
    static const QString KEY_SOUND_TOUCH_ENABLED;
    static const QString KEY_VOLUME_LEVEL;
};

#endif // SETTINGS_MANAGER_HPP
