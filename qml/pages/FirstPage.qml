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
import "../js/parser.js" as Parser

Page {
    id: page

    property string response

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
        handler.showHvoDates = Storage.getSetting("hvoDates") === "1" ? true:false
        handler.showInternalDates = loggedIn
        firstAidHandler.show = Storage.getSetting("showFirstAid") === "1" ? true:false

        // Check if there are login information
        var pass = Storage.getSetting("pass");
        if(pass !== null && pass !== ""){
            Parser.post('task=1&user='+Storage.getSetting("loginName")+'&password='+pass)
        }
    }

    onResponseChanged: {
        if(response == '')
            return 0

        var data = JSON.parse(response);

        if(data.status === "login"){
            firstName = data.name
            hash = data.hash
            loggedIn = true
            console.log("Erfolgreich eingeloggt")

            persLoader.running = true
            persErrorText.text = ""
            Parser.post("task=2&hash="+data.hash)
        }else if(data.status === "pers"){
            persLoader.running = false
            Parser.readPersList(data.data)
        }else if(data.status === 'error'){
            persLoader.running = false
            persErrorText.text = data.err
        }else if(data.status === 'expired'){
            loggedIn = false
            console.log('Login abgelaufen. Neue Loginversuch')
            Parser.post('task=1&user='+Storage.getSetting("loginName")+'&password='+Storage.getSetting("pass"))
        }else{
            persLoader.running = false
            persErrorText.text = 'Unbekannter Fehler.'
        }

        response = ''
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: canvas
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: header.height+content.height
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
            MenuItem {
                text: loggedIn ? "Logout":"Login"
                onClicked: pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
            }
        }
        PushUpMenu {
            visible: loggedIn
            MenuItem {
                text: "Aktualisieren"
                onClicked: {
                    persErrorText.text = ""
                    persLoader.running = true
                    persList.clear()
                    Parser.post("task=2&hash="+hash)
                }
            }
            MenuItem {
                text: "Telefonliste"
                onClicked: pageStack.push(Qt.resolvedUrl("ContactsPage.qml"))
            }
            MenuItem {
                text: "Statistik"
                onClicked: pageStack.push(Qt.resolvedUrl("StatPage.qml"))
            }
        }

        PageHeader {
            id: header
            title: "BRK Aubing"
        }

        Column {
            id: content
            width: page.width - 2*Theme.paddingMedium
            spacing: Theme.paddingLarge
            anchors.top: header.bottom
            x: Theme.paddingMedium

            // Ausbildungdanzeige
            Column {
                id: planColumn
                width: parent.width
                spacing: Theme.paddingLarge

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
                    visible: loader.running
                }

                Label {
                    visible: handler.fileStat === 0
                    anchors.topMargin: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.highlightColor

                    text: "Aktualisiere Daten"
                }
            }

            // Persönliche Daten
            Column {
                id: persColumn
                width: parent.width
                spacing: Theme.paddingMedium
                visible: loggedIn || persLoader.running || persErrorText.text !== ""

                SilicaListView {
                    id: persView
                    visible: persList.count > 0
                    width: parent.width
                    height: contentHeight //Theme.itemSizeMedium * persList.count + 2*(Theme.itemSizeMedium - Theme.paddingMedium)
                    clip: true

                    model: persList

                    delegate: ListItem {
                        id: listItem
                        width: persColumn.width
                        contentHeight: persItem.height + persDesc.height + Theme.paddingMedium

                        Text {
                            id: persItem
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            wrapMode: Text.Wrap

                            text: (date === '' ? '':date+': ') +type
                        }
                        Text {
                            id: persDesc
                            anchors.top:  persItem.bottom
                            width: parent.width
                            color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                            wrapMode: Text.Wrap

                            text: desc
                        }

                        onClicked: {
                            dienstID = refId
                            typeID = typeId
                            pageStack.push(Qt.resolvedUrl("DienstPage.qml"))
                        }
                    }

                    section.property: "sort"
                    section.criteria: ViewSection.FullString
                    section.delegate: ListItem {
                        height: Theme.itemSizeMedium - Theme.paddingMedium

                        Rectangle {
                            height: 2
                            width: content.width
                            color:Theme.highlightColor
                        }

                        Label {
                            y: Theme.paddingMedium
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeLarge
                            text: section == "offen" ? "Offene San Dienste": section == "voll" ? "Besetzte San Dienste":"Deine nächsten Termine"
                        }
                    }
                }

                // Anzeige falls Fehler
                Text {
                    id: persErrorText
                    visible: text !== ""
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: ""
                }

                // Lade Anzeige
                BusyIndicator {
                    id: persLoader
                    anchors.horizontalCenter: parent.horizontalCenter
                    size: BusyIndicatorSize.Large
                    visible: persLoader.running
                }

                Label {
                    id: persLoaderText
                    visible: persLoader.running
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
                width: parent.width
                height: ehContent.height+3*Theme.paddingLarge
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
                    visible: firstAideLoader.running
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
}


