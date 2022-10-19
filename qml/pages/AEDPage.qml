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

    Component.onCompleted: {
        Storage.initialize();
        hash = Storage.getSetting("hash")
        Parser.post('task=9&hash='+ hash)
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

        if(resp.status === "aedPlan"){
            data = resp.data
//console.log(JSON.stringify(data, 0, 2));
            Parser.readAedPlan(data)
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

        contentHeight: aedPlan.count === 0 ? page.height:header.height+content.height+aedPlanview.height
        VerticalScrollDecorator { flickable: canvas }

        PushUpMenu {
            visible: loggedIn
            MenuItem {
                text: "Aktualisieren"
                onClicked: {
                    errorText.text = ""
                    loader.running = true
                    Parser.post("task=9&hash="+hash)
                }
            }
        }

        PageHeader {
            id: header
            title: "AED Prüfungsplan"
        }

        Column {
            id: content
            visible: aedPlan.count > 0
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            spacing: Theme.paddingLarge
            anchors.top: header.bottom

            Label {
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Die Prüfung dauert 30 Minuten und findet im BRK Haus Aubing statt."
            }
        }

        SilicaListView {
            id: aedPlanview
            anchors.top: content.bottom
            visible: aedPlan.count > 0
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: Theme.itemSizeLarge * aedPlan.count
            spacing: Theme.paddingSmall
            clip: true

            model: aedPlan

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

                    text: date+" - Prüfer: "+trainer
                }
                Text {
                    id: shiftNote
                    anchors.top:  shift.bottom
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    wrapMode: Text.Wrap

                    text: helfer1+" | "+helfer2
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
                    typeID = 22
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
