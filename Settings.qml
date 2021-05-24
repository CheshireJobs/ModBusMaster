import QtQuick 2.0
import QtQuick.Controls 2.5

Item {
    id: settingsTime
    anchors.fill: parent

    RoundButton {
        anchors.centerIn: parent.Center
        width: 60
        height: 60
        text: "set"
        onClicked: hndl.setTime()
    }

}
