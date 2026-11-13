import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC

Rectangle {
    id: root
    required property string sizeName
    required property int sizeIndex
    required property int count
    property bool stale: false
    property bool compact: false
    readonly property bool available: count > 0
    // DHL yellow is deliberately limited to the physical compartment glyph.
    readonly property color compartmentYellow: "#ffcc00"
    implicitWidth: Kirigami.Units.gridUnit * 3.5
    implicitHeight: Kirigami.Units.gridUnit * (compact ? 5.5 : 9)
    color: Kirigami.Theme.alternateBackgroundColor
    radius: Kirigami.Units.smallSpacing
    Accessible.role: Accessible.StaticText
    Accessible.name: "Größe " + sizeName + ": " + count + " freie Fächer" + (stale ? ", veralteter Datenstand" : "")

    Kirigami.Icon {
        anchors.top: parent.top
        anchors.topMargin: Kirigami.Units.smallSpacing * 2
        anchors.horizontalCenter: parent.horizontalCenter
        width: Kirigami.Units.iconSizes.small
        height: width
        visible: !root.compact
        source: root.stale ? "dialog-warning" : root.available ? "dialog-positive" : "dialog-close"
        color: root.stale ? Kirigami.Theme.neutralTextColor : root.available ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
        Accessible.ignored: true
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: countLabel.top
        anchors.margins: Kirigami.Units.smallSpacing
        anchors.topMargin: root.compact ? Kirigami.Units.smallSpacing : Kirigami.Units.gridUnit * 2
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.compact ? Kirigami.Units.gridUnit * 1.4 : Kirigami.Units.gridUnit * (1.35 + root.sizeIndex * 0.72)
            radius: 3
            color: root.available ? root.compartmentYellow : "transparent"
            border.width: root.available ? 0 : 2
            border.color: Kirigami.Theme.disabledTextColor
            PC.Label {
                anchors.centerIn: parent
                text: root.sizeName
                font.bold: true
                color: root.available ? "#202020" : Kirigami.Theme.textColor
                Accessible.ignored: true
            }
        }
    }
    PC.Label {
        id: countLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: statusLabel.top
        anchors.bottomMargin: 2
        horizontalAlignment: Text.AlignHCenter
        text: root.count.toString()
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.3
        font.bold: true
        Accessible.ignored: true
    }
    PC.Label {
        id: statusLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
        horizontalAlignment: Text.AlignHCenter
        text: root.compact ? "frei" : root.available ? "frei" : "keine frei"
        font: Kirigami.Theme.smallFont
        Accessible.ignored: true
    }
}
