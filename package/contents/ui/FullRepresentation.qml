pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC

PC.ScrollView {
    id: root
    required property var dataSource
    readonly property var station: dataSource.snapshot
    readonly property bool compact: availableWidth < Kirigami.Units.gridUnit * 18 || availableHeight < Kirigami.Units.gridUnit * 22
    Layout.minimumWidth: Kirigami.Units.gridUnit * 14
    Layout.minimumHeight: Kirigami.Units.gridUnit * 10
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredHeight: Kirigami.Units.gridUnit * 23
    implicitWidth: Layout.preferredWidth
    implicitHeight: Layout.preferredHeight
    contentWidth: availableWidth

    ColumnLayout {
        x: Kirigami.Units.smallSpacing
        width: root.availableWidth - Kirigami.Units.smallSpacing * 2
        spacing: root.compact ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true
            Kirigami.Icon {
                source: Qt.resolvedUrl("../images/packstation.svg")
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: implicitWidth
                Accessible.ignored: true
            }
            Kirigami.Heading {
                Layout.fillWidth: true
                level: 2
                text: root.station ? root.station.name : "DHL Packstation"
                wrapMode: root.compact ? Text.NoWrap : Text.Wrap
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
            PC.ToolButton {
                icon.name: "view-refresh"
                text: "Aktualisieren"
                display: PC.AbstractButton.IconOnly
                enabled: !root.dataSource.loading
                onClicked: root.dataSource.refresh()
                PC.ToolTip.text: text
                PC.ToolTip.visible: hovered
                Accessible.name: text
            }
        }
        PC.Label {
            Layout.fillWidth: true
            visible: !!root.station
            text: root.station ? [root.station.location, root.station.address].filter(Boolean).join("\n") : ""
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            color: Kirigami.Theme.textColor
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: root.dataSource.error !== "" || root.dataSource.stale
            type: root.dataSource.error !== "" ? Kirigami.MessageType.Error : Kirigami.MessageType.Warning
            text: root.dataSource.error !== ""
                ? root.dataSource.error + (root.station ? " Letzte bekannte Werte werden angezeigt." : " Einstellungen über das Kontextmenü prüfen.")
                : root.compact ? "Veralteter DHL-Datenstand" : "DHL-Daten sind älter als 15 Minuten oder haben keinen gültigen Zeitstempel."
        }
        PC.BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            visible: root.dataSource.loading
            running: visible
            Accessible.name: "Daten werden aktualisiert"
        }
        PC.Label {
            visible: !root.station && !root.dataSource.loading && !root.dataSource.error
            text: "Noch keine Daten vorhanden."
        }
        ColumnLayout {
            Layout.fillWidth: true
            visible: !!root.station
            spacing: root.compact ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            Kirigami.Separator { Layout.fillWidth: true }
            RowLayout {
                Layout.fillWidth: true
                PC.Label {
                    text: "Freie Fächer"
                    font.bold: true
                    Layout.fillWidth: true
                }
                PC.Label {
                    text: root.station ? root.station.total + " insgesamt" : ""
                }
            }
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: Kirigami.Units.smallSpacing
                columnSpacing: Kirigami.Units.smallSpacing
                Repeater {
                    model: ["S", "M", "L", "XL"]
                    CompartmentTile {
                        required property string modelData
                        required property int index
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        compact: root.compact
                        sizeName: modelData
                        sizeIndex: index
                        count: root.station ? root.station.counts[index] : 0
                        stale: root.dataSource.stale
                    }
                }
            }
            PC.Label {
                Layout.fillWidth: true
                visible: !root.compact
                text: root.station && root.station.total === 0 ? "Aktuell sind keine freien Fächer gemeldet." : "Freie Fächer sind eine Momentaufnahme, keine Reservierung."
                wrapMode: Text.Wrap
            }
            PC.Label {
                Layout.fillWidth: true
                text: "DHL-Datenstand: " + (root.station && root.station.sourceTimestamp ? Qt.formatDateTime(root.station.sourceTimestamp, "dd.MM.yyyy HH:mm:ss") : "unbekannt")
                    + (root.compact ? "" : "\nAbgerufen: " + (root.station ? Qt.formatDateTime(root.dataSource.fetchedAt, "dd.MM.yyyy HH:mm:ss") : "—")
                    + "\nAutomatische Aktualisierung alle 5 Minuten")
                font: Kirigami.Theme.smallFont
                color: Kirigami.Theme.textColor
                wrapMode: Text.Wrap
            }
        }
    }
}
