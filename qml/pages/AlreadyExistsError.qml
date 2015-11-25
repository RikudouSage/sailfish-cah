import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property int f_width: screen.width
    Column {
        PageHeader {
            title: qsTr("Error")
        }
        Label {
            text: qsTr("We're sorry, this username already exists :( Try different one")
            width: f_width
        }
    }
}
