#include "StandTester.h"
#include <QDebug>
#include <QList>

StandTester::StandTester(QQmlContext *context, QObject *parent) :
    m_context (context),
    m_modBusMaster (new ModBusMaster(context))
{
    m_currentDiscreteMode = STAND_MODE_DISABLE_OUTPUTS;
    m_messageBox.setFixedSize(500, 200);

    m_timerStopTest.setInterval(1000);

    connect(&m_timerStopTest, &QTimer::timeout, this, &StandTester::readCurrentMode);
    connect(this, &StandTester::onStopTestByCar, this, &StandTester::stndDisconnect);

}

StandTester::~StandTester() {
    delete m_modBusMaster;
}

bool StandTester::connectDevice(QString namePort, int baudRate, int dataBits, int parity, int stopBits) {
    m_modBusMaster->connectionSettings->updateSettings( namePort, baudRate, dataBits, parity, stopBits);
    m_modBusMaster->connectDevice();
    if( getDeviceInfo(1) != 48) { // проверка на соотвествие нашему устройству
        m_modBusMaster->unConnectDevice();
        m_messageBox.critical(nullptr,"Error","Подключение не удалось, выбран неверный COM-порт.");
        return false;
    } else {
        return true;
    }
}

void StandTester::disconnectDevice() {
    m_modBusMaster->unConnectDevice();
}

int StandTester::getDeviceInfo(int slaveAdress) {
    m_modBusMaster->readRequest(QModbusDataUnit::InputRegisters, 0x1000, 62, slaveAdress);
    if(m_modBusMaster->m_replyErr == QModbusDevice::Error::NoError) {
        auto tmpArr = m_modBusMaster->getDataUnit()->values();
        AppStruct_Base_Params_t* data = reinterpret_cast<AppStruct_Base_Params_t*>(tmpArr.data());
        QString infoText;
    //    infoText = tr( "ID: %1"
    //                        " \nВерсия платы: %2"
    //                        " \nВерсия прошивки старшая и младшая: %3"
    //                        " \nВерсия прошивки: %4"
    //                        " \nПроизводитель платы: %5"
    //                        " \nНазвание продукта: %6"
    //                        " \nНазвание модели: %7 "
    //                        " \nURL: %8"
    //                        " \nВерсия протокола связи: %9"
    //                        " \nКоличество интерфейсов: %10"
    //                        " \nКоличество аналоговых входов: %11"
    //                        " \nКоличество дискретных входов: %12"
    //                        " \nКоличество аналоговых выходов: %13"
    //                        " \nКоличество дискретных выходов: %14" ).
    //            arg(data->ID).arg(data->Version).
    //            arg(data->FWVerMajorMinor).arg(data->FWVerRelease).arg(data->Vendor).arg(data->ProductName).
    //            arg(data->ModelName).arg(data->URL).arg(data->CommVersion).arg(data->InterfaceCount).
    //            arg(data->AnalogueInputsCount).arg(data->DiscreteInputsCount).arg(data->AnalogueOutputsCount).
    //            arg(data->DiscreteOutputsCount);
        return data->ID;
    }
    else {
        return 0;
    }
}

void StandTester::startTest(QVector<int> discreteOutputs,
                            int mode, DiscreteOutSequenceModel* discreteOutSequenceModel, int delayValue, int countCycleValue) {
    m_currentDiscreteMode = static_cast<Stand_Mode_t>(mode);

    if (m_currentDiscreteMode == 0)
        return;

    if (m_currentDiscreteMode == 1) {
        int countDiscreteRegisters = App_Bits_To_Bytes_N(discreteOutputs.count(), 16);
        QVector<uint16_t> outputsDiscrete;
        for(int i = 0; i < countDiscreteRegisters; ++i)
            outputsDiscrete.append(0);
        int j = 0;
        for( int i = 0 ; i < discreteOutputs.count() ; ++i) {
            if(discreteOutputs[i])
                outputsDiscrete[j] = Set_Bit(outputsDiscrete[j], (i % (discreteOutputs.count()/countDiscreteRegisters)) );
            if( (i+1) % (discreteOutputs.count()/countDiscreteRegisters) == 0 && i != 0 ) ++j;
        }
        /// mode
        QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_DO , m_discreteSlaveAdress);
        QVector<quint16> data;
        data.append(((quint16*)&m_currentDiscreteMode)[0]);
        writeUnitMode.setValues(data);
        m_modBusMaster->writeRequest( writeUnitMode, m_discreteSlaveAdress);

        /// end mode
        // запись значений выходов дискретов в регистры
        QModbusDataUnit writeUnit = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_DO,
                                                            countDiscreteRegisters);
        writeUnit.setValues(outputsDiscrete);
        m_modBusMaster->writeRequest( writeUnit, m_discreteSlaveAdress); // NOTE : m_currentSlaveAdress

    } else if ( m_currentDiscreteMode == 2) {
        QVector<Stand_Discrete_Seq_Item_t> discreteOutSequensce = discreteOutSequenceModel->getDicreteOutSeq();
        int countDiscreteRowRegisters = m_discreteOutInfo.OutputCountDiscrete / 8 / 2 + 4 / 2; //кол-вол регистров на дискреты + задережку

        QModbusDataUnit writeUnitSeq;

        QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_DO, 1);
        QVector<quint16> data;
        m_currentDiscreteMode = STAND_MODE_SET_VALUE;
        data.append(((quint16*)&m_currentDiscreteMode)[0]);
        writeUnitMode.setValues(data);
        m_modBusMaster->writeRequest( writeUnitMode, m_discreteSlaveAdress);

        m_currentDiscreteMode = STAND_MODE_SEQUENCE;
        QVector<quint16> dataSeq2;

        int countRows = discreteOutSequensce.count();
        int i = 0;
        int countRowsToSend = 0;

        while (countRows) {
            countRowsToSend = countRows > 30 ? 30 : countRows; // 30 - max row count in 1 record
            writeUnitSeq = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                    STAND_MODBUS_ADDRESS_HR_SEQ_DO + (i * countDiscreteRowRegisters ),
                                                                            countRowsToSend * countDiscreteRowRegisters );
            for(int j = 0; j < countRowsToSend; ++j) {
                dataSeq2.append(((quint16*)&discreteOutSequensce[i+j].OutputsState)[0]);
                dataSeq2.append(((quint16*)&discreteOutSequensce[i+j].OutputsState)[1]);
                dataSeq2.append(((quint16*)&discreteOutSequensce[i+j].Delay)[0]);
                dataSeq2.append(((quint16*)&discreteOutSequensce[i+j].Delay)[1]);
            }

            writeUnitSeq.setValues(dataSeq2);
            m_modBusMaster->writeRequest( writeUnitSeq, m_discreteSlaveAdress);// запись последовательности
            countRows -= countRowsToSend;
            i += countRowsToSend;
            dataSeq2.clear();
        }

        //QVector<quint16>* dataSeq = reinterpret_cast<QVector<quint16>*>(&tmp);

        /// -----
        Stand_Outputs_Mode_Config_t structModeConfig;
        structModeConfig.Mode = m_currentDiscreteMode;
        structModeConfig.SequenceLen = discreteOutSequensce.count();
        structModeConfig.SequenceRepeat = countCycleValue;
        structModeConfig.SequencePause = delayValue;

        QModbusDataUnit writeUnitStruct = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_DO , 5);

         QVector<quint16> dataStruct;

         dataStruct.append(*((quint16*)&structModeConfig.Mode));
         dataStruct.append(*((quint16*)&structModeConfig.SequenceLen));
         dataStruct.append(*((quint16*)&structModeConfig.SequenceRepeat));
         dataStruct.append(((quint16*)(&structModeConfig.SequencePause))[0]);
         dataStruct.append(((quint16*)(&structModeConfig.SequencePause))[1]);
         //QVector<quint16>* dataStruct = reinterpret_cast<QVector<quint16>*>(test.data());
         writeUnitStruct.setValues(dataStruct);

         m_modBusMaster->writeRequest( writeUnitStruct, m_discreteSlaveAdress); // запись занчения
         m_timerStopTest.start();
    }
}

void StandTester::readCurrentMode() {
    Stand_Outputs_Mode_Config_t dataMode;
    m_modBusMaster->readRequest(QModbusDataUnit::HoldingRegisters, STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_DO,
                                5, 1); // данные дискретной платы

    auto modbusDataUnit = m_modBusMaster->getDataUnit()->values();
    Stand_Outputs_Mode_Config_t* data = reinterpret_cast<Stand_Outputs_Mode_Config_t*>(modbusDataUnit.data());
    dataMode = *data;

    if(dataMode.Mode == STAND_MODE_DISABLE_OUTPUTS) {
        onEndTestDiscrete();
        m_timerStopTest.stop();
    }
}

void StandTester::startAnalogTest(QVector<qreal> editedAnalogOutputs, int mode,
                                  AnalogOutSequenceModel *analogOutSequenceModel,
                                    int delayValue, int countCycleValue) {
    m_currentAnalogMode = static_cast<Stand_Mode_t>(mode);

    if (m_currentAnalogMode == 0)
        return;

    if (m_currentAnalogMode == 1) {

        m_analogOutputsState.clear();
        int countRegisters = 24; //App_Bits_To_Bytes_N(analogOutInfo.OutputCountAnalogue , 16); // TODO: проверка на заполненность данных

        QVector<float> testData;
        testData.clear();

        for(int i = 0; i < 12; ++i) { /// считывание из интерфейса
            testData.append(editedAnalogOutputs[i]);
        }

        QVector<quint16> writeData;
        writeData.clear();
        for(int i = 0; i < 12; ++i) {
            writeData.append( ((quint16*)&(testData[i]))[0] );
            writeData.append( ((quint16*)&(testData[i]))[1] );
        }

        ///mode
        QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_AO, 1);
        QVector<quint16> data;
        m_currentAnalogMode = STAND_MODE_SET_VALUE;
        data.append(((quint16*)&m_currentAnalogMode)[0]);
        writeUnitMode.setValues(data);
        m_modBusMaster->writeRequest( writeUnitMode, m_analogSlaveAdress);
        ///

        QModbusDataUnit writeUnit = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_AO,
                                                            countRegisters);
        writeUnit.setValues(writeData);
        m_modBusMaster->writeRequest(writeUnit, m_analogSlaveAdress);
    } else if ( m_currentAnalogMode == 2) {

        QVector<Stand_Analogue_Seq_Item_t> analogOutSequensce = analogOutSequenceModel->getAnalogOutSeq();
        int countAnalogSeqRegisters = ((analogOutSequenceModel->m_columnCount * 2) + 2) /** analogOutSequensce.count()*/; // (12*2) + 2
        QModbusDataUnit writeUnitSeq;

        QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_AO, 1);
        QVector<quint16> data;
        m_currentAnalogMode = STAND_MODE_SET_VALUE;
        data.append(((quint16*)&m_currentAnalogMode)[0]);
        writeUnitMode.setValues(data);
        m_modBusMaster->writeRequest( writeUnitMode, m_analogSlaveAdress);

        m_currentAnalogMode = STAND_MODE_SEQUENCE;
        QVector<quint16> dataSeq2;

        int cnt = 0;
        for(int i = 0; i < analogOutSequensce.count(); ++i) {
            for(int j = 0; j < analogOutSequenceModel->m_columnCount; j++) {
                dataSeq2.append(((quint16*)&analogOutSequensce[i].OutputsState[j])[0]);
                dataSeq2.append(((quint16*)&analogOutSequensce[i].OutputsState[j])[1]);
            }
            dataSeq2.append(((quint16*)&analogOutSequensce[i].Delay)[0]);
            dataSeq2.append(((quint16*)&analogOutSequensce[i].Delay)[1]);

            writeUnitSeq = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                         (STAND_MODBUS_ADDRESS_HR_SEQ_AO +
                                                            (i * countAnalogSeqRegisters)),
                                                                   countAnalogSeqRegisters);
            writeUnitSeq.setValues(dataSeq2);
            m_modBusMaster->writeRequest( writeUnitSeq, m_analogSlaveAdress);
            dataSeq2.clear();

        }
        //QVector<quint16>* dataSeq = reinterpret_cast<QVector<quint16>*>(&tmp);


        Stand_Outputs_Mode_Config_t structModeConfig;
        structModeConfig.Mode = m_currentAnalogMode;
        structModeConfig.SequenceLen = analogOutSequensce.count();
        structModeConfig.SequenceRepeat = countCycleValue;
        structModeConfig.SequencePause = delayValue;

        QModbusDataUnit writeUnitStruct = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_AO , 5);

         QVector<quint16> dataStruct;

         dataStruct.append(*((quint16*)&structModeConfig.Mode));
         dataStruct.append(*((quint16*)&structModeConfig.SequenceLen));
         dataStruct.append(*((quint16*)&structModeConfig.SequenceRepeat));
         dataStruct.append(((quint16*)(&structModeConfig.SequencePause))[0]);
         dataStruct.append(((quint16*)(&structModeConfig.SequencePause))[1]);
         //QVector<quint16>* dataStruct = reinterpret_cast<QVector<quint16>*>(test.data());
         writeUnitStruct.setValues(dataStruct);
         m_modBusMaster->writeRequest( writeUnitStruct, m_analogSlaveAdress);
    }
}

void StandTester::stopAnalogTest() {
    int countRegisters = 24; //App_Bits_To_Bytes_N(analogOutInfo.OutputCountAnalogue , 16); // TODO: проверка на заполненность данных

    QVector<float> testData;
    for(int i = 0; i < 12; ++i) {
        testData.append(0);
    }
//    qint16* writeData = reinterpret_cast<qint16*>(testData.data());

    QVector<quint16> writeData;
    for(int i = 0; i < 12; ++i) {
        writeData.append( ((quint16*)&(testData[i]))[0] );
        writeData.append( ((quint16*)&(testData[i]))[1] );
    }

    ///mode
    QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                    STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_AO, 1);
    QVector<quint16> data;
    m_currentAnalogMode = STAND_MODE_SET_VALUE;
    data.append(((quint16*)&m_currentAnalogMode)[0]);
    writeUnitMode.setValues(data);
    m_modBusMaster->writeRequest( writeUnitMode, m_analogSlaveAdress);
    ///___

    QModbusDataUnit writeUnit = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                    STAND_MODBUS_ADDRESS_HR_AO,
                                                        countRegisters);
    writeUnit.setValues(writeData);
    m_modBusMaster->writeRequest(writeUnit, m_analogSlaveAdress);
}

void StandTester::startTestTimer(int mode, int freqValTimer1, int dutyValTimer1,
                                 int freqValTimer2, int dutyValTimer2, int freqValTimer3, int dutyValTimer3,
                                 int freqValTimer4, int dutyValTimer4) {
    m_currentDiscreteMode = static_cast<Stand_Mode_t>(mode);

    if (m_currentDiscreteMode == 0)
        return;
    int countTimerRegisters = 8;

    QVector<quint16> dataTimers;
    dataTimers.append(*(quint16*)&freqValTimer1);
    dataTimers.append(*(quint16*)&dutyValTimer1);
    dataTimers.append(*(quint16*)&freqValTimer2);
    dataTimers.append(*(quint16*)&dutyValTimer2);
    dataTimers.append(*(quint16*)&freqValTimer3);
    dataTimers.append(*(quint16*)&dutyValTimer3);
    dataTimers.append(*(quint16*)&freqValTimer4);
    dataTimers.append(*(quint16*)&dutyValTimer4);

    QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_TIMER_OUTPUTS_CONFIG , 1);
    QVector<quint16> dataMode;
    dataMode.append(((quint16*)&m_currentDiscreteMode)[0]);
    writeUnitMode.setValues(dataMode);
    m_modBusMaster->writeRequest( writeUnitMode, 1);

    // запись значений выходов таймеров в регистры
    QModbusDataUnit writeUnitDataTimer = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                 STAND_MODBUS_ADDRESS_HR_TIM, countTimerRegisters);
    writeUnitDataTimer.setValues(dataTimers);
    m_modBusMaster->writeRequest( writeUnitDataTimer, 1); // NOTE : m_currentSlaveAdress
}

void StandTester::startTestSeqTimer(int mode, TimerOutSequenceModel *timerOutSequenceModel,
                                     int countCycleValue, int delayValue) {
    m_currentDiscreteMode = static_cast<Stand_Mode_t>(mode);

    if (m_currentDiscreteMode == 0)
        return;
    QVector<Stand_Timer_Seq_Item_t> timerOutSequensce =  timerOutSequenceModel->getTimerOutSeq();

    int countTimerSeqRegisters = 10 * timerOutSequensce.count();
    QVector<quint16> dataSeq2;
    for(int i = 0; i < timerOutSequensce.count(); ++i) {
        for(int j = 0; j < 4; ++j) {
            dataSeq2.append(*((quint16*)&timerOutSequensce[i].OutputsState[j].Frequency));
            dataSeq2.append(*((quint16*)&timerOutSequensce[i].OutputsState[j].Duty));
        }
        dataSeq2.append(((quint16*)&timerOutSequensce[i].Delay)[0]);
        dataSeq2.append(((quint16*)&timerOutSequensce[i].Delay)[1]);
    }

    QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                    STAND_MODBUS_ADDRESS_HR_TIMER_OUTPUTS_CONFIG , 1);
    QVector<quint16> dataMode;
    m_currentDiscreteMode = STAND_MODE_SET_VALUE;
    dataMode.append(((quint16*)&m_currentDiscreteMode)[0]);
    writeUnitMode.setValues(dataMode);
    m_modBusMaster->writeRequest( writeUnitMode, 1);

    QModbusDataUnit writeUnitSeq = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                 STAND_MODBUS_ADDRESS_HR_SEQ_TIM, countTimerSeqRegisters);

    writeUnitSeq.setValues(dataSeq2);
    m_modBusMaster->writeRequest( writeUnitSeq, 1);

    m_currentDiscreteMode = STAND_MODE_SEQUENCE;

    Stand_Outputs_Mode_Config_t structModeConfig;
    structModeConfig.Mode = m_currentDiscreteMode;
    structModeConfig.SequenceLen = timerOutSequensce.count();
    structModeConfig.SequenceRepeat = countCycleValue;
    structModeConfig.SequencePause = delayValue;

    QModbusDataUnit writeUnitStruct = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                    STAND_MODBUS_ADDRESS_HR_TIMER_OUTPUTS_CONFIG , 5);

     QVector<quint16> dataStruct;

     dataStruct.append(*((quint16*)&structModeConfig.Mode));
     dataStruct.append(*((quint16*)&structModeConfig.SequenceLen));
     dataStruct.append(*((quint16*)&structModeConfig.SequenceRepeat));
     dataStruct.append(((quint16*)(&structModeConfig.SequencePause))[0]);
     dataStruct.append(((quint16*)(&structModeConfig.SequencePause))[1]);

     writeUnitStruct.setValues(dataStruct);
     m_modBusMaster->writeRequest( writeUnitStruct, 1);
}

void StandTester::stopTest(QVector<int> discreteOutputs) {

     m_currentDiscreteMode = STAND_MODE_SET_VALUE;

     int countDiscreteRegisters = App_Bits_To_Bytes_N(discreteOutputs.count(), 16);
     QVector<uint16_t> outputsDiscrete;
     for(int i = 0; i < countDiscreteRegisters; ++i)
         outputsDiscrete.append(0);
     int j = 0;
     for( int i = 0 ; i < discreteOutputs.count() /** countSequence*/ ; ++i) {
         if(discreteOutputs[i])
             outputsDiscrete[j] = Set_Bit(outputsDiscrete[j], (i % (discreteOutputs.count()/countDiscreteRegisters)) );
         if( (i+1) % (discreteOutputs.count()/countDiscreteRegisters) == 0 && i !=0 ) ++j;
     }

     QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                     STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_DO , 1);
     QVector<quint16> data;
     data.append(((quint16*)&m_currentDiscreteMode)[0]);
     writeUnitMode.setValues(data);
     m_modBusMaster->writeRequest( writeUnitMode, 1);

     // запись значений выходов дискретов в регистры
     QModbusDataUnit writeUnit = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                    STAND_MODBUS_ADDRESS_HR_DO,
                                                        countDiscreteRegisters);
     writeUnit.setValues(outputsDiscrete);
     m_modBusMaster->writeRequest( writeUnit, 1);
}

void StandTester::stopTimerTest() {

    if (m_currentDiscreteMode == 0)
        return;
    int countTimerRegisters = 8;

    QVector<quint16> dataTimers;
    for(int i = 0; i< 8; ++i) {
        dataTimers.append(0);
    }

    QModbusDataUnit writeUnitMode = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                        STAND_MODBUS_ADDRESS_HR_TIMER_OUTPUTS_CONFIG , 1);
    m_currentDiscreteMode = STAND_MODE_SET_VALUE;
    QVector<quint16> dataMode;
    dataMode.append(((quint16*)&m_currentDiscreteMode)[0]);
    writeUnitMode.setValues(dataMode);
    m_modBusMaster->writeRequest( writeUnitMode, 1);

    // запись значений выходов таймеров в регистры
    QModbusDataUnit writeUnitDataTimer = QModbusDataUnit(QModbusDataUnit::HoldingRegisters,
                                                 STAND_MODBUS_ADDRESS_HR_TIM, countTimerRegisters);
    writeUnitDataTimer.setValues(dataTimers);
    m_modBusMaster->writeRequest( writeUnitDataTimer, m_discreteSlaveAdress); // NOTE : m_currentSlaveAdress
}

void StandTester::loadSequence(QString nameFile, QUrl urlFile, DiscreteOutSequenceModel *discreteOutSequenceModel, bool url) {
    int i = 0;
    bool ok;

    QFile file(url? urlFile.toLocalFile() : nameFile );

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << file.errorString();
          return;
    }

    QByteArray line = file.readLine();
    discreteOutSequenceModel->m_rowCount = line.toInt(&ok);
    line = file.readLine();
    discreteOutSequenceModel->delayDiscrete = line.toInt(&ok);

    discreteOutSequenceModel->updateRowsCount(discreteOutSequenceModel->m_rowCount, discreteOutSequenceModel->delayDiscrete);
    QVector<Stand_Discrete_Seq_Item_t> dicreteOutSeqArr = discreteOutSequenceModel->getDicreteOutSeq();

    line = file.readLine();
    discreteOutSequenceModel->delay = line.toInt(&ok);
    line = file.readLine();
    discreteOutSequenceModel->countCycle = line.toInt(&ok);
    while (!file.atEnd()) {
        line = file.readLine();
        dicreteOutSeqArr[i++].OutputsState = line.toUInt(&ok);
    }
    discreteOutSequenceModel->setDiscreteOutSeq(dicreteOutSeqArr);
    file.close();
}

void StandTester::saveSequence(QUrl nameFile, DiscreteOutSequenceModel *discreteOutSequenceModel) {
    int i = 0;
    QVector<Stand_Discrete_Seq_Item_t> dicreteOutSeqArr = discreteOutSequenceModel->getDicreteOutSeq();

    QFile file( nameFile.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << file.errorString();
          return;
    }
    QTextStream stream( &file );
    stream << discreteOutSequenceModel->m_rowCount << Qt::endl;
    stream << discreteOutSequenceModel->delayDiscrete << Qt::endl;
    stream << discreteOutSequenceModel->delay << Qt::endl;
    stream << discreteOutSequenceModel->countCycle << Qt::endl;
    for(i = 0; i < dicreteOutSeqArr.count(); ++i) {
         stream << dicreteOutSeqArr[i].OutputsState << Qt::endl;
    }
    file.close();
}

void StandTester::loadAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel) {
    int i = 0;
    bool ok;

    QFile file(nameFile.toLocalFile());

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << file.errorString();
          return;
    }

    QByteArray line = file.readLine();
    analogOutSequenceModel->m_rowCount = line.toInt(&ok);
    line = file.readLine();
    analogOutSequenceModel->delayAnalog = line.toInt(&ok);
    analogOutSequenceModel->updateRowsCount(analogOutSequenceModel->m_rowCount, analogOutSequenceModel->delayAnalog);
    QVector<Stand_Analogue_Seq_Item_t> analogOutSeqArr = analogOutSequenceModel->getAnalogOutSeq();
    line = file.readLine();
    analogOutSequenceModel->delay = line.toInt(&ok);
    line = file.readLine();
    analogOutSequenceModel->countCycle = line.toInt(&ok);
    while (!file.atEnd()) {
           for(int j = 0; j< analogOutSequenceModel->m_columnCount; j++) {
           line = file.readLine();
           analogOutSeqArr[i].OutputsState[j] = line.toDouble(&ok);
           }
           i++;
    }
    analogOutSequenceModel->setAnalogOutSeq(analogOutSeqArr);
    file.close();
}

void StandTester::saveAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel) {
    int i = 0;
    QVector<Stand_Analogue_Seq_Item_t> analogOutSeqArr = analogOutSequenceModel->getAnalogOutSeq();

    QFile file( nameFile.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
          return;
    }
    QTextStream stream( &file );
    stream << analogOutSequenceModel->m_rowCount << Qt::endl;
    stream << analogOutSequenceModel->delayAnalog << Qt::endl;
    stream << analogOutSequenceModel->delay << Qt::endl;
    stream << analogOutSequenceModel->countCycle << Qt::endl;

    for(i = 0; i < analogOutSeqArr.count(); ++i) {
        for(int j = 0; j < analogOutSequenceModel->m_columnCount; j++ )
         stream << analogOutSeqArr[i].OutputsState[j] << Qt::endl;
    }
    file.close();
}

void StandTester::loadTimerSequence(QUrl nameFile, TimerOutSequenceModel *timerOutSequenceModel) {
    int i = 0;
    bool ok;

    QFile file(nameFile.toLocalFile());

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << file.errorString();
          return;
    }

    QByteArray line = file.readLine();
    timerOutSequenceModel->m_rowCount = line.toInt(&ok);
    line = file.readLine();
    timerOutSequenceModel->delayTimer = line.toInt(&ok);

    timerOutSequenceModel->updateRowsCount(timerOutSequenceModel->m_rowCount,timerOutSequenceModel->delayTimer);
    QVector<Stand_Timer_Seq_Item_t> timerOutSeqArr = timerOutSequenceModel->getTimerOutSeq();

    line = file.readLine();
    timerOutSequenceModel->delay = line.toInt(&ok);
    line = file.readLine();
    timerOutSequenceModel->countCycle = line.toInt(&ok);
    while (!file.atEnd()) {
           for(int j = 0; j <timerOutSequenceModel->m_columnCount / 2; ++j ) {
                line = file.readLine();
                timerOutSeqArr[i].OutputsState[j].Frequency = line.toDouble(&ok);
                line = file.readLine();
                timerOutSeqArr[i].OutputsState[j].Duty = line.toDouble(&ok);
           }
           i++;
    }
    timerOutSequenceModel->setTimerOutSeq(timerOutSeqArr);
    file.close();
}

void StandTester::saveTimerSequence(QUrl nameFile, TimerOutSequenceModel *timerOutSequenceModel) {
    int i = 0;
    QVector<Stand_Timer_Seq_Item_t> timerOutSeqArr = timerOutSequenceModel->getTimerOutSeq();

    QFile file( nameFile.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
          return;
    }
    QTextStream stream( &file );
    stream << timerOutSequenceModel->m_rowCount << Qt::endl;
    stream << timerOutSequenceModel->delayTimer << Qt::endl;
    stream << timerOutSequenceModel->delay << Qt::endl;
    stream << timerOutSequenceModel->countCycle << Qt::endl;

    for(i = 0; i < timerOutSequenceModel->m_rowCount; ++i) {
        for(int j = 0; j < timerOutSequenceModel->m_columnCount / 2; ++j) {
            stream << timerOutSeqArr[i].OutputsState[j].Frequency << Qt::endl;
             stream << timerOutSeqArr[i].OutputsState[j].Duty << Qt::endl;
        }
    }

    file.close();
}

bool StandTester::getState() {
    return m_modBusMaster->getDeviceState();
}

void StandTester::startCommonTestByTypeCar(DiscreteOutSequenceModel *discreteModel, QVector<qreal> analogValues) {
    QVector<int> discreteOutputs;
    for( int i = 0; i < 32; i++ ) {
        discreteOutputs.append(0);
    }
    QString curTime = QDateTime::currentDateTime().time().toString();
    QString curDate = QDateTime::currentDateTime().date().toString(Qt::ISODate);
    onGetTimeTest(curDate, curTime);
    qDebug() << curDate <<  curTime;

    AnalogOutSequenceModel *analogModule = nullptr;
    startAnalogTest(analogValues, STAND_MODE_SET_VALUE, analogModule, 1000, 1);
    startTest(discreteOutputs, STAND_MODE_SEQUENCE, discreteModel, 1000, 1);

    connect(this, &StandTester::onEndTestDiscrete, this, [this, discreteOutputs]() {
                stopTest(discreteOutputs);
                stopAnalogTest();
                onStopTestByCar();
            });
}

void StandTester::stndDisconnect(){
    disconnect(this,&StandTester::onEndTestDiscrete,nullptr,nullptr);
}

void StandTester::readCurrentSettings(int slaveAdress) { // считаывает основные параметры платы(кол-во дискр и аналогов)
    if (m_modBusMaster->connectionSettings) {
        if (slaveAdress == m_discreteSlaveAdress) {
            m_modBusMaster->readRequest(QModbusDataUnit::InputRegisters, STAND_MODBUS_ADDRESS_IR_OUTPUTS_INFO,
                                        sizeof(Stand_Outputs_Info_t) / 2, slaveAdress); // данные дискретной платы

            auto modbusDataUnit = m_modBusMaster->getDataUnit()->values();
            Stand_Outputs_Info_t* data = reinterpret_cast<Stand_Outputs_Info_t*>(modbusDataUnit.data());
            m_discreteOutInfo = *data;
        }
        else if(slaveAdress == m_analogSlaveAdress) {
            m_modBusMaster->readRequest(QModbusDataUnit::InputRegisters, STAND_MODBUS_ADDRESS_IR_OUTPUTS_INFO,
                                        sizeof(Stand_Outputs_Info_t) / 2, slaveAdress); // данные аналоговой платы
            auto modbusDataUnit = m_modBusMaster->getDataUnit()->values();
            Stand_Outputs_Info_t* data = reinterpret_cast<Stand_Outputs_Info_t*>(modbusDataUnit.data());
            analogOutInfo = *data;
        }
        else
            qDebug() << "StandTester::readCurrentSettings() - неизвестный адрес устройства";
    }
}


QVector<uint16_t> StandTester::getCurrentDiscreteOutputsState() {
    m_discreteOutputsState.clear();
    int countRegisters = App_Bits_To_Bytes_N(m_discreteOutInfo.OutputCountDiscrete, 16);
    m_modBusMaster->readRequest(QModbusDataUnit::InputRegisters, STAND_MODBUS_ADDRESS_IR_DO,
                                countRegisters, m_discreteSlaveAdress);
    auto responce = m_modBusMaster->getDataUnit()->values();
    uint16_t* discreteOutputs = static_cast<uint16_t*>(responce.data());

    for (int i = 0; i < m_discreteOutInfo.OutputCountDiscrete; ++i) {
        m_discreteOutputsState.append(Check_Bit(*discreteOutputs, i % 16) ? 1 : 0 );
         if ((((i + 1) % 16) == 0) && (i != 0) && ( i != m_discreteOutInfo.OutputCountDiscrete - 1)) {
             ++discreteOutputs;
         }
    }
    return m_discreteOutputsState;
}

QVector<float> StandTester::getCurrentAnalogOutputsState() {
    m_analogOutputsState.clear();
    int countRegisters = 24; //App_Bits_To_Bytes_N(analogOutInfo.OutputCountAnalogue , 16); // TODO: проверка на заполненность данных

    m_modBusMaster->readRequest(QModbusDataUnit::InputRegisters, STAND_MODBUS_ADDRESS_IR_AO,
                                countRegisters, m_analogSlaveAdress);
    auto responce = m_modBusMaster->getDataUnit()->values();

    float* analogOutputs = reinterpret_cast<float*>(responce.data());

    for (int i = 0; i < analogOutInfo.OutputCountAnalogue; ++i) {
            m_analogOutputsState.append(analogOutputs[i]);
    }

    return m_analogOutputsState;
}


void StandTester::synchronizeWithSystemTime() { // не для стенда, тестовая плата
    QModbusDataUnit writeUnit = QModbusDataUnit(QModbusDataUnit::HoldingRegisters, 0x1100, 1); //NOTE: статические адреса тестовой платы

    int32_t time = static_cast<int32_t>(std::time(nullptr));
    QVector<quint16> data;

    data.append( ((quint16*)&time)[0]); // NOTE: вручную?
    data.append( ((quint16*)&time)[1]);

    writeUnit.setValues(data);

    m_modBusMaster->writeRequest( writeUnit, 0x0C);
}

//void StandTester::updateAccelerometerData(QAbstractSeries *seriesX,
//                                          QAbstractSeries *seriesY, QAbstractSeries *seriesZ) { // не для стенда, тестовая плата
//    // TODO: очень медленно, переделать архитектуру
//    int x = 0;
//    int y = 0;
//    int z = 0;
//    m_modBusMaster->readRequest(QModbusDataUnit::InputRegisters, 0x4E49, 26, 0x0C); // чтение с датчиков
//    auto tmpArr = m_modBusMaster->getDataUnit()->values();
//    int32_t *data;
//    data = reinterpret_cast<int32_t*>(tmpArr.data());
//    x = data[ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_X];
//    y = data[ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_Y];
//    z = data[ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_Z];
//    m_data.update(seriesX, seriesY, seriesZ, x, y, z);
//}
