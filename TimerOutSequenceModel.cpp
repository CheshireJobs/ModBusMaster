#include "TimerOutSequenceModel.h"
#include <QDebug>

TimerOutSequenceModel::TimerOutSequenceModel() {
    m_tmp.Delay = 1000;
    for(int i = 0; i < m_rowCount; ++i) {
        for(int j = 0; j < m_columnCount / 2; ++j) {
            m_tmp.OutputsState[j].Frequency = 0;
            m_tmp.OutputsState[j].Duty = 0;
        }
        m_timerOutSeqArr.append(m_tmp);
    }
}

int TimerOutSequenceModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_rowCount;
}

int TimerOutSequenceModel::columnCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_columnCount;
}


QVariant TimerOutSequenceModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() )
        return QVariant();

    switch (role) {
        case CellRole:
            return QVariant(index.column() % 2? m_timerOutSeqArr[index.row()].OutputsState[index.column()/2].Duty :
                                                        m_timerOutSeqArr[index.row()].OutputsState[index.column()/2].Frequency);
        default:
            break;
    }
}

bool TimerOutSequenceModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (role != CellRole || data(index, role) == value)
        return false;
    bool ok;

   if(index.column() % 2) {
       m_timerOutSeqArr[index.row()].OutputsState[index.column()/2].Duty = value.toFloat(&ok);

    } else {
       m_timerOutSeqArr[index.row()].OutputsState[index.column()/2].Frequency = value.toFloat(&ok);
    }

    emit dataChanged(index, index, {role});

   return true;
}

void TimerOutSequenceModel::updateRowsCount(int count, int delay) {
    beginResetModel();
   int oldCount = m_timerOutSeqArr.count();
    m_tmp.Delay = delay;
    m_rowCount = count;
    if(oldCount < m_rowCount) {
        for(int i = oldCount; i < m_rowCount; ++i) {
            for(int j = 0; j < m_columnCount / 2; ++j) {
                m_tmp.OutputsState[j].Frequency = 0;
                m_tmp.OutputsState[j].Duty = 0;
            }
            m_timerOutSeqArr.append(m_tmp);
        }
    } else {
        for(int i = count; i < oldCount; ++i) {
            m_timerOutSeqArr.removeLast();
        }
    }

    endResetModel();
}

void TimerOutSequenceModel::updateDelayTimer(int delay) {
    beginResetModel();
    for (int i = 0; i < m_rowCount; ++i) {
        m_timerOutSeqArr[i].Delay = delay;
    }
    endResetModel();
}

void TimerOutSequenceModel::clearModel(int count, int delay) {
    beginResetModel();
    m_timerOutSeqArr.clear();
    m_tmp.Delay = delay;
    m_rowCount = count;
    for(int i = 0; i < m_rowCount; ++i) {
        for(int j = 0; j < m_columnCount / 2; ++j) {
            m_tmp.OutputsState[j].Frequency = 0;
            m_tmp.OutputsState[j].Duty = 0;
        }
        m_timerOutSeqArr.append(m_tmp);
    }
    endResetModel();
}
