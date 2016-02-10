import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    SilicaFlickable {
        id: aboutContent
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: aboutContent }

        Column {
            id: column
            width: page.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Kursbeschreibungen"
            }

            Label {
                anchors.topMargin: 2*Theme.paddingLarge
                color: Theme.primaryColor

                text: "Allgemein"
            }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap

                text: "Alle Kurse finden im BRK Haus Aubing, Altostr. 16 in München (Aubing) statt. Das BRK Haus Aubing ist nur wenige Gehminuten von der S-Bahnstation Aubing entfernt. Kostenfreie Parkplätze gibt es in der Ubostr."
            }

            Label {
                color: Theme.primaryColor

                text: "Aubinger Ersthelfer"
            }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap

                text: "Der Aubinger Ersthelfer ist ein spezielles Angebot an interessierte Bürger ihr Erste Hilfe Wissen aufzufrischen. Der Inhalte passen sich an Ihre Fragen an und wird durch praktische Übungen ergänzt. Der Kurs wird kostenfrei angeboten, dennoch würden wir uns über einen Umkostenbeitrag in Form einer Spende freuen."
            }

            Label {
                color: Theme.primaryColor

                text: "Erste Hilfe Kurs"
            }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap

                text: "Wir bieten auch den Standard Erste Hilfe Kurs an in dem Sie einen Erste Hilfe Schein erwerben können. Der Erste Hilfe Kurs gilt für alle Führerscheine, Übungsleiter, sämtliche Studiengänge und jeden der lernen möchte sich und anderen zu helfen. Die Kursgebühr richtet sich nach den staatlichen vorgaben (aktuell 40 €) und ist im Kurs zu entrichten."
            }
        }
    }
}
