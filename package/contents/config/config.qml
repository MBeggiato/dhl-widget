import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "Packstation"
        icon: Qt.resolvedUrl("../images/packstation.svg").toString()
        source: "configGeneral.qml"
    }
}
