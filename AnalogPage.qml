import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import AnalogOutSequenceModel 0.1
import QtQuick.Dialogs 1.2

Rectangle {
    id: settings
    width: 1226
    height: 994
    color: "#ffffff"
    radius: 8
    border.color: "#dfe0eb"

    Component.onCompleted: {
        analogOutputsModel.clear()
        for ( var i = 0; i < 12 ; ++i) {
            analogOutputsModel.append({"value" : 0});
        }
    }

    function startTest() {
        var i = 0;
        if(setValueModeButton.isSelect) {
            console.log("уст значения")
            for( i = 0; i < 12; ++i ) {
                hndl.editedAnalogOutputs[i] = analogOutputsModel.get(i).value
            }
            hndl.startAnalogTesting(1, analogOutSequenceModel, delay.text, countRepeat.text)
        } else if(sequenceModeButton.isSelect) {
            console.log("последовательность")
            hndl.startAnalogTesting(2, analogOutSequenceModel, delay.text, countRepeat.text)
        }
    }

    function stopTest() {
        var i = 0;
        hndl.stopAnalogTesting()
    }
    function canTest() {
        if(sequenceModeButton.isSelect && countRows.text === "" && countRepeat === "" && delay === "" && delayAnalog === "" ) {
            return false
        } else {
            return true
        }
    }

    function saveSequence(nameFile) {
        analogOutSequenceModel.delay = delay.text
        analogOutSequenceModel.countCycle = countRepeat.text
        analogOutSequenceModel.delayAnalog = delayAnalog.text
        hndl.saveAnalogSequence(nameFile, analogOutSequenceModel)
    }

    function loadSequense(nameFile) {
        hndl.loadAnalogSequence(nameFile, analogOutSequenceModel)
        countRows.flagChange = false
        countRows.text = analogOutSequenceModel.m_rowCount
        countRows.flagChange = true
        delayAnalog.text = analogOutSequenceModel.delayAnalog
        delay.text = analogOutSequenceModel.delay
        countRepeat.text = analogOutSequenceModel.countCycle
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

    DropShadow {
        id: settingsShadow
        color: "#dde2ff"
        radius: 8
        anchors.fill: settings
        source: settings
        fast: true
        z: -1
        anchors.topMargin: 0
        verticalOffset: 2
        spread: 0
        samples: 18
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.bottomMargin: 0
        horizontalOffset: 2
    }

    Text {
        id: text11
        x: 28
        y: 25
        color: "#252733"
        text: qsTr("Aналоговые выходы")
        font.pixelSize: 16
        font.weight: Font.Bold
        font.bold: true
        font.family: "Mulish"
    }

    Rectangle {
        id: currentState
        x: 30
        y: 67
        width: 925
        height: 126
        color: "#ffffff"
        radius: 8
        border.color: "#dfe0eb"

        DropShadow {
            id: currentStateShadow
            color: "#dde2ff"
            radius: 8
            anchors.fill: currentState
            source: currentState
            anchors.topMargin: 0
            z: -1
            fast: true
            verticalOffset: 2
            spread: 0
            anchors.rightMargin: 0
            samples: 18
            anchors.leftMargin: 0
            anchors.bottomMargin: 0
            horizontalOffset: 2
        }

        Text {
            id: text12
            x: 21
            y: 22
            color: "#252733"
            text: qsTr("Текущее состояние")
            font.pixelSize: 14
            font.weight: Font.Bold
            font.bold: true
            font.family: "Mulish"
        }

        Rectangle {
            x: 21
            y: 65
            width: 488
            height: 1
            color: "#ebedf0"
            border.color: "#ebedf0"
        }

        ListView {
            id: analogList
            x: 21
            y: 72
            width: 500
            height: 29
            orientation: ListView.Horizontal
            interactive: false
            spacing: 6

            model: hndl.analogList? hndl.analogList.isEmpty? 0 : hndl.analogList : 0

            delegate: Rectangle {
                id: curAnalogCheckElement
                property var curIndex: index
                width: 36
                height: 27
                anchors.topMargin: 10
                color: "transparent"
                radius: 8
                border.color: "#3751FF"

                Text {
                    anchors.fill: parent
                    text: Math.round(hndl.analogList[curAnalogCheckElement.curIndex].value*100)/100
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 9
                    color: "#252733"
                }
            }
        }

        Rectangle {
            x: 21
            y: 107
            width: 434
            height: 0
            color: "#ebedf0"
            border.color: "#ebedf0"
        }

        Text {
            id: text52
            x: 32
            y: 45
            color: "#3751ff"
            text: qsTr("1")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.weight: Font.Normal
            font.bold: false
        }

        Text {
            id: text65
            x: 72
            y: 45
            color: "#3751ff"
            text: qsTr("2")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text66
            x: 114
            y: 45
            color: "#3751ff"
            text: qsTr("3")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text67
            x: 156
            y: 45
            color: "#3751ff"
            text: qsTr("4")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text68
            x: 198
            y: 45
            color: "#3751ff"
            text: qsTr("5")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text69
            x: 240
            y: 45
            color: "#3751ff"
            text: qsTr("6")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text70
            x: 283
            y: 45
            color: "#3751ff"
            text: qsTr("7")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text71
            x: 326
            y: 45
            color: "#3751ff"
            text: qsTr("8")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text72
            x: 369
            y: 45
            color: "#3751ff"
            text: qsTr("9")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text73
            x: 411
            y: 45
            color: "#3751ff"
            text: qsTr("10")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text74
            x: 453
            y: 45
            color: "#3751ff"
            text: qsTr("11")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }

        Text {
            id: text75
            x: 495
            y: 45
            color: "#3751ff"
            text: qsTr("12")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Normal
        }
    }

    Rectangle {
        id: modeWork
        x: 29
        y: 227
        width: 926
        height: 553
        color: "#ffffff"
        radius: 8
        border.color: "#dfe0eb"

        DropShadow {
            id: modeWorkShadow
            color: "#dde2ff"
            radius: 8
            anchors.fill: modeWork
            source: modeWork
            fast: true
            z: -1
            anchors.topMargin: 0
            verticalOffset: 2
            spread: 0
            samples: 18
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.bottomMargin: 0
            horizontalOffset: 2
        }

        Text {
            id: text13
            x: 26
            y: 21
            color: "#252733"
            text: qsTr("Режим работы")
            font.pixelSize: 14
            font.weight: Font.Bold
            font.bold: true
            font.family: "Mulish"
        }

        Rectangle {
            id: setValueModeButton
            property bool isSelect: false
            x: 26
            y: 50
            width: 120
            height: 20
            radius: 100
            border.color: "#A4A6B3"
            Text {
                id: setValueModeButtonText
                color: "#a4a6b3"
                anchors.fill: parent
                text: qsTr("установка значения")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Mulish"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    setValueModeButton.isSelect = true
                    setValueModeButtonText.color = setValueModeButton.isSelect? "#ffffff" : "#a4a6b3"
                    setValueModeButton.border.color = setValueModeButton.isSelect? "#3751FF" : "#a4a6b3"
                    setValueModeButton.color =  setValueModeButton.isSelect? "#3751FF" : "#ffffff"
                    setValueRect.visible = true
                    modeWorkText.text = "Установка значения"

                    sequenceModeButton.isSelect = false
                    sequenceModeButtonText.color = sequenceModeButton.isSelect? "#ffffff" : "#a4a6b3"
                    sequenceModeButton.border.color = sequenceModeButton.isSelect? "#3751FF" : "#a4a6b3"
                    sequenceModeButton.color = sequenceModeButton.isSelect? "#3751FF" : "#ffffff"
                    sequenseRect.visible = false
                    sequenceModeSettings.visible = false
                }
                hoverEnabled: true
                onEntered: {
                    cursorShape = Qt.PointingHandCursor                       }
                onExited: {
                    cursorShape = Qt.ArrowCursor
                }
            }

        }

        Rectangle {
            id: sequenceModeButton
            property bool isSelect: true
            x: 165
            y: 50
            width: 120
            height: 20
            radius: 100
            border.color: "#3751FF"
            color: "#3751FF"

            Text {
                id: sequenceModeButtonText
                color: "#ffffff"
                text: qsTr("последовательность")
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Mulish"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    sequenceModeButton.isSelect = true
                    sequenceModeButtonText.color = sequenceModeButton.isSelect? "#ffffff" : "#a4a6b3"
                    sequenceModeButton.border.color = sequenceModeButton.isSelect? "#3751FF" : "#a4a6b3"
                    sequenceModeButton.color = sequenceModeButton.isSelect? "#3751FF" : "#ffffff"
                    sequenseRect.visible = true
                    sequenceModeSettings.visible = true
                    modeWorkText.text = "Последовательность срабатывания выходов"

                    setValueModeButton.isSelect = false
                    setValueModeButtonText.color = setValueModeButton.isSelect? "#ffffff" : "#a4a6b3"
                    setValueModeButton.border.color = setValueModeButton.isSelect? "#3751FF" : "#a4a6b3"
                    setValueModeButton.color =  setValueModeButton.isSelect? "#3751FF" : "#ffffff"
                    setValueRect.visible = false
                }
                hoverEnabled: true
                onEntered: {
                    cursorShape = Qt.PointingHandCursor                       }
                onExited: {
                    cursorShape = Qt.ArrowCursor
                }
            }
        }

        Rectangle {
            id: sequenceMode
            x: 26
            y: 84
            width: 592
            height: 428
            visible: true
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"
            DropShadow {
                id: currentStateShadow2
                color: "#dde2ff"
                radius: 8
                anchors.fill: sequenceMode
                source: sequenceMode
                anchors.bottomMargin: 0
                horizontalOffset: 2
                spread: 0
                anchors.topMargin: 0
                anchors.rightMargin: 0
                samples: 18
                anchors.leftMargin: 0
                z: -1
                fast: true
                verticalOffset: 2
            }

            Text {
                id: modeWorkText
                x: 21
                y: 22
                width: 261
                height: 36
                visible: true
                color: "#252733"
                text: qsTr("Последовательность срабатывания выходов")
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
            }

            Rectangle {
                id: sequenseRect
                x: 21
                y: 68
                width: 548
                height: 283
                visible: true
                color: "transparent"
                border.color: "#00000000"

                TableView {
                    id: analogSequence
                    x: 20
                    y: 22
                    width: 520
                    height: 318
                    reuseItems: false
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    columnSpacing: 2

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }

                    model: AnalogOutSequenceModel {
                        id: analogOutSequenceModel
                    }

                    delegate: Rectangle {
                        id: sequenceRow
                        width: 36
                        height: 42
                        implicitHeight: height
                        implicitWidth: width

                        Rectangle {
                            id: analogCheckElement
                            width: 36
                            height: 27
                            anchors.top: sequenceRow.top
                            anchors.topMargin: 10
                            color: "transparent"
                            radius: 8
                            border.color: "#3751FF"

                            TextInput {
                                id: cell
                                anchors.fill: parent
                                text: Math.round(model.data*100)/100
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
//                                inputMask: "[+-]99.9"
                                font.pointSize: 9
                                color: "#252733"
                                focus: true
                                selectByMouse: true
                                activeFocusOnPress: true
                                activeFocusOnTab: true
                                mouseSelectionMode: TextInput.SelectWords

                                onEditingFinished : {
                                    model.data = text
                                    cell.focus = false
                                }

                                MouseArea {
                                    anchors.fill: cell
                                    onClicked: {
//                                       cell.focus = true
                                       cell.forceActiveFocus()
                                       cell.selectAll()
                                    }
                                }

                            }
                        }
                        Rectangle {
                            id: separator
                            width: sequenceRow.width
                            height: 1
                            anchors.bottom: sequenceRow.bottom
                            color: "#EBEDF0"
                            border.color: "#EBEDF0"
                        }
                    }
                }

                Text {
                    id: text28
                    x: 34
                    y: 0
                    width: 8
                    height: 14
                    color: "#3751ff"
                    text: qsTr("1")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text29
                    x: 73
                    y: 0
                    color: "#3751ff"
                    text: qsTr("2")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text30
                    x: 111
                    y: 0
                    color: "#3751ff"
                    text: qsTr("3")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text31
                    x: 150
                    y: 0
                    color: "#3751ff"
                    text: qsTr("4")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text32
                    x: 188
                    y: 0
                    color: "#3751ff"
                    text: qsTr("5")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text33
                    x: 226
                    y: 0
                    color: "#3751ff"
                    text: qsTr("6")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text34
                    x: 264
                    y: 0
                    color: "#3751ff"
                    text: qsTr("7")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text35
                    x: 302
                    y: 0
                    color: "#3751ff"
                    text: qsTr("8")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text36
                    x: 340
                    y: 0
                    color: "#3751ff"
                    text: qsTr("9")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text37
                    x: 371
                    y: 0
                    color: "#3751ff"
                    text: qsTr("10")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text38
                    x: 411
                    y: 0
                    color: "#3751ff"
                    text: qsTr("11")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text39
                    x: 445
                    y: 0
                    color: "#3751ff"
                    text: qsTr("12")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Rectangle {
                    x: 20
                    y: 20
                    width: 445
                    height: 1
                    color: "#ebedf0"
                    border.color: "#ebedf0"
                }
            }
        }

        Rectangle {
            id: setValueRect
            x: 48
            y: 150
            width: 522
            height: 129
            visible: false
            color: "#ffffff"
            radius: 8
            border.color: "#ffffff"

            ListModel {
                id: analogOutputsModel
            }

            ListView {
                id: editableAnalogList
                x: 2
                y: 31
                width: 512
                height: 29
                orientation: ListView.Horizontal
                interactive: false
                delegate: Rectangle {
                    id: editableAnalogCheckElement
                    property var curIndex: index
                    width: 36
                    height: 27
                    color:"transparent"
                    radius: 8
                    border.color: "#3751FF"
                    TextInput {
                        id: te
                        color: "#252733"
                        text: qsTr("0")
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 9
                        focus: true
                        selectByMouse: true
                        activeFocusOnPress: true
                        activeFocusOnTab: true
                        mouseSelectionMode: TextInput.SelectWords

                        onEditingFinished : {
                            if(parseDouble(te.text) > 10.8 || parseDouble(te.text) < -10.8) {
                            }
                            analogOutputsModel.get(editableAnalogCheckElement.curIndex).value = parseFloat(text)
                            te.focus = false
                        }

                        MouseArea {
                            anchors.fill: te
                            onClicked: {
                               te.forceActiveFocus()
                               te.selectAll()
                            }
                        }

                    }
                    anchors.topMargin: 10
                }
                model: analogOutputsModel
                spacing: 6
            }

            Rectangle {
                x: 2
                y: 24
                width: 495
                height: 1
                color: "#ebedf0"
                border.color: "#ebedf0"
            }

            Rectangle {
                x: 2
                y: 66
                width: 495
                height: 1
                color: "#ebedf0"
                border.color: "#ebedf0"
            }

            Text {
                id: text40
                x: 17
                y: 8
                color: "#3751ff"
                text: qsTr("1")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text41
                x: 59
                y: 8
                color: "#3751ff"
                text: qsTr("2")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text42
                x: 101
                y: 8
                color: "#3751ff"
                text: qsTr("3")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text43
                x: 143
                y: 8
                color: "#3751ff"
                text: qsTr("4")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text44
                x: 185
                y: 8
                color: "#3751ff"
                text: qsTr("5")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text45
                x: 227
                y: 8
                color: "#3751ff"
                text: qsTr("6")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text46
                x: 270
                y: 8
                color: "#3751ff"
                text: qsTr("7")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text47
                x: 312
                y: 8
                color: "#3751ff"
                text: qsTr("8")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text48
                x: 354
                y: 8
                color: "#3751ff"
                text: qsTr("9")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text49
                x: 392
                y: 8
                color: "#3751ff"
                text: qsTr("10")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text50
                x: 434
                y: 8
                color: "#3751ff"
                text: qsTr("11")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }

            Text {
                id: text51
                x: 476
                y: 8
                color: "#3751ff"
                text: qsTr("12")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.weight: Font.Normal
                font.bold: false
            }
        }

        Rectangle {
            id: sequenceModeSettings
            x: 618
            y: 84
            width: 222
            height: 428
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"
            DropShadow {
                id: currentStateShadow1
                color: "#dde2ff"
                radius: 8
                anchors.fill: sequenceModeSettings
                source: sequenceModeSettings
                anchors.bottomMargin: 0
                horizontalOffset: 2
                spread: 0
                anchors.topMargin: 0
                anchors.rightMargin: 0
                samples: 18
                anchors.leftMargin: 0
                z: -1
                fast: true
                verticalOffset: 2
            }

            Text {
                id: text15
                x: 64
                y: 8
                color: "#9fa2b4"
                text: qsTr("количество строк")
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }

            Rectangle {
                x: 0
                y: 61
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            TextInput {
                id: countRows
                property bool flagChange: true
                x: 96
                y: 31
                width: 30
                height: 24
                color: "#252733"
                text: qsTr("1")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                inputMask: ""
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                onEditingFinished: {
                    if(flagChange) {
                        if( parseInt(countRows.text) > 11) {
                                countRows.text = "11"
                        }
                        if( parseInt(countRows.text) <= 0) {
                                countRows.text = "1"
                        }
                        analogOutSequenceModel.updateRowsCount(parseInt(countRows.text), parseInt(delayAnalog.text))
                    }
                    countRows.focus = false
                }

            }

            Rectangle {
                x: 0
                y: 122
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Rectangle {
                x: 0
                y: 183
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Rectangle {
                x: 0
                y: 305
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Text {
                id: text17
                x: 57
                y: 70
                color: "#9fa2b4"
                text: qsTr("количество повторов")
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }

            TextInput {
                id: countRepeat
                x: 74
                y: 92
                width: 81
                height: 24
                color: "#252733"
                text: qsTr("10")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                selectByMouse: true
                inputMask: ""
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
            }

            Text {
                id: text19
                x: 32
                y: 131
                color: "#9fa2b4"
                text: qsTr("задержка между повторами (с)")
                font.pixelSize: 11
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }

            TextInput {
                id: delay
                validator: RegExpValidator { regExp: /^(?!0+[1-9])\d{1,5}(?:,\d{10})*(?:\.\d{0,3})?$/ } ///^([0-9][0-9]*)+(.[0-9]{0,3})?$/
                x: 73
                y: 153
                width: 81
                height: 24
                color: "#252733"
                text: qsTr("1")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLength: 7
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                onEditingFinished:  {
                    delay.focus = false
                    if(delay.text == "") {
                        delay.text = 0
                    }
                    delay.text = parseFloat(delay.text)
                    console.log(delay.text)

                }
                onTextChanged: {
//                    if(delay.text == "") {
//                        delay.text = 0
//                    }
                }

            }

            Text {
                id: saveButton
                x: 79
                y: 267
                color: "#3751ff"
                text: qsTr("сохранить")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                enabled: canTest()
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        fileSaveDialog.visible = true
                    }
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }

            }

            Text {
                id: loadButton
                x: 82
                y: 328
                color: "#3751ff"
                text: qsTr("загрузить")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        fileDialog.visible = true
                    }
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }

            }

            Rectangle {
                x: 0
                y: 244
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Text {
                id: text26
                x: 10
                y: 192
                color: "#9fa2b4"
                text: qsTr("задержка срабатывания аналогов (с)")
                font.pixelSize: 11
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }

            TextInput {
                id: delayAnalog
                x: 79
                y: 214
                width: 69
                height: 24
                color: "#252733"
                text: qsTr("1")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                inputMask: ""
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                onEditingFinished: {
                    analogOutSequenceModel.updateDelayAnalog(parseInt(delayAnalog.text))
                    delayAnalog.focus = false
                }
            }

            Rectangle {
                x: 0
                y: 367
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Text {
                id: resetButton
                x: 84
                y: 389
                color: "#3751ff"
                text: qsTr("сбросить")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        analogOutSequenceModel.clearModel(parseInt(countRows.text), parseInt(delayAnalog.text) )
                    }
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }
                font.bold: true
                font.family: "Mulish"
                font.weight: Font.Bold
            }
        }
    }

    Text {
        id: text9
        x: 806
        y: 786
        color: "#9fa2b4"
        text: qsTr("из")
        font.pixelSize: 16
        font.family: "Mulish"
    }

    Text {
        id: text10
        x: 883
        y: 783
        width: 13
        height: 22
        color: "#9fa2b4"
        text: qsTr("<")
        font.pixelSize: 18
        font.family: "Mulish"
    }

    Text {
        id: text14
        x: 929
        y: 783
        color: "#9fa2b4"
        text: qsTr(">")
        font.pixelSize: 18
        font.family: "Mulish"
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked:  {
                discreteRow.isCurrentItem = true
                discreteRow.color = "#F7F8FC"

                analogRow.isCurrentItem = false
                timerRow.isCurrentItem = false

                analogRow.color = "#ffffff"
                timerRow.color = "#ffffff"
                discretePage.visible = true
                analogPage.visible = false
                timerPage.visible = false
            }

            onEntered: {
                cursorShape = Qt.PointingHandCursor
            }
            onExited: {
                cursorShape = Qt.ArrowCursor
            }
        }
    }

    Text {
        id: countPagesText
        x: 841
        y: 786
        width: 17
        height: 17
        color: "#9fa2b4"
        text: "3"//countPages
        font.pixelSize: 16
        font.family: "Mulish"
    }

    Text {
        id: currentNomberPage
        x: 783
        y: 786
        color: "#9fa2b4"
        text: qsTr("1")
        font.pixelSize: 16
        font.family: "Mulish"
    }

}







/*##^##
Designer {
    D{i:0;formeditorZoom:0.66}
}
##^##*/
