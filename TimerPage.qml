import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import AnalogOutSequenceModel 0.1
import TimerOutSequenceModel 0.1
import QtQuick.Dialogs 1.2

Rectangle {
    id: settings
    width: 1226
    height: 796
    color: "#ffffff"
    radius: 8
    border.color: "#dfe0eb"

    function startTest() {
        var i = 0;
        if(setValueModeButton.isSelect) {
            console.log("уст значения")
            hndl.startTimerTest(1,freqTimer1.text,parseFloat(rateTimer1.text)*100,
                                freqTimer2.text,parseFloat(rateTimer2.text)*100,
                                freqTimer3.text, parseFloat(rateTimer3.text)*100,
                                freqTimer4.text, parseFloat(rateTimer4.text)*100)
        } else if(sequenceModeButton.isSelect) {
            console.log("последовательность")
            hndl.startTimerSeqTest(2, timerOutSequenceModel, countRepeat.text , delay.text)
        }
    }

    function stopTest() {
        hndl.stopTimerTest()
    }

    function saveSequence(nameFile) {
        timerOutSequenceModel.delay = delay.text
        timerOutSequenceModel.countCycle = countRepeat.text
        timerOutSequenceModel.delayTimer = delayTimer.text
        hndl.saveTimerSequence(nameFile, timerOutSequenceModel)
    }

    function loadSequense(nameFile) {
        hndl.loadTimerSequence(nameFile,timerOutSequenceModel) //analogOutSequenceModel
        countRows.flagChange = false
        countRows.text = timerOutSequenceModel.m_rowCount
        countRows.flagChange = true
        delay.text = timerOutSequenceModel.delay
        delayTimer.text = timerOutSequenceModel.delayTimer
        countRepeat.text = timerOutSequenceModel.countCycle
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
        text: qsTr("Таймеры")
        font.pixelSize: 16
        font.weight: Font.Bold
        font.bold: true
        font.family: "Mulish"
    }

    Rectangle {
        id: modeWork
        x: 30
        y: 67
        width: 926
        height: 549
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
            id: workMode
            x: 26
            y: 84
            width: 655
            height: 428
            visible: true
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"
            DropShadow {
                id: currentStateShadow2
                color: "#dde2ff"
                radius: 8
                anchors.fill: workMode
                source: workMode
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
                id: setValueRect
                x: 22
                y: 66
                width: 598
                height: 337
                visible: false
                color: "#ffffff"
                radius: 8
                border.color: "#ffffff"

                Rectangle {
                    id: timer1
                    x: 0
                    y: -6
                    width: 219
                    height: 116
                    visible: true
                    color: "#ffffff"
                    radius: 8
                    border.color: "#3751ff"
                    DropShadow {
                        id: timer1Shadow
                        color: "#dde2ff"
                        radius: 8
                        anchors.fill: timer1
                        source: timer1
                        horizontalOffset: 2
                        z: -1
                        fast: true
                        spread: 0
                        anchors.bottomMargin: 0
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
                        samples: 18
                        anchors.rightMargin: 0
                        verticalOffset: 2
                    }

                    Text {
                        id: text12
                        x: 153
                        y: 8
                        color: "#3751ff"
                        text: qsTr("Таймер 1")
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.weight: Font.Bold
                        font.bold: true
                    }

                    Rectangle {
                        id: freq1
                        x: 118
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow3
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq1
                            source: freq1
                            anchors.topMargin: 0
                            spread: 0
                            fast: true
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            anchors.leftMargin: 0
                            z: -1
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: rateTimer1
                            x: 8
                            y: 4
                            width: 70
                            height: 15
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        id: text21
                        x: 41
                        y: 46
                        color: "#252733"
                        text: qsTr("частота, Гц")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Text {
                        id: text22
                        x: 126
                        y: 38
                        width: 78
                        height: 21
                        color: "#252733"
                        text: qsTr("коэффициент заполнения")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq
                        x: 14
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow2
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq
                            source: freq
                            anchors.topMargin: 0
                            fast: true
                            spread: 0
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            z: -1
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: freqTimer1
                            x: 8
                            y: 1
                            width: 70
                            height: 20
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }


                }

                ListModel {
                    id: analogOutputsModel
                }

                Rectangle {
                    id: timer2
                    x: 266
                    y: -6
                    width: 219
                    height: 116
                    visible: true
                    color: "#ffffff"
                    radius: 8
                    border.color: "#3751ff"
                    DropShadow {
                        id: timer1Shadow1
                        color: "#dde2ff"
                        radius: 8
                        anchors.fill: timer2
                        source: timer2
                        anchors.topMargin: 0
                        fast: true
                        spread: 0
                        samples: 18
                        verticalOffset: 2
                        anchors.bottomMargin: 0
                        z: -1
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        horizontalOffset: 2
                    }

                    Text {
                        id: text16
                        x: 152
                        y: 8
                        color: "#3751ff"
                        text: qsTr("Таймер 2")
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: true
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq2
                        x: 118
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow4
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq2
                            source: freq2
                            anchors.topMargin: 0
                            fast: true
                            spread: 0
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            z: -1
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: rateTimer2
                            x: 8
                            y: 4
                            width: 70
                            height: 15
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        id: text23
                        x: 41
                        y: 46
                        color: "#252733"
                        text: qsTr("частота, Гц")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Text {
                        id: text24
                        x: 126
                        y: 38
                        width: 78
                        height: 21
                        color: "#252733"
                        text: qsTr("коэффициент заполнения")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq3
                        x: 14
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow5
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq3
                            source: freq3
                            anchors.topMargin: 0
                            spread: 0
                            fast: true
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            anchors.leftMargin: 0
                            z: -1
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: freqTimer2
                            x: 8
                            y: 1
                            width: 70
                            height: 20
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    id: timer3
                    x: 0
                    y: 151
                    width: 219
                    height: 116
                    visible: true
                    color: "#ffffff"
                    radius: 8
                    border.color: "#3751ff"
                    DropShadow {
                        id: timer1Shadow2
                        color: "#dde2ff"
                        radius: 8
                        anchors.fill: timer3
                        source: timer3
                        anchors.topMargin: 0
                        fast: true
                        spread: 0
                        samples: 18
                        verticalOffset: 2
                        anchors.bottomMargin: 0
                        z: -1
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        horizontalOffset: 2
                    }

                    Text {
                        id: text18
                        x: 152
                        y: 8
                        color: "#3751ff"
                        text: qsTr("Таймер 3")
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: true
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq4
                        x: 118
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow6
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq4
                            source: freq4
                            anchors.topMargin: 0
                            fast: true
                            spread: 0
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            z: -1
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: rateTimer3
                            x: 8
                            y: 4
                            width: 70
                            height: 15
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        id: text25
                        x: 41
                        y: 46
                        color: "#252733"
                        text: qsTr("частота, Гц")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Text {
                        id: text28
                        x: 126
                        y: 38
                        width: 78
                        height: 21
                        color: "#252733"
                        text: qsTr("коэффициент заполнения")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq5
                        x: 14
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow7
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq5
                            source: freq5
                            anchors.topMargin: 0
                            spread: 0
                            fast: true
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            anchors.leftMargin: 0
                            z: -1
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: freqTimer3
                            x: 8
                            y: 1
                            width: 70
                            height: 20
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    id: timer4
                    x: 266
                    y: 151
                    width: 219
                    height: 116
                    visible: true
                    color: "#ffffff"
                    radius: 8
                    border.color: "#3751ff"
                    DropShadow {
                        id: timer1Shadow3
                        color: "#dde2ff"
                        radius: 8
                        anchors.fill: timer4
                        source: timer4
                        anchors.topMargin: 0
                        fast: true
                        spread: 0
                        samples: 18
                        verticalOffset: 2
                        anchors.bottomMargin: 0
                        z: -1
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        horizontalOffset: 2
                    }

                    Text {
                        id: text20
                        x: 152
                        y: 8
                        color: "#3751ff"
                        text: qsTr("Таймер 4")
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: true
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq6
                        x: 118
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow8
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq6
                            source: freq6
                            anchors.topMargin: 0
                            fast: true
                            spread: 0
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            z: -1
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: rateTimer4
                            x: 8
                            y: 4
                            width: 70
                            height: 15
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        id: text29
                        x: 41
                        y: 46
                        color: "#252733"
                        text: qsTr("частота, Гц")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Text {
                        id: text30
                        x: 126
                        y: 38
                        width: 78
                        height: 21
                        color: "#252733"
                        text: qsTr("коэффициент заполнения")
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.family: "Mulish"
                        font.bold: false
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        id: freq7
                        x: 14
                        y: 71
                        width: 86
                        height: 22
                        visible: true
                        color: "#ffffff"
                        radius: 8
                        border.color: "#3751ff"
                        DropShadow {
                            id: timer2Shadow9
                            color: "#dde2ff"
                            radius: 8
                            anchors.fill: freq7
                            source: freq7
                            anchors.topMargin: 0
                            spread: 0
                            fast: true
                            samples: 18
                            verticalOffset: 2
                            anchors.bottomMargin: 0
                            anchors.leftMargin: 0
                            z: -1
                            anchors.rightMargin: 0
                            horizontalOffset: 2
                        }

                        TextInput {
                            id: freqTimer4
                            x: 8
                            y: 1
                            width: 70
                            height: 20
                            color: "#252733"
                            text: qsTr("1000")
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Mulish"
                            font.bold: true
                            font.weight: Font.Bold
                        }
                    }
                }



            }

            Rectangle {
                id: sequenseRect
                x: 0
                y: 59
                width: 631
                height: 327
                visible: true
                color: "transparent"
                border.color: "#00000000"

                TableView {
                    id: timerSequence
                    x: 20
                    y: 67
                    width: 622
                    height: 260
                    visible: true
                    reuseItems: false
                    columnSpacing: 5

                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }

                    model: TimerOutSequenceModel {
                        id: timerOutSequenceModel
                    }

                    delegate: Rectangle {
                        id: sequenceRow
                        width: 70
                        height: 46
                        implicitHeight: height
                        implicitWidth: width

                        Rectangle {
                            id: timerCheckElement
                            width: 75
                            height: 27
                            anchors.top: sequenceRow.top
                            anchors.topMargin: 10
                            color: "transparent"
                            radius: 8
                            border.color: "#3751FF"

                            TextInput {
                                id: timerTextImput
                                anchors.fill: parent
                                text: Math.round(model.data * 100) / 100
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 9
                                color: "#252733"
                                focus: true
                                selectByMouse: true
                                activeFocusOnPress: true
                                activeFocusOnTab: true
                                mouseSelectionMode: TextInput.SelectWords

                                onEditingFinished : {
                                    model.data = text
                                    timerTextImput.focus = false
                                }

                                MouseArea {
                                    anchors.fill: timerTextImput
                                    onClicked: {
                                       timerTextImput.forceActiveFocus()
                                       timerTextImput.selectAll()
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

                Rectangle {
                    x: 26
                    y: 67
                    width: 593
                    height: 1
                    color: "#ebedf0"
                    border.color: "#ebedf0"
                }

                Text {
                    id: text31
                    x: 30
                    y: 48
                    color: "#9fa2b4"
                    text: qsTr("частота, Гц")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text32
                    x: 93
                    y: 37
                    width: 78
                    height: 24
                    color: "#9fa2b4"
                    text: qsTr("коэффициент заполнения")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text33
                    x: 66
                    y: 18
                    color: "#252733"
                    text: qsTr("Таймер 1")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text34
                    x: 177
                    y: 48
                    color: "#9fa2b4"
                    text: qsTr("частота, Гц")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text35
                    x: 240
                    y: 37
                    width: 78
                    height: 24
                    color: "#9fa2b4"
                    text: qsTr("коэффициент заполнения")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text36
                    x: 217
                    y: 18
                    color: "#252733"
                    text: qsTr("Таймер 2")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text37
                    x: 324
                    y: 48
                    color: "#9fa2b4"
                    text: qsTr("частота, Гц")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text38
                    x: 391
                    y: 37
                    width: 78
                    height: 24
                    color: "#9fa2b4"
                    text: qsTr("коэффициент заполнения")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text39
                    x: 368
                    y: 18
                    color: "#252733"
                    text: qsTr("Таймер 3")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text40
                    x: 475
                    y: 48
                    color: "#9fa2b4"
                    text: qsTr("частота, Гц")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text41
                    x: 542
                    y: 37
                    width: 78
                    height: 24
                    color: "#9fa2b4"
                    text: qsTr("коэффициент заполнения")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }

                Text {
                    id: text42
                    x: 517
                    y: 18
                    color: "#252733"
                    text: qsTr("Таймер 4")
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Mulish"
                    font.bold: false
                    font.weight: Font.Normal
                }
            }

        }

        Rectangle {
            id: sequenceModeSettings
            x: 678
            y: 84
            width: 222
            height: 428
            visible: true
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
                x: 104
                y: 27
                color: "#252733"
                text: qsTr("2")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                onEditingFinished: {
                    if(flagChange) {
                        timerOutSequenceModel.updateRowsCount(parseInt(countRows.text), parseInt(delayTimer.text))
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
                x: 100
                y: 92
                width: 21
                height: 24
                color: "#252733"
                text: qsTr("1")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
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
                x: 104
                y: 150
                color: "#252733"
                text: qsTr("1")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
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
                text: qsTr("задержка срабатывания таймеров (с)")
                font.pixelSize: 11
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }

            TextInput {
                id: delayTimer
                x: 104
                y: 214
                color: "#252733"
                text: qsTr("1")
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
                onEditingFinished: {
                    timerOutSequenceModel.updateDelayTimer(parseInt(delayTimer.text))
                }
            }

            Rectangle {
                x: 0
                y: 364
                width: 222
                height: 1
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Text {
                id: resetButton
                x: 82
                y: 386
                color: "#3751ff"
                text: qsTr("сбросить")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Mulish"
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    hoverEnabled: true
                    onClicked: {
                        timerOutSequenceModel.clearModel(parseInt(countRows.text), parseInt(delayTimer.text))
                    }
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }
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
        x: 882
        y: 783
        width: 13
        height: 22
        color: "#9fa2b4"
        text: qsTr("<")
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
        id: text14
        x: 928
        y: 783
        color: "#9fa2b4"
        text: qsTr(">")
        font.pixelSize: 18
        font.family: "Mulish"

    }

    Text {
        id: countPagesText
        x: 840
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
        x: 782
        y: 786
        color: "#9fa2b4"
        text: qsTr("3")
        font.pixelSize: 16
        font.family: "Mulish"
    }

}












/*##^##
Designer {
    D{i:0;formeditorZoom:1.33}
}
##^##*/
