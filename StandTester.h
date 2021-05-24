#ifndef STANDTESTER_H
#define STANDTESTER_H
#include "stand_defs.h"
#include "app_defs.h"
#include "ModBusMaster.h"
#include "settingsDialog.h"
#include "datasource.h"
#include "DiscreteOutSequenceModel.h"
#include "TimerOutSequenceModel.h"
#include "AnalogOutSequenceModel.h"
#include "FileLoader.h"

class StandTester : public QObject
{
    Q_OBJECT

public:
    StandTester(QQmlContext *context, QObject *parent = nullptr);
    ~StandTester();

    int m_discreteSlaveAdress = 1;
    int m_analogSlaveAdress = 2;
    QTimer m_timerStopTest;

    Stand_Mode_t curStandMode; /*!< Текущее состояние стенда */
    Stand_Outputs_Info_t m_discreteOutInfo; /*!< Информация о дискретной плате*/
    Stand_Outputs_Info_t analogOutInfo; /*!< Информация об аналоговой плате*/

    bool connectDevice(QString namePort, int baudRate, int dataBits, int parity, int stopBits); // MB установка соединения с устройством
    void disconnectDevice();

    void synchronizeWithSystemTime();
//    void updateAccelerometerData(QAbstractSeries *seriesX,
//                                 QAbstractSeries *seriesY, QAbstractSeries *seriesZ);
    void readCurrentSettings(int slaveAdress); // считывает информацию о плате?

    void readCurrentMode();

    QVector<uint16_t> getCurrentDiscreteOutputsState();
    QVector<float> getCurrentAnalogOutputsState();
    void stndDisconnect();

    int getDeviceInfo(int slaveAdress); // информация о плате (только тестовая плата?)

    void startTest(QVector<int> discreteOutputs, int mode,
                   DiscreteOutSequenceModel *discreteOutSequenceModel, int delayValue, int countCycleValue);// по такому типу старт
    /// Аналоги
    void startAnalogTest(QVector<qreal> editedAnalogOutputs, int mode, AnalogOutSequenceModel *analogOutSequenceModel, int delayValue, int countCycleValue);
    void stopAnalogTest();
    ///

    void startTestTimer(int mode, int freqValTimer1, int dutyValTimer1,int freqValTimer2, int dutyValTimer2,
                                    int freqValTimer3,int dutyValTimer3, int freqValTimer4, int dutyValTimer4 );

    void startTestSeqTimer(int mode, TimerOutSequenceModel *timerOutSequenceModel,
                                                int countCycleValue, int delayValue);

    void stopTest(QVector<int> discreteOutputs);
    void stopTimerTest();

    void loadSequence(QString nameFile, QUrl urlFile, DiscreteOutSequenceModel *discreteOutSequenceModel, bool url);
    void saveSequence(QUrl nameFile, DiscreteOutSequenceModel *discreteOutSequenceModel);

    void loadAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel);
    void saveAnalogSequence(QUrl nameFile, AnalogOutSequenceModel *analogOutSequenceModel);

    void loadTimerSequence(QUrl nameFile,TimerOutSequenceModel *timerOutSequenceModel);
    void saveTimerSequence(QUrl nameFile, TimerOutSequenceModel *timerOutSequenceModel);

    bool getState();

    // тестирование по типу машины
    void startCommonTestByTypeCar(DiscreteOutSequenceModel* discreteModel, QVector<qreal> analogValues);

signals:
    void onOutputCountDiscreteChanged();
    void onEndTestDiscrete();
    void onStopTestByCar();
    void onGetTimeTest(QString date, QString time);

private:
    QQmlContext *m_context;
    ModBusMaster *m_modBusMaster;
    QMessageBox m_messageBox;
//    DataSource m_data;

    int m_currentSlaveAdress = -1;

    QVector<uint16_t> m_discreteOutputsState;
    QVector<float> m_analogOutputsState;
    Stand_Mode_t m_currentDiscreteMode;
    Stand_Mode_t m_currentAnalogMode;
//    FileLoader m_FileLoader;

};

#endif // STANDTESTER_H
