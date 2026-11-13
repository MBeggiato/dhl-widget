pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC

Item {
    id: root
    required property var stations
    required property var favorite
    property int selectedIndex: -1
    property int sizeFilter: 0
    readonly property var selected: selectedIndex >= 0 ? stations[selectedIndex] : null
    signal refreshRequested()
    Layout.minimumWidth: Kirigami.Units.gridUnit * 14
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * (selected ? 24 : 7 + 7 * stations.filter(station => station.configured).length)
    implicitWidth: Layout.preferredWidth
    implicitHeight: Layout.preferredHeight

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
        RowLayout {
            Layout.fillWidth: true
            PC.ToolButton {
                visible: root.selected !== null
                icon.name: "go-previous"
                text: "Zum Vergleich"
                Accessible.name: text
                onClicked: root.selectedIndex = -1
            }
            Kirigami.Heading {
                Layout.fillWidth: true
                level: 2
                text: root.selected ? (root.selected.nickname || "Details") : "Packstationen"
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
            PC.ToolButton {
                icon.name: "view-refresh"
                text: "Alle Stationen aktualisieren"
                display: PC.AbstractButton.IconOnly
                Accessible.name: text
                PC.ToolTip.text: text
                PC.ToolTip.visible: hovered
                onClicked: root.refreshRequested()
            }
        }
        RowLayout {
            visible: root.selected === null
            Layout.fillWidth: true
            PC.Label { text: "Größe:" }
            PC.ComboBox {
                Layout.fillWidth: true
                model: ["Alle", "S", "M", "L", "XL"]
                currentIndex: root.sizeFilter
                onActivated: root.sizeFilter = currentIndex
                Accessible.name: "Fachgröße im Vergleich hervorheben"
            }
        }
        PC.ScrollView {
            id: comparisonScroll
            visible: root.selected === null
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            ColumnLayout {
                width: comparisonScroll.availableWidth
                spacing: Kirigami.Units.smallSpacing
                Repeater {
                    model: root.stations
                    StationRow {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        visible: modelData.configured
                        station: modelData
                        favorite: modelData === root.favorite
                        sizeFilter: root.sizeFilter
                        onClicked: root.selectedIndex = index
                    }
                }
                PC.Label {
                    Layout.fillWidth: true
                    visible: !root.stations.some(station => station.configured)
                    text: "Noch keine Station eingerichtet. Über das Kontextmenü die Widget-Einstellungen öffnen und Standort-IDs eintragen."
                    wrapMode: Text.Wrap
                }
                PC.Label {
                    Layout.fillWidth: true
                    text: "Station für Details auswählen. Verfügbarkeit ist eine Momentaufnahme, keine Reservierung."
                    wrapMode: Text.Wrap
                    font: Kirigami.Theme.smallFont
                }
            }
        }
        FullRepresentation {
            visible: root.selected !== null && !!root.selected.configured
            Layout.fillWidth: true
            Layout.fillHeight: true
            dataSource: root.selected || root.favorite
        }
    }
    Connections {
        target: root.selected
        function onStationIdChanged() { root.selectedIndex = -1 }
    }
}
