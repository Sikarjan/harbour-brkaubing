import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Dialog {
    id: page

    onAccepted: {
        handler.offset = internalDatesSwitch.checked ? handler.nextEventsArray[24]:0

        firstAidHandler.show = firstAidCalendar.checked
        handler.showInternalDates = internalDatesSwitch.checked
        handler.showHvoDates = hvoDatesSwitch.checked

        Storage.initialize();
        Storage.setSetting("showFirstAid", firstAidCalendar.checked)
        Storage.setSetting("internalDates", internalDatesSwitch.checked)
        Storage.setSetting("hvoDates", hvoDatesSwitch.checked)
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Lokale Dateien löschen"
                onClicked: {
                    handler.clear();
                    handler.load("ausbildung.xml");
                    firstAidHandler.clear();
                    firstAidHandler.load("firstAid.xml")
                    pageStack.pop()
                }
            }
        }

        DialogHeader {
            id: header
            title: "Einstellungen"
            acceptText: "Speichern"
            cancelText: "Abbrechen"
        }

        Column {
            id: column
            width: parent.width - Theme.paddingLarge
            anchors.top: header.bottom
            x: Theme.paddingMedium

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                text: "Anzeigeeinstellungen"
            }

            TextSwitch {
                id: firstAidCalendar
                text: "Zeige Erste Hilfe Kurse"
                description: "Anzeige Erste Hilfe Termine"
                checked: firstAidHandler.show
            }

            TextSwitch {
                id: internalDatesSwitch
                text: "Zeige interne BAs"
                description: "Für BRK Aubing Mitglieder"
                checked: handler.showInternalDates
            }

            TextSwitch {
                id: hvoDatesSwitch
                text: "Zeige HvO Termine"
                description: "HvO Supervisionstermine"
                checked: handler.showHvoDates
            }
        }
    }
}
