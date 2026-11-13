import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "../package/contents/ui" as Widget

ApplicationWindow {
    id: window
    visible: true
    width: 420
    height: 650
    color: Kirigami.Theme.backgroundColor
    title: "Packstation · Demodaten"
    QtObject {
        id: first
        property string stationId: "1-10000001"
        property string nickname: "Am Stadtpark"
        property bool configured: true
        property bool loading: false
        property bool stale: false
        property string error: ""
        property date fetchedAt: new Date("2026-06-15T10:30:00+02:00")
        property var snapshot: ({name: "DHL Packstation 101", location: "Am Stadtpark", address: "Parkstraße 12, Beispielstadt", total: 18, counts: [3, 10, 5, 0], sourceTimestamp: first.fetchedAt})
        function refresh() {}
    }
    QtObject {
        id: second
        property string stationId: "1-10000002"
        property string nickname: "Am Bahnhof"
        property bool configured: true
        property bool loading: false
        property bool stale: false
        property string error: ""
        property date fetchedAt: first.fetchedAt
        property var snapshot: ({name: "DHL Packstation 202", location: "Bahnhofsvorplatz", address: "Bahnhofstraße 8, Beispielstadt", total: 7, counts: [0, 4, 2, 1], sourceTimestamp: first.fetchedAt})
        function refresh() {}
    }
    QtObject {
        id: third
        property string stationId: "1-10000003"
        property string nickname: "Beim Supermarkt"
        property bool configured: true
        property bool loading: false
        property bool stale: false
        property string error: ""
        property date fetchedAt: first.fetchedAt
        property var snapshot: ({name: "DHL Packstation 303", location: "Supermarkt", address: "Marktstraße 3, Beispielstadt", total: 12, counts: [6, 3, 1, 2], sourceTimestamp: first.fetchedAt})
        function refresh() {}
    }
    Item {
        id: capture
        anchors.fill: parent
        Rectangle { anchors.fill: parent; color: Kirigami.Theme.backgroundColor }
        Widget.ComparisonView {
            id: comparison
            anchors.fill: parent
            anchors.margins: 14
            anchors.bottomMargin: 34
            stations: [first, second, third]
            favorite: first
        }
        Label {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: "DEMO · Fiktive Standorte und Beispieldaten"
            font.pixelSize: 11
        }
    }
    property int step: 0
    Timer {
        interval: 700
        running: true
        repeat: true
        onTriggered: {
            const names = ["comparison", "detail", "compact"]
            if (window.step > 2) { Qt.quit(); return }
            const name = names[window.step]
            capture.grabToImage(function(result) {
                const path = Qt.resolvedUrl("../docs/screenshots/" + name + ".png").toString().replace("file://", "")
                if (!result.saveToFile(path)) { console.error("Screenshot fehlgeschlagen:", path); Qt.exit(1); return }
                console.log("Gespeichert:", path)
                window.step++
                if (window.step === 1) comparison.selectedIndex = 0
                if (window.step === 2) { comparison.selectedIndex = -1; window.width = 290; window.height = 630 }
            })
        }
    }
}
