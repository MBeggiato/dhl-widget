#!/usr/bin/env bash
# Install the current local source tree, then reload only the Plasma shell.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ID=de.local.packstation
for tool in kpackagetool6 systemctl; do
    command -v "$tool" >/dev/null || { printf 'Fehlendes Werkzeug: %s\n' "$tool" >&2; exit 1; }
done
[[ -f "$ROOT/package/metadata.json" ]] || { echo 'Widget-Paket nicht gefunden.' >&2; exit 1; }
if ! systemctl --user cat plasma-plasmashell.service >/dev/null 2>&1; then
    echo 'Plasma-Systemd-Dienst nicht verfügbar. Keine Installation und kein Neustart durchgeführt.' >&2
    exit 1
fi
if kpackagetool6 --type Plasma/Applet --show "$ID" >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$ROOT/package"
else
    kpackagetool6 --type Plasma/Applet --install "$ROOT/package"
fi
printf '\nWidget installiert. Desktop und Panel werden kurz neu geladen; Anwendungen bleiben geöffnet.\n'
systemctl --user restart plasma-plasmashell.service
systemctl --user is-active --quiet plasma-plasmashell.service
printf 'Fertig: Packstation aktualisiert und Plasma neu gestartet.\n'
