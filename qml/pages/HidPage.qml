import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage
import "../js/parser.js" as Parser

Page {
    id: page
    property string response
    property string helferName

    Component.onCompleted: {
        Storage.initialize();
        Parser.post('task=4&hash='+Storage.getSetting("hash")+'&hid='+hid)
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

        if(resp.status === 'error'){
            errorText.text = resp.err
        }else{
            helferName = data.Nachname+', '+data.Vorname
            Parser.readHidList(data)
            console.log(hidList.count)
        }
    }

    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        contentHeight: hidList.count === 0 ? parent.height:content.height
        VerticalScrollDecorator { flickable: canvas }

        SilicaListView {
            id: content
            x: Theme.paddingSmall
            width: parent.width - x*2
            height: Theme.itemSizeMedium * hidList.count
            spacing: Theme.paddingSmall

            header: PageHeader {
                id: header
                title: helferName
            }

            model: hidList

            delegate: ListItem {
                contentHeight: Theme.itemSizeSmall

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            text: "Zwischenablage"
                            onClicked: Clipboard.text = value
                        }
                    }
                }

                Label {
                    id: keyLabel
                    width: parent.width/3
                    height: Theme.itemSizeSmall
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true

                    text: key
                }
                Label {
                    anchors.top: keyLabel.top
                    anchors.left: keyLabel.right
                    width: parent.width/3*2
                    wrapMode: Text.WordWrap

                    text: value
                }
            }
        }

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
            anchors.centerIn: parent
            x: Theme.paddingSmall
            width: parent.width - 2*x
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.secondaryHighlightColor
            wrapMode: Text.WordWrap
        }
    }
}
