#ifndef MODBUSMASTER_H
#define MODBUSMASTER_H

#include <QQmlContext>
#include <QSerialPort>
#include <QModbusDataUnit>
#include <QModbusRtuSerialMaster>
#include <QTimer>
#include <QTime>
#include "log.h"
#include "stand_defs.h"
#include <QMessageBox>
#include "Requester.h"

class SettingsDialog;
class QModbusClient;

class ModBusMaster: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool status MEMBER m_state NOTIFY m_onSateChanged)
    Q_PROPERTY(QVariantList slaveAdress MEMBER m_slaveAdress)

public:
    ModBusMaster(QQmlContext *context,QObject *parent = nullptr);
    ~ModBusMaster();
    bool flag = true;

    void connectDevice();
    void unConnectDevice();
    void readRequest(QModbusDataUnit::RegisterType typeRegister,int startAdress,int count,int slaveAdress);
    void writeRequest(QModbusDataUnit writeUnit, int slaveAdress);
    void readId(int adress);
    void readyReadId();
    bool getDeviceState();

    SettingsDialog* connectionSettings = nullptr;
    QModbusDataUnit* getDataUnit();
    QVariantList m_slaveAdress;
    QModbusDevice::Error m_replyErr; //QModbusResponse
    QModbusResponse m_reply;
    int currentAdress;

signals:
    void m_onSateChanged();
    void logAdded();

private:
    bool m_state = false; /*!< Состояние устройства */
    QModbusClient *m_modbusDevice = nullptr; /*!< Modbus устройство */
    QQmlContext *m_context = nullptr;
    QModbusDataUnit *m_unit = nullptr;
    int32_t *m_data;
    Log m_log;
    QTime m_startTime;
    QTime m_endTime;
    QMessageBox m_messageBox;
    QModbusReply *lastReadRequest = nullptr;
    QModbusReply *lastWriteRequest = nullptr;

    void initActionsConnections();
    void readReady();
    void changedSatate();
};

#endif // MODBUSMASTER_H
