import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    id: addfavourite

    property int f_width: screen.height
    property int pic_id

    allowedOrientations: Orientation.Landscape

    property string description

    Column {
        spacing: Theme.paddingLarge
        width: registerpage.width
        anchors.fill: parent

        DialogHeader {
            id: dialogheader
            acceptText: qsTr("Save")
            cancelText: qsTr("Cancel")
        }
        TextField {
            id: descriptionText
            width: parent.width
            placeholderText: qsTr("Description")
            text: pic_id
        }
    }
    onDone: {
        if(result == DialogResult.Accepted) {
            description = descriptionText.text;
        }
    }
}




