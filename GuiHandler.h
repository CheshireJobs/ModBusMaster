#ifndef GUIHANDLER_H
#define GUIHANDLER_H

#include <QtCharts>
#include "log.h"
#include "StandTester.h"
#include "Requester.h"


class GuiHandler: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString infoText MEMBER m_infoText NOTIFY infoTextChanged)
    Q_PROPERTY(bool discreteState MEMBER m_discreteState)
    Q_PROPERTY(QVariantList discreteList MEMBER m_discreteList NOTIFY discreteListChanged) // для модели

    Q_PROPERTY(QVariantList akbParamList MEMBER m_akbParamList NOTIFY paramListChanged)
    Q_PROPERTY(QVariantList gpsParamList MEMBER m_gpsParamList NOTIFY paramListChanged)
    Q_PROPERTY(QVariantList sdCardParamList MEMBER m_sdCardParamList NOTIFY paramListChanged)

    Q_PROPERTY(QVariantList paramList MEMBER m_bkpParamList NOTIFY paramListChanged)
    Q_PROPERTY(QVariantList sadcoF1ParamList MEMBER m_sadcoF1ParamList NOTIFY paramListChanged)
    Q_PROPERTY(QVariantList sadcoF4ParamList MEMBER m_sadcoF4ParamList NOTIFY paramListChanged)
    Q_PROPERTY(QVariantList elementsResult MEMBER m_elementsResult NOTIFY onElementsResultListChanged) //m_resultTest
    Q_PROPERTY(QVariantList boardsResult MEMBER m_boardsResult NOTIFY onBoardsResultListChanged)

    Q_PROPERTY(QString resultTest MEMBER m_resultTest)
    Q_PROPERTY(int testResult MEMBER m_testResult NOTIFY testResultChanged)
    Q_PROPERTY(int countErrors MEMBER m_countErrors )
    Q_PROPERTY(int countOk MEMBER m_countOk)
    Q_PROPERTY(int countWarnings MEMBER m_countWarnings )
    Q_PROPERTY(int countCheck MEMBER m_countCheck )

    Q_PROPERTY(QString additionalInfo MEMBER m_additionalInfo )
    Q_PROPERTY(QVariantList discreteList2 MEMBER m_discreteList2 NOTIFY discreteListChanged)
    Q_PROPERTY(QVariantList analogList MEMBER m_analogList NOTIFY analogListChanged)
    Q_PROPERTY(QVector<int> editedDiscreteOutputs MEMBER m_editedDiscreteOutputs) // который отправляем на запись
    Q_PROPERTY(QVector<qreal> editedAnalogOutputs MEMBER m_editedAnalogOutputs)

public:
    GuiHandler(QQmlContext *context);
    ~GuiHandler();

//    QDataTime

public slots:

    void openMapToCoordinates(double longitude, double altitude);
    // settings
    bool onConnectedClicked(QString namePort, int baudRate,
                            int dataBits, int parity, int stopBits);
    void dicsonnectDevice();

    //dataSourse
//    void update(QAbstractSeries *seriesX, QAbstractSeries *seriesY, QAbstractSeries *seriesZ);
    void getIdxData(); //! для вывода основной информации о плате ( устройстве)
    void setTime();

    ///standTester

    void setDiscreteSettings();
    void readDiscreteCount();

    void setAnalogSettings();
    void readAnalogCount();

    void readCommonOutputs();

    // discrete
    void loadSequence(QString nameFile, QUrl urlFile, DiscreteOutSequenceModel *discreteOutSequenceModel, bool url);
    void saveSequence(QUrl nameFile, DiscreteOutSequenceModel *discreteOutSequenceModel);

    void startTesting(int mode, DiscreteOutSequenceModel* discreteOutSequenceModel,
                         int delayValue, int countCycleValue);
    void stopTest();

    // analogue
    void loadAnalogSequence(QUrl nameFile,AnalogOutSequenceModel *analogOutSequenceModel);
    void saveAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel);

    void startAnalogTesting(int mode, AnalogOutSequenceModel *analogOutSequenceModel,
                            int delayValue, int countCycleValue);

    void stopAnalogTesting();

    // timers
    void loadTimerSequence(QUrl nameFile,TimerOutSequenceModel *timerOutSequenceModel);
    void saveTimerSequence(QUrl nameFile, TimerOutSequenceModel *timerOutSequenceModel);

    void startTimerTest(int mode, int freqValTimer1, int dutyValTimer1,int freqValTimer2, int dutyValTimer2,
                                   int freqValTimer3, int dutyValTimer3, int freqValTimer4, int dutyValTimer4);

    void startTimerSeqTest(int mode, TimerOutSequenceModel* timerOutSequenceModel,
                                                int countCycleValue, int delayValue);

    void stopTimerTest();


    void discreteTimerStart();
    void discreteTimerStop();

    void analogTimerStart();
    void analogTimerStop();

    void commonTimerStart();
    void commonTimerStop();

    bool getState() { return m_stand->getState();}

    void setTypeCar(QString typeCar);

    // client
    void getType(bool isIMEI, QString number, QString typeCar);
    void setCurTimeTest(QString date, QString time);
    void getLocsRequest(bool isIMEI, QString number, QString typeCar);
    void setParams();
    void startCommonTest(DiscreteOutSequenceModel *discreteModel, QVector<qreal> analogValues);

signals:
    void infoTextChanged();
    void discreteListChanged();
    void analogListChanged();
    void paramListChanged();
    void onElementsResultListChanged();
    void onBoardsResultListChanged();
    void stopTestByTypeCar();
    void testResultChanged();

private:
    bool m_discreteState = false;
    QString m_infoText;
    QQmlContext *m_context;
    StandTester *m_stand;
    Requester *m_client;
    QString m_resultTest;
    QString m_additionalInfo;
    int m_countErrors = 0;
    int m_countOk = 0;
    int m_countWarnings = 0;
    int m_countCheck = 0;

    QMessageBox m_messageBox;

    int m_testResult = -1;
    QVector<int> m_testResultArray;
    QVariantList m_akbParamList;
    QVariantList m_gpsParamList;
    QVariantList m_sdCardParamList;
    QVariantList m_bkpParamList;
    QVariantList m_sadcoF1ParamList;
    QVariantList m_sadcoF4ParamList;
    QVariantList m_elementsResult;
    QVariantList m_boardsResult;

    QVariantList m_discreteList; // модель
    QVariantList m_discreteList2;
    QVariantList m_analogList;
    QVector<int> m_editedDiscreteOutputs;
    QVector<qreal> m_editedAnalogOutputs;
    QVector<uint16_t> m_currentDiscreteOutputsState;
    QTimer *m_discreteTimer;
    QTimer *m_analogTimer;
    QTimer *m_commonTimer;
};

#endif // GUIHANDLER_H
