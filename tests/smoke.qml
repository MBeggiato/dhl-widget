import QtQuick
import QtQuick.Controls
import "../package/contents/ui" as Widget

ApplicationWindow {
    width: 380
    height: 460
    visible: true
    QtObject {
        id: fixture
        property var snapshot: ({ name: "DHL Packstation 132", location: "ALDI Markt", address: "Gutenbergstr. 46, 72555 Metzingen", total: 18, counts: [3, 10, 5, 0], sourceTimestamp: new Date() })
        property string stationId: "1-72555132"
        property string nickname: "Beim ALDI"
        property bool configured: true
        property bool loading: false
        property bool stale: false
        property string error: ""
        property date fetchedAt: new Date()
        function refresh() {}
    }
    Widget.ComparisonView { anchors.fill: parent; stations: [fixture, fixture, fixture]; favorite: fixture }
    Timer { interval: 500; running: true; onTriggered: Qt.quit() }
}
