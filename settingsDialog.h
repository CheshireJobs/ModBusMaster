#ifndef SETTINGSDIALOG_H
#define SETTINGSDIALOG_H

#include <QObject>
#include <QSerialPort>
#include <QVariantList>
#include <QComboBox>
#include <QDebug>

class SettingsDialog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList portsInfoList MEMBER m_portsInfoList NOTIFY onFillPortsInfo)
    Q_PROPERTY(QString m_currentNamePort MEMBER m_currentNamePort NOTIFY onFillPortsInfo )

//Settings m_currentSettings;
public:
    struct Settings {
        QString name;
        qint32 baudRate;
        QSerialPort::DataBits dataBits;
        QSerialPort::Parity parity;
        QSerialPort::StopBits stopBits;
        QSerialPort::FlowControl flowControl;
        bool localEchoEnabled;
    };

    explicit SettingsDialog(QObject *parent = nullptr);
    ~SettingsDialog();
    Settings getSettings() const;

public slots:
    void apply();
    void updateSettings(QString namePort, int baudRate,
                        int dataBits, int parity, int stopBits);

signals:
    void onFillPortsInfo();


private slots:
    void fillPortParameters();
    void fillPortsInfo();

private:
    Settings m_currentSettings;
    QString m_currentNamePort;
    QVariantList m_portsInfoList;
    QTimer *m_updatePortsInfo;
};

#endif // SETTINGSDIALOG_H
