#ifndef DATASOURCE_H
#define DATASOURCE_H

#include <QtCore/QObject>
#include <QtCharts/QAbstractSeries>

QT_CHARTS_USE_NAMESPACE

class DataSource : public QObject
{
    Q_OBJECT
public:
    DataSource();

public slots:
    void update(QAbstractSeries *seriesX, QAbstractSeries *seriesY, QAbstractSeries *seriesZ, int x, int y, int z);

private:
    double m_index = 0;
};

#endif // DATASOURCE_H
