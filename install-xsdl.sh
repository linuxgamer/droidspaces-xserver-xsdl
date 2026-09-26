#!/usr/bin/bash

# --- detect init (pid 1) ---
INIT="$(ps -p 1 -o comm= 2>/dev/null || echo unknown)"
echo "init: $INIT"

# --- DE check: no autoinstall, just make sure some supported DE is there ---
# keep this list in sync with startxsdl
DEFOUND=""
for pair in xfce:startxfce4 kde:startplasma-x11 mate:mate-session cinnamon:cinnamon-session lxqt:startlxqt lxde:startlxde gnome:gnome-session budgie:budgie-desktop; do
    name="${pair%%:*}"
    cmd="${pair##*:}"
    if command -v "$cmd" >/dev/null; then
        DEFOUND="$DEFOUND $name"
    fi
done
if [ -z "$DEFOUND" ]; then
    echo "ERROR: no supported DE found (xfce/kde/mate/cinnamon/lxqt/lxde/gnome/budgie)"
    echo "install one of them with ur package manager first, then rerun"
    exit 1
fi
echo "detected DE:$DEFOUND"
echo "startxsdl picks one automatically, or force it: startxsdl <de>"

# --- the DE runs as whoever runs this script (root = plain unit, no changes) ---
DE_USER="${SUDO_USER:-$(id -un)}"
DE_UID="$(id -u "$DE_USER")"
DE_GID="$(id -g "$DE_USER")"
DE_HOME="$(awk -F: -v u="$DE_USER" '$1 == u {print $6}' /etc/passwd)"
echo "desktop will run as: $DE_USER"

# --- install launcher ---
sudo mv startxsdl /usr/bin

# --- install the service for ur init ---
case "$INIT" in
    systemd)
        if [ ! -d /run/systemd/system ]; then
            echo "ERROR: systemd pid1 but /run/systemd/system is missing (chroot?)"
            echo "start /usr/bin/startxsdl manually instead"
            exit 1
        fi
        if [ "$DE_USER" = "root" ]; then
            sudo mv init/xsdl.service /etc/systemd/system
        else
            sudo tee /etc/systemd/system/xsdl.service >/dev/null <<EOF
[Unit]
Description=Launches DE and connects to X-server.

[Service]
Type=simple
WorkingDirectory=-$DE_HOME
Environment=HOME=$DE_HOME
Environment=XDG_RUNTIME_DIR=/run/user/$DE_UID
User=$DE_USER
ExecStartPre=+/usr/bin/mkdir -p /run/user/$DE_UID
ExecStartPre=+/usr/bin/chown $DE_UID:$DE_GID /run/user/$DE_UID
ExecStart=/usr/bin/startxsdl

[Install]
WantedBy=multi-user.target
EOF
        fi
        sudo systemctl enable xsdl.service
        ;;
    openrc*)
        if [ "$DE_USER" = "root" ]; then
            sudo mv init/xsdl.openrc /etc/init.d/xsdl
        else
            sudo tee /etc/init.d/xsdl >/dev/null <<EOF
#!/sbin/openrc-run

description="Launches DE and connects to X-server (XSDL)."

depend() {
	need localmount
}

start_pre() {
	mkdir -p /run/user/$DE_UID
	chown $DE_UID:$DE_GID /run/user/$DE_UID
}

command="/bin/su"
command_args="-l $DE_USER -c /usr/bin/startxsdl"
EOF
        fi
        sudo chmod +x /etc/init.d/xsdl
        sudo rc-update add xsdl default
        ;;
    runit)
        sudo mkdir -p /etc/sv/xsdl
        if [ "$DE_USER" = "root" ]; then
            sudo mv init/xsdl.runit /etc/sv/xsdl/run
        else
            sudo tee /etc/sv/xsdl/run >/dev/null <<EOF
#!/bin/sh
[ -d /run/user/$DE_UID ] || {
	mkdir -p /run/user/$DE_UID
	chown $DE_UID:$DE_GID /run/user/$DE_UID
}
exec su -l '$DE_USER' -c /usr/bin/startxsdl
EOF
        fi
        sudo chmod +x /etc/sv/xsdl/run
        # enable = symlink into the service dir (path differs between distros)
        for svcdir in /run/runit/service /var/service; do
            if [ -d "$svcdir" ]; then
                sudo ln -sf /etc/sv/xsdl "$svcdir/xsdl"
                break
            fi
        done
        ;;
    *)
        echo "ERROR: init '$INIT' is not supported (systemd/openrc/runit only)"
        echo "u can still start the desktop manually: /usr/bin/startxsdl"
        exit 1
        ;;
esac

echo "gui installed! reboot to start desktop!"
echo "run install-turnip.sh to get gui acceleration on ADRENO gpus"
