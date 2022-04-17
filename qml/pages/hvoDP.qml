import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import Nemo.Notifications 1.0
import "../js/storage.js" as Storage
import "../js/parser.js" as Parser

Page {
    id: page
    property string response
    property string hash: ''
    property int sort: 1

    Component.onCompleted: {
        Storage.initialize();
        hash = Storage.getSetting("hash")
        Parser.post('task=8&hash='+ hash)
        loader.running = true
    }

    onResponseChanged: {
        loader.running = false
        if(response == ''){
            errorText.text = 'Beim Laden der Daten ist ein Fehler aufgetreten.'
            return 0
        }
//console.log(response)
        var resp = JSON.parse(response);
        var data = ''

        if(resp.status === "hvoDP"){
            data = resp.data
//console.log(JSON.stringify(data, 0, 2));
            Parser.readHvoDP(data)
        }else{
            errorText.text = resp.err;
        }
    }

    Notification {
         id: notification
         category: "x-nemo.example"
     }

    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        contentHeight: hvoDP.count === 0 ? page.height:header.height+content.height+hvoDPview.height
        VerticalScrollDecorator { flickable: canvas }

        PullDownMenu {
            MenuItem {
                text: "Letzter Monat"
                visible: sort != 3
                onClicked: {
                    sort = 3
                    Parser.post('task=8&hash='+hash+'&&sort=3')
                }
            }
            MenuItem {
                text: "Kommende"
                visible: sort != 2
                onClicked: {
                    sort = 2
                    Parser.post('task=8&hash='+hash+'&&sort=2')
                }
            }
            MenuItem {
                text: "Aktuell"
                visible: sort != 1
                onClicked: {
                    sort = 1
                    Parser.post('task=8&hash='+hash+'&&sort=1')
                }
            }
        }

        PageHeader {
            id: header
            title: "HvO Dienstplan"
        }

        Column {
            id: content
            visible: hvoDP.count > 0
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            spacing: Theme.paddingLarge
            anchors.top: header.bottom

            Label {
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                width: parent.width
                wrapMode: Text.WordWrap
                text: "FS: 08:00 bis 15:00<br>SS: 15:00 bis 22:00<br>ZS: nach Angabe"
            }
        }

        SilicaListView {
            id: hvoDPview
            anchors.top: content.bottom
            visible: hvoDP.count > 0
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: Theme.itemSizeLarge * hvoDP.count
            spacing: Theme.paddingSmall
            clip: true

            model: hvoDP

            delegate: ListItem {
                id: listItem
                width: parent.width
                contentHeight: shift.height + shiftNote.height + Theme.paddingSmall

                Text {
                    id: shift
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: Text.Wrap

                    text: (date === '' ? '':date+': ') +type
                }
                Text {
                    id: shiftNote
                    anchors.top:  shift.bottom
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    wrapMode: Text.Wrap

                    text: helfer+(note ===''? '':'<br>'+note)
                }
                Rectangle {
                    anchors.top: shiftNote.bottom
                    anchors.topMargin: 2
                    width: page.width
                    height: 2
                    color: Theme.secondaryColor
                }

                onClicked: {
                    dienstID = refId
                    typeID = 2
                    pageStack.push(Qt.resolvedUrl("DienstPage.qml"))
                }
            }
        }
        // Lade Anzeige
        BusyIndicator {
            id: loader
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom;
            running: true;
            size: BusyIndicatorSize.Large
            visible: loader.running
        }

        Text {
            id: errorText
            anchors.centerIn: parent
            width: parent.width - 2*Theme.paddingMedium
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.WordWrap
        }
    }
}
