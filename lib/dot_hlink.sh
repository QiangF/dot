# vim: ft=sh
dot_hlink() {
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

  replace() { #{{{
    # replace "${orig}" "${dotfile}"
    if [ -d "$1" ]; then
      rm -rf -- "$1"
    else
      rm -f -- "$1"
    fi
    ln "$2" "$1"
    echo "$(prmpt 2 done)$1"
  } #}}}

  replace_and_backup() { #{{{
    # replace_and_backup "${orig}" "${dotfile}"
    backuped="$1$(date +'_%Y%m%d_%H%M%S')"
    mv -i "$1" "${backuped}"
    ln "$2" "$1"
    echo "$(prmpt 2 done)$1"
    echo "$(prmpt 2 "make backup")${backuped}"
  } #}}}

  if_issame() { #{{{
    local orig="$1"
    local dotfile="$2"

    # fileA -ef fileB returns 0 (success) if fileA is a symlink or hardlink to fileB

    # if the link has already be set: do nothing
    if [ "${orig}" -ef "${dotfile}" ] && ! [ -L "${orig}" ]; then
      ${dotset_verbose} && echo "$(prmpt 2 same file)${orig}"
      return 0
    fi

    echo "$(prmpt 1 conflict)Hard link already exists at $(bd_ ${orig})"

    ${dotset_ignore} && return 0

    if ! ${dotset_force}; then
      echo -n "  $(prmpt 2 now)"
      echo "${orig} $(tput setaf 5)<--$(tput sgr0) ${orig}"
      echo -n "  $(prmpt 3 try)"
      echo "${orig} $(tput setaf 5)<--$(tput sgr0) ${dotfile}"
      __confirm n "Re-link for $(bd_ ${orig}) ? " || return 0
    fi
    ln "${dotfile}" "${orig}"
    echo "$(prmpt 2 done)${orig}"

    return 0
  } #}}}

  if_exist() { #{{{
    # local line
    local orig="$1"
    local dotfile="$2"

    if ${dotset_ignore}; then
      echo "$(prmpt 1 conflict)File already exists at $(bd_ ${orig})."
      return 0
    fi

    if ${dotset_force}; then
      replace "${orig}" "${dotfile}"
      return 0
    fi

    if ${dotset_backup}; then
      replace_and_backup "${orig}" "${dotfile}"
      return 0
    fi

    while true; do
      echo "$(prmpt 1 conflict)File already exists at $(bd_ ${orig})."
      echo "Choose the operation:"
      echo "    ($(bd_ d)):show diff"
      echo "    ($(bd_ e)):edit files"
      echo "    ($(bd_ f)):replace"
      echo "    ($(bd_ b)):replace and make backup"
      echo "    ($(bd_ n)):do nothing"
      echo -n ">>> "; read line
      case $line in
        [Dd] )
          eval "${diffcmd}" "${dotfile}" "${orig}"
          echo ""
          ;;
        [Ee] )
          eval "${edit2filecmd}" "${dotfile}" "${orig}"
          ;;
        [Ff] )
          replace "${orig}" "${dotfile}"
          break
          ;;
        [Bb] )
          replace_and_backup "${orig}" "${dotfile}"
          break
          ;;
        [Nn] )
          break
          ;;
        *)
          echo "Please answer with [d/e/f/b/n]."
          ;;
      esac
    done

    return 0
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

    if [ -e "${orig}" ]; then                    # if the file already exists:
      if_issame "${orig}" "${dotfile}"         #      do nothing or relink
    else                                         # else:
      ln "${dotfile}" "${orig}"               #   make link
      test $? && echo "$(prmpt 2 done)${orig}"
    fi
    # set read-only
    chmod -w -R "${orig}"

  } #}}}

  parse_linkfiles _dot_set

  unset -f check_dir if_issame if_exist _dot_set replace replace_and_backup $0
}
