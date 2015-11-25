import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property int f_width: screen.width
    Column {
        PageHeader {
            title: qsTr("Error")
        }
        Label {
            text: qsTr("Unknown error occured, please contact author")
            width: f_width
        }
    }
}
