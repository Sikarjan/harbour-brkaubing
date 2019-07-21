import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage
import "../js/parser.js" as Parser

Page {
    id: page
    property string response

    Component.onCompleted: {
        Storage.initialize();
        Parser.post('task=7&hash='+Storage.getSetting("hash")+'&refId='+dienstID+'&typeId='+typeID)
        loader.running = true
    }

    onResponseChanged: {
        if(response == ''){
            errorText.text = 'Beim Laden der Daten ist ein Fehler aufgetreten.'
            return 0
        }

        var resp = JSON.parse(response);
        loader.running = false

        if(resp.status === "error"){
            errorText.text = resp.data
        }else{
            statTable.text = "<style>table {width: "+ parent.width +"; color:"+ Theme.highlightColor +" } td, th {padding: 0 " + Theme.paddingSmall +"}</style>" + resp.data
        }
    }

    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        contentHeight: statTable.height
        VerticalScrollDecorator { flickable: canvas }

        PageHeader {
            id: header
            title: "Deine Statistik"
        }

        Text {
            id: statTable
            anchors.top: header.bottom
            textFormat: Text.RichText
            width: parent.width
            height: contentHeight
        }

// Neu mit Tabelle!
/*
        SilicaListView {
            id: content
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: Theme.itemSizeSmall * statList.count
            spacing: 0

            header: PageHeader {
                id: header
                title: "Deine Statistik"
            }

            model: statList

            delegate: ListItem {
                property int lWidth: parent.width*0.2 - 4 - Theme.paddingMedium
                Row {
                    width: parent.width
                    spacing: Theme.paddingMedium

                    Label {
                        text: year
                        width: lWidth
                    }
                    Rectangle {
                      height: parent.height
                      width: 1
                      color: Theme.highlightColor
                    }
                    Label {
                        text: san
                        width: lWidth
                    }
                    Label {
                        text: hvo
                        width: lWidth
                    }
                    Label {
                        text: sonst
                        width: lWidth
                    }
                    Label {
                        text: sum
                    }
                }
            }

//            section.property: "rank"
//            section.criteria: ViewSection.FullString
//            section.delegate: sectionHeading
        }
/*
        Component {
            id: sectionHeading
            Rectangle {
                width: canvas.width
                height: sectionHead.height + Theme.paddingMedium
                x: Theme.horizontalPageMargin*-1
                color: Theme.highlightBackgroundColor

                Text {
                    id: sectionHead
                    text: section
                    font.bold: true
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
*/
        // Lade Anzeige
        BusyIndicator {
            id: loader
            anchors.horizontalCenter: parent.horizontalCenter
            running: errorText === '';
            size: BusyIndicatorSize.Large
            visible: loader.running
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.WordWrap
        }
    }
}
