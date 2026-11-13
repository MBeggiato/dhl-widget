pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool inTray: Plasmoid.containment && Plasmoid.containment.pluginName === "org.kde.plasma.private.systemtray"
    readonly property var stations: [first, second, third]
    SharedConfig { localConfig: Plasmoid.configuration }
    readonly property int favoriteIndex: Plasmoid.configuration["favoriteStation"]
    readonly property var favorite: stations[favoriteIndex] && stations[favoriteIndex].configured
        ? stations[favoriteIndex] : first.configured ? first : second.configured ? second : third
    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation
    toolTipMainText: favorite.nickname || (favorite.snapshot ? favorite.snapshot.name : "DHL Packstation")
    toolTipSubText: favorite.snapshot
        ? favorite.snapshot.total + " freie Fächer · Favorit" + (favorite.stale ? " · Veraltete Daten" : "")
        : (favorite.error || (favorite.configured ? "Daten werden geladen …" : "Bitte Stationen einrichten"))
    toolTipTextFormat: Text.PlainText

    StationData {
        id: first
        stationId: Plasmoid.configuration["stationId"]
        nickname: Plasmoid.configuration["stationName"]
    }
    StationData {
        id: second
        stationId: Plasmoid.configuration["stationId2"]
        nickname: Plasmoid.configuration["stationName2"]
    }
    StationData {
        id: third
        stationId: Plasmoid.configuration["stationId3"]
        nickname: Plasmoid.configuration["stationName3"]
    }
    function refreshAll() {
        for (const station of stations) station.refresh()
    }
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Alle Stationen aktualisieren"
            icon.name: "view-refresh"
            onTriggered: root.refreshAll()
        }
    ]
    compactRepresentation: PC.ToolButton {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 2
        Layout.minimumHeight: Kirigami.Units.gridUnit * 2
        text: (root.favorite.snapshot ? root.favorite.snapshot.total.toString() : "—") + (root.favorite.stale ? " !" : "")
        icon.source: Qt.resolvedUrl("../images/packstation.svg")
        display: root.inTray ? PC.AbstractButton.IconOnly : PC.AbstractButton.TextBesideIcon
        Accessible.name: root.toolTipMainText + ": " + root.toolTipSubText
        onClicked: root.expanded = !root.expanded
    }
    fullRepresentation: ComparisonView {
        stations: root.stations
        favorite: root.favorite
        onRefreshRequested: root.refreshAll()
    }
}
