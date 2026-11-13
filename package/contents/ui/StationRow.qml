pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC

PC.ItemDelegate {
    id: root
    required property var station
    property bool favorite: false
    property int sizeFilter: 0
    readonly property var snapshot: station.snapshot
    width: parent ? parent.width : implicitWidth
    Accessible.name: (station.nickname || (snapshot ? snapshot.name : station.stationId))
        + (snapshot ? ", " + snapshot.total + " freie Fächer" : ", keine Daten")
        + (station.stale ? ", veralteter Datenstand" : "") + ", Details öffnen"
    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        RowLayout {
            Layout.fillWidth: true
            PC.Label {
                Layout.fillWidth: true
                text: root.station.nickname || (root.snapshot ? root.snapshot.name : root.station.stationId)
                textFormat: Text.PlainText
                font.bold: true
                elide: Text.ElideRight
            }
            Kirigami.Icon {
                visible: root.favorite
                source: "rating"
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: implicitWidth
                Accessible.name: "Favorit im Panel"
            }
            Kirigami.Icon {
                source: "go-next"
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: implicitWidth
                Accessible.ignored: true
            }
        }
        PC.Label {
            Layout.fillWidth: true
            visible: !!root.snapshot
            text: root.snapshot ? [root.snapshot.location, root.snapshot.address].filter(Boolean).join(" · ") : ""
            textFormat: Text.PlainText
            elide: Text.ElideRight
            font: Kirigami.Theme.smallFont
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            Repeater {
                model: ["S", "M", "L", "XL"]
                Rectangle {
                    id: cell
                    required property int index
                    required property string modelData
                    readonly property bool emphasized: root.sizeFilter === 0 || root.sizeFilter === index + 1
                    readonly property int count: root.snapshot ? root.snapshot.counts[index] : -1
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: Kirigami.Units.gridUnit * 2.6
                    radius: Kirigami.Units.smallSpacing
                    color: emphasized && count > 0 ? "#ffcc00" : Kirigami.Theme.alternateBackgroundColor
                    border.width: root.sizeFilter === index + 1 ? 2 : 0
                    border.color: Kirigami.Theme.textColor
                    Accessible.role: Accessible.StaticText
                    Accessible.name: "Größe " + modelData + ": " + (count < 0 ? "unbekannt" : count + " frei")
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        PC.Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: cell.modelData
                            font: Kirigami.Theme.smallFont
                            color: cell.emphasized && cell.count > 0 ? "#202020" : Kirigami.Theme.textColor
                        }
                        PC.Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: cell.count < 0 ? "—" : cell.count.toString()
                            font.bold: true
                            color: cell.emphasized && cell.count > 0 ? "#202020" : Kirigami.Theme.textColor
                        }
                    }
                }
            }
        }
        PC.Label {
            Layout.fillWidth: true
            text: root.station.loading ? "Wird aktualisiert …"
                : root.station.error ? root.station.error
                : root.snapshot ? (root.station.stale ? "Veraltet · " : "Stand ")
                    + (root.snapshot.sourceTimestamp ? Qt.formatDateTime(root.snapshot.sourceTimestamp, "dd.MM. HH:mm") : "unbekannt")
                    + " · " + root.snapshot.total + " frei insgesamt"
                : "Noch keine Daten"
            color: root.station.error || root.station.stale ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.textColor
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
        }
    }
}
