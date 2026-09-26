# XSDL-droidspaces

Run a full Linux desktop inside an Android container (droidspaces / proot / chroot / LXC) and display it with **Xserver XSDL** instead of the bloaty termux + termux-x11 combo.

```
┌────────────────────────── android ───────────────────────────┐
│  ┌── container (arm64 rootfs) ──┐    ┌── Xserver XSDL app ─┐ │
│  │ DE (xfce/kde/mate/...)       │──► │ X11  :0             │ │
│  │ startxsdl                    │──► │ pulseaudio :4713    │ │
│  │ [turnip vulkan for adreno]   │    └─────────────────────┘ │
│  └──────────────────────────────┘                            │
└──────────────────────────────────────────────────────────────┘
```

The container pushes X11 + audio over localhost to XSDL. A tiny init service starts the desktop on every container boot.

## What's inside

| file | what it does |
|---|---|
| `install-xsdl.sh` | detects ur init, installs `startxsdl` + a matching service file |
| `startxsdl` | sets `DISPLAY`/`PULSE_SERVER`, autodetects ur DE and starts it |
| `init/xsdl.service` | systemd unit |
| `init/xsdl.openrc` | openrc script |
| `init/xsdl.runit` | runit run script |
| `install-turnip.sh` | downloads + installs turnip (vulkan for adreno), optional |
| `anland/` | optional sub-project: same setup but for the [anland](https://github.com/SuperTurtleDev/anland) wayland host — native android windows instead of one XSDL screen (rooted devices only, see `anland/README.md`) |

## Quick start

inside ur container:

```sh
# 1. install a DE with ur own package manager, e.g. on debian:
sudo apt install xfce4 xfce4-terminal

# 2. install the service
./install-xsdl.sh

# 3. (optional) 3d acceleration on adreno gpus
./install-turnip.sh
```

open **Xserver XSDL** on ur phone, reboot the container — desktop should pop up.

## Supported

- **init:** systemd, openrc, runit (unknown init = manual start hint, no crash)
- **DE:** xfce, kde, mate, cinnamon, lxqt, lxde, gnome, budgie — autodetected, force one with `startxsdl kde`
- **turnip distros:** debian (trixie), ubuntu (noble/questing/resolute), fedora (43/44), alpine (3.24), arch, void
- **gpus:** arm64 + adreno only. tested adrenos: 660 710 720 722 730 732 735 740 750 810 829 830 840 (others *may* work, the script just warns)

all scripts auto-detect stuff and tell u what they found; nothing gets auto-installed behind ur back.

## Troubleshooting

- **"systemd pid1 but /run/systemd/system is missing"** — ur inside a chroot/proot nested on a systemd host. the unit wont work there; start `/usr/bin/startxsdl` manually.
- **turnip: "adreno gpu not detected"** — ur container hides `/dev/kgsl`. if u know ur phone has a tested adreno, ignore the warning.
- **turnip installed but no vulkan** — set the driver override: `echo 'MESA_LOADER_DRIVER_OVERRIDE=kgsl' | sudo tee -a /etc/environment`, or per-app: `MESA_LOADER_DRIVER_OVERRIDE=kgsl <app>`.
- **uninstall turnip** — see [lfdevs/mesa-for-android-container](https://github.com/lfdevs/mesa-for-android-container): delete the files from the tarball (`tar tf`) and reinstall ur distro's mesa packages.
- **black screen / no audio** — XSDL app must be running (or use its "keep running in background" setting); check `DISPLAY=127.0.0.1:0` and `PULSE_SERVER=tcp:127.0.0.1:4713`.

## Credits

- turnip builds: [lfdevs/mesa-for-android-container](https://github.com/lfdevs/mesa-for-android-container)
- [Xserver XSDL](https://github.com/pelya/commandergenius) by pelya

## License

GPL-3.0 — see [LICENSE](LICENSE).

---

## RU

Полноценный Linux-десктоп внутри контейнера на Android (droidspaces / proot / chroot / LXC) с выводом через приложение **Xserver XSDL** вместо громоздкого termux + termux-x11.

**Установка** (внутри контейнера):

```sh
# 1. поставить DE своим пакетным менеджером, например на debian:
sudo apt install xfce4 xfce4-terminal

# 2. поставить сервис
./install-xsdl.sh

# 3. (опционально) 3d-ускорение на adreno
./install-turnip.sh
```

Открыть **Xserver XSDL** на телефоне, перезапустить контейнер — рабочий стол появится сам.

**Поддерживается:** init — systemd/openrc/runit; DE — xfce/kde/mate/cinnamon/lxqt/lxde/gnome/budgie (`startxsdl kde` — явно указать); turnip — debian trixie / ubuntu noble,questing,resolute / fedora 43,44 / alpine 3.24 / arch / void; только arm64 + adreno (протестированы: 660 710 720 722 730 732 735 740 750 810 829 830 840).

**Частые проблемы:** systemd-ошибка в chroot — запускать `/usr/bin/startxsdl` руками; «adreno not detected» — контейнер скрывает `/dev/kgsl`, предупреждение можно игнорировать; vulkan не работает — `MESA_LOADER_DRIVER_OVERRIDE=kgsl`; чёрный экран/нет звука — XSDL должен быть запущен, проверь `DISPLAY=127.0.0.1:0` и `PULSE_SERVER=tcp:127.0.0.1:4713`.

**Альтернатива для рутированных устройств:** [anland](https://github.com/SuperTurtleDev/anland) — каждое Linux-окно становится настоящим нативным Android-окном. Скрипты запуска под него лежат в [anland/README.md](anland/README.md).
