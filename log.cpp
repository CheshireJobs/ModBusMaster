#include "log.h"
#include <QDateTime>
#include <QDebug>

Log::Log() {

}

Log::~Log() {

}

void Log::addRWLog(QString typeLog, QString typeRegister,
                        int startAdress, int count, int slaveAdress, QVector<quint16> data) {
    QString timeLog = QDateTime::currentDateTimeUtc().time().toString(); // получено отправлено
    QString tempData;
    QVariantMap tmp;
    tmp.clear();
    for( int i = 0; i< data.count(); ++i) {
        tempData.append(QString::number(data[i]) + " ");
    }

    tmp.insert("value", tr (" %1"
                    " %2"
                    " startAdress: %3,"
                    " count: %4,"
                    " slaveAdress: %5,"
                    " data: %6,"
                    " %7").
                    arg(timeLog).
                    arg(typeRegister).
                    arg(startAdress).
                    arg(count).
                    arg(slaveAdress).
                    arg(tempData).
                    arg(typeLog ));
    m_Logs.append(tmp);
    onLogListChange();
}

void Log::addErrorLog(QString typeLog, QString error) {
    QString timeLog = QDateTime::currentDateTimeUtc().time().toString();
    QVariantMap tmp;
    tmp.clear();
    tmp.insert("value", timeLog + typeLog + error );
    m_Logs.append(tmp);
    onLogListChange();
}

QVariantList Log::getLogs() {
    return m_Logs;
}
