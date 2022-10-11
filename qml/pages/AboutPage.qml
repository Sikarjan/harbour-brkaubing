import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: column
            spacing: Theme.paddingLarge
            anchors {
                fill: parent
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("About BRK Aubing")
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                linkColor: Theme.primaryColor
                textFormat: Text.RichText
                text: "<html><style>a {color:"+ Theme.primaryColor +";}</style>Version 1.5.0<br>"+qsTr("Contact")+": <a href=\"mailto:Admin@brk-aubing.de\">Admin@brk-aubing.de</a><br>Homepage: <a href=\"https://brk-aubing.de\">brk-aubing.de</a></html>"
                onLinkActivated: Qt.openUrlExternally(link);
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                wrapMode: Text.WordWrap

                text: qsTr("This app is meant for people living in the west of Munich who are interested in the Red Cross Aubing activities. It downloads the BRK Aubing calendar to your phone and displays the next courses, gatherings and activities. If you want to visit us find us at Altostr. 16 Munich (Aubing)")
            }
        }
    }
}
