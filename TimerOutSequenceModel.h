#ifndef TIMEROUTSEQUENCEMODEL_H
#define TIMEROUTSEQUENCEMODEL_H
#include <QAbstractTableModel>
#include "stand_defs.h"

class TimerOutSequenceModel: public QAbstractTableModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(int delay MEMBER delay)
    Q_PROPERTY(int delayTimer MEMBER delayTimer)
    Q_PROPERTY(int countCycle MEMBER countCycle)
    Q_PROPERTY(int m_rowCount MEMBER m_rowCount)

public:
    enum Roles {
        CellRole,
        HeaderRole
    };
    QHash<int, QByteArray> roleNames() const override {
        return {
            { CellRole, "data" },
            { HeaderRole, "mIndex" }
        };

    }

    int m_columnCount = 8;
    int m_rowCount = 0;
    int delayTimer = 0;
    int delay = 0;
    int countCycle = 0;

    explicit TimerOutSequenceModel();
    int rowCount(const QModelIndex & = QModelIndex()) const override;
    int columnCount(const QModelIndex & = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    QVector<Stand_Timer_Seq_Item_t> getTimerOutSeq() { return  m_timerOutSeqArr; }

    void setTimerOutSeq(QVector<Stand_Timer_Seq_Item_t> timerOutSeqArr) {
        beginResetModel();
        m_timerOutSeqArr = timerOutSeqArr;
        endResetModel();
    }
public slots:
    void updateRowsCount(int count, int delay);
    void updateDelayTimer(int delay);
    void clearModel(int count, int delay);

private:
    Stand_Timer_Seq_Item_t m_tmp;
    QVector<Stand_Timer_Seq_Item_t> m_timerOutSeqArr;

};

#endif // TIMEROUTSEQUENCEMODEL_H
