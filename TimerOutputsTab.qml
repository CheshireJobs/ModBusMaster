import QtQuick 2.12
import QtQuick.Controls 2.12
import TimerOutSequenceModel 0.1
import QtQuick.Dialogs 1.2

Item {
    id: timerTab

    function startTest() {
        if(modeModel.get(listViewModeWork.currentIndex).value === 0) {
           return;
        } else if(modeModel.get(listViewModeWork.currentIndex).value === 1) {
        hndl.startTimerTest(modeModel.get(listViewModeWork.currentIndex).value,
                            freqTextField.text,parseFloat(dutyTextField.text)*100,
                            freqTextField2.text,parseFloat(dutyTextField2.text)*100,
                            freqTextField3.text, parseFloat(dutyTextFieldTimer3.text)*100,
                            freqTextFieldTimer4.text, parseFloat(dutyTextFieldTimer4.text)*100)
        } else {
            hndl.startTimerSeqTest(modeModel.get(listViewModeWork.currentIndex).value, timerOutSequenceModel ,
                                   countCycleValue.text , delayValue.text)
        }
    }

    function stopTest() {
        hndl.stopTimerTest()
    }

    function saveSequence(nameFile) {
        timerOutSequenceModel.delay = delayValue.text
        timerOutSequenceModel.countCycle = countCycleValue.text
        hndl.saveTimerSequence(nameFile, timerOutSequenceModel)
    }

    function loadSequense(nameFile) {
        hndl.loadTimerSequence(nameFile, timerOutSequenceModel)
        delayValue.text = timerOutSequenceModel.delay
        countCycleValue.text = timerOutSequenceModel.countCycle
        countRow.text = timerOutSequenceModel.m_rowCount
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        visible: false
        folder: shortcuts.home
        selectMultiple: false

        nameFilters: "*.stnd"
        onAccepted: {
            loadSequense(fileDialog.fileUrl)
        }
        onRejected: {
        }
    }

    FileDialog {
        id: fileSaveDialog
        title: "Сохранение"
        visible: false
        selectExisting: false
        selectMultiple: false
        folder: shortcuts.home

        nameFilters: "*.stnd"
        onAccepted: {
            saveSequence(fileSaveDialog.fileUrl)
        }
        onRejected: {
        }
    }


    Rectangle {
        id: borderTimerTab
        border.color: "gray"
        width: parent.width
        height:  parent.height
        radius: 5

        Rectangle {
            id: labelRect
            anchors.top: parent.top
            width: parent.width
            height: 25
            radius: 5
            color: "lightgray"

            Text {
                id: labelTab
                anchors.left: turnOnButton.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                width: 201
                height: 25
                text: "Таймеры"
                font.pixelSize: 20
                color: "black"
            }

            Rectangle {
                id: turnOnButton
                property bool turnOn: true

                height: 25
                width: 30
                color: "#338cd4"
                anchors.left: parent.left

                Text {
                    id: txt
                    height: parent.height
                    width: parent.width
                    text: turnOnButton.turnOn? " - " : " + "
                    anchors.horizontalCenter: parent.Center
                    color: "white"
                    font.bold: true
                    font.pixelSize: 20
                }


                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        turnOnButton.turnOn = !turnOnButton.turnOn
                        if(!turnOnButton.turnOn) {
                            listViewModeWork.currentIndex = 0
                            timerTab.height = 35
                            modeWork.visible = false
                        } else {
                            timerTab.height = 500
                            modeWork.visible = true
                        }
                    }
                }
            }
        }

         GroupBox {
             id: modeWork
             title: "Режим работы"

             anchors.top: labelRect.bottom
             anchors.topMargin: 10
             width: parent.width
             height: parent.height

             ListView {
                 id: listViewModeWork
                 property var currentIndex

                 anchors.top: parent.top
                 height: 50
                 width: 300
                 interactive: false
                 orientation: ListView.Horizontal

                 model: ListModel {
                     id: modeModel
                     ListElement {
                         value: 0x0000
                         text: "выключено"
                         visible: false
                     }
                     ListElement {
                         value: 0x0001
                         text: "установка значения"
                     }
                     ListElement{
                         value: 0x0002
                         text: "последовательность значений"
                     }
                 }

                 delegate: RadioButton {
                     id:  modeWorkList
                     text: modeModel.get(index).text

                     onClicked: {
                         listViewModeWork.currentIndex = index
//                         if(checked) testStartStop.enabled = true
                         if (checked && index === 0) {
                             timersRow.visible = false
                             seqTimerOutTable.visible = false
                             sequenceButtonsRow.visible =false
                             timerSeqLabels.visible = false
                         } else if (checked && index === 1) {
                             timersRow.visible = true
                             seqTimerOutTable.visible = false
                             sequenceButtonsRow.visible =false
                             timerSeqLabels.visible = false

                         } else {
                             timersRow.visible = false
                             sequenceButtonsRow.visible = true
                            seqTimerOutTable.visible = true
                             timerSeqLabels.visible = true
                        }
                     }
                 }
             }

             Row {
                 id: timersRow
                 anchors.top: listViewModeWork.bottom
                 width: parent.width
                 height: 230
                 spacing: 10
                 visible: false

                 GroupBox {
                     id: time
                     width: 200
                     height: 140
                     title: qsTr("Timer 1")

                     Label {
                         id: freqTextFieldLabel
                         anchors.top: parent.top
//                         width: freqTextField.width
                         height: 20
                         text: "Частота Гц"
                     }

                     TextField {
                         id: freqTextField
                         anchors.top: freqTextFieldLabel.bottom
                         height: 30
                         width: 70
                         placeholderText: qsTr("частота Гц")

                         background: Rectangle {
                             id: control
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: control.enabled ? "#21be2b" : "transparent"
                         }
                     }

                     Label {
                         id: dutyTextFieldLabel
                         anchors.top: freqTextField.bottom
//                         width: dutyTextField.width
                         height: 20
                         text: "Коэфф. заполнения"
                     }

                     TextField {
                         id: dutyTextField
                         anchors.top: dutyTextFieldLabel.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("Коэфф")

                         background: Rectangle {
                             id: control2
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: control2.enabled ? "#21be2b" : "transparent"
                         }
                     }
                 }

                 GroupBox {
                     id: timer2
                     width: 200
                     height: 140
                     title: qsTr("Timer 2")

                     Label {
                         id: freqTextField2Label
                         anchors.top: parent.top
                         width: dutyTextField.width
                         height: 20
                         text: "частота Гц"
                     }

                     TextField {
                         id: freqTextField2
                         anchors.top: freqTextField2Label.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("частота Гц")

                         background: Rectangle {
                             id: controlTimer2
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: controlTimer2.enabled ? "#21be2b" : "transparent"
                         }
                     }

                     Label {
                         id: dutyTextField2Label
                         anchors.top: freqTextField2.bottom
                         width: dutyTextField.width
                         height: 20
                         text: "Коэфф. заполнения"
                     }

                     TextField {
                         id: dutyTextField2
                         anchors.top: dutyTextField2Label.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("Коэфф. заполнения")

                         background: Rectangle {
                             id: control2Timer2
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: control2Timer2.enabled ? "#21be2b" : "transparent"
                         }
                     }

                 }

                 GroupBox {
                     id: timer3
                     width: 200
                     height: 140
                     title: qsTr("Timer 3")

                     Label {
                         id: freqTextField3Label
                         anchors.top: parent.top
                         width: dutyTextField.width
                         height: 20
                         text: "частота Гц"
                     }

                     TextField {
                         id: freqTextField3
                         anchors.top: freqTextField3Label.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("частота Гц")

                         background: Rectangle {
                             id: controlTimer3
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: controlTimer3.enabled ? "#21be2b" : "transparent"
                         }
                     }

                     Label {
                         id: dutyTextFieldTimer3Label
                         anchors.top: freqTextField3.bottom
                         width: dutyTextField.width
                         height: 20
                         text: "Коэфф. заполнения"
                     }

                     TextField {
                         id: dutyTextFieldTimer3
                         anchors.top: dutyTextFieldTimer3Label.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("Коэфф. заполнения %")

                         background: Rectangle {
                             id: control2Timer3
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: control2Timer3.enabled ? "#21be2b" : "transparent"
                         }
                     }

                 }

                 GroupBox {
                     id: timer4
                     width: 200
                     height: 140
                     title: qsTr("Timer 4")

                     Label {
                         id: freqTextFieldTimer4Label
                         anchors.top: parent.top
                         width: dutyTextField.width
                         height: 20
                         text: "частота Гц"
                     }

                     TextField {
                         id: freqTextFieldTimer4
                         anchors.top: freqTextFieldTimer4Label.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("частота Гц")

                         background: Rectangle {
                             id: controlTimer4
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: controlTimer4.enabled ? "#21be2b" : "transparent"
                         }
                     }

                     Label {
                         id: dutyTextFieldTimer4Label
                         anchors.top: freqTextFieldTimer4.bottom
                         width: dutyTextField.width
                         height: 20
                         text: "Коэфф. заполнения"
                     }

                     TextField {
                         id: dutyTextFieldTimer4
                         anchors.top: dutyTextFieldTimer4Label.bottom

                         height: 30
                         width: 70
                         placeholderText: qsTr("Коэфф. заполнения %")

                         background: Rectangle {
                             id: control2Timer4
                             implicitWidth: 200
                             implicitHeight: 40
                             border.color: controlTimer4.enabled ? "#21be2b" : "transparent"
                         }
                     }

                 }

             }

             TableView {
                 id: seqTimerOutTable
                 anchors.top: timerSeqLabels.bottom
                 anchors.bottom: parent.bottom
                 visible: false
                 height: parent.height
                 width: parent.width

                 ScrollBar.horizontal: ScrollBar {}
                 ScrollBar.vertical: ScrollBar {}

                 model: TimerOutSequenceModel {
                     id: timerOutSequenceModel
                 }

                 delegate: TextField {
                     id: cellField
                     width: 80
                     height: 30

                     text: model.data

//                     placeholderText: qsTr("enter txt") /* model.index % 2 ? qsTr("duty") :*/

                     background: Rectangle {
                         id: cellFieldBg
                         implicitWidth: 80
                         implicitHeight: 30
                         border.color: cellFieldBg.enabled ? "#21be2b" : "transparent"
                     }
                     onActiveFocusChanged: {
                         model.data = text
                     }
                }
             }

             Row {
                 id: sequenceButtonsRow

                 anchors.top: listViewModeWork.bottom
                 anchors.left: parent.left
                 anchors.leftMargin: 10

                 visible: false

                 width: 500
                 height: 50
                 spacing: 10

                 TextField {
                     id: delayValue
                     height: 30
                     width: 80
                     placeholderText: qsTr("Enter delay")
  //                   visible: false
                     background: Rectangle {
                         id: control4
                         implicitWidth: 200
                         implicitHeight: 40
                         border.color: control4.enabled ? "#21be2b" : "transparent"
                     }
                     Label {
                         id: delayLabel
                         height: 25
                         width: 80
                         anchors.top: delayValue.top
                         Text {
                             anchors.bottom: parent.top
                             anchors.centerIn: parent.Center
                             text: "Задержка [мс]"
                         }
                     }
                 }
                 TextField {
                     id: countCycleValue
                     height: 30
                     width: 80
                     placeholderText: qsTr("Count repeat")

                     background: Rectangle {
                         id: control5
                         implicitWidth: 200
                         implicitHeight: 40
                         border.color: control5.enabled ? "#21be2b" : "transparent"
                     }
                     Label {
                         id: countCycleLabel
                         height: 25
                         width: 80
                         anchors.top: countCycleValue.top
                         Text {
                             anchors.bottom: parent.top
                             anchors.centerIn: parent.Center
                             text: "Кол-во повторов"
                         }
                     }
                 }
                 TextField {
                     id: countRow
                     height: 30
                     width: 80
                     placeholderText: qsTr("Count rows")

                     background: Rectangle {
                         implicitWidth: 200
                         implicitHeight: 40
                         border.color: enabled ? "#21be2b" : "transparent"
                     }
                     Label {
                         id: countRowLabel
                         height: 25
                         width: 80
                         anchors.top: countRow.top
                         Text {
                             id: rowCount
                             anchors.bottom: parent.top
                             anchors.centerIn: parent.Center
                             text: "Кол-во строк"
                         }
                     }

                     onAccepted: {
                         timerOutSequenceModel.updateRowsCount(parseInt(countRow.text))
                     }
                 }

                 Button {
                     id: saveSequenceButton
                     text: "Сохранить"
                     height: 30
                     width: 100
                     enabled: (!delayValue.text || !countCycleValue.text)? false : true
                     onClicked: {
                         fileSaveDialog.visible = true
                     }
                 }
                 Button {
                     id: loadSequenceButton
                     text: "Загрузить"
                     height: 30
                     width: 100
                     enabled: true
                     onClicked: {
                         fileDialog.visible = true
                     }
                 }
                 Button {
                     id: hideSequenceButton
                     text: hide? "Скрыть таблицу" : "Показать таблицу"
                     property bool hide: true
                     height: 30
                     width: 100
                     enabled: true

                     onClicked: {
                         hide = !hide
                          seqTimerOutTable.visible = hide
                     }
                 }

             }

             Column {
                 id: timerSeqLabels
                 anchors.top: sequenceButtonsRow.bottom
                 anchors.left: parent.left
                 visible: false
                 width: 500
                 height: 35

                 Row {
                     id: nameTimers
                     height: 15

                     Label {
                         id: timer1Label
                         anchors.top: parent.top
                         anchors.left: parent.left
                         anchors.leftMargin: 60

                         text: "Таймер 1"
                     }
                     Label {
                         id: timer2Label
                         anchors.top: parent.top
                         anchors.left: timer1Label.right
                         anchors.leftMargin: 110
                         text: "Таймер 2"
                     }
                     Label {
                         id: timer3Label
                         anchors.top: parent.top
                         anchors.left: timer2Label.right
                         anchors.leftMargin: 120
                         text: "Таймер 3"
                     }
                     Label {
                         id: timer4Label
                         anchors.top: parent.top
                         anchors.left: timer3Label.right
                         anchors.leftMargin: 110
                         text: "Таймер 4"
                     }
                 }

                 Row {
                     anchors.top: nameTimers.bottom
                     width: parent.width
                     height: 15
                     anchors.leftMargin: 10
//                     spacing: 10

                     Label {
                         width: 80
                         Text {
                             id: name
                             width: parent.width
                             text: "частота, Гц"
                             anchors.centerIn: parent.Center
                         }
                     }
                     Label {
                         width: 80
                         text: "коэфф"
                     }
                     Label {
                         width: 80
                         text: "частота, Гц"
                     }
                     Label {
                         width: 80
                         text: "коэфф"
                     }
                     Label {
                         width: 80
                         text: "частота, Гц"
                     }
                     Label {
                         width: 80
                         text: "коэфф"
                     }
                     Label {
                         width: 80
                         text: "частота, Гц"
                     }
                     Label {
                         width: 80
                         text: "коэфф"
                     }
                 }
             }

         }

         Button {
             id: startTestTimer
             visible: false

             anchors.bottom: parent.bottom
             anchors.right: parent.right
             width: 160
             height: 60

             property bool start: false

             text: start? "Завершить тестирование" : "Начать тестирование"

             onClicked: {
                 if(!start) {
                     startTest()
                 } else {
                     stopTest()
                 }
                 start = !start
             }
         }
    }
}
