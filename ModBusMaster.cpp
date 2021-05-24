#include <QEventLoop>
#include <QModbusPdu>
#include <QModbusResponse>
#include "ModBusMaster.h"
#include "settingsDialog.h"
#include "log.h"


ModBusMaster::ModBusMaster(QQmlContext *context, QObject *parent) :
    connectionSettings (new SettingsDialog),
    m_context (context),
    m_unit (new QModbusDataUnit)
{

    m_messageBox.setFixedSize(500, 200);

    QModbusRtuSerialMaster* pxModbusMaster = new QModbusRtuSerialMaster(this);
    pxModbusMaster->setInterFrameDelay(10000);
    qDebug() << pxModbusMaster->interFrameDelay();

    m_modbusDevice = pxModbusMaster;
    initActionsConnections();

    if(m_modbusDevice) {
        connect(m_modbusDevice, &QModbusClient::stateChanged,
                this, &ModBusMaster::changedSatate);
    }
}

ModBusMaster::~ModBusMaster() {
    delete connectionSettings;
    delete m_unit;
    if(m_modbusDevice)
            m_modbusDevice->disconnectDevice();
    delete m_modbusDevice;
}

void ModBusMaster::connectDevice() {
    if(!m_modbusDevice) {
        m_messageBox.critical(nullptr,"Error","ModBusMaster::setConnected() - !m_modbusDevice");
//        qDebug()<< "ModBusMaster::setConnected() - !m_modbusDevice";
        return;
    }
    const SettingsDialog::Settings currentSettings = connectionSettings->getSettings();
    if(m_modbusDevice->state() != QModbusDevice::ConnectedState) { // NOTE: clear connections parameters
        m_modbusDevice->setConnectionParameter(QModbusDevice::SerialPortNameParameter, currentSettings.name);
        m_modbusDevice->setConnectionParameter(QModbusDevice::SerialDataBitsParameter, currentSettings.dataBits);
        m_modbusDevice->setConnectionParameter(QModbusDevice::SerialParityParameter, QSerialPort::NoParity);
        m_modbusDevice->setConnectionParameter(QModbusDevice::SerialBaudRateParameter, currentSettings.baudRate);
        m_modbusDevice->setConnectionParameter(QModbusDevice::SerialStopBitsParameter, currentSettings.stopBits);

        m_modbusDevice->setTimeout(1000);
        m_modbusDevice->setNumberOfRetries(3);

        if(!m_modbusDevice->connectDevice()) {
            m_messageBox.critical(nullptr,"Error","Подключение не удалось: " + m_modbusDevice->errorString());
        }
    }
}

void ModBusMaster::unConnectDevice() {
    if(m_modbusDevice) {
        m_modbusDevice->disconnectDevice();
    }
    else {
        m_messageBox.critical(nullptr,"Error","Выбран неверный COM-порт");
    }
}

void ModBusMaster::readRequest(QModbusDataUnit::RegisterType typeRegister, int startAdress,
                                                                    int count, int slaveAdress) {
    if (auto *lastRequest = m_modbusDevice->sendReadRequest( QModbusDataUnit(typeRegister, startAdress, count), slaveAdress)) {
        if (!lastRequest->isFinished()){
            QEventLoop loop;
            connect(lastRequest, &QModbusReply::finished, &loop, &QEventLoop::quit);
            connect(lastRequest, &QModbusReply::finished, this, &ModBusMaster::readReady);
            loop.exec();
        }
        else
            delete lastRequest;
    } else {
       m_messageBox.critical(nullptr, "Error", "Read error: " + m_modbusDevice->errorString());
       m_log.addErrorLog("error",m_modbusDevice->errorString());
    }
    m_replyErr = m_modbusDevice->error();
}

void ModBusMaster::readReady() {
    auto lastRequest = qobject_cast<QModbusReply *>(sender());
    lastReadRequest = lastRequest;
    if (!lastRequest) {
        m_messageBox.critical(nullptr,"Error","!lastRequest");
    }
    if (lastRequest->error() == QModbusDevice::NoError) {
        *m_unit = lastRequest->result();
        m_log.addRWLog("read", "ImputRegisters", m_unit->startAddress(),
                       m_unit->valueCount(), 0x1100, lastRequest->result().values());
    } else if (lastRequest->error() == QModbusDevice::ProtocolError) {
        m_messageBox.critical(nullptr,"Error",tr( "Read response error: %1 (Mobus exception: 0x%2").
                            arg(lastRequest->errorString()).
                            arg(lastRequest->rawResult().exceptionCode()));
         m_log.addErrorLog("Read response error:",lastRequest->errorString()
                           + " Mobus exception: 0x" + lastRequest->rawResult().exceptionCode());
    } else {
          m_messageBox.critical(nullptr,"Error",tr("Read response error: %1 (code: 0x%2)").
                    arg(lastRequest->errorString()).
                    arg(lastRequest->error()));
          m_log.addErrorLog("Read response error:",lastRequest->errorString()
                            + " code: 0x" + lastRequest->error());
      }
    lastRequest->deleteLater();
}

void ModBusMaster::writeRequest(QModbusDataUnit writeUnit, int slaveAdress) {
    if (!m_modbusDevice)
        return;
    if (auto *lastRequest = m_modbusDevice->sendWriteRequest(writeUnit, slaveAdress)) { //адрес нач.
        if (!lastRequest->isFinished()) {
            connect(lastRequest, &QModbusReply::finished, this, [this, lastRequest]() {
                if (lastRequest->error() == QModbusDevice::ProtocolError) {
                  m_messageBox.critical(nullptr,"Error", tr("Write response error: %1 (Mobus exception: 0x%2)")
                        .arg(lastRequest->errorString()).arg(lastRequest->rawResult().exceptionCode(), -1, 16));
                } else if (lastRequest->error() != QModbusDevice::NoError) {
                   m_messageBox.critical(nullptr,"Error",tr("Write response error: %1 (code: 0x%2)").
                        arg(lastRequest->errorString()).arg(lastRequest->error(), -1, 16));
                }
                lastRequest->deleteLater();
            });
            m_log.addRWLog("write", "ImputRegisters", writeUnit.startAddress(),
                           writeUnit.valueCount(), slaveAdress, writeUnit.values());
        } else {
            lastRequest->deleteLater();
        }
    } else {
      m_messageBox.critical(nullptr,"Error",tr("Write error: ") + m_modbusDevice->errorString());
       m_log.addErrorLog("Write error: ", m_modbusDevice->errorString());
    }
}

void ModBusMaster::readId(int adress) {
    QByteArray data;
    QModbusRequest request(QModbusPdu::ReportServerId, data);
    if( auto reply = m_modbusDevice->sendRawRequest(request, adress) ) {
        if (!reply->isFinished()) {
            QEventLoop loop;
            connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
            connect(reply, &QModbusReply::finished, this, &ModBusMaster::readyReadId);
            loop.exec();
        } else {
              reply->deleteLater();
          }
    } else {
         m_messageBox.critical(nullptr,"Error", tr("Write error: ") + m_modbusDevice->errorString());
    } 
}

void ModBusMaster::readyReadId() {
    auto reply = qobject_cast<QModbusReply *>(sender());
    if (!reply)
        m_messageBox.critical(nullptr,"Error","!lastRequest");
    m_replyErr = reply->error();
    if (reply->error() == QModbusDevice::NoError) {
        m_replyErr = reply->error();
    } else if (reply->error() == QModbusDevice::ProtocolError) {
       m_messageBox.critical(nullptr,"Error",tr( "Read response error: %1 (Mobus exception: 0x%2").
                      arg(reply->errorString()).
                      arg(reply->rawResult().exceptionCode()));
        m_log.addErrorLog("Read response error:",reply->errorString()
                               + " Mobus exception: 0x" + reply->rawResult().exceptionCode());
    } else {
        m_messageBox.critical(nullptr,"Error",tr("Read response error: %1 (code: 0x%2)").
                  arg(reply->errorString()).
                  arg(reply->error()));
        m_log.addErrorLog("Read response error:",reply->errorString()
                                + " code: 0x" + reply->error());
    }
    reply->deleteLater();
}

bool ModBusMaster::getDeviceState() {
    if( m_modbusDevice->state() == QModbusDevice::ConnectedState)
        return true;
    else
        return false;
}

void ModBusMaster::changedSatate() {
    if (m_modbusDevice->state() == QModbusDevice::UnconnectedState)
        m_state = false;
    else if (m_modbusDevice->state() == QModbusDevice::ConnectedState)
        m_state = true;
    m_onSateChanged();
}

void ModBusMaster::initActionsConnections() {
    m_context->setContextProperty("master", this);
    m_context->setContextProperty("settingsDialog", connectionSettings);
    m_context->setContextProperty("log", &m_log);
}

QModbusDataUnit* ModBusMaster::getDataUnit() {
    return m_unit;
}
