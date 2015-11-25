import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    id: registerpage

    property int f_width: screen.height

    allowedOrientations: Orientation.Landscape

    property string username
    property string password
    property bool login: false // zda se jedná o login nebo registraci

    visible: false
    function db() {
        var db = LocalStorage.openDatabaseSync("CaHDB","1.0","Database for users", 1000000);
        return db;
    }

    Column {
        spacing: Theme.paddingLarge
        width: registerpage.width
        anchors.fill: parent

        DialogHeader {
            id: dialogheader
            acceptText: qsTr("Register")
            cancelText: qsTr("Cancel")
        }
        TextField {
            id: usernameField
            width: parent.width
            placeholderText: qsTr("Username")
        }
        TextField {
            id: passwordField
            width: parent.width
            echoMode: TextInput.Password
            placeholderText: qsTr("Password")
        }
        Button {
            text: qsTr("Already registered? Log in here")
            width: f_width
            onClicked: {
                visible = false;
                login = true;
                dialogheader.acceptText = qsTr("Login");
            }
        }
    }
    onDone: {
        if(result == DialogResult.Accepted) {
            username = usernameField.text;
            password = passwordField.text;
        }
    }
}




