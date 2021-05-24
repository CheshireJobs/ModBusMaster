#ifndef ANALOGOUTSEQUENCEMODEL_H
#define ANALOGOUTSEQUENCEMODEL_H

#include <QAbstractTableModel>
#include <QAbstractItemModel>
#include <QVector>
#include "stand_defs.h"

class AnalogOutSequenceModel : public QAbstractTableModel
{
     Q_OBJECT
     Q_ENUMS(Roles)

    Q_PROPERTY(int delay MEMBER delay)
    Q_PROPERTY(int delayAnalog MEMBER delayAnalog)
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

   explicit AnalogOutSequenceModel();

   int delay = 0;
   int delayAnalog = 0;
   int countCycle = 0;
   int m_rowCount = 0;
   int m_columnCount = 12;

   int rowCount(const QModelIndex & = QModelIndex()) const override;
   int columnCount(const QModelIndex & = QModelIndex()) const override;

   QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
   bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

   QVector<Stand_Analogue_Seq_Item_t> getAnalogOutSeq() { return  m_analogOutSeqArr; }

   void setAnalogOutSeq(QVector<Stand_Analogue_Seq_Item_t> analogOutSeqArr) {
       beginResetModel();
       m_analogOutSeqArr = analogOutSeqArr;
       endResetModel();
   }

public slots:
      void updateRowsCount(int count, int delay);
      void updateDelayAnalog(int delay);
      void clearModel(int count, int delay);

private:

   Stand_Analogue_Seq_Item_t m_tmp;
   QVector<Stand_Analogue_Seq_Item_t> m_analogOutSeqArr;

};

#endif // ANALOGOUTSEQUENCEMODEL_H
