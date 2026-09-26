#!/usr/bin/bash

# --- detect init (pid 1) ---
INIT="$(ps -p 1 -o comm= 2>/dev/null || echo unknown)"
echo "init: $INIT"

# --- DE check: wayland sessions only, no autoinstall ---
# keep this list in sync with startanland
DEFOUND=""
for pair in kde:startplasma-wayland gnome:gnome-session xfce:xfce4-session lxqt:startlxqtwayland; do
    name="${pair%%:*}"
    cmd="${pair##*:}"
    if command -v "$cmd" >/dev/null; then
        DEFOUND="$DEFOUND $name"
    fi
done
if [ -z "$DEFOUND" ]; then
    echo "ERROR: no supported wayland DE found (kde/gnome/xfce/lxqt)"
    echo "install one of them with ur package manager first, then rerun"
    exit 1
fi
echo "detected DE:$DEFOUND"

# --- install launcher ---
sudo mv startanland /usr/bin

# --- warn if the xsdl service is still enabled (two DEs would fight) ---
case "$INIT" in
    systemd)
        if systemctl is-enabled xsdl.service >/dev/null 2>&1; then
            echo "WARNING: xsdl.service is still enabled"
            echo "disable it: sudo systemctl disable xsdl.service"
        fi
        ;;
    openrc*)
        rc-update show default | grep -q xsdl && echo "WARNING: xsdl still in default runlevel, remove with: sudo rc-update del xsdl default"
        ;;
    runit)
        for svcdir in /run/runit/service /var/service; do
            [ -L "$svcdir/xsdl" ] && echo "WARNING: xsdl runit service enabled, unlink: sudo rm $svcdir/xsdl" && break
        done
        ;;
esac

# --- install the service for ur init ---
case "$INIT" in
    systemd)
        if [ ! -d /run/systemd/system ]; then
            echo "ERROR: systemd pid1 but /run/systemd/system is missing (chroot?)"
            echo "start /usr/bin/startanland manually instead"
            exit 1
        fi
        sudo mv init/anland.service /etc/systemd/system
        sudo systemctl enable anland.service
        ;;
    openrc*)
        sudo mv init/anland.openrc /etc/init.d/anland
        sudo chmod +x /etc/init.d/anland
        sudo rc-update add anland default
        ;;
    runit)
        sudo mkdir -p /etc/sv/anland
        sudo mv init/anland.runit /etc/sv/anland/run
        sudo chmod +x /etc/sv/anland/run
        # enable = symlink into the service dir (path differs between distros)
        for svcdir in /run/runit/service /var/service; do
            if [ -d "$svcdir" ]; then
                sudo ln -sf /etc/sv/anland "$svcdir/anland"
                break
            fi
        done
        ;;
    *)
        echo "ERROR: init '$INIT' is not supported (systemd/openrc/runit only)"
        echo "u can still start the desktop manually: /usr/bin/startanland"
        exit 1
        ;;
esac

echo "anland gui installed! the DE will start when the anlandx session is up"
echo "gpu part: run ../install-turnip.sh (need 26.3.0+ build for anland, which we pin)"
