#include "GuiHandler.h"
#include "settingsDialog.h"

GuiHandler::GuiHandler(QQmlContext *context) :
     m_context (context),
     m_stand(new StandTester(context)),
     m_client(new Requester),
     m_discreteTimer(new QTimer),
     m_analogTimer(new QTimer),
     m_commonTimer(new QTimer)
{
    m_context->setContextProperty("hndl", this);

    m_discreteTimer->setInterval(1000);
    m_discreteTimer->setSingleShot(false);

    m_commonTimer->setInterval(10);
    m_commonTimer->setSingleShot(false);

    m_analogTimer->setInterval(1000);
    m_analogTimer->setSingleShot(false);

    m_messageBox.setFixedSize(500, 200);

    m_client->initRequester("sps.gis.ru.net", 8080, nullptr); // 172.25.78.139/api/locs

    connect(m_client, &Requester::onParseEnd, this, &GuiHandler::setParams);

    connect(m_client, &Requester::endPrepareCommonTestParameters,
                       this, &GuiHandler::startCommonTest);
    connect(m_stand,&StandTester::onGetTimeTest,this, &GuiHandler::setCurTimeTest);

    connect(m_stand, &StandTester::onStopTestByCar, this, &GuiHandler::stopTestByTypeCar);

    connect(m_discreteTimer, &QTimer::timeout, this, &GuiHandler::readDiscreteCount);
    connect(m_analogTimer, &QTimer::timeout, this, &GuiHandler::readAnalogCount);

    connect(m_commonTimer, &QTimer::timeout, this, &GuiHandler::readCommonOutputs);
}

GuiHandler::~GuiHandler() {
    if( m_commonTimer->isActive())
        m_commonTimer->stop();
    delete m_commonTimer;
    if( m_analogTimer->isActive())
        m_analogTimer->stop();
    delete m_analogTimer;

    if( m_discreteTimer->isActive())
        m_discreteTimer->stop();
    delete m_discreteTimer;    

    delete m_client;
    delete m_stand;
}

void GuiHandler::openMapToCoordinates(double longitude, double altitude) {
    QString urlTemplate = "http://maps.yandex.ru/?text=%1,%2";
    QDesktopServices::openUrl(QUrl(urlTemplate.arg(longitude, 0, 'f', 6).arg(altitude, 0, 'f', 6)));
}

bool GuiHandler::onConnectedClicked(QString namePort, int baudRate, int dataBits, int parity, int stopBits) {
    return m_stand->connectDevice( namePort, baudRate, dataBits, parity, stopBits);
    //    setTime();
}

void GuiHandler::dicsonnectDevice() {
    m_stand->disconnectDevice();
}

//void GuiHandler::update(QAbstractSeries *seriesX,
//                        QAbstractSeries *seriesY, QAbstractSeries *seriesZ) {
//    m_stand->updateAccelerometerData( seriesX, seriesY, seriesZ);
//}

void GuiHandler::getIdxData() {
    m_infoText = m_stand->getDeviceInfo(1);  // bool if() -> signal
    infoTextChanged();
}

void GuiHandler::setTime() {
    m_stand->synchronizeWithSystemTime();
}

void GuiHandler::setDiscreteSettings() {
    m_stand->readCurrentSettings(m_stand->m_discreteSlaveAdress);
}

void GuiHandler::readDiscreteCount() { //TODO: исправить - объеденить с readAnalogCount(analogSlave)?
    m_discreteList.clear();
    m_discreteList2.clear();
    m_currentDiscreteOutputsState = m_stand->getCurrentDiscreteOutputsState();
    QVariantMap test;
    for(int i = 0; i < m_currentDiscreteOutputsState.count() / 2; ++i) { //NOTE: КОСТЫЛЬ
        test.insert("value", m_currentDiscreteOutputsState[i]);
        m_discreteList.append(test);
    }
    test.clear();
    for (int i = m_currentDiscreteOutputsState.count() / 2; i < m_currentDiscreteOutputsState.count(); ++i) {
        test.insert("value", m_currentDiscreteOutputsState[i]);
        m_discreteList2.append(test);
    }
    discreteListChanged();
}

void GuiHandler::setAnalogSettings(){
    m_stand->readCurrentSettings(m_stand->m_analogSlaveAdress);
}

void GuiHandler::readAnalogCount() {
    m_analogList.clear();
    QVector<float> currentAnalogOutputsState = m_stand->getCurrentAnalogOutputsState();
    QVariantMap test;
    for (int i = 0; i < currentAnalogOutputsState.count() ; ++i) {
            test.insert("value", currentAnalogOutputsState[i]);
            m_analogList.append(test);
    }
    analogListChanged();
}

void GuiHandler::readCommonOutputs() {
    readDiscreteCount();
    readAnalogCount();
}

void GuiHandler::startAnalogTesting(int mode, AnalogOutSequenceModel *analogOutSequenceModel,
                                    int delayValue, int countCycleValue) {
    m_stand->startAnalogTest(m_editedAnalogOutputs, mode, analogOutSequenceModel,delayValue,countCycleValue);
}

void GuiHandler::stopAnalogTesting() {
    m_stand->stopAnalogTest();
    readAnalogCount();
}

void GuiHandler::startTesting(int mode, DiscreteOutSequenceModel *discreteOutSequenceModel,
                                    int delayValue, int countCycleValue) {
    m_stand->startTest(m_editedDiscreteOutputs, mode, discreteOutSequenceModel, delayValue,  countCycleValue);
    m_discreteState = true;
}

void GuiHandler::startTimerSeqTest(int mode, TimerOutSequenceModel *timerOutSequenceModel,
                                   int countCycleValue, int delayValue ) {
     m_stand->startTestSeqTimer( mode, timerOutSequenceModel,
                                 countCycleValue, delayValue);
}

void GuiHandler::stopTimerTest() {
    m_stand->stopTimerTest();
}

void GuiHandler::startTimerTest(int mode, int freqValTimer1, int dutyValTimer1,int freqValTimer2, int dutyValTimer2,
                                            int freqValTimer3, int dutyValTimer3, int freqValTimer4, int dutyValTimer4) {

    m_stand->startTestTimer(mode, freqValTimer1, dutyValTimer1, freqValTimer2, dutyValTimer2,
                                        freqValTimer3, dutyValTimer3, freqValTimer4,  dutyValTimer4);
}

void GuiHandler::stopTest() {
    m_stand->stopTest(m_editedDiscreteOutputs);
    m_discreteState = false;
    readDiscreteCount();
}

void GuiHandler::loadSequence(QString nameFile, QUrl urlFile, DiscreteOutSequenceModel *discreteOutSequenceModel, bool url) {
    m_stand->loadSequence(nameFile, urlFile, discreteOutSequenceModel, url);
}

void GuiHandler::saveSequence(QUrl nameFile, DiscreteOutSequenceModel *discreteOutSequenceModel) {
    m_stand->saveSequence(nameFile, discreteOutSequenceModel);
}

void GuiHandler::loadAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel) {
    m_stand->loadAnalogSequence(nameFile, analogOutSequenceModel);
}

void GuiHandler::saveAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel) {
    m_stand->saveAnalogSequence(nameFile, analogOutSequenceModel);
}

void GuiHandler::loadTimerSequence(QUrl nameFile, TimerOutSequenceModel *timerOutSequenceModel){
    m_stand->loadTimerSequence(nameFile, timerOutSequenceModel);
}

void GuiHandler::saveTimerSequence(QUrl nameFile, TimerOutSequenceModel *timerOutSequenceModel){
    m_stand->saveTimerSequence(nameFile, timerOutSequenceModel);
}

void GuiHandler::discreteTimerStart() {
    m_discreteTimer->start();
}

void GuiHandler::discreteTimerStop() {
    m_discreteTimer->stop();
}

void GuiHandler::analogTimerStart() {
    m_analogTimer->start();
}

void GuiHandler::analogTimerStop() {
    m_analogTimer->stop();
}

void GuiHandler::commonTimerStart() {
    m_commonTimer->start();
}
void GuiHandler::commonTimerStop() {
    m_commonTimer->stop();
}

void GuiHandler::setTypeCar(QString typeCar) {
    m_client->setTypeCar(typeCar);
}

void GuiHandler::getType(bool isIMEI, QString number, QString typeCar) {
    m_client->getTypeCarRequest(isIMEI, number);
}

void GuiHandler::setCurTimeTest(QString date, QString time) {
    m_client->setCurrentTestByCarDate(date);
    m_client->setCurrentTestByCarTime(time);
}

void GuiHandler::getLocsRequest(bool isIMEI, QString number, QString typeCar) {
    m_client->getLocsRequest(isIMEI, number, typeCar);
}

void GuiHandler::setParams() {
    bkp bkpData = m_client->getBkpData();
    sadcoF1 sadcoF1Data = m_client->getSadcoF1Data();
    sadcoF4 sadcoF4Data = m_client->getSadcoF4Data();
    m_sadcoF1ParamList.clear();
    m_sadcoF4ParamList.clear();
    m_bkpParamList.clear();
    m_akbParamList.clear();
    m_gpsParamList.clear();
    m_sdCardParamList.clear();
    m_additionalInfo = " ";
    QVariantMap tmp;

    m_testResult = 0; // 0 - исправен, 1 - предупреждение, 2 - неисправность
    m_boardsResult.clear();
//    m_elementsResult.clear();

    ///F1
    // "device_ident"  8
    if(sadcoF1Data.flagIdent) {
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.boardId);
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.deviceId);
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.modelName);
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.version);
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.fwVerRealise);
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.fwVerMajor);
        m_sadcoF1ParamList.append(sadcoF1Data.deviceIdentPacket.fwVerMinor);
    } else {

    }
    ///F4
    //locs 1
    if(sadcoF4Data.flagLocs) {
        tmp.clear();
        // скорость и высота - ?
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.dt);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.hdop);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.longitude);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.latitude);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.numsats);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.bat_level);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.ign_state);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.eng_run_time);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.in1);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.in2);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.gsm_level);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.temperature);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.in3);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.in4);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.d1);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.d2);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.d3);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.d4);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.d5);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.d6);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.cnt1);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.cnt2);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.cnt3);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.cnt4);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.cnt5);
        m_sadcoF4ParamList.append(sadcoF4Data.locsPacket.cnt6);
        tmp["name"] = "АКБ";
        tmp["color"] = sadcoF4Data.locsPacket.in1["flag"].toString();
        tmp["description"] = tmp["color"].toString() == "#9FA2B4"? "нет данных" : tmp["color"].toString() == "#FEC400"? "предупреждение" :
                                                      tmp["color"].toString() == "#F12B2C"? "неисправность" : "в норме";
        m_akbParamList.append(sadcoF4Data.locsPacket.in1);
        m_boardsResult.append(tmp);

        tmp["name"] = "GPS-антенна";
        tmp["color"] = "#29CC97";
        tmp["description"] = "в норме";
        m_gpsParamList.append(sadcoF4Data.locsPacket.hdop);
        m_gpsParamList.append(sadcoF4Data.locsPacket.longitude);
        m_gpsParamList.append(sadcoF4Data.locsPacket.latitude);
        m_gpsParamList.append(sadcoF4Data.locsPacket.numsats);
        m_boardsResult.append(tmp);

        onElementsResultListChanged();
    } else {
        tmp.clear();
        tmp["name"] = "АКБ";
        tmp["color"] = "#9FA2B4";
        tmp["description"] = "нет данных";
        m_boardsResult.append(tmp);

        tmp["name"] = "GPS-антенна";
        tmp["color"] = "#F12B2C";
        tmp["description"] = "неисправность";
        m_boardsResult.append(tmp);
        onBoardsResultListChanged();

        m_testResult = 2;
        onElementsResultListChanged();
    }

    //8
    if(sadcoF4Data.flagIdent) {
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.boardId);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.deviceId);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.modelName);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.version);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.fwVerRealise);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.fwVerMajor);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceIdentPacket.fwVerMinor);
    }

    //9
    if(sadcoF4Data.flagStatus) {
        tmp.clear();
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.coreVoltage);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.temperature);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.coreLoad);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.coreLoadMax);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.powerMode);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.heapTotal);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.heapAvailable);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.storageTotal);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.storageAvailable);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.externalTotal);
        m_sadcoF4ParamList.append(sadcoF4Data.deviceStatusPacket.externalAvailable);
        tmp["name"] = "SD - карта";
        tmp["color"] = sadcoF4Data.deviceStatusPacket.externalAvailable["flag"].toString();
        tmp["description"] = tmp["color"].toString() == "#FEC400"? "предупреждение" :
                                                      tmp["color"].toString() == "#F12B2C"? "неисправность" : "в норме";
        m_sdCardParamList.append(sadcoF4Data.deviceStatusPacket.externalAvailable);
        m_boardsResult.append(tmp);
        onBoardsResultListChanged();

        onElementsResultListChanged();
    } else {
        tmp.clear();
        tmp["name"] = "SD - карта";
        tmp["color"] = "#9FA2B4";
        tmp["description"] = "нет данных";
        m_boardsResult.append(tmp);
        onBoardsResultListChanged();
        m_testResult = 2;
        onElementsResultListChanged();
    }

    ///bkp
    // "device_ident" // 8
    if(bkpData.flagIdent) {
        m_bkpParamList.append(bkpData.deviceIdentPacket.boardId);
        m_bkpParamList.append(bkpData.deviceIdentPacket.deviceId);
        m_bkpParamList.append(bkpData.deviceIdentPacket.modelName);
        m_bkpParamList.append(bkpData.deviceIdentPacket.version);
        m_bkpParamList.append(bkpData.deviceIdentPacket.fwVerRealise);
        m_bkpParamList.append(bkpData.deviceIdentPacket.fwVerMajor);
        m_bkpParamList.append(bkpData.deviceIdentPacket.fwVerMinor);
    }

    //9
    if(bkpData.flagStatus) {
        m_bkpParamList.append(bkpData.deviceStatusPacket.coreVoltage);
        m_bkpParamList.append(bkpData.deviceStatusPacket.temperature);
        m_bkpParamList.append(bkpData.deviceStatusPacket.coreLoad);
        m_bkpParamList.append(bkpData.deviceStatusPacket.coreLoadMax);
        m_bkpParamList.append(bkpData.deviceStatusPacket.powerMode);
    }

    // 112
    if(bkpData.flagCycles112) {
        for(int i = 0 ; i < bkpData.cycles112Packet.dCur.count(); i++) {
            for(int j = 0; j < bkpData.cycles112Packet.dCur[i].count(); j++) {
                m_bkpParamList.append(bkpData.cycles112Packet.dCur[i][j]);
             }
        }
        m_bkpParamList.append(bkpData.cycles112Packet.a1Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a2Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a3Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a4Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a5Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a6Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a7Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a8Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a9Cur);
        m_bkpParamList.append(bkpData.cycles112Packet.a10Cur);
    }

   m_testResultArray.clear();
   int boardTestResult = -1;
   int tmpBoardTestResult = -1;
   bool flag = true;
   m_countCheck = 0;
   m_countErrors = 0;
   m_countOk = 0;
   m_countWarnings = 0;

   for( int i = 0; i < m_bkpParamList.count(); i++) {
       QVariantMap test = m_bkpParamList[i].toMap();
       if(((!QString::compare(test["flag"].toString(), "#29CC97"))
           || (!QString::compare(test["flag"].toString(), "#9FA2B4")))) {
           m_countOk++;
          if(!QString::compare(test["flag"].toString(), "#9FA2B4")) m_countCheck++;
           boardTestResult = 0;

       } else if((!QString::compare(test["flag"].toString(), "#FEC400"))) {
             boardTestResult = 1;
             m_countWarnings++;
       } else {
           boardTestResult = 2;
           m_countErrors++;
       }
       m_testResultArray.append(boardTestResult);
       if(flag) {
           if(boardTestResult == 2){
               flag = false;
               tmpBoardTestResult = boardTestResult;
           } else if(boardTestResult == 1) {
               tmpBoardTestResult = boardTestResult;
           }
       }
   }

   tmp["name"] = "Плата БКП";
   tmp["color"] = !(bkpData.flagIdent && bkpData.flagCycles112 && bkpData.flagStatus)? "#9FA2B4" : tmpBoardTestResult == 1? "#FEC400" : tmpBoardTestResult == 2? "#F12B2C" : "#29CC97";
   tmp["description"] = !(bkpData.flagIdent && bkpData.flagCycles112 && bkpData.flagStatus)? "нет данных" :tmpBoardTestResult == 1? "предупреждение" :
                                                 tmpBoardTestResult == 2? "неисправность" : "в норме";
   m_boardsResult.append(tmp);
   onBoardsResultListChanged();

   flag = true;
   tmpBoardTestResult = -1;

   for( int i = 0; i < m_sadcoF1ParamList.count(); i++) {
       QVariantMap test = m_sadcoF1ParamList[i].toMap();

       if(((!QString::compare(test["flag"].toString(), "#29CC97"))
           || (!QString::compare(test["flag"].toString(), "#9FA2B4")))) {
           m_countOk++;
           if(!QString::compare(test["flag"].toString(), "#9FA2B4"))
               m_countCheck++;
           boardTestResult = 0;

       } else if((!QString::compare(test["flag"].toString(), "#FEC400"))) {
             boardTestResult = 1;
             m_countWarnings++;
       } else {
           boardTestResult = 2;
           m_countErrors++;
       }
        m_testResultArray.append( boardTestResult );
        if(flag) {
            if(boardTestResult == 2){
                flag = false;
                tmpBoardTestResult = boardTestResult;
            } else if(boardTestResult == 1) {
                tmpBoardTestResult = boardTestResult;
            }
        }
   }

   tmp["name"] = "Плата Садко - чип F1";
   tmp["color"] = !(sadcoF1Data.flagIdent)? "#9FA2B4" : tmpBoardTestResult == 1? "#FEC400" :tmpBoardTestResult == 2? "#F12B2C" : "#29CC97";
   tmp["description"] = !(sadcoF1Data.flagIdent)? "нет данных" : tmpBoardTestResult == 1? "предупреждение" :
                                                 tmpBoardTestResult == 2? "неисправность" : "в норме";
   m_boardsResult.append(tmp);
   onBoardsResultListChanged();

   flag = true;
   tmpBoardTestResult = -1;

   for( int i = 0; i < m_sadcoF4ParamList.count(); i++) {
       QVariantMap test = m_sadcoF4ParamList[i].toMap();

       if((!QString::compare(test["flag"].toString(), "#29CC97"))
               || (!QString::compare(test["flag"].toString(), "#9FA2B4"))) {
           m_countOk++;
            if (!QString::compare(test["flag"].toString(), "#9FA2B4"))
                m_countCheck++;

           boardTestResult = 0;

       } else if(!QString::compare(test["flag"].toString(), "#FEC400")) {
             boardTestResult = 1;
             m_countWarnings++;
       } else {
           boardTestResult = 2;
           m_countErrors++;
       }

       if(flag) {
           if(boardTestResult == 2){
               flag = false;
               tmpBoardTestResult = boardTestResult;
           } else if(boardTestResult == 1) {
               tmpBoardTestResult = boardTestResult;
           }
       }
        m_testResultArray.append(boardTestResult);
   }

   tmp["name"] = "Плата Садко - чип F4";
   tmp["color"] = !(sadcoF4Data.flagIdent && sadcoF4Data.flagLocs && sadcoF4Data.flagStatus)? "#9FA2B4" : tmpBoardTestResult == 1? "#FEC400" :tmpBoardTestResult == 2? "#F12B2C" : "#29CC97";
   tmp["description"] =!(sadcoF4Data.flagIdent && sadcoF4Data.flagLocs && sadcoF4Data.flagStatus)? "нет данных" : tmpBoardTestResult == 1? "предупреждение" :
                                                 tmpBoardTestResult == 2? "неисправность" : "в норме";

   m_boardsResult.append(tmp);
   onBoardsResultListChanged();

   flag = true;
   tmpBoardTestResult = -1;

   if (!(sadcoF4Data.flagStatus && sadcoF4Data.flagIdent && sadcoF4Data.flagLocs &&
        sadcoF1Data.flagIdent && bkpData.flagStatus && bkpData.flagCycles112 && bkpData.flagIdent)) {
       m_testResult = 2;
   }

   if(m_testResult == 0) {
       for(int i = 0; i < m_testResultArray.count(); i++) {
           if(m_testResultArray[i] == 2) {
               m_testResult = 2;
               break;
           }
           if(m_testResultArray[i] == 1) {
               m_testResult = 1;
           }
       }
   }

   //доп инфо отсутсвия пакетов
   if(!(sadcoF4Data.flagStatus && bkpData.flagStatus)) {
        m_additionalInfo +=  "нет данных 9 пакета; ";
        m_countErrors++;
   }
   if(!(sadcoF1Data.flagIdent && bkpData.flagIdent && sadcoF4Data.flagIdent)) {
       m_additionalInfo += "нет данных 8 пакета; ";
       m_countErrors++;
   }
   if(!(bkpData.flagCycles112)) {
       m_additionalInfo +=  "нет данных 112 пакета; ";
       m_countErrors++;
   }
   if(!(sadcoF4Data.flagLocs) ) {
       m_additionalInfo += "нет данных 1 пакета; ";
       m_countErrors++;
   }

   m_resultTest = m_testResult == 1? "Тестирование пройдено. Есть предупреждения" :
                                           m_testResult == 2 ? "Тестирование не пройдено. Есть Неисправности" :
                                                              "Тестирование пройдено.";
    testResultChanged();

    paramListChanged();
}

void GuiHandler::startCommonTest(DiscreteOutSequenceModel *discreteModel, QVector<qreal> analogValues) {
    m_stand->startCommonTestByTypeCar(discreteModel,analogValues);
}
