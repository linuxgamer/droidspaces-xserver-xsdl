# anland sub-project

Alternative display backend: instead of Xserver XSDL, the desktop runs on [anland](https://github.com/SuperTurtleDev/anland) — a Wayland host for Android where **every Linux window is a real native Android window** (own entry in the app switcher, split-screen, per-window keyboard). X11 apps work too, via anland's rootless Xwayland.

## Requirements (read this first)

- **ROOTED device** — unlike the XSDL setup, anland needs root: a SukiSU/KernelSU module + host APK on the android side
- arm64, droidspaces (or similar) container
- the anland host side must be installed: module + APK, see the [anland repo](https://github.com/SuperTurtleDev/anland)

## Setup

1. host side (android): install the `anland-awl` module + host APK
2. container side: extract the CI artifact and run its setup script:

```sh
tar xzf anlandx.tar.gz && bash anlandx/setupanlandx.sh
```

3. install a DE with a wayland session (see table below)
4. then, from this folder:

```sh
./install-anland.sh
```

The script auto-detects ur init (systemd/openrc/runit), installs `startanland` + a matching service, and warns if the old `xsdl.service` is still enabled (two desktops would fight over the display).

## Supported DEs here

| DE | wayland session | notes |
|---|---|---|
| kde | `startplasma-wayland` | best wayland support |
| gnome | `gnome-session` | native wayland |
| xfce | `xfce4-session` | experimental, xfce 4.20+, needs `labwc` |
| lxqt | `startlxqtwayland` | experimental |

X11-only DEs (mate, cinnamon, lxde, budgie) are **not supported as desktops here** — they belong on the XSDL side. Individual X11 apps still work through anland's rootless Xwayland.

## GPU

Use the turnip script from the repo root: `../install-turnip.sh`. The pinned build (26.3.0+) is exactly the version that adds anland support.

## Caveats

- 6.x (main branch) is an active rewrite and not yet as feature-complete as 5.x; 5.x (legacy branch) is recommended by the author for the full desktop experience
- the DE starts only when the anlandx session is up; if the container boots before the host daemon, the systemd unit will retry (`Restart=on-failure`), on other inits just restart the service or launch via `startanland` / anland-shell manually
- keep only ONE display service enabled: either `xsdl.*` or `anland.*`
- the DE runs as whoever ran the installer (root in a stock droidspaces rootfs); non-root users get a proper per-user service — but then the anlandx session must run as THAT SAME user, the wayland socket is per-user (`/run/user/<uid>`) and `startanland` wont find it otherwise

## Credits

- anland: [SuperTurtleDev/anland](https://github.com/SuperTurtleDev/anland) (GPL-3.0)
- this sub-project only adds launcher/init scripts for it; all the hard work is theirs

---

## RU

Альтернативный вывод: вместо Xserver XSDL десктоп работает на [anland](https://github.com/SuperTurtleDev/anland) — Wayland-хосте для Android, где каждое Linux-окно является настоящим нативным Android-окном (свитчер, split-screen, своя клавиатура). X11-приложения тоже работают через rootless Xwayland.

**Важно: нужен РУТ** (в отличие от варианта с XSDL) — модуль SukiSU/KernelSU + host APK на стороне Android, arm64, контейнер droidspaces.

**Установка:** 1) поставить host-часть anland (модуль + APK); 2) в контейнере распаковать CI-артефакт и выполнить `bash anlandx/setupanlandx.sh`; 3) поставить DE с wayland-сессией; 4) из этой папки — `./install-anland.sh` (сам определит init, поставит `startanland` + сервис и предупредит, если включён старый `xsdl.service`).

**DE:** kde и gnome — нативный wayland; xfce (4.20+, нужен labwc) и lxqt — экспериментально. mate/cinnamon/lxde/budgie как десктопы тут не поддерживаются (это к XSDL), но отдельные X11-приложения работают.

**GPU:** `../install-turnip.sh` — зафиксированная сборка 26.3.0+ как раз та, что добавила поддержку anland.

**Нюансы:** 6.x ещё не догнала 5.x по функциям (для полного десктопа автор советует 5.x); сервис стартует DE только при поднятом anlandx (systemd-юнит сам перезапускается, на остальных init — руками); держи включённым только ОДИН дисплейный сервис — `xsdl.*` или `anland.*`. DE запускается от того юзера, кто запускал установщик (в стандартном rootfs это root); если юзер не root — сессия anlandx должна работать от того же юзера, wayland-сокет пользовательский (`/run/user/<uid>`), иначе `startanland` его не найдёт.
