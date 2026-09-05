#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/.lib.sh"

INSTALL_ENV_FILE=".install.env"

declare -i installed_count
installed_count=0

SOURCE_FILE=
DESTINATION_DIR=

# find and install all of the linting configs
while IFS= read -r -d '' directory; do
    directory_name="$(basename "$directory")"
    log info "Processing $directory_name..."
    cd "$directory" || continue
    if [ ! -f "$INSTALL_ENV_FILE" ]; then
        continue
    fi
    unset SOURCE_FILE DESTINATION_DIR

    # shellcheck disable=SC1090
    source "$INSTALL_ENV_FILE" && link-config "$SOURCE_FILE" "$DESTINATION_DIR" && ((installed_count++))
done < <(find "$SCRIPT_DIR/../data/.fayers-configs" -type d -mindepth 1 -maxdepth 1 -not -name '.*' -print0)

[ $installed_count -eq 1 ] && config_word="config" || config_word="configs"

if [ $installed_count -gt 0 ]; then
    log success "$installed_count $config_word installed!"
else
    log info "No $config_word installed"
fi
