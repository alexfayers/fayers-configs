log() {
    local levels=(debug info warn error success) i
    for i in "${!levels[@]}"; do [[ "${levels[i]}" == "$1" ]] && break; done
    [[ "${levels[i]}" != "$1" ]] && { >&2 echo "Unknown level: $1"; return 1; }
    if [ -t 2 ]; then
        local c=("\033[0;90m" "\033[0;37m" "\033[0;33m" "\033[0;31m" "\033[0;32m") p=("⚙︎" "▶" "⚠︎" "✗" "✓")
        >&2 echo -e "${c[i]}${p[i]} $2\033[0;0m"
    else
        local p=("[.]" "[*]" "[-]" "[!]" "[+]")
        >&2 echo "${p[i]} $2"
    fi
}

link-config() {
    local source_file install_dir
    source_file="$1"
    shift

    if [ ! -f "$source_file" ]; then
        log error "Source file does not exist: $source_file"
        return 1
    fi
    source_file_base="$(basename "$source_file")"

    install_dir="$1"
    shift
    if [ ! -d "$install_dir" ]; then
        log debug "Creating directory: $install_dir"
        mkdir -p "$install_dir" || return 1
    fi
    
    destination_file="$install_dir/$source_file_base"
    if [ -L "$destination_file" ] && [ "$(readlink "$destination_file")" = "$source_file" ]; then
        log debug "Link already installed: $destination_file"
        return 0
    elif [ -f "$destination_file" ] || [ -d "$destination_file" ]; then
        log warn "Config already exists: $destination_file"
        return 1
    else
        log info "Installing $destination_file..."
        ln -s "$source_file" "$destination_file" || return 1
    fi

    log success "$destination_file installed"
}
