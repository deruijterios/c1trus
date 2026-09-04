#!/bin/bash

echo "c1trus 1.0.5"
sleep 0.5
echo "Do not connect your device in normal mode, connect in recovery or DFU mode."

IDENTIFIER=$(irecovery -q ProductType 2>/dev/null | grep -oE 'iPhone(6|7),(1|2)' | head -n 1)
ECID=$(irecovery -q UniqueChipID 2>/dev/null)

if [[ -z "$IDENTIFIER" || -z "$ECID" ]]; then
    echo "No device detected. Is your device in normal mode?"
    echo "Please connect your device in Recovery or DFU mode."
    exit 1
fi

echo "Device detected: $IDENTIFIER"
echo "ECID: $ECID"

if [[ $IDENTIFIER == iPhone6,1 ]]; then
    SEP="sep-firmware.n51.RELEASE.im4p"
    KERNELCACHE10="kernelcache.release.n51"
    DEVICETREE="DeviceTree.n51ap.im4p"

    sudo rm -rf "tmpmanifest"
    mkdir -p tmpmanifest

    cd tmpmanifest
    curl -L -o Manifest.plist https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/resources/manifest/BuildManifest_iPhone6,1_10.3.3.plist
    cd ..

    MANIFEST="tmpmanifest/Manifest.plist"
fi

if [[ $IDENTIFIER == iPhone6,2 ]]; then
    SEP="sep-firmware.n53.RELEASE.im4p"
    KERNELCACHE10="kernelcache.release.n53"
    DEVICETREE="DeviceTree.n53ap.im4p"

    sudo rm -rf "tmpmanifest"
    mkdir -p tmpmanifest

    cd tmpmanifest
    curl -L -o Manifest.plist https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/resources/manifest/BuildManifest_iPhone6,2_10.3.3.plist
    cd ..

    MANIFEST="tmpmanifest/Manifest.plist"
fi

sleep 0.5

echo "Checking for installed or required dependencies..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    dist=3
    DISTRO="macos"

else
    dist=0
    DISTRO="unknown"
fi

if [[ $dist == 3 ]]; then

    echo "macOS detected."

    if ! command -v brew &>/dev/null; then
        echo "[!] Homebrew is not installed."
        echo "Please install Homebrew first."
        echo "https://brew.sh"
        exit 1
    fi

    DEPENDENCIES=(
        libusb
        libusbmuxd
        libimobiledevice
        zenity
        git
        curl
        make
        python
    )

    MISSING_PACKAGES=()

    for pkg in "${DEPENDENCIES[@]}"; do
        if ! brew list --formula "$pkg" &>/dev/null; then
            MISSING_PACKAGES+=("$pkg")
        fi
    done

    if [ ${#MISSING_PACKAGES[@]} -ne 0 ]; then
        echo "Missing packages detected: ${MISSING_PACKAGES[*]}"
        echo "Installing missing dependencies..."

        brew update || true
        brew install "${MISSING_PACKAGES[@]}"
    else
        echo "All dependencies are installed."
    fi

elif [[ "$DISTRO" == "unknown" ]]; then

    echo "Unsupported OS, are you on Linux?"
    sleep 0.5
    echo "c1trus only supports macOS systems, Linux support will come eventually."
    exit 1

fi

stat_size() {
    if stat -c %s "$1" >/dev/null 2>&1; then
        stat -c %s "$1"
    else
        stat -f %z "$1"
    fi
}

find_dmg() {
    dir="$1"
    mode="$2"
    max_size="${3:-}"

    find "$dir" -type f -name '*.dmg' ! -name '._*' -print |
    while IFS= read -r f; do
        size=$(stat_size "$f") || continue

        if [[ -n "$max_size" && "$size" -ge "$max_size" ]]; then
            continue
        fi

        printf '%s %s\n' "$size" "$f"
    done |
    if [[ "$mode" == "smallest" ]]; then
        sort -n
    else
        sort -nr
    fi |
    head -n 1 |
    cut -d' ' -f2-
}

find_dmg_arm64e() {
    dir="$1"
    mode="$2"
    max_size="${3:-}"

    find "$dir" -type f -name '*.dmg*' ! -name '._*' -print |
    while IFS= read -r f; do
        size=$(stat_size "$f") || continue

        if [[ -n "$max_size" && "$size" -ge "$max_size" ]]; then
            continue
        fi

        printf '%s %s\n' "$size" "$f"
    done |
    if [[ "$mode" == "smallest" ]]; then
        sort -n
    else
        sort -nr
    fi |
    head -n 1 |
    cut -d' ' -f2-
}

require_file() {
    if [[ ! -f "$1" ]]; then
        echo "Required file missing: $1"
        exit 1
    fi
}

require_dir() {
    if [[ ! -d "$1" ]]; then
        echo "Required directory missing: $1"
        exit 1
    fi
}


while true; do
    clear

    echo "c1trus 1.0.5"
    echo "1) Downgrade to iOS 11.4.1-12.5.7"
    echo "2) Downgrade to iOS 10.3.3 untethered"
    echo "3) Exit"

    read -r -p "Select: " choice

    case "$choice" in

        1)
            IDENTIFIER=$(irecovery -q ProductType 2>/dev/null | grep -oE 'iPhone(7),(1|2)' | head -n 1)

            case "$IDENTIFIER" in
                iPhone7,1|iPhone7,2)
                    echo "Supported: $IDENTIFIER"
                    echo "c1trus is still under development, use it carefully."

                    sleep 1

                    echo "iOS 11.4.1-12.5.7 downgrade support is still under development and testing."

                    exit 1
                    ;;

                *)
                    echo "Only supported on iPhone7,1 or iPhone7,2."
                    echo "Detected: [$IDENTIFIER]"
                    ;;
            esac

            read -r -p "Press Enter to continue..."
            ;;


        2)

            IDENTIFIER=$(irecovery -q ProductType 2>/dev/null | grep -oE 'iPhone(6),(1|2)' | head -n 1)
            ECID=$(irecovery -q UniqueChipID 2>/dev/null)

            case "$IDENTIFIER" in
                iPhone6,1|iPhone6,2)
                    echo "Supported: $IDENTIFIER"
                    echo "ECID: $ECID"
                    echo "c1trus is still under development, use it carefully."
                    echo "Restoring to iOS 10.3.3..."

                    sleep 1

                    echo "You need to put your device in pwned DFU mode, please put your device in DFU mode firstly."

                    sleep 1

                    read -r -p "When you are ready, press enter to continue."

                    ./bin/ipwnder -p
                    sleep 1

                    if irecovery -q 2>/dev/null | grep -q "PWND"; then

                        echo "Device is in pwned DFU mode."

                    else

                        echo "Device is not pwned DFU mode. Try again."
                        exit 1

                    fi

                IPSW=$(zenity --file-selection \
                --title="Choose the iOS 10.3.3 IPSW file." \
                --file-filter="IPSW Files | *.ipsw")

                if [ -z "$IPSW" ]; then
                echo "IPSW file not selected. Exiting..."
                exit 1
                    fi

                    echo "extracting ipsw"

                    mkdir -p tmp
                    mkdir -p tmp/Firmware
                    mkdir -p tmp/Firmware/all_flash

                    unzip -j "$IPSW" \
                        "Firmware/all_flash/$SEP" \
                        -d tmp/Firmware/all_flash

                    SEP_PATH="tmp/Firmware/all_flash/$SEP"


                    echo "Fetching shsh blobs for iOS 10.3.3"

                    mkdir -p shsh

                    sudo ./bin/tsschecker \
                        -d "$IDENTIFIER" \
                        -s \
                        -e "$ECID" \
                        -i 10.3.3 \
                        -o \
                        -m "$MANIFEST" \
                        --save-path shsh


                    shshpath=$(find shsh -type f -name "*.shsh2" -print | sort | head -n 1)


                    if [[ -z "$shshpath" ]]; then

                        echo "SHSH not found. Try again."
                        exit 1

                    fi


                    sudo FUTURERESTORE_I_SOLEMNLY_SWEAR_THAT_I_AM_UP_TO_NO_GOOD=1 \
                        ./bin/futurerestore_macos-main \
                        -t "$shshpath" \
                        --use-pwndfu \
                        --latest-baseband \
                        --sep "$SEP_PATH" \
                        --sep-manifest "$MANIFEST" \
                        --no-rsep \
                        "$IPSW"


                    echo "Restore has finished! Read above if there's any errors"

                    sudo rm -rf "tmp"
                    sudo rm -rf "tmpmanifest"
                    sudo rm -rf "shsh"

                    exit 0

                    ;;

                *)
                    echo "Only supported on iPhone6,1 or iPhone6,2."
                    echo "Detected: [$IDENTIFIER]"
                    ;;
            esac

            read -r -p "Press Enter to continue..."
            ;;


        3)
            echo "Exiting..."
            exit 1
            ;;


        *)
            echo "Invalid option."
            exit 1
            ;;

    esac
done