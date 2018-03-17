import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Dialog {
    id: page

    Component.onCompleted: {
        Storage.initialize();
        saveLogin.checked = Storage.getSetting("saveLogin")
    }

    onAccepted: {
        firstAidHandler.show = firstAidCalendar.checked
        handler.showHvoDates = hvoDatesSwitch.checked

        Storage.setSetting("showFirstAid", firstAidCalendar.checked)
        Storage.setSetting("hvoDates", hvoDatesSwitch.checked)
        Storage.setSetting("saveLogin", saveLogin.checked)
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
                id: hvoDatesSwitch
                text: "Zeige HvO Termine"
                description: "HvO Supervisionstermine"
                checked: handler.showHvoDates
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                text: "Account Einstellungen"
            }

            TextSwitch {
                id: saveLogin
                text: "Speicher Logindaten"
                description: "Benutzername und Passwort werden auf dem Gerät gespeichert"
            }
        }
    }
}
