import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0

import harbour.brkaubing 1.0

Page {
    id: root
    property string dataURL: handler.filePath()
    property bool modelDataError: false
    property string statusMessage: ""
    property string filter: ""
    property var date : new Date()
    property int now: date.getTime()/1000 - 24*3600 // Termine die schon waren sollen nicht mehr angezeigt werden.
    property var event

    XmlListModel {
        id: planModel
        source: root.dataURL
        query: "/xml/termin"+filter
        XmlRole { name: "type"; query: "@type/number()" }
        XmlRole { name: "datum"; query: "datum/string()" }
        XmlRole { name: "art"; query: "art/string()" }
        XmlRole { name: "thema"; query: "thema/string()" }
        XmlRole { name: "anmerkung"; query: "anmerkung/string()"}

        onStatusChanged: {
            root.modelDataError = false
            if(status == XmlListModel.Error) {
                root.state = "Offline"
                root.statusMessage = "Ein Fehler ist aufgetreten: " + errorString()
                root.modelDataError = true
                //console.log("Terminplan: " + root.statusMessage)
            } else if (status == XmlListModel.Ready) {
                if(get(0) === undefined){
                    root.state = "Offline"
                    root.statusMessage = "Die lokalen Daten sind defekt. Bitte starten Sie die App neu."
                    handler.clear()
                    root.modelDataError = true
                } else {
                    root.state = "Online"
                    root.statusMessage = "Aktuelle Daten sind verfügbar. "+now
                }
 //               console.log("Terminpaln: "+root.statusMessage)
            } else if (status == XmlListModel.Loading){
                root.state = "Läd..."
                root.statusMessage = "Daten werden geladen."
            } else if(status == XmlListModel.Null) {
                root.state = "Loading"
                root.statusMessage = "Forecast data is empty..."
                //console.log("Terminplan: " + root.statusMessage)
            } else {
                root.modelDataError = fase
                //console.log("Terminplan: Unklarer Zustand der XML Datei: " + status)
            }
        }
    }

    TempFile {
        id: tempfile
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: planModel.status === XmlListModel.Loading
        size: BusyIndicatorSize.Large
    }

    SilicaListView {
        id: terminplaView
        anchors.fill: parent

        VerticalScrollDecorator { flickable: terminplaView}
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: "Nach Update suchen"
                onClicked: handler.load()
            }

            MenuItem {
                text: "Alle"
                visible: root.filter != ""
                onClicked: root.filter = ""
            }
            MenuItem {
                text: "HvO Supervisionen"
                visible: root.filter != "[@type='2']"
                onClicked: root.filter = "[@type='2']"
            }
            MenuItem {
                text: "Bereitschaftsabende"
                visible: root.filter != "[@type='0']"
                onClicked: root.filter = "[@type='0']"
            }
        }

        header: PageHeader {
            title: "Ausbildungsplan"
        }

        Column {
            id: column
            visible: root.modelDataError
            anchors.centerIn: parent
            height: labelWarning.height+textWarning.height+Theme.paddingLarge
            width: root.width-Theme.paddingLarge
            spacing: Theme.paddingLarge

            Label {
                id: labelWarning
                font.pixelSize: Theme.fontSizeMedium
                width: column.width
                color: Theme.highlightColor
                text: "Fehler"
            }
            Text {
                id: textWarning
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.primaryColor
                text: root.statusMessage
                wrapMode: Text.WordWrap
            }
        }

        model: planModel

        delegate: ListItem {
            id: dateItem
            menu: contextMenu
            contentHeight: labelArt.height + labelThema.height + (model.anmerkung !== "false" ? labelAnmerkung.height:0) +15
//            visible: isVisible(model.type)
            x: Theme.paddingMedium
/* Funktion funktioniert nicht!
            function isVisible(type){
                if(model.date < now){
                    return false
                }else if(type === 1 && !handler.showInternalDates){
                    dateItem.height = 0
                    return false
                }else{
                    return true
                }
            }*/

            Label {
                id: labelArt
                text: Qt.formatDateTime(new Date(model.datum*1000),"dd.MM.yyyy - hh:mm" ) + "  --  " +model.art
                font.pixelSize: Theme.fontSizeMedium
                font.bold: false
                color: Theme.secondaryColor
            }
            Text {
                id: labelThema
                text: model.thema
                font.pixelSize: Theme.fontSizeLargeBase
                color: Theme.primaryColor
                anchors.top: labelArt.bottom
                width: root.width - 2*Theme.paddingLarge
                wrapMode: Text.WordWrap
            }
            Text {
                id: labelAnmerkung
                visible: model.anmerkung !== "false"
                text: model.anmerkung
                font.pixelSize: Theme.fontSizeMedium
                font.bold: false
                color: Theme.secondaryColor
                width: root.width - 2*Theme.paddingLarge
                anchors.top: labelThema.bottom
                wrapMode: Text.WordWrap
            }

            Component {
                id: contextMenu

                ContextMenu {
                    MenuItem {
                        text: "Zum Kalender hinzufügen"
                        onClicked: {
                            var end = (Number(model.datum)+1.5*3600)*1000;
                            var event = [
                                        'BEGIN:VEVENT',
                                        'DTSTAMP:'+Qt.formatDateTime(new Date(),"yyyyMMddThhmmss"),
                                        'DTSTART:'+Qt.formatDateTime(new Date(model.datum*1000),"yyyyMMddThhmmss"),
                                        'DTEND:'+Qt.formatDateTime(new Date(end),"yyyyMMddThhmmss"),
                                        'SUMMARY:'+model.thema,
                                        'DESCRIPTION:'+(model.anmerkung !== "false" ? model.anmerkung:""),
                                        'LOCATION:BRK Haus Aubing, Altrostr. 16 München',
                                        'UID:'+model.index+"@brk-aubing.de",
                                        'END:VEVENT'
                                    ].join("\r\n");
                            tempfile.shareCalEvent(event)
                        }
                    }
                }
            }
        }
    }
}
