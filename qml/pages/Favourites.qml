import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.Landscape
    property int f_width: page.orientation == Orientation.Portrait?screen.width:screen.height
    property string user_id
    property var jsondata: false


    Column {
        Label {
            visible: false
            text: qsTr("Loaded")
        }
    }


    Timer {
        id: maintimer
        running: true
        interval: 500
        onTriggered: {
            if(jsondata) {
                maintimer.running = false;
            }
        }
    }

    Component.onCompleted: {
        function load() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET","http://cah.chrastecky.cz/favorites/",true);
            xhr.onreadystatechange = function() {
                if(xhr.readyState == xhr.DONE) {
                    jsondata = xhr.responseText;
                }
            }
            xhr.send();
        }
    }
}
