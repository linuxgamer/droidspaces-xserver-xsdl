#!/usr/bin/bash

# turnip (adreno vulkan) builds, source: https://github.com/lfdevs/mesa-for-android-container
# bump TAG when a new release drops; assets are named turnip_<ver>_<distro>_arm64.tar.gz
TAG="turnip-26.3.0-devel-20260824"
VER="${TAG#turnip-}"  # 26.3.0-devel-20260824
URL="https://github.com/lfdevs/mesa-for-android-container/releases/download/$TAG"

# --- arch check: builds are arm64 only ---
ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ]; then
    echo "ERROR: arch is '$ARCH' but these builds are arm64 only"
    exit 1
fi

# --- gpu check: SOFT warning, containers often hide gpu info ---
GPU_MODEL="$(cat /sys/class/kgsl/kgsl-3d0/gpu_model 2>/dev/null)"
if [ -z "$GPU_MODEL" ] && command -v getprop >/dev/null; then
    GPU_MODEL="$(getprop ro.soc.model 2>/dev/null)"
fi
SUPPORTED="660 710 720 722 730 732 735 740 750 810 829 830 840"
case "$GPU_MODEL" in
    *[Aa]dreno*)
        MODEL="$(printf '%s' "$GPU_MODEL" | grep -o '[0-9]\{3\}' | head -1)"
        # unquoted on purpose: splits the list into one model per line
        # shellcheck disable=SC2086
        if [ -n "$MODEL" ] && printf '%s\n' $SUPPORTED | grep -qx "$MODEL"; then
            echo "gpu: $GPU_MODEL ($MODEL) — in the tested list"
        elif [ -n "$MODEL" ]; then
            echo "WARNING: adreno $MODEL is not in the tested list ($SUPPORTED)"
            echo "it may still work, continuing anyway"
        else
            echo "WARNING: could not parse adreno model from '$GPU_MODEL', continuing anyway"
        fi
        ;;
    *)
        echo "WARNING: adreno gpu not detected (ur container may just hide /dev/kgsl)"
        echo "if u DO have a supported adreno, ignore this and continue"
        ;;
esac

# --- detect distro and pick the matching build ---
# shellcheck disable=SC1091
. /etc/os-release 2>/dev/null
ID="${ID:-unknown}"
echo "distro: ${PRETTY_NAME:-unknown}"

case "$ID" in
    debian) ASSET="turnip_${VER}_debian_${VERSION_CODENAME:-trixie}_arm64.tar.gz" ;;
    ubuntu) ASSET="turnip_${VER}_ubuntu_${VERSION_CODENAME}_arm64.tar.gz" ;;
    fedora) ASSET="turnip_${VER}_fedora_${VERSION_ID%%.*}_arm64.tar.gz" ;;
    alpine) ASSET="turnip_${VER}_alpine_${VERSION_ID%.*}_arm64.tar.gz" ;;
    arch)
        # arch gets a pacman pkg instead, and its name doesn't follow turnip_<ver>
        # the trailing pkg rev (-1) can change between releases, bump it with TAG
        ASSET="vulkan-freedreno-1-${VER%%-*}-1-aarch64.pkg.tar.xz"
        ;;
    void)   ASSET="turnip_${VER}_void_arm64.tar.gz" ;;
    *)
        echo "ERROR: distro '$ID' not supported (debian/ubuntu/fedora/alpine/arch/void)"
        echo "check releases manually: $URL"
        exit 1
        ;;
esac
echo "picked build: $ASSET"

# --- downloader: curl or wget, whichever exists ---
if command -v curl >/dev/null; then
    DL="curl -fL --progress-bar -o"
elif command -v wget >/dev/null; then
    DL="wget -q --show-progress -O"
else
    echo "ERROR: need curl or wget to download"
    exit 1
fi

# --- download into turnip/ (created at runtime, gitignored) ---
mkdir -p turnip
cd turnip || exit 1
echo "downloading $ASSET..."
$DL "$ASSET" "$URL/$ASSET" || {
    rm -f "$ASSET"
    echo "ERROR: download failed for '$ASSET'"
    echo "ur distro version may have no build; assets available in $TAG:"
    curl -fsSL "https://api.github.com/repos/lfdevs/mesa-for-android-container/releases/tags/$TAG" 2>/dev/null \
        | grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 | sed 's/^/  /' \
        || echo "  (could not list them, check: $URL)"
    exit 1
}

# --- extract to / and refresh linker cache ---
echo "extracting to / ..."
case "$ASSET" in
    *.gz) sudo tar -xzf "$ASSET" -C / ;;
    *)    sudo tar -xf "$ASSET" -C / ;;
esac
sudo ldconfig || echo "WARNING: ldconfig failed, u may need to restart the container"

echo "done! to actually use turnip set the loader override, e.g.:"
echo "  echo 'MESA_LOADER_DRIVER_OVERRIDE=kgsl' | sudo tee -a /etc/environment"
echo "  or per-app: MESA_LOADER_DRIVER_OVERRIDE=kgsl <app>"
