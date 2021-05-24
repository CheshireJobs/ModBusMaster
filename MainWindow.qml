import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: mainWindow

    visible: true
    width: 1630
    height: 930

    property alias currentIndex: listViewLeftPanel.currentIndex

    MessageDialog {
        id: messageDialogClose
        title: "Error"
        visible: false
        text: "Тестирование не окончено"

        onAccepted: {
        }
    }

    onClosing: {
        if(hndl.discreteState) {
            close.accepted = false
            messageDialogClose.visible = true
        }
    }

    Component.onCompleted: {
        loader.source = padgdesListModel.get(currentIndex).component
    }

    MessageDialog {
        id: messageDialog
        title: "Error"
        visible: false
        text: "Устройство не подключено."
        onAccepted: {
        }
    }

Item {
    anchors.fill: parent
    anchors.rightMargin: 0
    anchors.bottomMargin: 0
    anchors.leftMargin: 0
    anchors.topMargin: 0

    Rectangle {
        id: windowArea
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        color: "#363740"

        Rectangle {
            id: leftPanel
            width: 220
            height: parent.height
            anchors.top: parent.top
            color: "transparent"

            Item {
                id: logo
                width: parent.width
                height: 100
                anchors.top: parent.top
//                color: "transparent"

                Image {
                    id: imageLogo
                    height: 100
                    width: 207
                    source: "logo"
                    anchors.verticalCenterOffset: 0
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 7
                }
            }

            ListView {
                id: listViewLeftPanel
                anchors.top: logo.bottom
                width: parent.width
                height: 300
                interactive: false
                delegate:  Rectangle {
                    id: elementList
                    width: parent.width
                    height: 60
//                    enabled:  //padgdesListModel.get(index).enabled
                    color:  ListView.isCurrentItem? "#40414d" : "#363740"

                    Image {
                        id: image
                        height: 16
                        width: 16
                        source: icon
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                     }

                    Text {
                        text: name
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        anchors.left: image.right
                        anchors.leftMargin: 15
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        color: elementList.ListView.isCurrentItem? "#DDE2FF" : "#A4A6B3"
                        font.pixelSize: 16
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.family: "Mulish"
                    }

                    MouseArea {
                        property bool flag: false
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            listViewLeftPanel.currentIndex = index
                            if (index !== 0) {
                                if( !hndl.getState()) {
                                    messageDialog.visible = true;
                                    listViewLeftPanel.currentIndex = 0;
                                }
                            }
                            loader.source = padgdesListModel.get(currentIndex).component

                        }
                        onEntered: {
                            cursorShape = Qt.PointingHandCursor
                            elementList.opacity = 0.9
                        }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                            elementList.opacity = 1
                        }
                    }
                }

                model: ListModel {
                    id: padgdesListModel

                    ListElement {
                        icon: "device.png"
                        name: "Подключение устройства"
                        component: "DevicePage.qml"
                        enabled: true
                    }                   
                    ListElement {
                        icon: "custom.png"
                        name: "Настраиваемое тестирование"
                        component: "CustomTestPage.qml"
                        enabled: true
                    }
                    ListElement {
                        icon:"auto.png"
                        name: "Автоматическое тестирование"
                        component: "AutoTestPage.qml"
                        enabled: true
                    }
                    ListElement {
                        icon: "settings.png"
                        name: "Настройки"
                        component: "SettingsPage.qml"
                        enabled: true
                    }
                    ListElement {
                        icon: "obmen.png"
                        name: "Данные обмена"
                        component: "Log.qml"
                        enabled: true
                    }
                }
            }
        }

        Item {
            id: workArea
            width: parent.width - leftPanel.width
            height: parent.height
            anchors.top: parent.top
            anchors.left: leftPanel.right
//            color: "transparent"

            Loader {
                id: loader
//                asynchronous: true
                width: parent.width
                height: parent.height
            }
        }
    }
}
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.25;height:930;width:1630}
}
##^##*/
