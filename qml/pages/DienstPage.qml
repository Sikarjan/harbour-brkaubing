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
        Parser.post('task=3&hash='+Storage.getSetting("hash")+'&refId='+dienstID)
        loader.running = true
    }

    onResponseChanged: {
        if(response == ''){
            errorText.text = 'Beim Laden der Daten ist ein Fehler aufgetreten.'
            return 0
        }

        var resp = JSON.parse(response);
        var data = resp.data

        loader.running = false
        heading.text = data[0].dienst
        place.text = "Ort: "+data[0].ort
        time.text = 'Zeit: '+ Qt.formatDateTime(new Date(data[0].datum*1000),"dd.MM.yyyy - hh:mm" ) + ' bis ' + Qt.formatDateTime(new Date(data[0].ende*1000),"hh:mm" )
        note.text = data[0].anmerkung

        Parser.readHelferList(data)
    }

    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        contentHeight: header.height+content.height
        VerticalScrollDecorator { flickable: canvas }

        PageHeader {
            id: header
            title: "Dienstdetails"
        }

        Column {
            id: content
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            spacing: Theme.paddingLarge
            anchors.top: header.bottom

            Label {
                id: heading
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }
            Label {
                id: place
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Label {
                id: time
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Text {
                id: note
                width: parent.width
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
            }

            SilicaListView {
                id: helferView
                visible: helferList.count > 0
                width: parent.width
                height: Theme.itemSizeMedium * helferList.count
                spacing: Theme.paddingSmall

                model: helferList

                delegate: ListItem {
                    width: content.width
                    height: Theme.itemSizeMedium

                    Text {
                        id: nameItem
                        width: parent.width
                        font.pixelSize: Theme.fontSizeMedium
                        color: helferView.highlighted ? Theme.highlightColor : Theme.primaryColor
                        wrapMode: Text.WordWrap

                        text: name
                    }
                    Label {
                        id: posItem
                        anchors.top:  nameItem.bottom
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryHighlightColor

                        text: pos+' | Anwesend: '+start+' - '+ende
                    }
                    Text {
                        anchors.top:  posItem.bottom
                        font.pixelSize: Theme.fontSizeSmall
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                        wrapMode: Text.WordWrap

                        text: anmerkung
                    }

                    onClicked: {
                        hid = helfer
                        pageStack.push(Qt.resolvedUrl("HidPage.qml"))
                    }
                }

                section.property: "type"
                section.criteria: ViewSection.FullString
                section.delegate: Label {
                    color: Theme.highlightColor
                    text: "Helfer"
                }
            }
        }

        // Lade Anzeige
        BusyIndicator {
            id: loader
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom;
            running: errorText === '';
            size: BusyIndicatorSize.Large
            visible: loader.running
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom;
            width: parent.width
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.WordWrap
        }
    }
}
