EN:
script to setup droidspaces debian13xfce rootfs to use "xserver xsdl" app instead of bloatware termux-x11/termux
install-xsdl.sh detects ur init (systemd/openrc/runit) and installs a matching service file
startxsdl detects ur DE (xfce/kde/mate/cinnamon/lxqt/lxde/gnome/budgie) and starts it, or force one: startxsdl kde
any supported DE must be installed beforehand, distro doesnt matter

RU:
скриптик чтоб debian13xfce rootfs из droidspaces юзала нормальный "xserver xsdl" а не тяжелый termux/termux-x11
install-xsdl.sh сам определяет init (systemd/openrc/runit) и ставит под него свой сервис-файл
startxsdl сам определяет DE (xfce/kde/mate/cinnamon/lxqt/lxde/gnome/budgie) и стартует её, либо укажи явно: startxsdl kde
любая поддерживаемая DE должна быть уже установлена, дистрибутив не важен
