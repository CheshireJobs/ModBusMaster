#include "AnalogOutSequenceModel.h"
#include <QDebug>

AnalogOutSequenceModel::AnalogOutSequenceModel() {
    m_tmp.Delay = 1000;
    for (int i = 0; i < m_rowCount; ++i) {
        for(int j = 0; j < m_columnCount; j++) {
            m_tmp.OutputsState[j] = 0.0;
        }
        m_analogOutSeqArr.append(m_tmp);
    }
}

int AnalogOutSequenceModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_rowCount;
}

int AnalogOutSequenceModel::columnCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_columnCount;
}

QVariant AnalogOutSequenceModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return QVariant();

    switch (role) {
        case CellRole:
            return QVariant(m_analogOutSeqArr[index.row()].OutputsState[index.column()]);
        default:
            break;
    }
}

bool AnalogOutSequenceModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (role != CellRole || data(index, role) == value)
        return false;
    bool ok;

    m_analogOutSeqArr[index.row()].OutputsState[index.column()] = value.toDouble(&ok);

    emit dataChanged(index, index, {role});

    return true;
}

void AnalogOutSequenceModel::updateRowsCount(int count, int delay) {
    beginResetModel();
    int oldCount = m_analogOutSeqArr.count();
    m_tmp.Delay = delay;
    m_rowCount = count;
    if(oldCount < m_rowCount) {
        for (int i = oldCount; i < m_rowCount; ++i) {
            for(int j = 0; j < m_columnCount; j++) {
                m_tmp.OutputsState[j] = 0.0;
            }
            m_analogOutSeqArr.append(m_tmp);
        }
    } else {
        for(int i = count; i < oldCount; ++i) {
            m_analogOutSeqArr.removeLast();
        }
    }
    endResetModel();
}

void AnalogOutSequenceModel::updateDelayAnalog(int delay) {
    beginResetModel();
    for (int i = 0; i < m_rowCount; ++i) {
        m_analogOutSeqArr[i].Delay = delay;
    }
    endResetModel();
}

void AnalogOutSequenceModel::clearModel(int count, int delay) {
    beginResetModel();
    m_analogOutSeqArr.clear();
    m_rowCount = count;
    m_tmp.Delay = delay;
    for (int i = 0; i < m_rowCount; ++i) {
        for(int j = 0; j < m_columnCount; j++) {
            m_tmp.OutputsState[j] = 0.0;
        }
        m_analogOutSeqArr.append(m_tmp);
    }
    endResetModel();
}
