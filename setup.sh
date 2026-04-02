#!/usr/bin/env bash
# EfficientServer - Quick server environment setup script
# Usage: bash setup.sh [module1] [module2] ...
#        bash setup.sh --all
#        bash setup.sh --list

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERR]${NC}  $*" >&2; }

list_modules() {
    echo "Available modules:"
    for f in "$MODULES_DIR"/*.sh; do
        name=$(basename "$f" .sh)
        desc=$(grep '^# DESC:' "$f" | sed 's/^# DESC: //')
        printf "  %-20s %s\n" "$name" "$desc"
    done
}

run_module() {
    local module="$1"
    local module_file="$MODULES_DIR/${module}.sh"
    if [[ ! -f "$module_file" ]]; then
        log_error "Module not found: $module"
        return 1
    fi
    log_info "Running module: $module"
    bash "$module_file"
    log_success "Module done: $module"
}

if [[ $# -eq 0 ]]; then
    echo "Usage: bash setup.sh [--list | --all | module1 module2 ...]"
    list_modules
    exit 0
fi

case "$1" in
    --list)
        list_modules
        ;;
    --all)
        for f in "$MODULES_DIR"/*.sh; do
            run_module "$(basename "$f" .sh)"
        done
        ;;
    *)
        for module in "$@"; do
            run_module "$module"
        done
        ;;
esac
