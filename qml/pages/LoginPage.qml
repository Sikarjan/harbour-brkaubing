import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage
import "../js/sha512.js" as SHA
import "../js/parser.js" as Parser

Page {
    id: loginPage

    property string firstName
    property string response
    property bool saveLogin

    Component.onCompleted: {
        Storage.initialize();
        firstName = Storage.getSetting("firstName");
        saveLogin = Storage.getSetting("saveLogin") === false ? false:true
    }

    onResponseChanged: {
        if(response == '')
            return 0

        var data = JSON.parse(response);
        loginLoader.running = false

        if(data.status === "login"){
            firstName = data.name

            res.text = 'Du hast dich erfolgreich als '+firstName+' eingeloggt.'

            Storage.setSetting("loginName", login.text);
            Storage.setSetting("pass", SHA.hex_sha512(password.text))
            Storage.setSetting("firstName", data.name);
            Storage.setSetting("hash", data.hash);
            Storage.setSetting("hid", data.hid);
            Storage.setSetting("rank", data.rank);
            Storage.setSetting("internalDates", 1)

            loggedIn = true
            hash = data.hash
            hid = data.hid

            Parser.post('task=2&hash='+data.hash+'&hid='+data.hid)
        }else if(data.status === 'pers'){
            Parser.readPersList(data.data)
        }else if(data.status === 'error'){
            error.text = data.err
        }
        response = ''
    }

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: "BRK Aubing Login"
        }

        Column {
            id: loginView
            visible: !loggedIn
            width: parent.width - 2*Theme.paddingMedium
            spacing: Theme.paddingLarge
            anchors.top: header.bottom
            x: Theme.paddingMedium

            TextField {
                id: login
                width: parent.width
                label: "Login"
                placeholderText: "Login Name"
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
            }

            PasswordField {
                id: password
                width: parent.width
                label: "Passwort"
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: loginButton.pressed
            }

            Button {
                id: loginButton
                width: parent.width/3*2
                anchors.horizontalCenter: loginView.horizontalCenter
                text: "Login"
                onClicked: {
                    var pass = SHA.hex_sha512(password.text)
                    Parser.post('task=1&user='+login.text+'&password='+pass)
                    loginLoader.running = true
                }
            }

            BusyIndicator {
                id: loginLoader
                anchors.horizontalCenter: parent.horizontalCenter
                size: BusyIndicatorSize.Large
            }

            Label {
                id: error
                width: parent.width
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: 'Um dich einloggen zu können benötigt man einen Zugang zum internen Bereich des BRK Aubing. Dieser kann über die Homepage <a href="https://brk-aubing.de">BRK-Aubing.de</a> angefragt werden. Der interne Bereich ist nur für Mitglieder des BRK Aubing verfügbar.'
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }

        Column {
            id: logoutView
            visible: !loginView.visible
            width: parent.width - 2*Theme.paddingMedium
            spacing: 2*Theme.paddingLarge
            anchors.top: header.bottom
            x: Theme.paddingMedium

            Button {
                width: parent.width/3*2
                anchors.horizontalCenter: logoutView.horizontalCenter
                text: "Logout"
                onClicked: {
                    Storage.setSetting("loginName", "");
                    Storage.setSetting("pass", "")
                    Storage.setSetting("internalDates", 0)

                    persList.clear()
                    loggedIn = false
                    hash = ""
                    hid = 0

                    firstName = ""
                }
            }

            Label {
                id: res
                width: parent.width
                wrapMode: Text.Wrap
                text: ""
            }
        }
    }
}
