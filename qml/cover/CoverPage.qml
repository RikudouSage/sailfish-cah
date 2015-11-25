import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        source: "../img/cover.png"
        property real widthh: parent.height / 501 * 172
        width: widthh
        height: parent.height
    }
}


