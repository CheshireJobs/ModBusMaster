#ifndef DISCRETEOUTSEQUENCEMODEL_H
#define DISCRETEOUTSEQUENCEMODEL_H
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QAbstractTableModel>
#include <QVector>
#include "stand_defs.h"

class DiscreteOutSequenceModel : public QAbstractTableModel
{
    Q_OBJECT
    Q_ENUMS(Roles)
    Q_PROPERTY(int delay MEMBER delay)
    Q_PROPERTY(int delayDiscrete MEMBER delayDiscrete)
    Q_PROPERTY(int countCycle MEMBER countCycle)
    Q_PROPERTY(int m_rowCount MEMBER m_rowCount)

public:
    enum Roles {
        CellRole,
        HeaderRole
    };

    QHash<int, QByteArray> roleNames() const override {
        return {
            { CellRole, "checked" },
            { HeaderRole, "mIndex" }
        };
    }

    explicit DiscreteOutSequenceModel();

    int delay = 0;
    int delayDiscrete = 0;
    int countCycle = 0;
    int m_rowCount = 0;
    int m_columnCount = 16;

    int rowCount(const QModelIndex & = QModelIndex()) const override;
    int columnCount(const QModelIndex & = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    QVector<Stand_Discrete_Seq_Item_t> getDicreteOutSeq() { return  m_discreteOutSeqArr; }

    void setDiscreteOutSeq(QVector<Stand_Discrete_Seq_Item_t> dicreteOutSeqArr) {
        beginResetModel();
        m_discreteOutSeqArr = dicreteOutSeqArr;
        endResetModel();
    }

public slots:
    void updateRowsCount(int count, int delay);
    void updateDelayDiscrete(int delay);
    void clearModel(int count, int delay);

private:
    Stand_Discrete_Seq_Item_t m_tmp;
    QVector<Stand_Discrete_Seq_Item_t> m_discreteOutSeqArr;

};

#endif // DISCRETEOUTSEQUENCEMODEL_H
