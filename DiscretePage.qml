import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import DiscreteOutSequenceModel 0.1
import QtQuick.Dialogs 1.2


Rectangle {
    id: settings
    width: 1226
    height: 796
    color: "#ffffff"
    radius: 8
    border.color: "#dfe0eb"

    Component.onCompleted: {
        discreteOutputsModel.clear()
        discreteOutputsModel2.clear()
        for ( var i = 0; i < 16; ++i) {
            discreteOutputsModel.append({"value" : 0});
            discreteOutputsModel2.append({"value" : 0});
        }
    }

     function startTest() {
         var i = 0;

         if(setValueModeButton.isSelect) {
             console.log("уст значения")
             for( i = 0; i < discreteOutputsModel.count; ++i ) {
                 hndl.editedDiscreteOutputs[i] = discreteOutputsModel.get(i).value
             }
             for( i = 0; i < discreteOutputsModel2.count; ++i ) {
                 hndl.editedDiscreteOutputs[(i + discreteOutputsModel2.count)] = discreteOutputsModel2.get(i).value
             }
             hndl.startTesting( 1, discreteOutSequenceModel, delay.text, countRepeat.text)

         } else if(sequenceModeButton.isSelect) {
             console.log("последовательность")
             hndl.startTesting( 2, discreteOutSequenceModel, delay.text, countRepeat.text)
         }

     }

      function stopTest() {
          var i = 0;
          for( i = 0; i < discreteOutputsModel.count; ++i ) {
              hndl.editedDiscreteOutputs[i] = 0
          }
          for( i = 0; i < discreteOutputsModel2.count; ++i ) {
              hndl.editedDiscreteOutputs[(i + discreteOutputsModel2.count)] = 0
          }
          hndl.stopTest()
      }

      function saveSequence(nameFile) {
          discreteOutSequenceModel.delay = delay.text
          discreteOutSequenceModel.countCycle = countRepeat.text
          discreteOutSequenceModel.delayDiscrete = delayDiscrete.text
          hndl.saveSequence(nameFile, discreteOutSequenceModel)
      }

      function loadSequense(nameFile, url) {
          if(url) {
             hndl.loadSequence("", nameFile, discreteOutSequenceModel, url)
          } else {
             hndl.loadSequence(nameFile, "", discreteOutSequenceModel, url)
          }
          countRows.flagChange = false
          countRows.text = discreteOutSequenceModel.m_rowCount
          countRows.flagChange = true
          delay.text = discreteOutSequenceModel.delay
          delayDiscrete.text = discreteOutSequenceModel.delayDiscrete
          countRepeat.text = discreteOutSequenceModel.countCycle
      }

      FileDialog {
          id: fileDialog
          title: "Please choose a file"
          visible: false
          folder: shortcuts.home
          selectMultiple: false

          nameFilters: "*.stnd"

          onAccepted: {
              loadSequense(fileDialog.fileUrl, true)
              console.log(fileDialog.fileUrl)
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
        text: qsTr("Дискретные выходы")
        font.pixelSize: 16
        font.weight: Font.Bold
        font.bold: true
        font.family: "Mulish"
    }

    Rectangle {
        id: modeWork
        x: 28
        y: 227
        width: 924
        height: 533
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
                hoverEnabled: true
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
                    typeCar.visible = false
                    typeCarText.visible = false
                }
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
                hoverEnabled: true
                onClicked: {
                    sequenceModeButton.isSelect = true
                    sequenceModeButtonText.color = sequenceModeButton.isSelect? "#ffffff" : "#a4a6b3"
                    sequenceModeButton.border.color = sequenceModeButton.isSelect? "#3751FF" : "#a4a6b3"
                    sequenceModeButton.color = sequenceModeButton.isSelect? "#3751FF" : "#ffffff"
                    sequenseRect.visible = true
                    sequenceModeSettings.visible = true
                    typeCar.visible = true
                    typeCarText.visible = true
                    modeWorkText.text = "Последовательность срабатывания выходов"

                    setValueModeButton.isSelect = false
                    setValueModeButtonText.color = setValueModeButton.isSelect? "#ffffff" : "#a4a6b3"
                    setValueModeButton.border.color = setValueModeButton.isSelect? "#3751FF" : "#a4a6b3"
                    setValueModeButton.color =  setValueModeButton.isSelect? "#3751FF" : "#ffffff"
                    setValueRect.visible = false
                }

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
            width: 560
            height: 427
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
                anchors.leftMargin: 3
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
                x: 367
                y: 41
                width: 20
                height: 2
                color: "#3751ff"
                border.color: "#3751ff"
            }

            Rectangle {
                x: 459
                y: 41
                width: 20
                height: 2
                color: "#dfe0eb"
                border.color: "#dfe0eb"
            }

            Text {
                id: text24
                x: 393
                y: 34
                color: "#9fa2b4"
                text: qsTr("включен")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }

            Text {
                id: text25
                x: 485
                y: 34
                color: "#9fa2b4"
                text: qsTr("выключен")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Normal
                font.bold: false
                font.family: "Mulish"
            }
            DiscreteOutSequenceModel {
                id: discreteOutSequenceModel
            }

            Rectangle {
                id: sequenseRect
                x: 21
                y: 68
                width: 520
                height: 283
                visible: true
                color: "transparent"
                border.color: "#00000000"

                TableView {
                    id: discreteSequence
                    x: 20
                    y: 22
                    width: 498
                    height: 306
                    reuseItems: false
                    //            contentWidth: 26
                    //            contentHeight: 42

                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }

                    model: discreteOutSequenceModel

                    delegate: Rectangle {
                        id: sequenceRow
                        width: 26
                        height: 42
                        implicitHeight: height
                        implicitWidth: width

                        Rectangle {
                            id: discreteCheckElement
                            property int state: model.checked
                            width: 20
                            height: 20
                            anchors.top: sequenceRow.top
                            anchors.topMargin: 10
                            color: discreteCheckElement.state === 1? "#f12b2c":
                                    discreteCheckElement.state === 2? "#3751FF" : "transparent "
                            radius: height / 2
                            border.color: "#a4a6b3"

                            Text {
                                anchors.fill: parent
                                text: discreteCheckElement.state === 1? "+":
                                         discreteCheckElement.state === 2? "-" : " "
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 9
                                color: "white"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if(discreteCheckElement.state === 0) {
                                        model.checked = 1
                                        discreteCheckElement.state = 1
                                    } else if(discreteCheckElement.state === 1) {
                                        model.checked = 2
                                        discreteCheckElement.state = 2
                                    } else if(discreteCheckElement.state === 2) {
                                        model.checked = 0
                                        discreteCheckElement.state = 0
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
                    x: 25
                    y: 0
                    color: "#9fa2b4"
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
                    x: 51
                    y: 0
                    color: "#9fa2b4"
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
                    x: 77
                    y: 0
                    color: "#9fa2b4"
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
                    x: 103
                    y: 0
                    color: "#9fa2b4"
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
                    x: 129
                    y: 0
                    color: "#9fa2b4"
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
                    x: 155
                    y: 0
                    color: "#9fa2b4"
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
                    x: 181
                    y: 0
                    color: "#9fa2b4"
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
                    x: 207
                    y: 0
                    color: "#9fa2b4"
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
                    x: 233
                    y: 0
                    color: "#9fa2b4"
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
                    x: 256
                    y: 0
                    color: "#9fa2b4"
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
                    x: 281
                    y: 0
                    color: "#9fa2b4"
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
                    x: 307
                    y: 0
                    color: "#9fa2b4"
                    text: qsTr("12")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text40
                    x: 333
                    y: 0
                    color: "#9fa2b4"
                    text: qsTr("13")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text41
                    x: 359
                    y: 0
                    color: "#9fa2b4"
                    text: qsTr("14")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text42
                    x: 385
                    y: 0
                    color: "#9fa2b4"
                    text: qsTr("15")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                    font.family: "Mulish"
                    font.weight: Font.Normal
                }

                Text {
                    id: text43
                    x: 412
                    y: 0
                    color: "#9fa2b4"
                    text: qsTr("16")
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
                    width: 420
                    height: 1
                    color: "#ebedf0"
                    border.color: "#ebedf0"
                }
            }
        }

        Rectangle {
            id: setValueRect
            x: 65
            y: 152
            width: 490
            height: 129
            visible: false
            color: "#ffffff"
            radius: 8
            border.color: "#ffffff"

            ListModel {
                id: discreteOutputsModel
            }

            ListModel {
                id: discreteOutputsModel2
            }

            ListView {
                id: editableDiscreteList
                x: 8
                y: 31
                width: 425
                height: 29

                orientation: ListView.Horizontal
                interactive: false
                delegate: Rectangle {
                    id: curDiscreteCheckElement
                    property var state: 0
                    property bool isSelect: modelData.value === 1? true : false
                    width: 20
                    height: 20
                    color: curDiscreteCheckElement.state === 0 ? "transparent" :
                            curDiscreteCheckElement.state === 1 ? "#f12b2c" : "#3751FF"
                    radius: height / 2
                    border.color: "#a4a6b3"
                    Text {
                        color: "#ffffff"
                        text: curDiscreteCheckElement.state === 0 ? "" :
                                curDiscreteCheckElement.state === 1 ? "+" : "-"
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pointSize: 9
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if(curDiscreteCheckElement.state === 0) {
                                console.log(index)
                                discreteOutputsModel.get(index).value = 1
                                discreteOutputsModel2.get(index).value = 0
                                curDiscreteCheckElement.state = 1
                            } else if(curDiscreteCheckElement.state === 1) {
                                console.log(index)
                                discreteOutputsModel2.get(index).value = 1
                                discreteOutputsModel.get(index).value = 0
                                curDiscreteCheckElement.state = 2
                            } else if(curDiscreteCheckElement.state === 2) {
                                console.log(index)
                                discreteOutputsModel2.get(index).value = 0
                                discreteOutputsModel.get(index).value = 0
                                curDiscreteCheckElement.state = 0
                            }
                        }
                        onEntered: {
                            cursorShape = Qt.PointingHandCursor                       }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                        }

                    }
                    anchors.topMargin: 10
                }
                model: discreteOutputsModel
                spacing: 6
            }

            Text {
                id: text93
                x: 14
                y: 8
                color: "#9fa2b4"
                text: qsTr("1")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text94
                x: 40
                y: 8
                color: "#9fa2b4"
                text: qsTr("2")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text95
                x: 66
                y: 8
                color: "#9fa2b4"
                text: qsTr("3")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text96
                x: 92
                y: 8
                color: "#9fa2b4"
                text: qsTr("4")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text97
                x: 118
                y: 8
                width: 9
                color: "#9fa2b4"
                text: qsTr("5")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text98
                x: 144
                y: 8
                color: "#9fa2b4"
                text: qsTr("6")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text99
                x: 170
                y: 8
                color: "#9fa2b4"
                text: qsTr("7")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text100
                x: 196
                y: 8
                color: "#9fa2b4"
                text: qsTr("8")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text101
                x: 222
                y: 8
                color: "#9fa2b4"
                text: qsTr("9")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text102
                x: 245
                y: 8
                color: "#9fa2b4"
                text: qsTr("10")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text103
                x: 270
                y: 8
                color: "#9fa2b4"
                text: qsTr("11")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text104
                x: 296
                y: 8
                color: "#9fa2b4"
                text: qsTr("12")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text105
                x: 322
                y: 8
                color: "#9fa2b4"
                text: qsTr("13")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text106
                x: 348
                y: 8
                color: "#9fa2b4"
                text: qsTr("14")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text107
                x: 374
                y: 8
                color: "#9fa2b4"
                text: qsTr("15")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Text {
                id: text108
                x: 401
                y: 8
                color: "#9fa2b4"
                text: qsTr("16")
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.weight: Font.Normal
                font.family: "Mulish"
            }

            Rectangle {
                x: 8
                y: 24
                width: 400
                height: 1
                color: "#ebedf0"
                border.color: "#ebedf0"
            }

            Rectangle {
                x: 8
                y: 66
                width: 400
                height: 1
                color: "#ebedf0"
                border.color: "#ebedf0"
            }
        }

        ComboBox {
            id: typeCar
            visible: true
            currentIndex: 0
            model: ListModel {
                id: modelCar
                ListElement {
                    name: "не выбран"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "дуоматик"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "динамик"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПРС"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ПУМА"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ПМА"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ПМА-С"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "УНИМАТ КОМПАКТ"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "УНИМАТ"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПР-02"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПР-02М"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПР-02К"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПРС-02"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПРС-03"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ВПРС-03К"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "РБ"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "РПБ"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ПБ"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ПМГ"
                    file: ":/rcTest.stnd"
                }
                ListElement {
                    name: "ТЭС"
                    file: ":/rcTest.stnd"
                }
            }

            x: 479
            y: 40
            font.family: "Mulish"
            font.bold: true
            font.pointSize: 10

            delegate: ItemDelegate {

                width: typeCar.width
                contentItem: Text {
                    id: delegate
                    text: model.name
                    color: "#9fa2b4"
                    font: typeCar.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: typeCar.highlightedIndex === index
            }

            indicator: Canvas {
                id: canvas
                x: typeCar.width - width - typeCar.rightPadding
                y: typeCar.topPadding + (typeCar.availableHeight - height) / 2
                width: 12
                height: 8
                contextType: "2d"

                Connections {
                    target: typeCar
                    function onPressedChanged() { canvas.requestPaint(); }
                }

                onPaint: {
                    context.reset();
                    context.moveTo(0, 0);
                    context.lineTo(width, 0);
                    context.lineTo(width / 2, height);
                    context.closePath();
                    context.fillStyle = "#9fa2b4";
                    context.fill();
                }
            }

            contentItem: Text {
                font: typeCar.font
                color: "#9fa2b4"
                text: typeCar.model.get(typeCar.currentIndex).name
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 40
                border.color: "transparent"
                border.width: typeCar.visualFocus ? 2 : 1
                radius: 2
            }

            popup: Popup {
                y: typeCar.height - 1
                width: typeCar.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: typeCar.popup.visible ? typeCar.delegateModel : null
                    currentIndex: typeCar.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    border.color: "#9fa2b4"
                    radius: 2
                }
            }
            onCurrentIndexChanged: {
                if(currentIndex !== 0) {
//                    discreteOutSequenceModel.clearModel()
                    loadSequense(modelCar.get(currentIndex).file, false)
                }
            }
        }

        Text {
            id: typeCarText
            x: 362
            y: 52
            color: "#252733"
            text: qsTr("тип машины")
            font.pixelSize: 13
            font.family: "Mulish"
            font.weight: Font.Bold
            font.bold: true
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
                analogRow.isCurrentItem = true
                analogRow.color = "#F7F8FC"

                discreteRow.isCurrentItem = false
                timerRow.isCurrentItem = false

                discreteRow.color = "#ffffff"
                timerRow.color = "#ffffff"
                analogPage.visible = true
                discretePage.visible = false
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
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked:  {
                timerRow.isCurrentItem = true
                timerRow.color = "#F7F8FC"

                discreteRow.isCurrentItem = false
                analogRow.isCurrentItem = false

                discreteRow.color = "#ffffff"
                analogRow.color = "#ffffff"
                timerPage.visible = true
                discretePage.visible = false
                analogPage.visible = false
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
        text: qsTr("2")
        font.pixelSize: 16
        font.family: "Mulish"
    }

    Rectangle {
        id: currentState
        x: 27
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

        ListView {
            id: discreteList
            x: 35
            y: 67
            width: 427
            height: 29
            orientation: ListView.Horizontal
            interactive: false
            spacing: 6

            model: hndl.discreteList? 16 : 0 //hndl.discreteList.isEmpty? 0 : hndl.discreteList

            delegate: Rectangle {
                id: curDiscreteCheckElement3
                property bool isSelect: modelData.value === 1? true : false
                width: 20
                height: 20
                anchors.topMargin: 10
                color:  hndl.discreteList[index].value === 1? "#f12b2c" :
                        hndl.discreteList2[index].value === 1 ? "#3751FF" : "transparent"
                radius: height / 2
                border.color: "#a4a6b3"

                Text {
                    anchors.fill: parent
                    text: hndl.discreteList[index].value === 1? "+" :
                        hndl.discreteList2[index].value === 1 ? "-" : ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.pointSize: 9
                    color: "white"
                }
            }
        }

        Text {
            id: text61
            x: 40
            y: 45
            color: "#9fa2b4"
            text: qsTr("1")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text62
            x: 66
            y: 45
            color: "#9fa2b4"
            text: qsTr("2")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text63
            x: 92
            y: 45
            color: "#9fa2b4"
            text: qsTr("3")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text64
            x: 118
            y: 45
            color: "#9fa2b4"
            text: qsTr("4")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text65
            x: 144
            y: 45
            width: 9
            color: "#9fa2b4"
            text: qsTr("5")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text66
            x: 170
            y: 45
            color: "#9fa2b4"
            text: qsTr("6")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text67
            x: 196
            y: 45
            color: "#9fa2b4"
            text: qsTr("7")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text68
            x: 222
            y: 45
            color: "#9fa2b4"
            text: qsTr("8")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text69
            x: 248
            y: 45
            color: "#9fa2b4"
            text: qsTr("9")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text70
            x: 271
            y: 45
            color: "#9fa2b4"
            text: qsTr("10")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text71
            x: 296
            y: 45
            color: "#9fa2b4"
            text: qsTr("11")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text72
            x: 322
            y: 45
            color: "#9fa2b4"
            text: qsTr("12")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text73
            x: 348
            y: 45
            color: "#9fa2b4"
            text: qsTr("13")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text74
            x: 374
            y: 45
            color: "#9fa2b4"
            text: qsTr("14")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text75
            x: 400
            y: 45
            color: "#9fa2b4"
            text: qsTr("15")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Text {
            id: text76
            x: 427
            y: 45
            color: "#9fa2b4"
            text: qsTr("16")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.weight: Font.Normal
            font.family: "Mulish"
        }


        Rectangle {
            x: 34
            y: 60
            width: 410
            height: 1
            color: "#ebedf0"
            border.color: "#ebedf0"
        }


        Rectangle {
            x: 34
            y: 102
            width: 410
            height: 1
            color: "#ebedf0"
            border.color: "#ebedf0"
        }







    }

    Rectangle {
        id: sequenceModeSettings
        x: 615
        y: 310
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
            x: 85
            y: 27
            width: 52
            color: "#252733"
            text: qsTr("2")
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            inputMask: "000"
            font.weight: Font.Bold
            font.bold: true
            font.family: "Mulish"
            onEditingFinished: {
                if(flagChange) {
                    if(parseInt(countRows.text) > 128) {
                        countRows.text = "128"
                    }
                    if(parseInt(countRows.text) <= 0) {
                         countRows.text = "1"
                    }

                    discreteOutSequenceModel.updateRowsCount(parseInt(countRows.text), parseInt(delayDiscrete.text))
                    typeCar.currentIndex = 0
                }
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
            x: 90
            y: 89
            width: 52
            height: 24
            color: "#252733"
            text: qsTr("1")
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            inputMask: "0000"
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
            x: 101
            y: 150
            color: "#252733"
            text: qsTr("1")
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            inputMask: "00000"
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
            text: qsTr("задержка срабатывания дискретов (с)")
            font.pixelSize: 11
            font.weight: Font.Normal
            font.bold: false
            font.family: "Mulish"
        }

        TextInput {
            id: delayDiscrete
            x: 101
            y: 211
            color: "#252733"
            text: qsTr("1")
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Bold
            font.bold: true
            font.family: "Mulish"
            onEditingFinished: {
                discreteOutSequenceModel.updateDelayDiscrete(parseInt(delayDiscrete.text))
                typeCar.currentIndex = 0
            }

        }

        Rectangle {
            x: 0
            y: 369
            width: 222
            height: 1
            color: "#dfe0eb"
            border.color: "#dfe0eb"
        }

        Text {
            id: resetButton
            x: 82
            y: 391
            color: "#3751ff"
            text: qsTr("сбросить")
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    discreteOutSequenceModel.clearModel(parseInt(countRows.text), parseInt(delayDiscrete.text))
                    typeCar.currentIndex = 0
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









/*##^##
Designer {
    D{i:0;formeditorZoom:1.5}
}
##^##*/
