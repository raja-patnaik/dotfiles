#!/usr/bin/env bash
# OS Detection Script
# Returns the operating system type and version

set -euo pipefail

# Function to detect OS
detect_os() {
    local os=""
    local version=""
    local distro=""
    local is_wsl=false

    # Check for WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        is_wsl=true
    fi

    # Detect OS type
    case "$OSTYPE" in
        linux*)
            os="linux"
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                distro="$ID"
                version="$VERSION_ID"
            elif [[ -f /etc/redhat-release ]]; then
                distro="rhel"
                version=$(rpm -E %{rhel})
            elif [[ -f /etc/debian_version ]]; then
                distro="debian"
                version=$(cat /etc/debian_version)
            fi

            if [[ "$is_wsl" == true ]]; then
                os="wsl"
            fi
            ;;

        darwin*)
            os="macos"
            version=$(sw_vers -productVersion)

            # Detect architecture
            if [[ $(uname -m) == "arm64" ]]; then
                distro="apple-silicon"
            else
                distro="intel"
            fi
            ;;

        msys*|mingw*|cygwin*)
            os="windows"
            distro="git-bash"
            version=$(uname -r)
            ;;

        freebsd*)
            os="freebsd"
            version=$(uname -r)
            ;;

        *)
            os="unknown"
            ;;
    esac

    # Output JSON format
    cat <<EOF
{
  "os": "$os",
  "distro": "$distro",
  "version": "$version",
  "is_wsl": $is_wsl,
  "kernel": "$(uname -r)",
  "arch": "$(uname -m)",
  "hostname": "$(hostname)"
}
EOF
}

# Function to check if running in container
is_container() {
    if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to get package manager
get_package_manager() {
    local pm=""

    # Check for various package managers
    if command -v apt-get &>/dev/null; then
        pm="apt"
    elif command -v yum &>/dev/null; then
        pm="yum"
    elif command -v dnf &>/dev/null; then
        pm="dnf"
    elif command -v pacman &>/dev/null; then
        pm="pacman"
    elif command -v zypper &>/dev/null; then
        pm="zypper"
    elif command -v brew &>/dev/null; then
        pm="brew"
    elif command -v port &>/dev/null; then
        pm="macports"
    elif command -v pkg &>/dev/null; then
        pm="pkg"
    elif command -v scoop &>/dev/null; then
        pm="scoop"
    elif command -v winget &>/dev/null; then
        pm="winget"
    elif command -v choco &>/dev/null; then
        pm="choco"
    else
        pm="unknown"
    fi

    echo "$pm"
}

# Function to check for systemd
has_systemd() {
    if command -v systemctl &>/dev/null && systemctl list-units &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# Main execution
main() {
    local cmd="${1:-detect}"

    case "$cmd" in
        detect)
            detect_os
            ;;
        package-manager|pm)
            get_package_manager
            ;;
        is-container|container)
            is_container
            ;;
        has-systemd|systemd)
            has_systemd
            ;;
        simple)
            # Simple output for scripts
            case "$OSTYPE" in
                linux*) echo "linux" ;;
                darwin*) echo "macos" ;;
                msys*|mingw*|cygwin*) echo "windows" ;;
                *) echo "unknown" ;;
            esac
            ;;
        *)
            cat <<EOF
Usage: $(basename "$0") [COMMAND]

Commands:
  detect           Detect OS and output JSON (default)
  package-manager  Get the system package manager
  is-container     Check if running in a container
  has-systemd      Check if systemd is available
  simple           Output simple OS name

Examples:
  $(basename "$0")
  $(basename "$0") package-manager
  $(basename "$0") simple
EOF
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi