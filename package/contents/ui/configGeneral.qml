import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "../code/api.js" as Api

KCM.SimpleKCM {
    id: root
    property alias cfg_stationId: firstId.text
    property alias cfg_stationName: firstName.text
    property alias cfg_stationId2: secondId.text
    property alias cfg_stationName2: secondName.text
    property alias cfg_stationId3: thirdId.text
    property alias cfg_stationName3: thirdName.text
    property alias cfg_favoriteStation: favorite.currentIndex

    Kirigami.FormLayout {
        Label {
            Kirigami.FormData.isSection: true
            text: "Bis zu drei Stationen vergleichen. Die Reihenfolge entspricht den Feldern unten."
            wrapMode: Text.Wrap
        }
        TextField {
            id: firstId
            Kirigami.FormData.label: "Station 1 – Standort-ID:"
            placeholderText: "1-72555132"
            Accessible.name: "Standort-ID der ersten Station"
        }
        TextField {
            id: firstName
            Kirigami.FormData.label: "Kurzname:"
            placeholderText: "Optional, z. B. Beim ALDI"
            Accessible.name: "Kurzname der ersten Station"
        }
        TextField {
            id: secondId
            Kirigami.FormData.label: "Station 2 – Standort-ID:"
            placeholderText: "Leer lassen, um Station zu entfernen"
            Accessible.name: "Standort-ID der zweiten Station"
        }
        TextField {
            id: secondName
            Kirigami.FormData.label: "Kurzname:"
            placeholderText: "Optional"
            Accessible.name: "Kurzname der zweiten Station"
        }
        TextField {
            id: thirdId
            Kirigami.FormData.label: "Station 3 – Standort-ID:"
            placeholderText: "Leer lassen, um Station zu entfernen"
            Accessible.name: "Standort-ID der dritten Station"
        }
        TextField {
            id: thirdName
            Kirigami.FormData.label: "Kurzname:"
            placeholderText: "Optional"
            Accessible.name: "Kurzname der dritten Station"
        }
        ComboBox {
            id: favorite
            Kirigami.FormData.label: "Favorit im Panel:"
            model: ["Station 1", "Station 2", "Station 3"]
            Accessible.name: "Favoritenstation für die Panel-Anzeige"
        }
        Kirigami.InlineMessage {
            visible: [firstId.text, secondId.text, thirdId.text].some(value => value.trim() !== "" && !Api.validStationId(value))
            type: Kirigami.MessageType.Error
            text: "Standort-IDs müssen mit 1- beginnen, gefolgt von Ziffern. Ungültige IDs werden nicht abgefragt."
        }
        Label {
            text: "Die vollständige DHL-Standort-ID verwenden, nicht nur die aufgedruckte Nummer.\nLeere Einträge werden ausgeblendet. Ist der Favorit leer, wird die erste konfigurierte Station verwendet.\nDie konfigurierten Standort-IDs werden alle fünf Minuten direkt an DHL übermittelt."
            wrapMode: Text.Wrap
        }
    }
}
