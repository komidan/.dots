#!/usr/bin/env bash
# UPDATE.SH   - script to update debian raspberry pi simply and easily
# -e          ; exit immediately if command fails
# -u          ; treat unset variables as errors
# -o pipefail ; false | true exits with 1 instead of 0
# -x          ; prints commands before it runs, debugging
set -euo pipefail

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

# Logging Helpers
info() { echo -e "${PURPLE}INFO ${WHITE}» ${NC}$1"; }
error() { echo -e " ${RED}ERR ${WHITE}» ${NC}$1" >&2; }

step() {
    echo -ne "${CYAN}STEP ${WHITE}» ${NC}$1..."
    if shift && "$@" >/dev/null 2>&1; then
        echo -e " ${GREEN}done${NC}"
    else
        echo -e " ${RED}failed ${WHITE}(${RED}$?${WHITE})${NC}"
        return 1
    fi
}

source /etc/os-release
echo -e "${CYAN}${PRETTY_NAME}${NC}"

# Show upgradable package information in a list
UPGRADEABLE=$(apt list --upgradeable 2>/dev/null | tail -n +2 | wc -l)
HELD=$(apt-mark showhold 2>/dev/null | wc -l)

echo -e "  ${YELLOW}${UPGRADEABLE}${WHITE} Package(s) available to upgrade${NC}"
if (( UPGRADEABLE > 0)); then
    echo -e "      ${BLUE}$(apt-get -s upgrade | awk '$1 == "Inst" {print $2}')${NC}"
fi
echo -e "  ${YELLOW}${HELD}${WHITE} Package(s) on-hold: ${NC}"
echo -e "      ${BLUE}$(apt-mark showhold)${NC}"

if (( UPGRADEABLE < 1 )); then
    exit
fi

# Verify wanting to upgrade system
echo -e "${YELLOW}Press any key to continue, Ctrl+C to abort.${NC}"
read -r -n 1 -s
echo

# Info Variables
START_USED_TOTAL=$(df / --output=used -B1 | tail -1)
START_USED_CACHE=$(du -sb /var/cache/apt | cut -f1)
PKGS_PRE=$(dpkg -l 2>/dev/null | wc -l)

step "Updating package list" apt update
step "Upgrading packages" apt upgrade -y
step "Full-upgrading system" apt full-upgrade -y
step "Removing unused dependencies" apt autoremove -y 2>/dev/null
step "Cleaning apt cache" apt autoclean -y
apt clean # just another step
step "Trimming system logs (<7days)" journalctl --vacuum-time=7d 2>/dev/null

# used space after update
END_USED_TOTAL=$(df / --output=used -B1 | tail -1)
END_USED_CACHE=$(du -sb /var/cache/apt | cut -f1)

# Math
FREED_TOTAL=$((START_USED_TOTAL - END_USED_TOTAL))
FREED_TOTAL_MB=$((FREED_TOTAL / 1024 / 1024))
FREED_CACHE=$((START_USED_CACHE - END_USED_CACHE))
FREED_CACHE_MB=$((FREED_CACHE / 1024 / 1024))

# get difference in package cleanup
PKGS_POST=$(dpkg -l 2>/dev/null | wc -l)
REMOVED=$((PKGS_PRE - PKGS_POST))

if (( $REMOVED < 0 )); then
    REMOVED=$(( -REMOVED ))
    info "Added $REMOVED packages/dependencies"
elif (( $REMOVED > 0 )); then
    info "Removed $REMOVED packages/dependencies"
else
    info "No new packages/dependencies"
fi

info "Freed ${FREED_TOTAL_MB} MB in total"
info "Freed ${FREED_CACHE_MB} MB from cache (/var/cache/apt)"
info "DISK USAGE $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
