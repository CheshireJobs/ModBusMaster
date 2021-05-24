import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id: logItem
    width: parent.width
    height: parent.height
    visible: true
    color: "#F7F8FC"

    ListView {
        id: logsView
        width: parent.width - 20
        height: parent.height
        ScrollBar.vertical: ScrollBar{ policy: "AlwaysOn"}

        model:log.logs.isEmpty? 0 : log.logs
        delegate:
            TextArea {
                id: dataLog
                width: parent.width
                height: 30
                text: modelData.value
                enabled: false
                font.pixelSize: 14
                wrapMode:Text.WrapAnywhere
                color: "#252733"
            }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.33;height:1000;width:1600}
}
##^##*/
