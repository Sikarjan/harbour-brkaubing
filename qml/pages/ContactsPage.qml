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
        Parser.post('task=5&hash='+Storage.getSetting("hash"))
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
            Parser.readContactsList(data)
        }
    }

    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        contentHeight: content.height
        VerticalScrollDecorator { flickable: canvas }

        SilicaListView {
            id: content
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: Theme.itemSizeSmall * contactsList.count
            spacing: Theme.paddingSmall

            header: PageHeader {
                id: header
                title: "Telefonliste"
            }

            model: contactsList

            delegate: ListItem {
                Label {
                    id: nameLabel
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    color: content.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: Text.WordWrap

                    text: name
                }
                Label {
                    anchors.top: nameLabel.bottom
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor

                    text: edu
                }

                onClicked: {
                    hid = helfer
                    pageStack.push(Qt.resolvedUrl("HidPage.qml"))
                }
            }

            section.property: "rank"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading
        }
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
