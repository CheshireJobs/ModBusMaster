import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import DiscreteOutSequenceModel 0.1

Item {
    id: workArea
    property var parentHeight: parent.height
    width: parent.width
    height: parent.height

    property var countSquence: modeTextField.text

    Component.onCompleted: {
//        hndl.setDiscreteSettings()
//        hndl.readDiscreteCount()
        discreteOutputsModel.clear()
        discreteOutputsModel2.clear()
        for ( var i = 0; i < 16; ++i) {
            discreteOutputsModel.append({"value" : 0});
            discreteOutputsModel2.append({"value" : 0});
        }

    }

//    Connections {
//        target: hndl
//        onDiscreteListChanged: {
//            discreteOutputsModel.clear()
//            discreteOutputsModel2.clear()
//            for ( var i = 0; i < hndl.discreteList.length; ++i) {
//                discreteOutputsModel.append({"value" : 0});
//                discreteOutputsModel2.append({"value" : 0});
//            }
//        }
//    }

    function clearAllChoises(checked) {
        if(checked) {
            discreteOutputsModel.clear()
            discreteOutputsModel2.clear()
            for ( var i = 0; i < hndl.discreteList.length; ++i){
                discreteOutputsModel.append({"value" : 0});
                discreteOutputsModel2.append({"value" : 0});
            }
//            checkDelegate.checked = false
        }
    }

    function saveSequence(nameFile) {
        discreteOutSequenceModel.delay = delayValue.text
        discreteOutSequenceModel.countCycle = countCycleValue.text
        hndl.saveSequence(nameFile, discreteOutSequenceModel)
    }

    function loadSequense(nameFile) {
        hndl.loadSequence(nameFile, discreteOutSequenceModel)
        delayValue.text = discreteOutSequenceModel.delay
        countCycleValue.text = discreteOutSequenceModel.countCycle
        countRow.text = discreteOutSequenceModel.m_rowCount
    }

    function startTesting() {
        var i = 0;
        if( modeModel.get(listViewModeWork.currentIndex).value === 0) {
            console.log("выключено")
            return;
        } else if( modeModel.get(listViewModeWork.currentIndex).value === 1) {
            for( i = 0; i < discreteOutputsModel.count; ++i ) {
                hndl.editedDiscreteOutputs[i] = discreteOutputsModel.get(i).value
            }
            for( i = 0; i < discreteOutputsModel2.count; ++i ) {
                hndl.editedDiscreteOutputs[(i + discreteOutputsModel2.count)] = discreteOutputsModel2.get(i).value
            }
             hndl.startTesting( modeModel.get(listViewModeWork.currentIndex).value,
                               discreteOutSequenceModel, delayValue.text, countCycleValue.text)
        } else {
            hndl.startTesting( modeModel.get(listViewModeWork.currentIndex).value,
                              discreteOutSequenceModel, delayValue.text, countCycleValue.text)
        }
    }

    function stopTest() {
        var i = 0;
        if(modeModel.get(listViewModeWork.currentIndex).value === 0) {
            return;
        }
//        discreteOutputsModel.clear()
//        discreteOutputsModel2.clear()
//        for ( i = 0; i < hndl.discreteList.length; ++i ) {
//            discreteOutputsModel.append({"value" : 0});
//            discreteOutputsModel2.append({"value" : 0});
//        }

        for( i = 0; i < discreteOutputsModel.count; ++i ) {
            hndl.editedDiscreteOutputs[i] = 0
        }
        for( i = 0; i < discreteOutputsModel2.count; ++i ) {
            hndl.editedDiscreteOutputs[(i + discreteOutputsModel2.count)] = 0
        }
        hndl.stopTest()
    }

    MessageDialog {
        id: messageDialog
        title: "Error"
        visible: false
        text: "Введите все данные последовательности."

        onAccepted: {
        }
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
        id: borderDiscreteTab

        width: parent.width
        height: parent.height
        radius: 5

        border.color: "lightgray"

        Rectangle {
            id: discreteLabel

            anchors.top: parent.top
            width: parent.width
            height: 25
            radius: 5

            color: "lightgray"

            Text {
                id: discreteOutputsLabel

                anchors.left: turnOnButton.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                width: 201
                height: 25
                text: "Дискретные выходы"
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
                            workArea.height = 35
                            modeWork.visible = false
                            currentState.visible = false
                        } else {
                            workArea.height = 500
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
            height: 150

            title: "Текущее состояние "
            anchors.top: discreteLabel.bottom

            Label {
                id: plusLabel
                height: discreteList.height
                width: 50
                anchors.top: parent.top

                anchors.left: parent.left
                Text {
                    text: "+24"
                    font.pixelSize: 15
                    font.bold: true
                    topPadding: 15
                    leftPadding: 15
                }
            }
            Label {
                id: minusLabel

                height: discreteList.height
                width: 50

                anchors.top: plusLabel.bottom
                anchors.left: parent.left
                Text {
                    text: "GND"
                    font.pixelSize: 15
                    font.bold: true
                    topPadding: 15
                    leftPadding: 15
                }
            }

            ListView {
                id: discreteList

                anchors.top: parent.top
                anchors.left: plusLabel.right
                anchors.right: parent.right
                height: 50

                orientation: ListView.Horizontal
                interactive: false
                pixelAligned: true

                model: hndl.discreteList.isEmpty? 0 : hndl.discreteList

                delegate: CheckDelegate {
                    id: checkElement
                    width: 50
                    checked: modelData.value === 1? true : false
                    spacing: 0
                    opacity: checked? 1 : 0.5
                    enabled: false

                    indicator: Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        x: checkElement.width - width - checkElement.rightPadding
                        y: checkElement.topPadding + checkElement.availableHeight / 2 - height / 2
                        radius: 3
                        color: "transparent"
                        border.color: checkElement.down ? "#17a81a" : "#21be2b"

                        Rectangle {
                            width: 25
                            height: 25
                            x: 2.5
                            y: 2.5
                            radius: 3
                            color: checkElement.checked ? "#21be2b" : "gray"
                            border.color: checkElement.down ? "#17a81a" : "#21be2b"

                            Text {
                                text: index + 1
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideMiddle
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 60
                        implicitHeight: 40
                        visible: checkElement.down || checkElement.highlighted
                        color: checkElement.down ? "#bdbebf" : "#eeeeee"
                    }

                }
            }

            ListView {
                id: discreteList2

                anchors.top: discreteList.bottom
                anchors.left: minusLabel.right
                anchors.right: parent.right
                height: 50

                orientation: ListView.Horizontal
                interactive: false

                model: hndl.discreteList2.isEmpty? 0 : hndl.discreteList2

                delegate: CheckDelegate {
                    id: checkElement2

                    width: 50
                    checked: modelData.value === 1? true : false
                    spacing: 0
                    opacity: checked? 1 : 0.5
                    enabled: false

                    indicator: Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        x: checkElement2.width - width - checkElement2.rightPadding
                        y: checkElement2.topPadding + checkElement2.availableHeight / 2 - height / 2
                        radius: 3
                        color: "transparent"
                        border.color: checkElement2.down ? "#17a81a" : "#21be2b"

                        Rectangle {
                            width: 25
                            height: 25
                            x: 2.5
                            y: 2.5
                            radius: 3
                            color: checkElement2.checked ? "#21be2b" : "gray"
                            border.color: checkElement2.down ? "#17a81a" : "#21be2b"

                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: index + 1
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 60
                        implicitHeight: 40
                        visible: checkElement2.down || checkElement2.highlighted
                        color: checkElement2.down ? "#bdbebf" : "#eeeeee"
                    }

                }
            }
        }

        GroupBox {
            id: modeWork

            anchors.top: currentState.bottom
            width: parent.width
            height: parent.height - currentState.height - testStartStop.height - 10 - discreteLabel.height
            title: "Режим работы"

            ListView {
                id: listViewModeWork

                property var currentIndex

                anchors.top: parent.top
                width: 300
                height: 50

                orientation: ListView.Horizontal
                interactive: false

                model: ListModel {
                    id: modeModel
                    ListElement {
                        value: 0x0000
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
                            plusLabelWork.visible = false
                            minusLabelWork.visible = false
                            editableDiscreteList.visible = false;
                            editableDiscreteList2.visible = false;
                            seqDiscreteOutTable.visible = false;
                            sequenceButtonsRow.visible = false
                            delayValue.visible = false;
                            countCycleValue.visible = false;

                        } else if (checked && index === 1) {
//                            checkDelegate.visible = true
                            plusLabelWork.visible = true
                            minusLabelWork.visible = true
                            editableDiscreteList.visible = true;
                            editableDiscreteList2.visible = true;
                            seqDiscreteOutTable.visible = false;
//                            modeTextField.visible = false;
                            sequenceButtonsRow.visible = false
                            delayValue.visible = false;
                            countCycleValue.visible = false;

                        } else  {
//                            checkDelegate.visible = false
                            plusLabelWork.visible = false
                            minusLabelWork.visible = false
                            editableDiscreteList2.visible = false;
                            editableDiscreteList.visible = false;
                            seqDiscreteOutTable.visible = true
                            sequenceButtonsRow.visible = true
//                            modeTextField.visible = true;
                            delayValue.visible= true;
                            countCycleValue.visible = true;
                        }
                    }
                }
            }

            TextField {
                id: modeTextField
                anchors.top: listViewModeWork.bottom
                visible: false

                height: 30
                width: 70
                placeholderText: qsTr("Enter count")

                background: Rectangle {
                    id: control3
                    implicitWidth: 200
                    implicitHeight: 40
                    border.color: control3.enabled ? "#21be2b" : "transparent"
                }
            }


            Label {
                id: plusLabelWork
                visible: false
                height: editableDiscreteList.height
                width: 50
                anchors.top: listViewModeWork.bottom
                anchors.left: parent.left

                Text {
                    text: "+24"
                    font.pixelSize: 15
                    font.bold: true
                    topPadding: 15
                    leftPadding: 15
                }
            }
            Label {
                id: minusLabelWork
                visible: false
                height: editableDiscreteList2.height
                width: 50
                anchors.top: plusLabelWork.bottom
                anchors.left: parent.left

                Text {
                    text: "GND"
                    font.pixelSize: 15
                    font.bold: true
                    topPadding: 15
                    leftPadding: 15
                }
            }

            ListModel {
                id: discreteOutputsModel
            }
            ListModel {
                id: discreteOutputsModel2
            }

            ListView {
                id: editableDiscreteList

                anchors.top: listViewModeWork.bottom
                anchors.left: plusLabelWork.right
                anchors.right: parent.right
                height: 50
                pixelAligned: true
                orientation: ListView.Horizontal
                model: discreteOutputsModel
                visible: false
                interactive: false

                delegate: CheckDelegate {
                    id: editableCheckElement
                    width: 50
                    checked: modelData.value === 1? true : false
                    spacing: 0
                    opacity: checked? 1 : 0.5

                    indicator: Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            x: editableCheckElement.width - width - editableCheckElement.rightPadding
                            y: editableCheckElement.topPadding + editableCheckElement.availableHeight / 2 - height / 2
                            radius: 3
                            color: "transparent"
                            border.color: editableCheckElement.down ? "#17a81a" : "#21be2b"

                            Rectangle {
                                width: 25
                                height: 25
                                x: 2.5
                                y: 2.5
                                radius: 3
                                color: editableCheckElement.checked ? "#21be2b" : "gray"
                                border.color: editableCheckElement.down ? "#17a81a" : "#21be2b"

                                Text {
                                    text: index + 1
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "white"
                                }
                            }
                    }

                    background: Rectangle {
                        implicitWidth: 60
                        implicitHeight: 40
                        visible: editableCheckElement.down || editableCheckElement.highlighted
                        color: editableCheckElement.down ? "#bdbebf" : "#eeeeee"
                    }

                    onClicked: {
                        discreteOutputsModel.get(index).value = checked? 1 : 0
                        if( discreteOutputsModel.get(index).value && discreteOutputsModel2.get(index).value ) {
                            editableCheckElement.checked = false
                            discreteOutputsModel.get(index).value = 0
                        }
                    }
                }
            }

            ListView {
                id: editableDiscreteList2
                anchors.top: editableDiscreteList.bottom
                anchors.left: minusLabelWork.right
                anchors.right: parent.right
                height: 50
                interactive: false
                visible: false
//                enabled: false

                orientation: ListView.Horizontal
                model: discreteOutputsModel2

                delegate: CheckDelegate {
                    id: editableCheckElement2

                    width: 50
                    checked: modelData.value === 1? true : false
                    spacing: 0
                    opacity: checked? 1 : 0.5

                    indicator: Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            x: editableCheckElement2.width - width - editableCheckElement2.rightPadding
                            y: editableCheckElement2.topPadding + editableCheckElement2.availableHeight / 2 - height / 2
                            radius: 3
                            color: "transparent"
                            border.color: editableCheckElement2.down ? "#17a81a" : "#21be2b"

                            Rectangle {
                                width: 25
                                height: 25
                                x: 2.5
                                y: 2.5
                                radius: 3
                                color: editableCheckElement2.checked ? "#21be2b" : "gray"
                                border.color: editableCheckElement2.down ? "#17a81a" : "#21be2b"

                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    text: index + 1
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "white"
                                }
                            }
                    }
                    background: Rectangle {
                        implicitWidth: 60
                        implicitHeight: 40
                        visible: editableCheckElement2.down || editableCheckElement2.highlighted
                        color: editableCheckElement2.down ? "#bdbebf" : "#eeeeee"
                    }

                    onClicked: {
                        discreteOutputsModel2.get(index).value = checked? 1 : 0
                        if( discreteOutputsModel2.get(index).value  && discreteOutputsModel.get(index).value ) {
                            editableCheckElement2.checked = false
                            discreteOutputsModel2.get(index).value = 0
                        }
                    }
                }
            }

            TableView {
                id: seqDiscreteOutTable

                anchors.top: sequenceButtonsRow.bottom
                anchors.bottom: parent.bottom
                width: parent.width

                visible: false

                ScrollBar.horizontal: ScrollBar {

                }
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }

                model: DiscreteOutSequenceModel {
                    id: discreteOutSequenceModel
                }

                delegate: CheckBox {
                    height: 30
                    width: 30
                    checked: model.checked

                    Text {
                        id: text
                        anchors.left: parent.right
                        anchors.leftMargin: -5
                        text: model.mIndex
                        color: (model.mIndex < 17 && model.mIndex > 0) ?  "green" : "blue"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            model.checked = !model.checked
                        }
                    }
                }
            }

            Row {
                id: sequenceButtonsRow

                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: listViewModeWork.bottom
                width: parent.width//500
                height: 50
                spacing: 10

                visible: false

                TextField {
                    id: delayValue
                    height: 30
                    width: 80
                    placeholderText: qsTr("Enter delay")
                    visible: false

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
                    visible: false

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
//                            font.bold: true
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
                        discreteOutSequenceModel.updateRowsCount(parseInt(countRow.text))
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
                        seqDiscreteOutTable.visible = hide
                        hide? modeWork.height = workArea.height - currentState.height - testStartStop.height - 10 :
                                    modeWork.height = 170
                    }
                }



            }

//            CheckDelegate {
//                id: checkDelegate
//                anchors.left: modeWorkList.right
////                x: 208
////                y: 0
//                visible: false
//                text: qsTr("Снять все")
//                onCheckStateChanged: {
//                    clearAllChoises(checked)
//                }
//            }
        }

    Button {
        id: testStartStop
        property bool start: false
        visible: true

        width: 150
        height: 50
        anchors.top: modeWork.bottom
        anchors.right: parent.right
        enabled: {
            if((modeModel.get(listViewModeWork.currentIndex).value === 1))
                return true;
            else if((!delayValue.text || !countCycleValue.text)) {
               return false
           }
           else
               return true
        }
        text: start? "Завершить тестирование" : "Начать тестирование"
        onClicked: {
            start = !start
            if (start)  {
                startTesting()
                hndl.discreteTimerStart()
            } else {
                hndl.discreteTimerStop()
                stopTest()
            }
        }
    }
    }
}
