#include "datasource.h"
#include <QtCharts/QXYSeries>
#include <QtCharts/QAreaSeries>

QT_CHARTS_USE_NAMESPACE

Q_DECLARE_METATYPE(QAbstractSeries *)
Q_DECLARE_METATYPE(QAbstractAxis *)

DataSource::DataSource() {
    qRegisterMetaType<QAbstractSeries*>();
    qRegisterMetaType<QAbstractAxis*>();
}

void DataSource::update(QAbstractSeries *seriesX,
                        QAbstractSeries *seriesY, QAbstractSeries *seriesZ, int x, int y, int z) {
    if (seriesX && seriesY && seriesZ) {
       QXYSeries *xySeriesX = static_cast<QXYSeries *>(seriesX);
       QXYSeries *xySeriesY = static_cast<QXYSeries *>(seriesY);
       QXYSeries *xySeriesZ = static_cast<QXYSeries *>(seriesZ);

       m_index += 5;

       xySeriesX->append(m_index,x);
       xySeriesY->append(m_index,y);
       xySeriesZ->append(m_index,z);
    }
}
