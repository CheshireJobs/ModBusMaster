#include "Requester.h"
#include <math.h>
const QString Requester::httpTemplate = "http://%1:%2/lastpacks/%3?%4";
const QString Requester::httpsTemplate = "https://%1:%2/api/%3";
const QString Requester::KEY_QNETWORK_REPLY_ERROR = "QNetworkReplyError";
const QString Requester::KEY_CONTENT_NOT_FOUND = "ContentNotFoundError";

//        sendRequest("locs", Requester::Type::POST, dataRequest);
//        sendRequest("device_ident", Requester::Type::POST, dataRequest);
//        sendRequest("device_status", Requester::Type::POST, dataRequest);

Requester::Requester(QObject *parent) : QObject(parent),
    m_discreteSequencePlus(new  DiscreteOutSequenceModel()),
    m_discreteSequenceMinus(new  DiscreteOutSequenceModel())
{
    manager = new QNetworkAccessManager(this);
    m_messageBox.setFixedSize(500, 200);

    connect(this, &Requester::onGetTypeEnd, this, &Requester::startCommonTest);
    connect(this,  &Requester::onParseEnd, this, &Requester::reqDisconnect);

    initTypeCars();
}

//

void Requester::initRequester(const QString &host, int port, QSslConfiguration *value) {
    this->host = host;
    this->port = port;
    sslConfig = value;
    if (sslConfig != nullptr)
        pathTemplate = httpsTemplate;
    else
        pathTemplate = httpTemplate;
}

void Requester::initTypeCars() {
    typeCars.clear();
    QVariantMap type;

    type["type"] = "ПМГ";
    type["mask"] = 63;
    typeCars.append(type);

    type["type"] = "УТМ";
    type["mask"] = 12;
    typeCars.append(type);

    type["type"] = "УТМ-2";
    type["mask"] = 12;
    typeCars.append(type);

    type["type"] = "ПУМА";
    type["mask"] = 1966081;
    typeCars.append(type);

    type["type"] = "динамик";
    type["mask"] = 917505;
    typeCars.append(type);
    type["type"] = "дуоматик";
    type["mask"] = 917505;
    typeCars.append(type);
    type["type"] = "ПМА";
    type["mask"] = 917505;
    typeCars.append(type);

    type["type"] = "ПМА-С";
    type["mask"] = 8257537;
    typeCars.append(type);

    type["type"] = "УНИМАТ КОМПАКТ";
    type["mask"] = 983040;
    typeCars.append(type);

    type["type"] = "УНИМАТ";
    type["mask"] = 16711680;
    typeCars.append(type);

    type["type"] = "ВПР-02";
    type["mask"] = 3;
    typeCars.append(type);

    type["type"] = "ВПР-02М";
    type["mask"] = 196608;
    typeCars.append(type);

    type["type"] = "ВПР-02К";
    type["mask"] = 12517376;
    typeCars.append(type);

    type["type"] = "ВПРС-02";
    type["mask"] = 255;
    typeCars.append(type);
    type["type"] = "ВПРС-03";
    type["mask"] = 255;
    typeCars.append(type);

    type["type"] = "ВПРС-02К";
    type["mask"] = 8323072;
    typeCars.append(type);
    type["type"] = "ВПРС-03К";
    type["mask"] = 8323072;
    typeCars.append(type);

    type["type"] = "ПБ";
    type["mask"] = 255;
    typeCars.append(type);
    type["type"] = "РБ";
    type["mask"] = 255;
    typeCars.append(type);
    type["type"] = "РПБ";
    type["mask"] = 255;
    typeCars.append(type);
    type["type"] = "ТЭС";
    type["mask"] = 255;
    typeCars.append(type);
}

void Requester::sendRequest(const QString &apiStr, QString typeRequest,
                            Requester::Type type,
                            const QVariantMap &data)
{
    QNetworkRequest request = createRequest(apiStr, typeRequest);

    QNetworkReply *reply;
    switch (type) {
    case Type::POST: {
        QByteArray postDataByteArray = variantMapToJson(data);
        qDebug () <<"postDataByteArray" << postDataByteArray.data();
        reply = manager->post(request, postDataByteArray);
        break;
    } case Type::GET: {
        reply = manager->get(request);
        break;
    } case Type::DELET: {
        if (data.isEmpty())
            reply = manager->deleteResource(request);
        else
            reply = sendCustomRequest(manager, request, "DELETE", data);
        break;
    } case Type::PATCH: {
        reply = sendCustomRequest(manager, request, "PATCH", data);
        break;
    } default:
        reply = nullptr;
        Q_ASSERT(false);
    }

    connect(reply, &QNetworkReply::finished, this,
            [this, reply, typeRequest]() {
        QJsonObject obj = parseReply(reply);
        if (onFinishRequest(reply)) {
            parser(typeRequest,obj);
        } else {
                handleQtNetworkErrors(reply, obj);
                m_messageBox.critical(nullptr,"Error", reply->errorString());
                m_locsData.clear();
                onErrorReply();
        }
        reply->close();
        reply->deleteLater();
    } );

}

void Requester::sendMulishGetRequest(const QString &apiStr,
                                     const finishFunc &funcFinish)
{
    QNetworkRequest request = createRequest(apiStr,"false");
    //    QNetworkReply *reply;
    qInfo() << "GET REQUEST " << request.url().toString() << "\n";
    auto reply = manager->get(request);

    connect(reply, &QNetworkReply::finished, this,
            [this,  funcFinish, reply,apiStr]() {
        QJsonObject obj = parseReply(reply);
        if (onFinishRequest(reply)) {
            QString nextPage = obj.value("next").toString();
            if (!nextPage.isEmpty()) {
                QStringList apiMethodWithPage = nextPage.split("api/");
                sendMulishGetRequest(apiMethodWithPage.value(1),
                                     funcFinish
                                     );
            } else {
                if (funcFinish != nullptr)
                    funcFinish();
            }
        } else {
            handleQtNetworkErrors(reply, obj);
        }
        reply->close();
        reply->deleteLater();
    });
}

QString Requester::getToken() const {
    return token;
}

void Requester::setToken(const QString &value) {
    token = value;
}

////!!!!!
void Requester::parser(const QString &apiStr, QJsonObject obj) {
    locs packetLocs;
    deviceIdent packetDeviceIdent;
    deviceStatus packetDeviceStatus;
    cycles112 packetCycles112;

    m_locsData.clear();
    m_deviceIdentData.clear();
    m_deviceStatusData.clear();
    m_cycles112DataArray.clear();

    QJsonArray dataArray = obj["features"].toArray();
    QJsonObject dataObj;
    QJsonObject rawDataObject;

    qDebug() << "parser " << apiStr;
    if (apiStr == "locs") {
        if(dataArray.count() == 0) {
            qDebug() << "Нет данных 1 пакета.";
            m_sadcoF4Data.flagLocs = false;
            onParseLocsEnd();
            return;
        } else {
            m_sadcoF4Data.flagLocs = true;
        }
        m_locsData.clear();
        for(int i = 0; i < dataArray.count() ; i++) {
            //  TODO: здесь не заполнять все три поля, а делать это в проверке параметров( за исключением тех, что не проверяютcя)

            dataObj = dataArray.at(i).toObject();
            // --функция разбора поля data?
            QString rawDataString = dataObj["data"].toString();
            QStringList rawDataList = rawDataString.split(",", Qt::SkipEmptyParts);

            if(rawDataList.count() < 30) {
                qDebug() << rawDataList.count() << " error raw data!";
                return;
            }
            packetLocs.dt["value"] = dataObj["dt"].toString();
            packetLocs.dt["description"] = "Время формирования пакета";
            packetLocs.dt["flag"] = "#9FA2B4";

//            QString dateString = dataObj["dt"].toString();
//            QDate date = QDate::fromString(dateString,"yyyy-MM-ddTHH:mm:ss[.SS]");
//            qDebug() << dateString << date << date.toString(Qt::ISODateWithMs);

            // разбор сырых данных
            packetLocs.longitude["value"] = rawDataList[3].toDouble() / 1000000;
            packetLocs.longitude["description"] = "Долгота";
            packetLocs.longitude["flag"] = "#9FA2B4";

            packetLocs.latitude["value"] = rawDataList[4].toDouble() /1000000;
            packetLocs.latitude["description"] = "Широта";
            packetLocs.latitude["flag"] = "#9FA2B4";

            packetLocs.hdop["value"] = round((rawDataList[8].toDouble() * 0.01) * 100)/100;
            packetLocs.hdop["description"] = "Снижение точности в горизонтальной плоскости";
            packetLocs.hdop["flag"] = "#29CC97";

            packetLocs.numsats["value"] = rawDataList[9].toInt();
            packetLocs.numsats["description"] = "Количество видимых спутников";
            packetLocs.numsats["flag"] = "#29CC97";

            packetLocs.bat_level["value"] = round((rawDataList[10].toDouble() / 4059 * 3.3 * 11) * 100)/100;
            packetLocs.bat_level["flag"] = "#29CC97";
            packetLocs.bat_level["description"] = "Напряжение питания платы, В";

            packetLocs.ign_state["value"] = rawDataList[11].toInt();
            packetLocs.ign_state["flag"] = "#29CC97";
            packetLocs.ign_state["description"] = "Состояние внешнего питания";

            packetLocs.eng_run_time["value"] = rawDataList[12].toInt() / 60;
            packetLocs.eng_run_time["flag"] = "#29CC97";
            packetLocs.eng_run_time["description"] = "Время работы двигателя, мин.";

            packetLocs.in1["value"] = round((rawDataList[13].toDouble() / 4059 * 3.3 * 11) * 100)/100;
            packetLocs.in1["flag"] = "#29CC97";
            packetLocs.in1["description"] = "Напряжение АКБ, В";

            packetLocs.in2["value"] = round((rawDataList[14].toDouble() / 4059 * 3.3 * 11) * 100)/100;
            packetLocs.in2["flag"] = "#29CC97";
            packetLocs.in2["description"] = "Напряжение внешнего питания, В";

            packetLocs.gsm_level["value"] = rawDataList[15].toDouble();
            packetLocs.gsm_level["flag"] = "#29CC97";
            packetLocs.gsm_level["description"] = "Уровень сигнала";

            packetLocs.temperature["value"] = round((rawDataList[16].toDouble() * 0.1 - 273) * 100)/100;
            packetLocs.temperature["flag"] = "#29CC97";
            packetLocs.temperature["description"] = "Температура микроконтроллера, градусы";

            packetLocs.in3["value"] = round((rawDataList[17].toDouble() / 4059 * 3.3 * 11) * 100)/100; //round(value*100)/100
            packetLocs.in3["flag"] = "#29CC97";
            packetLocs.in3["description"] = "Напряжение на аналоговом входе 1, В";

            packetLocs.in4["value"] =round((rawDataList[18].toDouble() / 4059 * 3.3 * 11) * 100)/100;
            packetLocs.in4["flag"] = "#29CC97";
            packetLocs.in4["description"] = "Напряжение на аналоговом входе 2, В";

            packetLocs.d1["value"] = rawDataList[19].toInt();
            packetLocs.d1["flag"] = "#29CC97";
            packetLocs.d1["description"] = "Состояние дискретного входа 1";

            packetLocs.d2["value"] =  rawDataList[20].toInt();
            packetLocs.d2["flag"] = "#29CC97";
            packetLocs.d2["description"] = "Состояние дискретного входа 2";
            packetLocs.d3["value"] =  rawDataList[21].toInt();
            packetLocs.d3["flag"] = "#29CC97";
            packetLocs.d3["description"] = "Состояние дискретного входа 3";
            packetLocs.d4["value"] =  rawDataList[22].toInt();
            packetLocs.d4["flag"] = "#29CC97";
            packetLocs.d4["description"] = "Состояние дискретного входа 4";
            packetLocs.d5["value"] =  rawDataList[23].toInt();
            packetLocs.d5["flag"] = "#29CC97";
            packetLocs.d5["description"] = "Состояние дискретного входа 5";
            packetLocs.d6["value"] =  rawDataList[24].toInt();
            packetLocs.d6["flag"] = "#29CC97";
            packetLocs.d6["description"] = "Состояние дискретного входа 6";
            packetLocs.cnt1["value"] =  rawDataList[25].toInt();
            packetLocs.cnt1["flag"] = "#29CC97";
            packetLocs.cnt1["description"] = "Количество импульсов на дискретном входе 1";
            packetLocs.cnt2["value"] =  rawDataList[26].toInt();
            packetLocs.cnt2["flag"] = "#29CC97";
            packetLocs.cnt2["description"] = "Количество импульсов на дискретном входе 2";
            packetLocs.cnt3["value"] =  rawDataList[27].toInt();
            packetLocs.cnt3["flag"] = "#29CC97";
            packetLocs.cnt3["description"] = "Количество импульсов на дискретном входе 3";
            packetLocs.cnt4["value"] =  rawDataList[28].toInt();
            packetLocs.cnt4["flag"] = "#29CC97";
            packetLocs.cnt4["description"] = "Количество импульсов на дискретном входе 4";
            packetLocs.cnt5["value"] =  rawDataList[29].toInt();
            packetLocs.cnt5["flag"] = "#29CC97";
            packetLocs.cnt5["description"] = "Количество импульсов на дискретном входе 5";
            packetLocs.cnt6["value"] = rawDataList[30].toInt();
            packetLocs.cnt6["flag"] = "#29CC97";
            packetLocs.cnt6["description"] = "Количество импульсов на дискретном входе 6";
            m_locsData.append(packetLocs);
        }
        checkLocsParams(&m_locsData[0]);
        onParseLocsEnd();
    } else if (apiStr == "device_ident") {
        if(dataArray.count() == 0) {
            qDebug() <<  "Нет данных 8 пакета.";
            m_sadcoF1Data.flagIdent = false;
            m_sadcoF4Data.flagIdent = false;
            m_bkpData.flagIdent = false;
            onParseDeviceIdentEnd();
            return;
        } else {
            m_sadcoF1Data.flagIdent = true;
            m_sadcoF4Data.flagIdent = true;
            m_bkpData.flagIdent = true;
        }
        m_deviceIdentData.clear();
        for(int i = 0; i < dataArray.count(); i++) {
            dataObj = dataArray.at(i).toObject();

            QString rawDataString = dataObj["data"].toString();
            QStringList rawDataList = rawDataString.split(",", Qt::SkipEmptyParts);

            if(rawDataList.count() < 13) {
                qDebug() << rawDataList.count() << " error raw data 8!";
                return;
            }

            packetDeviceIdent.boardId["value"] = rawDataList[6].toInt() == 2? "Плата Садко, чип F4" :
                                                 rawDataList[6].toInt() == 1? "Плата Садко, чип F1" : "Плата БКП";
            packetDeviceIdent.boardId["flag"] = "#29CC97";
            packetDeviceIdent.boardId["description"] = "Тип платы";

            packetDeviceIdent.deviceId["value"] = rawDataList[7].toInt();
            packetDeviceIdent.deviceId["flag"] = "#29CC97";
            packetDeviceIdent.deviceId["description"] = "Идентификатор контроллера";

            packetDeviceIdent.modelName["value"] = rawDataList[8];
            packetDeviceIdent.modelName["flag"] = "#29CC97";
            packetDeviceIdent.modelName["description"] = "Название модели";

            packetDeviceIdent.version["value"] = rawDataList[9].toInt();
            packetDeviceIdent.version["flag"] = "#29CC97";
            packetDeviceIdent.version["description"] = "Версия платы";

            packetDeviceIdent.fwVerMajor["value"] = rawDataList[10].toInt();
            packetDeviceIdent.fwVerMajor["flag"] = "#29CC97";
            packetDeviceIdent.fwVerMajor["description"] = "Версия прошивки - старшая";

            packetDeviceIdent.fwVerMinor["value"] = rawDataList[11].toInt();
            packetDeviceIdent.fwVerMinor["flag"] = "#29CC97";
            packetDeviceIdent.fwVerMinor["description"] = "Версия прошивки - младшая";

            QString dateString = QString(rawDataList[12]);
            QDate date = QDate::fromString(dateString,"yyyyMMdd");
            packetDeviceIdent.fwVerRealise["value"] = date.toString(Qt::ISODate);
            packetDeviceIdent.fwVerRealise["flag"] = "#29CC97";
            packetDeviceIdent.fwVerRealise["description"] = "Версия прошивки - дата релиза";

            m_deviceIdentData.append(packetDeviceIdent);
        }
        setDeviceIdentData(m_deviceIdentData);

    } else if(apiStr == "device_status") {
        if(dataArray.count() == 0) {
            qDebug() <<  "Нет данных 9 пакета.";
            m_bkpData.flagStatus = false;
            m_sadcoF4Data.flagStatus = false;
            onParseDeviceStatusEnd();
            return;
        } else {
            m_bkpData.flagStatus = true;
            m_sadcoF4Data.flagStatus = true;
        }
        m_deviceStatusData.clear();
        for(int i = 0; i < dataArray.count(); i++) {
            dataObj = dataArray.at(i).toObject();

            QString rawDataString = dataObj["data"].toString();
            QStringList rawDataList = rawDataString.split(",", Qt::SkipEmptyParts);

            if(rawDataList.count() < 20) {
                qDebug() << rawDataList.count() << " error raw data 9!";
                return;
            }

            packetDeviceStatus.boardId["value"] = rawDataList[6].toInt() == 2? "Плата Садко, чип F4" :
                                                  rawDataList[6].toInt() == 1? "Плата Садко, чип F1" : "Плата БКП";
            packetDeviceStatus.boardId["flag"] = "#29CC97";
            packetDeviceStatus.boardId["description"] = "Идентификатор платы";

            packetDeviceStatus.coreVoltage["value"] = round((rawDataList[9].toInt() * 0.01) * 100 )/ 100;
            packetDeviceStatus.coreVoltage["flag"] = "#29CC97";
            packetDeviceStatus.coreVoltage["description"] = "Напряжение микроконтроллера, В";

            packetDeviceStatus.temperature["value"] = round((rawDataList[10].toInt() * 0.01) *100)/100;
            packetDeviceStatus.temperature["flag"] = "#29CC97";
            packetDeviceStatus.temperature["description"] = "Температура микроконтроллера, градусы";

            packetDeviceStatus.coreLoad["value"] = round((rawDataList[11].toInt() * 0.01)*100)/100;
            packetDeviceStatus.coreLoad["flag"] = "#29CC97";
            packetDeviceStatus.coreLoad["description"] = "Загрузка ядра микроконтроллера, % ";

            packetDeviceStatus.coreLoadMax["value"] = round((rawDataList[12].toInt() * 0.01)*100)/100;
            packetDeviceStatus.coreLoadMax["flag"] = "#29CC97";
            packetDeviceStatus.coreLoadMax["description"] = "Максимальная загрузка ядра микроконтроллера, %";

            packetDeviceStatus.powerMode["value"] = rawDataList[13].toInt();
            packetDeviceStatus.powerMode["flag"] = "#29CC97";
            packetDeviceStatus.powerMode["description"] = "Режим энергопотребления ";

            packetDeviceStatus.heapTotal["value"] = round((rawDataList[14].toInt() / 1024.)*100)/100;
            packetDeviceStatus.heapTotal["flag"] = "#29CC97";
            packetDeviceStatus.heapTotal["description"] = " Общий размер памяти ОС, kb";

            packetDeviceStatus.heapAvailable["value"] = round((rawDataList[15].toInt() / 1024.)*100)/100;
            packetDeviceStatus.heapAvailable["flag"] = "#29CC97";
            packetDeviceStatus.heapAvailable["description"] = "Доступный размер памяти ОС, kb";

            packetDeviceStatus.storageTotal["value"] = round((rawDataList[16].toInt() / 1024.)*100)/100;
            packetDeviceStatus.storageTotal["flag"] = "#9FA2B4";
            packetDeviceStatus.storageTotal["description"] = "Общий размер памяти хранения данных, kb";

            packetDeviceStatus.storageAvailable["value"] = round((rawDataList[17].toInt() / 1024.)*100)/100;
            packetDeviceStatus.storageAvailable["flag"] = "#9FA2B4";
            packetDeviceStatus.storageAvailable["description"] = "Доступный размер памяти хранения данных, kb";

            packetDeviceStatus.externalTotal["value"] = round((rawDataList[18].toInt() / 1024.)*100)/100;
            packetDeviceStatus.externalTotal["flag"] = "#29CC97";
            packetDeviceStatus.externalTotal["description"] = "Общий размер памяти на вн. носителе (SD), Mb";

            packetDeviceStatus.externalAvailable["value"] = round((rawDataList[19].toInt() / 1024.)*100)/100;
            packetDeviceStatus.externalAvailable["flag"] = "#29CC97";
            packetDeviceStatus.externalAvailable["description"] = "Доступный размер памяти на вн. носителе (SD), Mb ";
            m_deviceStatusData.append(packetDeviceStatus);
        }
        setDeviceStatusData(m_deviceStatusData);

    } else if (apiStr == "cycles_112") {
        if(dataArray.count() == 0) {
            qDebug() <<  "Нет данных 112 пакета.";
            m_bkpData.flagCycles112 = false;
            onParseCycles112End();
            onParseEnd();
            return;
        } else {
            m_bkpData.flagCycles112 = true;
        }
        m_cycles112DataArray.clear();
        for(int i = 0; i < dataArray.count(); i++) {
            dataObj = dataArray.at(i).toObject();

            QString rawDataString = dataObj["data"].toString();
            QStringList rawDataList = rawDataString.split(",", Qt::SkipEmptyParts);

            if(rawDataList.count() < 32) {
                qDebug() << rawDataList.count() << " error raw data112!";
                return;
            }
            packetCycles112.a1Cur["value"] = round((rawDataList[16].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a1Cur["flag"] = "#29CC97";
            packetCycles112.a1Cur["description"] = "Состояние аналогового входа 1 текущее";
            packetCycles112.a2Cur["value"] = round((rawDataList[17].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a2Cur["flag"] = "#29CC97";
            packetCycles112.a2Cur["description"] = "Состояние аналогового входа 2 текущее";
            packetCycles112.a3Cur["value"] = round((rawDataList[18].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a3Cur["flag"] = "#29CC97";
            packetCycles112.a3Cur["description"] = "Состояние аналогового входа 3 текущее";
            packetCycles112.a4Cur["value"] = round((rawDataList[19].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a4Cur["flag"] = "#29CC97";
            packetCycles112.a4Cur["description"] = "Состояние аналогового входа 4 текущее";
            packetCycles112.a5Cur["value"] = round((rawDataList[20].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a5Cur["flag"] = "#29CC97";
            packetCycles112.a5Cur["description"] = "Состояние аналогового входа 5 текущее";
            packetCycles112.a6Cur["value"] = round((rawDataList[21].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a6Cur["flag"] = "#29CC97";
            packetCycles112.a6Cur["description"] = "Состояние аналогового входа 6 текущее";
            packetCycles112.a7Cur["value"] = round((rawDataList[22].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a7Cur["flag"] = "#29CC97";
            packetCycles112.a7Cur["description"] = "Состояние аналогового входа 7 текущее";
            packetCycles112.a8Cur["value"] = round((rawDataList[23].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a8Cur["flag"] = "#29CC97";
            packetCycles112.a8Cur["description"] = "Состояние аналогового входа 8 текущее";
            packetCycles112.a9Cur["value"] = round((rawDataList[24].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a9Cur["flag"] = "#29CC97";
            packetCycles112.a9Cur["description"] = "Состояние аналогового входа 9 текущее";
            packetCycles112.a10Cur["value"] = round((rawDataList[25].toInt() * m_b + m_c)*100)/100;
            packetCycles112.a10Cur["flag"] = "#29CC97";
            packetCycles112.a10Cur["description"] = "Состояние аналогового входа 10 текущее";

            int discrete = rawDataList[29].toInt() + (rawDataList[30].toInt() << 8) + (rawDataList[31].toInt() << 16);
            QVariantMap tmp;
            QVector<QVariantMap> tmp2;

            for(int j = 0; j < 24; j++) {
                tmp["value"] = Check_Bit(discrete,j) << j;
                tmp["flag"] = "#29CC97";
                tmp["description"] = tr("Состояние дискретного входа %1 текущее").arg(i+1);
                tmp2.append(tmp);
            }
//            QVariantMap tmp;
//            QVector<QVariantMap> tmp2;

//            for(int j = 0; j < 12; j++) {
//                tmp["value"] = dataObj[tr("din%1cur").arg(j+1)].toString();
//                tmp["flag"] = "#29CC97";
//                tmp["description"] = tr("Состояние дискретного входа %1 текущее").arg(j+1);
//                tmp2.append(tmp);
//            }
            packetCycles112.dCur.append(tmp2);
            m_cycles112DataArray.append(packetCycles112);

        }
        setCycles112Data();
        checkCycles112Params(m_cycles112DataArray);
    }

}

bool Requester::setDeviceIdentData(QVector<deviceIdent> data) {
    int indexSadcoF1 = -1;
    int indexSadcoF4 = -1;
    int indexBkp = -1;

    for(int i = 0; i < data.count(); i++) {
       if(data[i].boardId["value"].toString() == "Плата Садко, чип F1") {
           indexSadcoF1 = i;
       }else if(data[i].boardId["value"].toString() == "Плата Садко, чип F4" ) {
            indexSadcoF4 = i;
        }else if(data[i].boardId["value"].toString() == "Плата БКП") {
            indexBkp = i;
        }
    }

    if( indexBkp == -1 ) {
       m_bkpData.flagIdent = false;
    } else {
        m_bkpData.deviceIdentPacket = data[indexBkp];
    }

    if(indexSadcoF1  == -1){
         m_sadcoF1Data.flagIdent = false;
    } else {
         m_sadcoF1Data.deviceIdentPacket = data[indexSadcoF1];
    }

    if(indexSadcoF4  == -1) {
         m_sadcoF4Data.flagIdent = false;
    } else {
         m_sadcoF4Data.deviceIdentPacket = data[indexSadcoF4];
    }

    onParseDeviceIdentEnd();
    return true;
}

void Requester::checkLocsParams(locs *data) {

    //hdop
    data->d1["value"] =  data->d1["value"] == 4095? "выкл" : "вкл";
    data->d2["value"] =  data->d2["value"] == 4095? "выкл" : "вкл";
    data->d3["value"] =  data->d3["value"] == 4095? "выкл" : "вкл";
    data->d4["value"] =  data->d4["value"] == 4095? "выкл" : "вкл";
    data->d5["value"] =  data->d5["value"] == 4095? "выкл" : "вкл";
    data->d6["value"] =  data->d6["value"] == 4095? "выкл" : "вкл";
    data->ign_state["value"] = data->ign_state["value"] == 0? "есть" : "нет";

    if(data->hdop["value"] > 300 * 0.01 || data->hdop["value"] < 1 * 0.01 ) {
        data->hdop["flag"] = "#F12B2C";
    } else if(data->hdop["value"] > 200 * 0.01){
        data->hdop["flag"] = "#FEC400";
    }
    //numsats
    data->numsats["flag"] = data->numsats["value"] < 1 ? "#F12B2C" : data->numsats["value"] < 3 ? "#FEC400" : "#29CC97";
    //bat_level
    data->bat_level["flag"] =
            data->bat_level["value"] > 2237.5 * 0.00886446886446886 || data->bat_level["value"] < 1342.5 * 0.00886446886446886 ? "#F12B2C" :
            data->bat_level["value"] > 1969 * 0.00886446886446886 || data->bat_level["value"] < 1611 * 0.00886446886446886 ? "#FEC400":
                                                                                  "#29CC97";
    //ign_state
    data->ign_state["flag"] = data->ign_state["value"] == "нет" ? "#F12B2C" : "#29CC97";
    //eng_run_time
    data->eng_run_time["flag"] = data->eng_run_time["value"] < 1 ? "#F12B2C" : "#29CC97";
    //in1
    data->in1["flag"] =
            data->in1["value"] > 1800 * 0.00886446886446886 || data->in1["value"] < 1016 * 0.00886446886446886 ? "#F12B2C" :
            data->in1["value"] > 1715 * 0.00886446886446886 || data->in1["value"] < 1241 * 0.00886446886446886 ? "#FEC400":
                                                                      "#29CC97";
    //in2
    data->in2["flag"] =
            data->in2["value"] > 3385 * 0.00886446886446886 || data->in2["value"] < 2031 * 0.00886446886446886 ? "#F12B2C" :
            data->in2["value"] > 2978.8 * 0.00886446886446886 || data->in2["value"] < 2437.2 * 0.00886446886446886 ? "#FEC400":
                                                                          "#29CC97";
    //gsm_level
    data->gsm_level["flag"] =
            data->gsm_level["value"] > 31 || data->gsm_level["value"] < 4 ? "#F12B2C" :
            data->gsm_level["value"] < 6 ? "#FEC400":
                                           "#29CC97";
    //temperature
    data->temperature["flag"] =
            data->temperature["value"] > (3580*0.1 - 273) || data->temperature["value"] < (2730*0.1 - 273) ? "#F12B2C" :
           data->temperature["value"] > (3380*0.1 - 273) || data->temperature["value"] < (2900*0.1 - 273) ? "#FEC400":
                                                                                                             "#29CC97";
    m_sadcoF4Data.locsPacket = *data;
}

bool Requester::setDeviceStatusData(QVector<deviceStatus> data) {
    int indexSadcoF4 = -1;
    int indexBkp = -1;

    for(int i = 0; i < data.count(); i++) {
        if(data[i].boardId["value"].toString() == "Плата Садко, чип F4" ) {
            indexSadcoF4 = i;
        }else if(data[i].boardId["value"] == "Плата БКП") {
            indexBkp = i;
        }
    }

    if(indexBkp == -1) {
        m_bkpData.flagStatus = false;
    } else {
         m_bkpData.deviceStatusPacket = data[indexBkp];
         checkDeviceStatusParams(&m_bkpData.deviceStatusPacket);
    }
    if(indexSadcoF4 == -1) {
        m_sadcoF4Data.flagStatus = false;
    } else {
        m_sadcoF4Data.deviceStatusPacket = data[indexSadcoF4];
        checkDeviceStatusParams(&m_sadcoF4Data.deviceStatusPacket);
    }

    onParseDeviceStatusEnd();

    return true;
}

void Requester::checkDeviceStatusParams(deviceStatus *data) {

    if(data->coreVoltage["value"] > 363 * 0.01 || data->coreVoltage["value"]  < 297 * 0.01 ) {
        data->coreVoltage["flag"] = "#F12B2C";
    } else if(data->coreVoltage["value"] > 346.5 * 0.01 || data->coreVoltage["value"]  < 313.5 * 0.01) {
        data->coreVoltage["flag"] = "#FEC400";
    }
    data->temperature["flag"] =
           data->temperature["value"] > (3580*0.1 - 273) || data->temperature["value"] < (2730*0.1 - 273) ? "#F12B2C" :
           data->temperature["value"] > (3380*0.1 - 273) || data->temperature["value"] < (2900*0.1 - 273) ? "#FEC400":
                                                                                                             "#29CC97";
    data->coreLoad["flag"] =
            data->coreLoad["value"] > 9000 * 0.01? "#F12B2C" : data->coreLoad["value"] > 5000* 0.01 ? "#FEC400": "#29CC97";
    data->coreLoadMax["flag"] =
            data->coreLoadMax["value"] > 9000 * 0.01? "#F12B2C" : data->coreLoadMax["value"] > 5000* 0.01 ? "#FEC400": "#29CC97";

    data->powerMode["value"] =
                data->powerMode["value"] == 0 ? "режим работы не определен" :
                data->powerMode["value"] == 1 ? "нормальный режим работы":
                data->powerMode["value"] == 2 ? "режим пониженного энегропотребления" :
                data->powerMode["value"] == 4 ? "режим сна":
                data->powerMode["value"] == 8 ? "режим остановки":
                data->powerMode["value"] == 16 ? "режим ожидания": "выключение";

    data->heapTotal["flag"] =
            data->heapTotal["value"] < 1 ? "#F12B2C" : "#29CC97";
    data->heapAvailable["flag"] =
            data->heapAvailable["value"] < 100./1024. ? "#F12B2C" :  data->heapAvailable["value"] < 1000./1024. ? "#FEC400": "#29CC97";
    data->externalTotal["flag"] =
            data->externalTotal["value"] < 1 ? "#FEC400": "#29CC97";
    data->externalAvailable["flag"] =
            data->externalAvailable["value"] < 1 ? "#FEC400": "#29CC97";

     data->storageTotal["flag"] = data->storageTotal["value"].toDouble() < 1024? "#FEC400" : "#29CC97";
    data->storageAvailable["flag"] =
          data->storageAvailable["value"].toDouble() >=  data->storageTotal["value"].toDouble() * 0.10 ? "#29CC97" :
                                                                                                         "#FEC400";
}

void Requester::checkCycles112Params(QVector<cycles112> &data) {

    m_cycles112Data.a1Cur["value"] = data[ data.count() - 1].a1Cur["value"];
     m_cycles112Data.a1Cur["flag"] = data[ data.count() - 1].a1Cur["value"] > 5 * 1.25 ||  data[ data.count() - 1].a1Cur["value"] < 5 * 0.75? "#F12B2C" :
            data[ data.count() - 1].a1Cur["value"] > 5 * 1.1 ||  data[ data.count() - 1].a1Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a2Cur["value"] = data[data.count() - 1].a2Cur["value"];
    m_cycles112Data.a2Cur["flag"] = data[data.count() - 1].a2Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a2Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a2Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a2Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a3Cur["value"] = data[data.count() - 1].a3Cur["value"];
    m_cycles112Data.a3Cur["flag"] = data[data.count() - 1].a3Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a3Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a3Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a3Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a4Cur["value"] = data[data.count() - 1].a4Cur["value"];
    m_cycles112Data.a4Cur["flag"] = data[data.count() - 1].a4Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a4Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a4Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a3Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a5Cur["value"] = data[data.count() - 1].a5Cur["value"];
    m_cycles112Data.a5Cur["flag"] = data[data.count() - 1].a5Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a5Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a5Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a5Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a6Cur["value"] = data[data.count() - 1].a6Cur["value"];
    m_cycles112Data.a6Cur["flag"] = data[data.count() - 1].a6Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a6Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a6Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a6Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a7Cur["value"] = data[data.count() - 1].a7Cur["value"];
    m_cycles112Data.a7Cur["flag"] = data[data.count() - 1].a7Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a7Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a7Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a7Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a8Cur["value"] = data[data.count() - 1].a8Cur["value"];
    m_cycles112Data.a8Cur["flag"] = data[data.count() - 1].a8Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a8Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a8Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a8Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a9Cur["value"] = data[data.count() - 1].a9Cur["value"];
    m_cycles112Data.a9Cur["flag"] = data[data.count() - 1].a9Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a9Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[data.count() - 1].a9Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a9Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

    m_cycles112Data.a10Cur["value"] = data[data.count() - 1].a10Cur["value"];
    m_cycles112Data.a10Cur["flag"] = data[data.count() - 1].a10Cur["value"] > 5 * 1.25 ||  data[data.count() - 1].a10Cur["value"] < 5 * 0.75? "#F12B2C" :
           data[ data.count() - 1].a10Cur["value"] > 5 * 1.1 ||  data[data.count() - 1].a10Cur["value"] < 5 * 0.9 ?  "#FEC400": "#29CC97";

///////////////////////////////

    for(int i = 0; i < data.count(); i++) {
        for(int count = 0; count < data[i].dCur.count(); count++) {
             for(int j = 0; j < data[i].dCur[i].count(); j++) {
                if(data[i].dCur[count][j]["value"] == false) {
                     m_cycles112Data.dCur[0][j]["value"] = "вкл";
                     m_cycles112Data.dCur[0][j]["flag"] = "#29CC97";
                }
             }
        }
     }
    m_bkpData.cycles112Packet = m_cycles112Data;

    onParseCycles112End();
    onParseEnd();
}

void Requester::getLocsRequest(bool isIMEI, QString number, QString typeCar) {
        QString typeNumber;
        QVariantMap time;
        QVariantMap timeOther;

        typeNumber = isIMEI? "imei" : "kr";

        time.clear();
        timeOther.clear();

        int timeReqFinish= abs(QTime::currentTime().secsTo(timeStartTest.addSecs(60)));

        int timeLocsStart = abs(QTime::currentTime().secsTo(timeStartTest.addSecs(-240))); //868136035383846
        int timeIdentStart = abs( QTime::currentTime().secsTo(timeStartTest.addSecs(-10920))); //-3720
        int timeDeviceStart = abs( QTime::currentTime().secsTo(timeStartTest.addSecs(-1920))); //-420
        int timeCycle112Start = abs(QTime::currentTime().secsTo(timeStartTest.addSecs(-120)));

         QString curDate = QDateTime::currentDateTime().date().toString(Qt::ISODate);

        qDebug() << QTime::currentTime() <<  timeReqFinish << timeLocsStart << timeIdentStart << timeDeviceStart << timeCycle112Start;

        QString apiStr = "%1=%2&pack=%3&histDate=%4&limit=10&start=%5&finish=%6";

        sendRequest(apiStr.arg(typeNumber).arg(number).arg("1").arg(curDate).arg(timeLocsStart).arg(timeReqFinish), "locs", Requester::Type::GET); // "2020-12-01" "2020-12-01" "2020-12-01" "2020-11-18"

        connect(this, &Requester::onParseLocsEnd, this, [this,typeNumber,number,apiStr,timeIdentStart,timeReqFinish,curDate]() {
            sendRequest(apiStr.arg(typeNumber).arg(number).arg("8").arg(curDate).arg(timeIdentStart).arg(timeReqFinish), "device_ident", Requester::Type::GET);
        });
        connect(this, &Requester::onParseDeviceIdentEnd, this, [this,typeNumber,number,apiStr,timeDeviceStart,timeReqFinish,curDate]() {
           sendRequest(apiStr.arg(typeNumber).arg(number).arg("9").arg(curDate).arg(timeDeviceStart).arg(timeReqFinish), "device_status", Requester::Type::GET);
        });
        connect(this, &Requester::onParseDeviceStatusEnd, this, [this,typeNumber,number,apiStr,timeCycle112Start,timeReqFinish, curDate]() {
            sendRequest(apiStr.arg(typeNumber).arg(number).arg("112").arg(curDate).arg(timeCycle112Start).arg(timeReqFinish), "cycles_112", Requester::Type::GET);
        });
}

void Requester::reqDisconnect() {
    disconnect(this,&Requester::onParseLocsEnd,nullptr,nullptr);
    disconnect(this,&Requester::onParseDeviceIdentEnd,nullptr,nullptr);
    disconnect(this,&Requester::onParseDeviceStatusEnd,nullptr,nullptr);
//        disconnect(this,&Requester::onParseLocsEnd,0,0);
}

QString Requester::getTypeCarRequest(bool isIMEI, QString number) {
    QVariantMap dataRequest;
    QString typeNumber;
    typeNumber = isIMEI? "imei" : "kr";
    dataRequest.insert(typeNumber, number);
    emit onGetTypeEnd();
    timeStartTest = QTime::currentTime();
    qDebug() << timeStartTest;
//    sendRequest("get_type", Requester::Type::POST, dataRequest);
}

void Requester::startCommonTest() {
    Stand_Discrete_Seq_Item_t tmp;
    QVector<Stand_Discrete_Seq_Item_t> dicreteOutSeqArr;
    dicreteOutSeqArr.clear();
    int testMask = 0;
    m_countDiscreteCurTypeCar = 0;

    for(int i = 0; i < typeCars.count(); ++i) {
        if(typeCars[i]["type"].toString() == m_typeCar) {
            qDebug() << "reqComm" << m_typeCar;
            testMask = typeCars[i]["mask"].toInt();
            break;
        }
    }

    if(testMask != 0) {
        // создание конфигурации тестирования
        tmp.Delay = 1000;
        for (int i = 0; i < 32; ++i) {
           tmp.OutputsState = 0;
           if( Check_Bit( testMask, i ) ) {
               tmp.OutputsState = Set_Bit(tmp.OutputsState, i);
               m_countDiscreteCurTypeCar++;
               dicreteOutSeqArr.append(tmp);
           }
           if( i < 12 ) { m_analogValues.append(5); } // 12 - аналогов в интерфейсе
        }
       m_discreteSequencePlus->setDiscreteOutSeq(dicreteOutSeqArr);
    }
    endPrepareCommonTestParameters(m_discreteSequencePlus, m_analogValues);
}

QVector<locs> Requester::getLocsData() const {
    return m_locsData;
}

QVector<deviceIdent> Requester::getDeviceIdentData() const {
    return m_deviceIdentData;
}

QVector<deviceStatus> Requester::getDeviceStatusData() const
{
    return m_deviceStatusData;
}

cycles112 Requester::getCycles112Data() const {
    return m_cycles112Data;
}

void Requester::setCycles112Data() {
        m_cycles112Data.dCur.clear();
        QVariantMap tmp;
        QVector<QVariantMap> tmp2;
        for(int i = 0; i < m_countDiscreteCurTypeCar; i++ ){ // 6 - int countDiscrete
            tmp["value"] = "выкл";
            tmp["flag"] = "#F12B2C";
            tmp["description"] = tr("Дискретный вход %1").arg(i+1);
            tmp2.append(tmp);
        }
        m_cycles112Data.dCur.append(tmp2);

        m_cycles112Data.a1Cur["flag"] = "#F12B2C";
        m_cycles112Data.a1Cur["value"] = 0;
        m_cycles112Data.a1Cur["description"] = "Аналоговый вход 1, B";
        m_cycles112Data.a2Cur["flag"] = "#F12B2C";
        m_cycles112Data.a2Cur["value"] = 0;
        m_cycles112Data.a2Cur["description"] = "Аналоговый вход 2, B";
        m_cycles112Data.a3Cur["flag"] = "#F12B2C";
        m_cycles112Data.a3Cur["value"] = 0;
        m_cycles112Data.a3Cur["description"] = "Аналоговый вход 3, B";
        m_cycles112Data.a4Cur["flag"] = "#F12B2C";
        m_cycles112Data.a4Cur["value"] = 0;
        m_cycles112Data.a4Cur["description"] = "Аналоговый вход 4, B";
        m_cycles112Data.a5Cur["flag"] = "#F12B2C";
        m_cycles112Data.a5Cur["value"] = 0;
        m_cycles112Data.a5Cur["description"] = "Аналоговый вход 5, B";
        m_cycles112Data.a6Cur["flag"] = "#F12B2C";
        m_cycles112Data.a6Cur["value"] = 0;
        m_cycles112Data.a6Cur["description"] = "Аналоговый вход 6, B";
        m_cycles112Data.a7Cur["flag"] = "#F12B2C";
        m_cycles112Data.a7Cur["value"] = 0;
        m_cycles112Data.a7Cur["description"] = "Аналоговый вход 7, B";
        m_cycles112Data.a8Cur["flag"] = "#F12B2C";
        m_cycles112Data.a8Cur["value"] = 0;
        m_cycles112Data.a8Cur["description"] = "Аналоговый вход 8, B";
        m_cycles112Data.a9Cur["flag"] = "#F12B2C";
        m_cycles112Data.a9Cur["value"] = 0;
        m_cycles112Data.a9Cur["description"] = "Аналоговый вход 9, B";
        m_cycles112Data.a10Cur["flag"] = "#F12B2C";
        m_cycles112Data.a10Cur["value"] = 0;
        m_cycles112Data.a10Cur["description"] = "Аналоговый вход 10, B";
}

void Requester::setCurrentTestByCarDate(const QString &currentTestByCarDate) {
    m_currentTestByCarDate = currentTestByCarDate;
}

void Requester::setCurrentTestByCarTime(const QString &currentTestByCarTime) {
    m_currentTestByCarTime = currentTestByCarTime;
}

bkp Requester::getBkpData() const
{
    return m_bkpData;
}

sadcoF1 Requester::getSadcoF1Data() const
{
    return m_sadcoF1Data;
}

sadcoF4 Requester::getSadcoF4Data() const
{
    return m_sadcoF4Data;
}

void Requester::setTypeCar(const QString &value) {
    m_typeCar = value;
}

///!!!!

QByteArray Requester::variantMapToJson(QVariantMap data)
{
    QJsonDocument postDataDoc = QJsonDocument::fromVariant(data);
    qDebug() << postDataDoc;
    QByteArray postDataByteArray = postDataDoc.toJson();

    return postDataByteArray;
}

QNetworkRequest Requester::createRequest(const QString &apiStr, QString typeRequest)
{
    QNetworkRequest request;
    QString reqAdrr = "LogsPlainDayServlet";
    QString url = pathTemplate.arg(host).arg(port).arg(reqAdrr).arg(apiStr);
    request.setUrl(QUrl(url));
    request.setRawHeader("Content-Type","application/json");
    if(!token.isEmpty())
        request.setRawHeader("Authorization",QString("token %1").arg(token).toUtf8());
    if (sslConfig != nullptr)
        request.setSslConfiguration(*sslConfig);

    return request;
}

QNetworkReply* Requester::sendCustomRequest(QNetworkAccessManager* manager,
                                            QNetworkRequest &request,
                                            const QString &type,
                                            const QVariantMap &data)
{
    request.setRawHeader("HTTP", type.toUtf8());
    QByteArray postDataByteArray = variantMapToJson(data);
    QBuffer *buff = new QBuffer;
    buff->setData(postDataByteArray);
    buff->open(QIODevice::ReadOnly);
    QNetworkReply* reply =  manager->sendCustomRequest(request, type.toUtf8(), buff);
    buff->setParent(reply);
    return reply;
}

QJsonObject Requester::parseReply(QNetworkReply *reply)
{
    QJsonObject jsonObj;
    QJsonDocument jsonDoc;
    QJsonParseError parseError;
    auto replyText = reply->readAll();
    jsonDoc = QJsonDocument::fromJson(replyText, &parseError);
    if(parseError.error != QJsonParseError::NoError){
        qWarning() << "Json parse error: " << parseError.errorString();
    }else{
        if(jsonDoc.isObject()) {
            jsonObj  = jsonDoc.object();
        }
        else if (jsonDoc.isArray()) {
            jsonObj["non_field_errors"] = jsonDoc.array();
        }
    }
    return jsonObj;
}

bool Requester::onFinishRequest(QNetworkReply *reply)
{
    auto replyError = reply->error();
    if (replyError == QNetworkReply::NoError ) {
        int code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if ((code >=200) && (code < 300)) {
            return true;
        }
    }
    return false;
}

void Requester::handleQtNetworkErrors(QNetworkReply *reply, QJsonObject &obj)
{
    auto replyError = reply->error();
    if (!(replyError == QNetworkReply::NoError ||
          replyError == QNetworkReply::ContentNotFoundError ||
          replyError == QNetworkReply::ContentAccessDenied ||
          replyError == QNetworkReply::ProtocolInvalidOperationError
          ) ) {
        qDebug() << reply->error();
        obj[KEY_QNETWORK_REPLY_ERROR] = reply->errorString();
    } else if (replyError == QNetworkReply::ContentNotFoundError)
        obj[KEY_CONTENT_NOT_FOUND] = reply->errorString();
}
