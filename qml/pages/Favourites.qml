import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.Landscape
    property int f_width: screen.height
    property string user_id
    property var jsondata: false
    property int button_height: 70
    width: f_width

    anchors.fill: parent
    function db() {
        var db = LocalStorage.openDatabaseSync("CaHDB","1.0","Database for users", 1000000);
        return db;
    }

    SilicaFlickable {
        id: flickable
        contentHeight: maincolumn.height
        height: page.height

        Column {
            id: maincolumn
            width: f_width

            PageHeader {
                id: header
                title: qsTr("Favorite comics")
            }

            Label {
                id: infolabel
                visible: true
                text: qsTr("Loading")
                width: parent.width - 40
                x: 20
                wrapMode: Text.Wrap
            }

            ListModel {
                id: lmodel
            }



            ListView {
                anchors.top: infolabel.bottom
                id: listview
                model: lmodel
                height: 100
                delegate: Button {
                    height: button_height
                    width: f_width
                    text: mtext
                    onClicked: {
                        db().transaction(function(tx) {
                            tx.executeSql("INSERT INTO current_favorite (pic_id) VALUES ("+mid+")");
                            pageStack.pop();
                        });
                    }
                }
            }

            Item {
                width: f_width
                height: 50
            }
        }

        Component.onCompleted: {
            infolabel.text = qsTr("Loading user info");
            db().transaction(function(tx) {
                var res = tx.executeSql("SELECT user_id FROM user");
                user_id = res.rows.item(0).user_id;
                function load() {
                    var xhr = new XMLHttpRequest();
                    var params = "user_id="+user_id;
                    xhr.open("POST","http://cah.chrastecky.cz/favorites/",true);
                    xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
                    xhr.setRequestHeader("Content-length", params.length);
                    xhr.setRequestHeader("Connection", "close");
                    xhr.onreadystatechange = function() {
                        if(xhr.readyState == xhr.DONE) {
                            var answer = xhr.responseText;
                            if(answer == "err_id") {
                                infolabel.text = qsTr("Error: ID does not exist");
                            } else if(answer == "err_no_pictures") {
                                infolabel.text = qsTr("It seems that you did not add any favorite images.")
                            } else {
                                jsondata = answer;
                                infolabel.visible = false;
                                console.log(jsondata);
                                var json_o = JSON.parse(jsondata);
                                for(var i = 0; i < json_o.length; i++) {
                                    console.log(json_o[i]);
                                    lmodel.append({mtext: json_o[i]["desc"], mid: json_o[i]["id"]});
                                    console.log(lmodel.count);
                                }
                                listview.height = i*70;
                                console.log(listview.height,page.height,flickable.height,maincolumn.height);
                            }
                        }
                    };
                    xhr.send(params);
                }
                load();
            });
        }
    }
}
