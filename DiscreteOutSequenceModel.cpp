#include "DiscreteOutSequenceModel.h"

DiscreteOutSequenceModel::DiscreteOutSequenceModel() {
     m_tmp.Delay = 1000;
     for (int i = 0; i < m_rowCount; ++i) {
         m_tmp.OutputsState = 0;
         m_discreteOutSeqArr.append(m_tmp);
     }
}

int DiscreteOutSequenceModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_rowCount;
}

int DiscreteOutSequenceModel::columnCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_columnCount;
}

QVariant DiscreteOutSequenceModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() /*|| role != CellRole*/)
        return QVariant();
    QString header = ((index.column() < 16) ? "+" : "-") + QString("%1").arg(index.column() % 16 + 1);

    switch (role) {
    case CellRole: {
        if(Check_Bit(m_discreteOutSeqArr[index.row()].OutputsState, index.column()) == 0 &&
                Check_Bit(m_discreteOutSeqArr[index.row()].OutputsState, (index.column() + 16)) == 0)
            return 0;
        if(Check_Bit(m_discreteOutSeqArr[index.row()].OutputsState, index.column()) == 1 &&
                Check_Bit(m_discreteOutSeqArr[index.row()].OutputsState, (index.column() + 16)) == 0)
            return 1;
        if(Check_Bit(m_discreteOutSeqArr[index.row()].OutputsState, index.column()) == 0 &&
                Check_Bit(m_discreteOutSeqArr[index.row()].OutputsState, (index.column() + 16)) == 1)
            return 2;
    }
//            return QVariant(Check_Bit(m_dicreteOutSeqArr[index.row()].OutputsState, index.column())? 1 : 0);
        case HeaderRole:
            return QVariant(header);
        default:
            break;
    }
}

bool DiscreteOutSequenceModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (role != CellRole || data(index, role) == value)
        return false;
    if (value == 0) {
        m_discreteOutSeqArr[index.row()].OutputsState = UnSet_Bit(m_discreteOutSeqArr[index.row()].OutputsState, index.column());
        m_discreteOutSeqArr[index.row()].OutputsState = UnSet_Bit(m_discreteOutSeqArr[index.row()].OutputsState, (index.column() + 16));
    } else if (value == 1) {
        m_discreteOutSeqArr[index.row()].OutputsState = Set_Bit(m_discreteOutSeqArr[index.row()].OutputsState, index.column());
        m_discreteOutSeqArr[index.row()].OutputsState = UnSet_Bit(m_discreteOutSeqArr[index.row()].OutputsState, (index.column() + 16));
    } else if (value == 2) {
        m_discreteOutSeqArr[index.row()].OutputsState = Set_Bit(m_discreteOutSeqArr[index.row()].OutputsState, (index.column() + 16));
        m_discreteOutSeqArr[index.row()].OutputsState = UnSet_Bit(m_discreteOutSeqArr[index.row()].OutputsState, index.column());
    }
//    m_dicreteOutSeqArr[index.row()].OutputsState = Check_Bit(m_dicreteOutSeqArr[index.row()].OutputsState, index.column()) ?
//                                                UnSet_Bit(m_dicreteOutSeqArr[index.row()].OutputsState, index.column()) :
//                                                Set_Bit(m_dicreteOutSeqArr[index.row()].OutputsState, index.column());
//    if (Check_Bit(m_dicreteOutSeqArr[index.row()].OutputsState, index.column())
//            && Check_Bit(m_dicreteOutSeqArr[index.row()].OutputsState,
//                         (index.column() >= 16 ? (index.column() - 16) : (index.column() + 16))) ) {

//        m_dicreteOutSeqArr[index.row()].OutputsState =
//                    UnSet_Bit(m_dicreteOutSeqArr[index.row()].OutputsState, index.column());
//    }
    emit dataChanged(index, index, {role});

    return true;
}

void DiscreteOutSequenceModel::updateRowsCount(int count, int delay) {
    beginResetModel();
    int oldCount = m_discreteOutSeqArr.count();
    m_tmp.Delay = delay;
    m_rowCount = count;
    if(oldCount < m_rowCount) {
        for (int i = oldCount; i < m_rowCount; ++i) {
            m_tmp.OutputsState = 0;
            m_discreteOutSeqArr.append(m_tmp);
        }
    } else {
        for(int i = count; i < oldCount; ++i) {
            m_discreteOutSeqArr.removeLast();
        }
    }
    endResetModel();
}

void DiscreteOutSequenceModel::updateDelayDiscrete(int delay) {
    beginResetModel();
    for (int i = 0; i < m_rowCount; ++i) {
        m_discreteOutSeqArr[i].Delay = delay;
    }
    endResetModel();
}

void DiscreteOutSequenceModel::clearModel(int count, int delay) {
    beginResetModel();
    m_discreteOutSeqArr.clear();
    m_rowCount = count;
    m_tmp.Delay = delay;
    for (int i = 0; i < m_rowCount; ++i) {
        m_tmp.OutputsState = 0;
        m_discreteOutSeqArr.append(m_tmp);
    }
    endResetModel();
}
