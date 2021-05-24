#include "settingsDialog.h"
#include <QSerialPortInfo>
#include <QDebug>
#include <QVariantMap>
#include <QComboBox>
#include <QTimer>


SettingsDialog::SettingsDialog(QObject *parent) :
    QObject(parent), m_updatePortsInfo(new QTimer)
{
    connect(m_updatePortsInfo, &QTimer::timeout, this, &SettingsDialog::fillPortsInfo);

    m_updatePortsInfo->start(500);
    m_updatePortsInfo->setSingleShot(false);
    m_currentNamePort = "нет данных";

}

SettingsDialog::~SettingsDialog() {
    delete (m_updatePortsInfo);
}

SettingsDialog::Settings SettingsDialog::getSettings() const {
    return m_currentSettings;
}

void SettingsDialog::apply() {

}

void SettingsDialog::fillPortParameters() {

}

void SettingsDialog::fillPortsInfo() {
    m_portsInfoList.clear();

    const auto infoPorts = QSerialPortInfo::availablePorts();
    QVariantMap test;
    for (const QSerialPortInfo &info : infoPorts) {
        test.insert("name",info.portName() ); //+ " " + info.description()
        m_portsInfoList.append(test);
    }
    onFillPortsInfo();
}

void SettingsDialog::updateSettings(QString namePort, int baudRate,
                                        int dataBits, int parity, int stopBits) {
    m_currentSettings.name = namePort;
    m_currentNamePort = namePort;
    m_currentSettings.baudRate = static_cast<QSerialPort::BaudRate>(baudRate);
    m_currentSettings.dataBits = static_cast<QSerialPort::DataBits>(dataBits);
    m_currentSettings.parity = static_cast<QSerialPort::Parity>(parity);
    m_currentSettings.stopBits = static_cast<QSerialPort::StopBits>(stopBits);
    m_currentSettings.flowControl = QSerialPort::FlowControl::HardwareControl;
}
