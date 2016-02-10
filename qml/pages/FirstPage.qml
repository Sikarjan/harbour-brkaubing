/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage
import "../js/globals.js" as Vars

Page {
    id: page

    Component.onCompleted: {
        if(!handler.filesChecked){
            handler.load(Vars.mainPath, Vars.trainingSchedule);
            handler.filesChecked = true;
        }
        if(!firstAidHandler.filesChecked){
            firstAidHandler.load(Vars.mainPath, Vars.firstAidSchedule);
            firstAidHandler.filesChecked = true;
        }

        Storage.initialize();
        if(Storage.getSetting("hvoDates") !== ""){
            handler.showHvoDates = Storage.getSetting("hvoDates") === "1" ? true:false
            handler.showInternalDates = Storage.getSetting("internalDates") === "1" ? true:false
            firstAidHandler.show = Storage.getSetting("showFirstAid") === "1" ? true:false
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: header.height+planColumn.height+ehColumn.height
        VerticalScrollDecorator { flickable: canvas }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: "Einstellungen"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"))
            }
        }

        PageHeader {
            id: header
            title: "BRK Aubing"
        }

        // Ausbildungdanzeige
        Column {
            id: planColumn
            width: page.width - 2*Theme.paddingMedium
            height: datesColumn.height+Theme.paddingLarge
            spacing: Theme.paddingLarge
            anchors.top: header.bottom
            x: Theme.paddingMedium

            // Anzeige der nächsten BA und Ereignisse
            Column {
                id: datesColumn
                visible: handler.fileStat > 0
                width: parent.width
                spacing: Theme.paddingLarge

                Button {
                    id: aplan
                    text: ">> Ausbildungsplan"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: pageStack.push(Qt.resolvedUrl("PlanPage.qml"))
                }

                // Anzeige Event
                Column {
                    id: eventDate
                    visible: handler.showEventDates
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Text {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.highlightColor
                        wrapMode: Text.WordWrap

                        text: "Nächste Aktion"
                    }
                    Text {
                        visible: handler.fileStat > 0
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                        wrapMode: Text.WordWrap

                        text: handler.actionItem
                    }
                }

                // Nächster BA
                Column {
                    id: baDate
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Text {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.highlightColor
                        wrapMode: Text.WordWrap

                        text: "Nächster Bereitschaftsabend"
                    }
                    Text {
                        visible: handler.fileStat > 0
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                        wrapMode: Text.WordWrap

                        text: handler.baItem
                    }
                }

                // Anzeige HvO
                Column {
                    id: hvoDate
                    visible: handler.showHvoDates
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Text {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.highlightColor
                        wrapMode: Text.WordWrap

                        text: "Nächste HvO Supervision"
                    }
                    Text {
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                        wrapMode: Text.WordWrap

                        text: handler.hvoItem
                    }
                }
            }

            // Anzeige falls Fehler
            Text {
                visible: handler.fileStat < 0
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Es konnten keine Daten gefunden werden. Bitte versuchen Sie es später nocheinmal."
            }

            // Lade Anzeige
            BusyIndicator {
                id: loader
                anchors.horizontalCenter: parent.horizontalCenter
                running: handler.fileStat === 0;
                size: BusyIndicatorSize.Large
            }

            Label {
                visible: handler.fileStat === 0
                anchors.topMargin: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor

                text: "Aktualisiere Daten"
            }
        }

        // EH Anzeige
        Column {
            id: ehColumn
            visible: firstAidHandler.show
            anchors.top: planColumn.bottom
            anchors.topMargin: Theme.paddingLarge
            width: planColumn.width
            height: ehContent.height+2*Theme.paddingLarge
            x: Theme.paddingMedium
            spacing: Theme.paddingLarge

            Column {
                id: ehContent
                width: parent.width
                spacing: Theme.paddingLarge

                Rectangle {
                    height: 2
                    width: parent.width
                    color:Theme.highlightColor
                }

                Button {
                    id: ehPlan
                    visible: firstAidHandler.fileStat > 0
                    text: ">> Erste Hilfe Kurse"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: pageStack.push(Qt.resolvedUrl("FirstAidPage.qml"))
                }

                // Anzeige der nächsten Kurse wenn alles okay
                Column {
                    visible: firstAidHandler.fileStat > 0
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Text {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.highlightColor
                        wrapMode: Text.WordWrap

                        text: "Nächster Aubinger Ersthelfer "
                    }
                    Text {
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                        wrapMode: Text.WordWrap

                        text: firstAidHandler.aubingerEH
                    }
                }
                Column {
                    visible: firstAidHandler.fileStat > 0
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Text {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.highlightColor
                        wrapMode: Text.WordWrap

                        text: "Nächster Erste Hilfe Kurs"
                    }
                    Text {
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                        wrapMode: Text.WordWrap

                        text: firstAidHandler.ehItem
                    }
                }
            }

            // Anderfalls Fehler
            Text {
                visible: handler.fileStat < 0
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Es konnten keine Daten gefunden werden. Bitte versuchen Sie es später nocheinmal."
            }

            // Sonst zeige Laden
            BusyIndicator {
                id: firstAideLoader
                anchors.horizontalCenter: parent.horizontalCenter
                running: firstAidHandler.fileStat === 0;
                size: BusyIndicatorSize.Large
            }

            Label {
                visible: firstAidHandler.fileStat === 0
                anchors.topMargin: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor

                text: "Aktualisiere Daten"
            }
        }
    }
}


