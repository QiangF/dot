# vim: ft=sh
dot_paste() {
  # option handling
  local arg
  local dotset_ignore=false
  local dotset_force=false
  local dotset_backup=false
  local dotset_verbose=false

  for arg in "$@"; do
    shift
    case "$arg" in
      "--ignore" ) set -- "$@" "-i" ;;
      "--force"  ) set -- "$@" "-f" ;;
      "--backup" ) set -- "$@" "-b" ;;
      "--verbose") set -- "$@" "-v" ;;
                *) set -- "$@" "$arg" ;;
    esac
  done

  OPTIND=1

  while getopts ifbv OPT; do
    case $OPT in
      "i" ) dotset_ignore=true ;;
      "f" ) dotset_force=true ;;
      "b" ) dotset_backup=true ;;
      "v" ) dotset_verbose=true ;;
    esac
  done

  check_dir() { #{{{
    local orig="$1"

    origdir="${orig%/*}"

    [ -d "${origdir}" ] && return 0

    echo "$(prmpt 1 error)$(bd_ ${origdir}) doesn't exist."

    ${dotset_ignore} && return 1

    if ! ${dotset_force}; then
      __confirm y "make directory $(bd_ ${origdir}) ? " || return 1
    fi
    mkdir -p "${origdir}" && return 0
  } #}}}

  _dot_set() { #{{{
    local dotfile orig
    dotfile="$1"
    orig="$2"

    # if dotfile doesn't exist, print error message and pass
    if [ ! -e "${dotfile}" ]; then
      echo "$(prmpt 1 "not found")${dotfile}"
      return 1
    fi

    # if the targeted directory doesn't exist,
    # ask whether make directory or not.
    check_dir "${orig}" || return 1
    cp -f -R "${dotfile}" "${orig}" 
    test $? && echo "$(prmpt 2 done)${orig}"

  } #}}}

  parse_linkfiles _dot_set

  unset -f check_dir _dot_set $0
}
