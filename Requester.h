#ifndef REQUESTER_H
#define REQUESTER_H

#include <QObject>
#include <QBuffer>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <functional>
#include <QMessageBox>
#include "stand_defs.h"
#include "DiscreteOutSequenceModel.h"

typedef struct locsPacket { // 1 пакет - 1 раз в 2,5 м.
    QVariantMap longitude; // долгота
    QVariantMap latitude; // широта

    QVariantMap hdop;
    QVariantMap numsats;
    QVariantMap bat_level;
    QVariantMap ign_state;
    QVariantMap eng_run_time;
    QVariantMap gsm_level;
    QVariantMap temperature;
    QVariantMap dt;
    QVariantMap in1;
    QVariantMap in2;
    QVariantMap in3;
    QVariantMap in4;
    QVariantMap d1;
    QVariantMap d2;
    QVariantMap d3;
    QVariantMap d4;
    QVariantMap d5;
    QVariantMap d6;
    QVariantMap cnt1;
    QVariantMap cnt2;
    QVariantMap cnt3;
    QVariantMap cnt4;
    QVariantMap cnt5;
    QVariantMap cnt6;
} locs;

typedef struct deviceIdentPacket { // 8 пакет 1 раз в 1 ч.
    QVariantMap boardId;
    QVariantMap deviceId;
    QVariantMap modelName;
    QVariantMap version;
    QVariantMap fwVerRealise;
    QVariantMap fwVerMajor;
    QVariantMap fwVerMinor;
    QVariantMap result;
} deviceIdent;

typedef struct deviceStatusPacket { // 9 пакет 1 раз в 5 м.

    QVariantMap boardId;
    QVariantMap coreVoltage;
    QVariantMap temperature;
    QVariantMap coreLoad;
    QVariantMap coreLoadMax;
    QVariantMap powerMode;
    QVariantMap heapTotal;
    QVariantMap heapAvailable;
    QVariantMap storageTotal;
    QVariantMap storageAvailable;
    QVariantMap externalTotal;
    QVariantMap externalAvailable;
    QVariantMap result;
} deviceStatus;

typedef struct cycles112Packet {
    QVariantMap a1Last;
    QVariantMap a2Last;
    QVariantMap a3Last;
    QVariantMap a4Last;
    QVariantMap a5Last;
    QVariantMap a6Last;
    QVariantMap a7Last;
    QVariantMap a8Last;
    QVariantMap a9Last;
    QVariantMap a10Last;
    QVariantMap a1Cur;
    QVariantMap a2Cur;
    QVariantMap a3Cur;
    QVariantMap a4Cur;
    QVariantMap a5Cur;
    QVariantMap a6Cur;
    QVariantMap a7Cur;
    QVariantMap a8Cur;
    QVariantMap a9Cur;
    QVariantMap a10Cur;

    QVector<QVector<QVariantMap>> dCur;
    QVariantMap d1Cur;
    QVariantMap d2Cur;
    QVariantMap d3Cur;
    QVariantMap d4Cur;
    QVariantMap d5Cur;
    QVariantMap d6Cur;
    QVariantMap d7Cur;
    QVariantMap d8Cur;
    QVariantMap d9Cur;
    QVariantMap d10Cur;
    QVariantMap d11Cur;
    QVariantMap d12Cur;
    QVariantMap d13Cur;
    QVariantMap d14Cur;
    QVariantMap d15Cur;
    QVariantMap d16Cur;
    QVariantMap d17Cur;
    QVariantMap d18Cur;
    QVariantMap d19Cur;
    QVariantMap d20Cur;
    QVariantMap d21Cur;
    QVariantMap d22Cur;
    QVariantMap d23Cur;
    QVariantMap d24Cur;
    QVariantMap result;

} cycles112;

typedef struct sadcoF1Packets {
    deviceIdent deviceIdentPacket; // 8
    bool flagIdent = false;
} sadcoF1;

typedef struct sadcoF4Packets {
    locs locsPacket; // 1
    deviceIdent deviceIdentPacket; // 8
    deviceStatus deviceStatusPacket; // 9
    bool flagLocs = false;
    bool flagIdent = false;
    bool flagStatus = false;
} sadcoF4;

typedef struct bkpPackets {
    deviceIdent deviceIdentPacket; // 8
    deviceStatus deviceStatusPacket; // 9
    cycles112 cycles112Packet; //112
    bool flagCycles112 = false;
    bool flagIdent = false;
    bool flagStatus = false;
} bkp;


class Requester: public QObject
{
    Q_OBJECT
public:
    typedef std::function<void()> finishFunc;

    static const QString KEY_QNETWORK_REPLY_ERROR;
    static const QString KEY_CONTENT_NOT_FOUND;
    int m_countDiscreteCurTypeCar = 12; // TODO: сделать 0!

    enum class Type {
        POST,
        GET,
        PATCH,
        DELET
    };

    explicit Requester(QObject *parent = nullptr);
    void reqDisconnect();

    void initRequester(const QString& host, int port, QSslConfiguration *value);

    void initTypeCars();

    void sendRequest(const QString &apiStr, QString typeRequest,
                     Type type = Type::GET,
                     const QVariantMap &data = QVariantMap());

    void sendMulishGetRequest(const QString &apiStr,
                              const finishFunc &funcFinish);

    QString getToken() const;
    void setToken(const QString &value);

    void parser(const QString &apiStr, QJsonObject obj); // обработчик всех пакетов


    bool setDeviceIdentData(QVector<deviceIdent> data);
    bool setDeviceStatusData(QVector<deviceStatus> data);

    void checkLocsParams(locs *data); // проверка 1-го пакета
    void checkDeviceStatusParams(deviceStatus *data); // проверка 9-го пакета
    void checkCycles112Params(QVector<cycles112> &data); // проверка 112-го пакета

    void getLocsRequest(bool isIMEI, QString number, QString typeCar);

    void startCommonTest();

    QString getTypeCarRequest(bool isIMEI, QString number);

    QVector<locs> getLocsData() const;

    QVector<deviceIdent> getDeviceIdentData() const;

    QVector<deviceStatus> getDeviceStatusData() const;

    cycles112 getCycles112Data() const;

    void setCycles112Data();

    QVector<qreal> m_analogValues;
    DiscreteOutSequenceModel *m_discreteSequencePlus;
    DiscreteOutSequenceModel *m_discreteSequenceMinus;

    void setCurrentTestByCarDate(const QString &currentTestByCarDate);

    void setCurrentTestByCarTime(const QString &currentTestByCarTime);

    bkp getBkpData() const;

    sadcoF1 getSadcoF1Data() const;

    sadcoF4 getSadcoF4Data() const;

    void setTypeCar(const QString &value);

   QTime timeStartTest;

private:
    static const QString httpTemplate;
    static const QString httpsTemplate;

    QString m_typeCar = "null";
    int m_packetsFlag = 0;

    double m_b = 0.008058608; // коэффициент для пересчета аналогов
    double m_c = -13.75; // коэффициент для пересчета аналогов

    bkp m_bkpData;
    sadcoF1 m_sadcoF1Data;
    sadcoF4 m_sadcoF4Data;

    QVector<locs> m_locsData;
    QVector<deviceIdent> m_deviceIdentData;
    QVector<deviceStatus> m_deviceStatusData;
    QVector<cycles112> m_cycles112DataArray;
    cycles112 m_cycles112Data;
    QVector<QVariantMap> typeCars;
    QString m_currentTestByCarDate = "EOF";
    QString m_currentTestByCarTime = "EOF";
    QMessageBox m_messageBox;

    QString host;
    int port;
    QString token;
    QSslConfiguration *sslConfig;

    QString pathTemplate;

    QByteArray variantMapToJson(QVariantMap data);

    QNetworkRequest createRequest(const QString &apiStr, QString typeRequest);

    QNetworkReply *sendCustomRequest(QNetworkAccessManager *manager,
                                     QNetworkRequest &request,
                                     const QString &type,
                                     const QVariantMap &data);

    QJsonObject parseReply(QNetworkReply *reply);

    bool onFinishRequest(QNetworkReply *reply);

    void handleQtNetworkErrors(QNetworkReply *reply, QJsonObject &obj);
    QNetworkAccessManager *manager;

signals:
    void networkError();
    void onParseEnd();
    void onParseLocsEnd();
    void onParseCycles112End();
    void onParseDeviceIdentEnd();
    void onParseDeviceStatusEnd();
    void onErrorReply();
    void onGetTypeEnd();
    void endPrepareCommonTestParameters(DiscreteOutSequenceModel*, QVector<qreal>);

};

#endif // REQUESTER_H