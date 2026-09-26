EN:
script to setup droidspaces debian13xfce rootfs to use "xserver xsdl" app instead of bloatware termux-x11/termux
install-xsdl.sh detects ur init (systemd/openrc/runit) and installs a matching service file
startxsdl detects ur DE (xfce/kde/mate/cinnamon/lxqt/lxde/gnome/budgie) and starts it, or force one: startxsdl kde
any supported DE must be installed beforehand, distro doesnt matter
install-turnip.sh detects ur distro (debian/ubuntu/fedora/alpine/arch/void), downloads the matching build from lfdevs/mesa-for-android-container into turnip/ and extracts it to /
needs an ADRENO gpu + MESA_LOADER_DRIVER_OVERRIDE=kgsl (script prints how)
tested adrenos: 660 710 720 722 730 732 735 740 750 810 829 830 840, script warns if urs is untested

RU:
скриптик чтоб debian13xfce rootfs из droidspaces юзала нормальный "xserver xsdl" а не тяжелый termux/termux-x11
install-xsdl.sh сам определяет init (systemd/openrc/runit) и ставит под него свой сервис-файл
startxsdl сам определяет DE (xfce/kde/mate/cinnamon/lxqt/lxde/gnome/budgie) и стартует её, либо укажи явно: startxsdl kde
любая поддерживаемая DE должна быть уже установлена, дистрибутив не важен
install-turnip.sh сам определяет дистр (debian/ubuntu/fedora/alpine/arch/void), качает подходящую сборку из lfdevs/mesa-for-android-container в turnip/ и распаковывает в /
нужен gpu ADRENO + MESA_LOADER_DRIVER_OVERRIDE=kgsl (скрипт подскажет как)
протестированные adreno: 660 710 720 722 730 732 735 740 750 810 829 830 840, скрипт предупредит если твоя не в списке
