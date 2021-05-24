#ifndef LOG_H
#define LOG_H
#include <QObject>
#include <QVariant>

class Log : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList logs MEMBER m_Logs NOTIFY onLogListChange)

public:
    Log();
    ~Log();
    void addRWLog(QString typeLog, QString typeRegister,
           int startAdress, int count, int slaveAdress, QVector<quint16> data);

    void addErrorLog(QString typeLog, QString error);
    QVariantList getLogs();

signals:
    void onLogListChange();

private:
    QVariantList m_Logs;

};

#endif // LOG_H
