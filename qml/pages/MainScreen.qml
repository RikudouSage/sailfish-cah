import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    property int f_width: screen.height

    property string jsondata: "" // drží v sobě json string z webu
    property variant json_o: "" // placeholder pro json object
    property string pic_id: "" // drží v sobě id obrázku (nebo random)
    property string video_url: "" // pokud existuje, má v sobě url videa
    property bool user_registered: false // zda je uživatel přihlášen
    property string username: "" // uživatelské jméno
    property string password: "" // heslo
    property string comic_id // ID současného komiksu
    property string user_id // ID uživatele
    property string delegated_id // ID z oblíbených

    allowedOrientations: Orientation.Landscape
    id: page

    function load() { // funkce asynchronně vezme data z webu a přiřadí je
        playbutton.visible = false;
        checktimer.running = true;
        flickabletop.contentY = 0;
        mainimage.opacity = 0;
        loadinglabel.visible = true;
        var xhr = new XMLHttpRequest();
        xhr.open("GET","http://cah.chrastecky.cz/"+pic_id,true);
        xhr.onreadystatechange = function() {
            if(xhr.readyState == xhr.DONE) {
                jsondata = xhr.responseText;
            }
        }
        xhr.send();
    }
    /**
     * Vytvoří připojení k lokální databázi
     */
    function db() {
        var db = LocalStorage.openDatabaseSync("CaHDB","1.0","Database for users", 1000000);
        return db;
    }

    function add_to_favourites() {

        var dialog = pageStack.push("AddFavouriteDialog.qml", {"pic_id": comic_id});
        dialog.accepted.connect(function() {
            var description = dialog.description;
            var xhr = new XMLHttpRequest();
            var params = "user_id="+user_id+"&comic_id="+comic_id+"&description="+description;
            xhr.open("POST","http://cah.chrastecky.cz/add-to-favourites/",true);
            xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
            xhr.setRequestHeader("Content-length", params.length);
            xhr.setRequestHeader("Connection", "close");
            xhr.onreadystatechange = function() {
                if(xhr.readyState == xhr.DONE) {
                    var answer = xhr.responseText;
                    console.log(answer);
                    if(answer == "err_unknown" || answer == "err_mysqli") {
                        errorlabel.visible = true;
                        errortimer.running = true;
                        errorlabel.text = qsTr("Unknown error occured, please contact author.");
                    } else if(answer == "err_id") {
                        errorlabel.visible = true;
                        errortimer.running = true;
                        errorlabel.text = qsTr("Error: This ID does not exist.");
                        db().transaction(function(tx) {
                            tx.executeSql("DELETE FROM user");
                            user_registered = false;
                        });
                    } else if(answer == "err_already_exists") {
                        errorlabel.visible = true;
                        errortimer.running = true;
                        errorlabel.text = qsTr("You have already added this comic to favourites before.");
                    } else {
                        errorlabel.visible = true;
                        errortimer.running = true;
                        errorlabel.text = qsTr("Successfully added to your favourites :)");
                    }
                }
            }
            xhr.send(params);
        });
    }

    SilicaFlickable {
        id: flickabletop
        anchors.fill: parent

        PullDownMenu {
            width: f_width

            MenuItem {
                id: favouritespull
                text: qsTr("Favorites")
                visible: false
                onClicked: {
                    if(user_registered) {
                        pageStack.push("Favourites.qml");
                    } else {
                        var dialog = pageStack.push("RegisterDialog.qml", {"username": "", "password": "", "login": false});
                        dialog.accepted.connect(function() {
                            var regUsername = dialog.username;
                            var regPassword = dialog.password;
                            var login = dialog.login;
                            console.log(regUsername,regPassword,login);

                            var xhr = new XMLHttpRequest();
                            var params = "username="+regUsername+"&password="+Qt.md5(regPassword);

                            if(login) {
                                var url = "http://cah.chrastecky.cz/check-login/";
                            } else {
                                var url = "http://cah.chrastecky.cz/register/";
                            }
                            console.log(url);
                            console.log(params);
                            xhr.open("POST",url,true);
                            xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
                            xhr.setRequestHeader("Content-length", params.length);
                            xhr.setRequestHeader("Connection", "close");
                            xhr.onreadystatechange = function() {
                                if(xhr.readyState == xhr.DONE) {
                                    var answer = xhr.responseText;
                                    console.log(answer);
                                    if(answer == "err") {
                                        errorlabel.visible = true;
                                        errortimer.running = true;
                                        errorlabel.text = qsTr("Unknown error occured, please contact author.");
                                    } else if(answer == "err_registered") {
                                        errorlabel.visible = true;
                                        errortimer.running = true;
                                        errorlabel.text = qsTr("We're sorry, this username already exists. Try different one.");
                                    } else if(answer == "err_login") {
                                        errorlabel.visible = true;
                                        errortimer.running = true;
                                        errorlabel.text = qsTr("Sorry, incorrect password or username.");
                                    } else {
                                        db().transaction(function(tx) {
                                            tx.executeSql("INSERT INTO user (user_id,username,password) VALUES (?,?,?)",[answer,regUsername,regPassword]);
                                            user_id = answer;
                                        });
                                        user_registered = true;
                                        errorlabel.visible = true;
                                        errortimer.running = true;
                                        errorlabel.text = qsTr("Successfully logged in, you can now save favourites.");
                                    }
                                }
                            }
                            xhr.send(params);
                        });
                    }
                }
            }

            MenuItem {
                id: addtofavourites
                visible: user_registered
                text: qsTr("Add to favorites")
                onClicked: {
                    add_to_favourites();
                }
            }

            MenuItem {
                id: random1
                text: qsTr("Random")
                enabled: ping.networkAccessible()
                onClicked: {
                    pic_id = "random"
                    load()
                }
            }

            MenuItem {
                enabled: json_o.next?true:false
                text: qsTr("Next")
                onClicked: {
                    pic_id = json_o.next;
                    load();
                }
            }
        }

        PushUpMenu {
            width: f_width
            MenuItem {
                enabled: json_o.prev?true:false
                text: qsTr("Previous")
                onClicked: {
                    pic_id = json_o.prev;
                    load();
                }
            }
            MenuItem {
                id: random2
                text: qsTr("Random")
                enabled: ping.networkAccessible()
                onClicked: {
                    pic_id = "random"
                    load()
                }
            }
            MenuItem {
                id: addtofavourites2
                visible: user_registered
                text: qsTr("Add to favourites")
                onClicked: {
                    add_to_favourites();
                }
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Cyanide & Happiness")
            }

            Label {
                id: errorlabel
                visible: false
                text: "Error"
                wrapMode: Text.Wrap
                width: f_width
            }

            Timer {
                id: errortimer
                interval: 9000
                running: false
                onTriggered: {
                    errortimer.running = false;
                    errorlabel.visible = false;
                }
            }

            Label {
                id: loadinglabel
                text: qsTr("Loading...")
                width: f_width
                horizontalAlignment: Text.AlignHCenter
            }
            Image {
                id: mainimage
                //visible: false
                opacity: 0;
                source: ""
                fillMode: Image.PreserveAspectFit
                width: column.width;
                z: 10
                //anchors.bottomMargin: 30
                PinchArea {
                    id: imagepinch
                    width: mainimage.width
                    height: mainimage.height
                    pinch.target: mainimage
                    pinch.minimumScale: 1.0
                    pinch.maximumScale: 5.0
                    pinch.dragAxis: Pinch.XAndYAxis
                    anchors.fill: parent
                    z: 20
                    onPinchStarted: {
                        console.log("started");
                    }
                    onPinchUpdated: {
                        console.log(pinch);
                    }
                }
                MouseArea {
                    id: playbutton
                    width: 50
                    height: 50
                    anchors.fill: parent
                    visible: false
                    onClicked: {
                        Qt.openUrlExternally(json_o.videolink);
                    }

                    Image {
                        id: playbuttonimage
                        source: "../img/play-button.png"
                        //visible: false
                        width: 200
                        height: 200
                        z: 30
                        x: mainimage.width / 2 - 100
                        y: mainimage.height / 2 - 100
                    }
                }
            }

            Item {
                width: f_width
                height: 50
            }

            Timer {
                id: checktimer
                interval: 1000
                running: false
                repeat: true
                onTriggered: {
                    if(jsondata) {
                        checktimer.running = false;
                        loadinglabel.visible = false;
                        json_o = JSON.parse(jsondata);
                        console.log(jsondata);
                        jsondata = "";
                        mainimage.source = json_o.src;
                        flickabletop.contentY = 0;
                        //mainimage.visible = true;
                        mainimage.opacity = 1;
                        comic_id = json_o.id;
                        imagepinch.height = mainimage.height;
                        var koef = mainimage.width / json_o.width;
                        var h = koef * json_o.height;
                        mainimage.height = h;
                        imagepinch.height = h;
                        if(json_o.videolink) {
                            playbutton.visible = true;
                            video_url = json_o.videolink;
                        }
                    }
                }
            }

            Timer {
                id: checkconnection
                interval: 1000
                running: false
                repeat: true
                onTriggered:  {
                    if(ping.networkAccessible() && (!random1.enabled || !random2.enabled)) {
                        random1.enabled = true;
                        random2.enabled = true;
                        loadinglabel.text = qsTr("Loading...");
                        load();
                    } else if(!ping.networkAccessible() && (random1.enabled || random2.enabled)) {
                        random1.enabled = false;
                        random2.enabled = false;
                        loadinglabel.text = qsTr("Oops, it looks like you are not connected to internet :(");
                    }
                }
            }

            Timer {
                id: currfavorite
                interval: 500
                running: true
                repeat: true
                onTriggered: {
                    db().transaction(function(tx) {
                        var res = tx.executeSql("SELECT pic_id FROM current_favorite");
                        if(res.rows.length) {
                            currfavorite.running = false;
                            pic_id = res.rows.item(0).pic_id;
                            tx.executeSql("DELETE FROM current_favorite");
                            load();
                            currfavorite.running = true;
                        }
                    });
                }
            }

            Component.onCompleted: {
                db().transaction(function(tx) {
                    //tx.executeSql("DROP TABLE IF EXISTS user");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS user (user_id INT, username TEXT, password TEXT)");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS current_favorite (pic_id INT)");
                    var already_exists = tx.executeSql('SELECT * FROM user');
                    if(already_exists.rows.length) {
                        user_registered = true;
                        username = already_exists.rows.item(0).username;
                        password = already_exists.rows.item(0).password;
                        user_id = already_exists.rows.item(0).user_id;
                        console.log("already exists");
                    }
                    favouritespull.visible = true;
                });
                if(!ping.networkAccessible()) {
                    loadinglabel.text = qsTr("Oops, it looks like you are not connected to internet :(");
                    checkconnection.running = true;
                } else {
                    load();
                }
            }
        }
    }
}
