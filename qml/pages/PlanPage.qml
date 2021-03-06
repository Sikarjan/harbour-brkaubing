import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
// import org.nemomobile.calendar 1.0 currently not supportet by Sailfish OS

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
            contentHeight: Theme.itemSizeLarge+(model.anmerkung !== "false" ? labelAnmerkung.height:0)+10
            visible: isVisible(model.type)
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
            Label {
                id: labelThema
                text: model.thema
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                anchors.top: labelArt.bottom
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

/*            Component {
                id: contextMenu

                ContextMenu {
                    MenuItem {
                        text: "Zum Kalender hinzufügen"
                        onClicked: {
                            console.log('Wird übertragen')
                            event = Calendar.createNewEvent()
                            event.setStartTime(new Date(model.datum*1000), CalendarEvent.SpecClockTime);
                            event.setEndTime(new Date((model.datum+1.5*3600)*1000),CalendarEvent.SpecClockTime);
                            event.displayLabel = model.art+": "+model.thema;
                            event.location = "BRK Haus Aubing, Altrostr. 16 München";
                            event.save();
                        }
                    }
                }
            }*/
        }
    }
}
