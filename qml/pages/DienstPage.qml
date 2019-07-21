import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import Nemo.Notifications 1.0
import "../js/storage.js" as Storage
import "../js/parser.js" as Parser

Page {
    id: page
    property string response

    Component.onCompleted: {
        Storage.initialize();
        Parser.post('task=3&hash='+Storage.getSetting("hash")+'&refId='+dienstID+'&typeId='+typeID)
        loader.running = true
    }

    onResponseChanged: {
        if(response == ''){
            errorText.text = 'Beim Laden der Daten ist ein Fehler aufgetreten.'
            return 0
        }

        var resp = JSON.parse(response);
        var data = ''

        if(resp.status === "sandienst"){
            data = resp.data
            loader.running = false
            heading.text = data[0].dienst
            place.text = "Ort: "+data[0].ort
            time.text = 'Zeit: '+ Qt.formatDateTime(new Date(data[0].datum*1000),"dd.MM.yyyy - hh:mm" ) + ' bis ' + Qt.formatDateTime(new Date(data[0].ende*1000),"hh:mm" )
            note.text = data[0].anmerkung

            Parser.readHelferList(data)
        }else if(resp.status === "eintragen"){
            if(typeof resp.err === 'undefined'){
                data = resp.data
                notification.summary = "Erfolgreich eingetragen"
                notification.body = data.msg

                helferList.set(data.pos, {"helfer": hid, "name": firstName})
            }else{
                notification.summary = "Fehler beim Eintragen"
                notification.body = resp.err
            }
            notification.previewSummary = notification.summary
            notification.previewBody = notification.body
            notification.publish()
        }
    }

    Notification {
         id: notification
         category: "x-nemo.example"
     }

    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        contentHeight: helferList.count === 0 ? page.height:header.height+content.height+helferView.height
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
                width: parent.width
                wrapMode: Text.WordWrap
            }
            Label {
                id: place
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                wrapMode: Text.WordWrap
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
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
            }

            Label {
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                y: Theme.paddingLarge

                text: "Helfer:"
            }


        }
        SilicaListView {
            id: helferView
            anchors.top: content.bottom
            visible: helferList.count > 0
            width: canvas.width
            height: Theme.itemSizeLarge * helferList.count
            spacing: Theme.paddingSmall

            model: helferList

            delegate: ListItem {
                id: helferItem
                width: canvas.width
                contentHeight: nameItem.height + posItem.height + (comItem.text == '' ? 0:comItem.contentHeight)

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            text: "Eintragen"
                            visible: typeID == -1 && helfer < 1
                            onClicked: eintragen()
                        }
                    }
                }

                RemorseItem { id: remorse }

                 function eintragen() {
                     remorseAction("Eintragen abbrechen", function(){
                         Parser.post('task=6&hash='+Storage.getSetting("hash")+'&refId='+dienstID+'&typeId='+typeID+'&role='+pos+'&pos='+(index+1))
                     });
                 }


                Text {
                    id: nameItem
                    width: content.width
                    x: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeMedium
                    color: helferView.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: Text.WordWrap

                    text: name
                }
                Label {
                    id: posItem
                    anchors.top:  nameItem.bottom
                    anchors.left: nameItem.left
                    font.pixelSize: Theme.fontSizeSmall
                    color: helferView.highlighted ? Theme.highlightColor : Theme.secondaryColor

                    text: pos+' | Anwesend: '+start+' - '+ende
                }
                Text {
                    id: comItem
                    anchors.top:  posItem.bottom
                    anchors.left: posItem.left
                    font.pixelSize: Theme.fontSizeSmall
                    width: nameItem.width
                    color: Theme.secondaryHighlightColor
                    wrapMode: Text.WordWrap

                    text: anmerkung
                }

                onClicked: {
                    if(helfer > 0){
                        hid = helfer
                        pageStack.push(Qt.resolvedUrl("HidPage.qml"))
                    }
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
            anchors.centerIn: parent
            anchors.top: header.bottom;
            x: Theme.paddingSmall
            width: parent.width - 2*x
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.WordWrap
        }
    }
}
