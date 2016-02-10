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
import org.nemomobile.notifications 1.0
import "pages"

import harbour.brkaubing 1.0

ApplicationWindow{
    id: appWindow
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    Notification {
        id: updateNote
        category: "x-nemo.example"
        summary: "Datei wurde aktualisiert"
        body: "Eine neue Ausbildungsdatei wurde eben heruntergeladen. Neue Termine sind verfügbar."
    }

    XmlFileHandler {
        id: handler;

        property bool filesChecked: false
        property bool showInternalDates: false
        property bool showHvoDates: true
        property bool showEventDates: false
        property int offset: 0
        property string actionItem: ""
        property string baItem: ""
        property string hvoItem: ""

        onNextEventsArrayChanged: {
            if(fileStat > 0){
//                for (var i = 0; i < nextEventsArray.length; i++){
//                    console.log(i+": "+nextEventsArray[i])
//                }
                if(showInternalDates)
                    offset = nextEventsArray[24]

                if(fileStat > 2)
                    updateNote.publish()

                actionItem = "am: "+handler.nextEventsArray[20]+" Uhr\n"+handler.nextEventsArray[22]
                baItem = "am: "+handler.nextEventsArray[handler.offset]+" Uhr
Thema: "+handler.nextEventsArray[handler.offset+2]
                hvoItem = "am: "+handler.nextEventsArray[8]+" Uhr"

                if(fileStat > 0 && handler.nextEventsArray[20].isEmpty){
                    var today = new Date()
                    var tmp = handler.nextEventsArray[20].split('.')
                    var newEventDate = new Date(("20"+tmp[2]).substring(0,4)*1,tmp[1]*1-1,tmp[0]*1,12,0,0,0)
                    showEventDates = newEventDate>today+21*24*3600000 ? false:true
                }else{
                    showEventDates = false
                }
            }
        }
    }

    XmlFileHandler {
        id: firstAidHandler

        property bool show: true
        property bool filesChecked: false
        property string aubingerEH: ""
        property string ehItem: ""

        onNextEventsArrayChanged: {
            if(fileStat > 0){
//                for (var i = 0; i < nextEventsArray.length; i++){
//                    console.log(i+": "+nextEventsArray[i])
//                }
                aubingerEH = "am: "+firstAidHandler.nextEventsArray[12]+" Uhr"
                ehItem = "am: "+firstAidHandler.nextEventsArray[8].substring(0,8)+" und "+Qt.formatDateTime(new Date((firstAidHandler.nextEventsArray[10]+"000")*1),"dd.MM.yyyy")+"\n"+firstAidHandler.nextEventsArray[11]
            }
        }
    }
}
