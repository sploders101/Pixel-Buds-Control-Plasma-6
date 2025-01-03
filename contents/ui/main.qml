import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support 2.0 as Plasma5Support

PlasmoidItem {
    id: root
    // Your further code
    Plasmoid.icon: Qt.resolvedUrl("../earbuds-outline.svg")
    property bool expanded: Plasmoid.expanded

    width: 50
    height: 40

    Plasma5Support.DataSource {
        id: backend
        engine: "executable"
        connectedSources: []

        property string soundMode
        property string getSoundModeCmd: "pbpctrl get anc"
        property string setSoundModeCmd: "pbpctrl set anc "

        onNewData: function(source, data) {
            switch(source) {
                case getSoundModeCmd:
                    soundMode = data.stdout.replace("\n", "");
                    break;
            }
            disconnectSource(source);
        }

        function getSoundMode() {
            connectSource(getSoundModeCmd);
        }
        function setSoundMode(mode) {
            connectSource(setSoundModeCmd + mode);
            soundMode = mode
            if (soundModePoller.running) {
                soundModePoller.skipOne = true;
            }
        }

        Component.onCompleted: {
            getSoundMode();
        }
    }

    fullRepresentation: GridLayout {
        Timer {
            id: soundModePoller

            interval: 1000
            running: root.expanded
            repeat: true
            triggeredOnStart: true

            onTriggered: {
                if (skipOne) {
                    skipOne = false;
                } else {
                    backend.getSoundMode();
                }
            }

            property bool skipOne: false
        }
        ColumnLayout {
            width: 300
            RadioButton {
                text: "Transparency"
                checked: backend.soundMode === "aware"
                onClicked: backend.setSoundMode("aware")
                Layout.fillWidth: true
            }
            RadioButton {
                text: "Noise Cancelling"
                checked: backend.soundMode === "active"
                onClicked: backend.setSoundMode("active")
            }
            RadioButton {
                text: "Off"
                checked: backend.soundMode === "off"
                onClicked: backend.setSoundMode("off")
                Layout.fillWidth: true
            }
        }
    }
}
