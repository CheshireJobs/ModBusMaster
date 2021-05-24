import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import AnalogOutSequenceModel 0.1

Item {
    id: analogOutputsTab

    width: parent.width
    height: parent.height

    Component.onCompleted: {
//        hndl.setAnalogSettings()
//        hndl.readAnalogCount()

        analogOutputsModel.clear()
        for ( var i = 0; i < 12 ; ++i) {
            analogOutputsModel.append({"value" : 0});
        }
    }

//    Connections {
//        target: hndl
//        onAnalogListChanged: {
//            analogOutputsModel.clear()
//            for ( var i = 0; i < hndl.analogList.length; ++i) {
//                analogOutputsModel.append({"value" : 0});
//            }

//        }
//    }

    function saveSequence(nameFile) {
        analogOutSequenceModel.delay = delayValue.text
        analogOutSequenceModel.countCycle = countCycleValue.text
        hndl.saveAnalogSequence(nameFile, analogOutSequenceModel)
    }

    function loadSequense(nameFile) {
        hndl.loadAnalogSequence(nameFile, analogOutSequenceModel)
//        countRow.text = analogOutSequenceModel.m_rowCount
        delayValue.text = analogOutSequenceModel.delay
        countCycleValue.text = analogOutSequenceModel.countCycle
    }

    function startTesting() {
        var i = 0;
        if(modeModel.get(listViewModeWork.currentIndex).value === 0) {
            return;
        } else if( modeModel.get(listViewModeWork.currentIndex).value === 1) {
            for( i = 0; i < 12; ++i ) {
                hndl.editedAnalogOutputs[i] = analogOutputsModel.get(i).value
            }
                hndl.startAnalogTesting(modeModel.get(listViewModeWork.currentIndex).value,
                                        analogOutSequenceModel, delayValue.text, countCycleValue.text)
            } else {
            hndl.startAnalogTesting(modeModel.get(listViewModeWork.currentIndex).value,
                                    analogOutSequenceModel, delayValue.text, countCycleValue.text)
        }
    }

     function stopTesting() {
         if(modeModel.get(listViewModeWork.currentIndex).value === 0) {
             return;
         }
//         analogOutputsModel.clear()
//         for ( var i = 0; i < hndl.analogList.length; ++i) {
//             analogOutputsModel.append({"value" : 0});
//         }
         hndl.stopAnalogTesting()

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

     MessageDialog {
         id: messageDialog
         title: "Error"
         visible: false
         text: "Введите значение в пределах [-10.8; +10.8] !"

         onAccepted: {
         }
     }

    Rectangle {
        id: borderAnalogTab

        width: parent.width
        height: parent.height
        radius: 5

        border.color: "lightgray"

        Rectangle {
            id: analogLabel

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
                text: "Аналоговые выходы"
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
                            analogOutputsTab.height = 35
                            modeWork.visible = false
                            currentState.visible = false
                        } else {
                            analogOutputsTab.height = 500
                            modeWork.visible = true
                            currentState.visible = true
                        }
                    }
                }
            }

        }

        GroupBox {
            id: currentState

            width: parent.width
            height: 130
            anchors.top: analogLabel.bottom
            title: "Текущее состояние"

            ListView {
                id: analogList
                width: 600
                anchors.top: parent.top
                height: 73
                orientation: ListView.Horizontal
                model: hndl.analogList.isEmpty? 0 : hndl.analogList

                interactive: false

//                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 10

                delegate: CheckDelegate {
                    id: checkElementAnalog
                    width: 50
                    height: 73
                    checked: true//!modelData.value? false : true   // сравнение с нулем дабл - переменная для сhecked
                    spacing: 0
                    property var curIndex: index

                    indicator: Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 15
                            color: "transparent"
                            border.color: checkElementAnalog.checked ? "gray" : "transparent"
                            border.width: 2

                            Rectangle {
                                width: 20
                                height: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 10
                                color: checkElementAnalog.checked ? "#21be2b" : "transparent"
                                opacity: 0.5

                                Rectangle {
                                    width: 20
                                    height: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "transparent"
                                    border.color: checkElementAnalog.checked? "#21be2b" : "gray"
                                    border.width: 3
                                    radius: 10

                                }
                            }
                        }
                    Text {
                        text: index + 1
                        anchors.fill: parent
                        elide: Text.ElideMiddle
                        font.pixelSize: 10
                        font.bold: checkElementAnalog.checked ? true : false
                        color: checkElementAnalog.checked ? "#21be2b" : "gray"
                    }

                    Tumbler {
                        id: control
                        width: parent.width
                        height: 40
                        anchors.topMargin: 2
                        anchors.bottom: parent.bottom
                        visible: checkElementAnalog.checked ? true : false
                        visibleItemCount: 3
                        wrap: false

                        model: 1

                        background: Item {
                            Rectangle {
                                opacity: control.enabled ? 0.2 : 0.1
                                border.color: "#000000"
                                width: parent.width
                                height: 1
                                anchors.top: parent.top
                            }
                            Rectangle {
                                opacity: control.enabled ? 0.2 : 0.1
                                border.color: "#000000"
                                width: parent.width
                                height: 1
                                anchors.bottom: parent.bottom
                            }
                        }
                        delegate: Text {
                            text: hndl.analogList[checkElementAnalog.curIndex].value + " B" //tumblerModel.get(index).voltage +
                            font.pixelSize: 15
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount /2)
                        }
                        Rectangle {
                            anchors.horizontalCenter: control.horizontalCenter
                            y: control.height * 0.2
                            width: 40
                            height: 1
                            color: "#21be2b"
                        }
                        Rectangle {
                            anchors.horizontalCenter: control.horizontalCenter
                            y: control.height * 0.8
                            width: 40
                            height: 1
                            color: "#21be2b"
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        width: 30
                        height: 30
                        radius: 15
                        anchors.horizontalCenter: parent.horizontalCenter
//                        anchors.verticalCenter: parent.verticalCenter
                        visible: checkElementAnalog.down || checkElementAnalog.highlighted
                        color: checkElementAnalog.down ? "#bdbebf" : "#eeeeee"
                    }
                }
            }

        }

        GroupBox {
            id: modeWork
            title: "Режим работы"

            anchors.top: currentState.bottom
            width: parent.width
            height: 250//parent.height - currentState.height - analogLabel.height - testStartStop.height

            ListView {
                id: listViewModeWork

                property var currentIndex

                anchors.top: parent.top
                width: 300
                height: 50

                interactive: false
                orientation: ListView.Horizontal

                model: ListModel {
                    id: modeModel
                    ListElement {
                        value: 0
                        text: "выключено"
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
                        if (checked && index === 0) {
                            editableAnalogList.visible = false
                            sequenceButtonsRow.visible = false
                            analogSeqTable.visible = false
                        } else if (checked && index === 1) {
                            editableAnalogList.visible = true

                            sequenceButtonsRow.visible = false
                            analogSeqTable.visible = false
                        } else  {
                            editableAnalogList.visible = false

                            sequenceButtonsRow.visible = true
                            analogSeqTable.visible = true
                        }
                    }
                }
            }

            ListModel {
                id: analogOutputsModel
            }

            ListView {
                id: editableAnalogList

                anchors.top: listViewModeWork.bottom
                anchors.leftMargin: 10
                anchors.topMargin: 10
                width: 600
                height: 73

                orientation: ListView.Horizontal
                interactive: false
                visible: false

                model: analogOutputsModel

                delegate: CheckDelegate {
                    id: editableCheckElementAnalog
                    width: 50
                    height: 73
                    checked: true //modelData.value === 1? true : false // сравнение с нулем дабл - переменная для сhecked
                    spacing: 0
                    property var curIndex: index

                    indicator: Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 15
                            color: "transparent"
                            border.color: editableCheckElementAnalog.checked ? "gray" : "transparent"
                            border.width: 2

                            Rectangle {
                                width: 20
                                height: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 10
                                color: editableCheckElementAnalog.checked ? "#21be2b" : "transparent"
                                opacity: 0.5

                                Rectangle {
                                    width: 20
                                    height: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "transparent"
                                    border.color: editableCheckElementAnalog.checked? "#21be2b" : "gray"
                                    border.width: 3
                                    radius: 10
                                }
                            }
                    }
                    Text {
                        text: index + 1
                        anchors.fill: parent
                        elide: Text.ElideMiddle
                        font.pixelSize: 10
                        font.bold: editableCheckElementAnalog.checked ? true : false
                        color: editableCheckElementAnalog.checked ? "#21be2b" : "gray"
                    }

                    Tumbler {
                        id: editableControl
                        width: parent.width
                        height: 40
                        anchors.topMargin: 2
                        anchors.bottom: parent.bottom
                        visible: editableCheckElementAnalog.checked ? true : false
                        visibleItemCount: 1
                        wrap: false
                        currentIndex: 10


                        model: ListModel {
                            id: tumblerModel
                            ListElement {
                                voltage: "-10"
                            }
                            ListElement {
                                voltage: "-9"
                            }
                            ListElement {
                                voltage: "-8"
                            }
                            ListElement {
                                voltage: "-7"
                            }
                            ListElement {
                                voltage: "-6"
                            }
                            ListElement {
                                voltage: "-5"
                            }
                            ListElement {
                                voltage: "-4"
                            }
                            ListElement {
                                voltage: "-3"
                            }
                            ListElement {
                                voltage: "-2"
                            }
                            ListElement {
                                voltage: "-1"
                            }
                            ListElement {
                                voltage: "0"
                            }
                            ListElement {
                                voltage: "1"
                            }
                            ListElement {
                                voltage: "2"
                            }
                            ListElement {
                                voltage: "3"
                            }
                            ListElement {
                                voltage: "4"
                            }
                            ListElement {
                                voltage: "5"
                            }
                            ListElement {
                                voltage: "6"
                            }
                            ListElement {
                                voltage: "7"
                            }
                            ListElement {
                                voltage: "8"
                            }
                            ListElement {
                                voltage: "9"
                            }
                            ListElement {
                                voltage: "10"
                            }
                        }

                        background: Item {
                            Rectangle {
                                opacity: editableControl.enabled ? 0.2 : 0.1
                                border.color: "#000000"
                                width: parent.width
                                height: 1
                                anchors.top: parent.top
                            }
                            Rectangle {
                                opacity: editableControl.enabled ? 0.2 : 0.1
                                border.color: "#000000"
                                width: parent.width
                                height: 1
                                anchors.bottom: parent.bottom
                            }
                        }
                        delegate: Text {
                            text: tumblerModel.get(index).voltage + " B"
                            font.pixelSize: 15
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (editableControl.visibleItemCount /2)
                        }
                        Rectangle {
                            anchors.horizontalCenter: editableControl.horizontalCenter
                            y: editableControl.height * 0.2
                            width: 40
                            height: 1
                            color: "#21be2b"
                        }
                        Rectangle {
                            anchors.horizontalCenter: editableControl.horizontalCenter
                            y: editableControl.height * 0.8
                            width: 40
                            height: 1
                            color: "#21be2b"
                        }
                        onCurrentIndexChanged: {
                            analogOutputsModel.get(editableCheckElementAnalog.curIndex).value
                                                = parseFloat(tumblerModel.get(currentIndex).voltage)
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        width: 30
                        height: 30
                        radius: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: editableCheckElementAnalog.down || editableCheckElementAnalog.highlighted
                        color: editableCheckElementAnalog.down ? "#bdbebf" : "#eeeeee"
                    }
                }

            }

            TableView {
                id: analogSeqTable

                anchors.top: sequenceButtonsRow.bottom
                anchors.left: parent.left
                leftMargin: 10
                width: 500
                height: 73

                visible: false
                ScrollBar.horizontal: ScrollBar {}
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }

                model: AnalogOutSequenceModel {
                    id: analogOutSequenceModel
                }

                delegate: TextField {
                    id: cellField

                    width: 40
                    height: 30

                    text: model.data

                    background: Rectangle {
                        id: cellFieldBg
                        implicitWidth: 40
                        implicitHeight: 30
                        border.color: cellFieldBg.enabled ? "#21be2b" : "transparent"
                    }

                    onActiveFocusChanged
                    /*onAccepted*/: {
                        if(parseInt(text) > 10.8 || parseInt(text) < -10.8 ) {
                            messageDialog.visible = true;
                            text = 0;
                        }
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
 //                   visible: false

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
    //                        font.bold: true
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
                        analogOutSequenceModel.updateRowsCount(parseInt(countRow.text))
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
                        analogSeqTable.visible = hide
 //                       hide? modeWork.height = workArea.height - currentState.height - testStartStop.height - 10 :
 //                                   modeWork.height = 170
                    }
                }

            }
    }

        Button {
            id: testStartStop
            property bool start: false

            anchors.top:  modeWork.bottom
            anchors.right: parent.right
            width: 150
            height: 50

            visible: true
//            enabled: {
//                if((modeModel.get(listViewModeWork.currentIndex).value === 1))
//                    return true;
//                else if((!delayValue.text || !countCycleValue.text)) {
//                   return false
//               }
//               else
//                   return true
//            }
            text: start? "Завершить тестирование" : "Начать тестирование"
            onClicked: {
                start = !start
                if (start)  {
                    startTesting()
                    hndl.analogTimerStart()
                } else {
                    hndl.analogTimerStop()
                    stopTesting()
                }
            }
        }
    }
}
