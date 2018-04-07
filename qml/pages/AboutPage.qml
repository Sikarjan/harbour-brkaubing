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
                text: "Version 1.0.0\nKontakt: Admin@brk-aubing.de"
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
