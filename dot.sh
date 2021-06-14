# vim: ft=zsh
# dot - dotfiles management framework

# Version:    1.2.2
# Repository: https://github.com/ssh0/dot
# Author:     ssh0 (Shotaro Fujimoto)
# License:    MIT

DOT_SCRIPT_ROOTDIR="$(builtin cd "$(dirname "${BASH_SOURCE:-${(%):-%N}}")" && builtin pwd)"
readonly DOT_SCRIPT_ROOTDIR
export DOT_SCRIPT_ROOTDIR

dot_usage() { #{{{
    cat << EOF
$DOT_COMMAND - Simplest dotfiles manager

Usage: $DOT_COMMAND [options] <commands> [<args>]
  $DOT_COMMAND (set | update) [-i | --ignore] [-f | --force] [-b | --backup] [-v | --verbose]
  $DOT_COMMAND add (<file> [$DOT_DIR/path/to/the/file]) | <symboliclinks>...
  $DOT_COMMAND unlink <symboliclinks>...
  $DOT_COMMAND clear
  $DOT_COMMAND (-h | --help)

Commands:
  cd      Change directory to 'dotdir'.
  list    Show the list which files will be managed by $DOT_COMMAND.
  check   Check the files are correctly linked to the right places.
  set     Set the symbolic links interactively.
  paste   Copy file to target interactively.
  hlink   Set the hard links interactively.
  add     Move the file to the dotfiles directory and make its symbolic link to that place.
  edit    Edit dotlink file.
  unlink  Unlink the selected symbolic links and copy from its original.
  clear   Remove the all symbolic links in 'dotlink'.
  config  Edit (or create if it does not exist) rcfile 'dotrc'.

Options:
  -h, --help      Show this help message.
  -H, --help-all  Show man page.
  -c <file>, --config <file>
                  Specify the configuration file to load.
                  default: \$HOME/.config/dot/dotrc

EOF
} #}}}

# Appending a line to a file only if it does not already exist
# -q be quiet
# -x match the whole line
# -F pattern is a plain string
# -P is used for Perl regular expressions (an extension to POSIX grep).
# \s match the white space characters; if followed by *, it matches an empty line also.
# -z suppress newline at the end of line, substituting it for null character. That is, grep knows where end of line is, but sees the input as one big line.

# $ grep -Pzo "(?s)^(\s*)\N*main.*?{.*?^\1}" *.c
# ^ matches the beginning of the line. $ matches the end of the line.
# (?s) activate PCRE_DOTALL, which means that . finds any character or newline
# \N find anything except newline, even with PCRE_DOTALL activated
# .*? find . in non-greedy mode, that is, stops as soon as possible.
# \1 backreference to the first group (\s*). This is a try to find the same indentation of method

# add lines to file if not already exist
dot_add() {
    LINE=$2
    FILE=$1
    [ -f "$FILE" ] && grep -qzP -- "\n$LINE" "$FILE" || echo -e "$LINE" >> "$FILE"
}

dot_main() {
  # Option handling {{{
  local arg
  for arg in "$@"; do
    shift
    case "$arg" in
      "--help") set -- "$@" "-h" ;;
      "--help-all") set -- "$@" "-H" ;;
      "--config") set -- "$@" "-c" ;;
      *)        set -- "$@" "$arg" ;;
    esac
  done

  OPTIND=1
  # local dotrc
  while getopts "s:c:hH" OPT
  do
    case $OPT in
       # source shell script
      "s")
        if [[ -f "$OPTARG" ]] ; then source "$OPTARG" ; fi 
        ;;
      "c")
        dotrc="$OPTARG"
        ;;
      "h")
        dot_usage
        unset -f dot_usage
        return 0
        ;;
      "H")
        man "${DOT_SCRIPT_ROOTDIR}/doc/dot.1"
        unset -f dot_usage
        return 0
        ;;
      * )
        dot_usage
        unset -f dot_usage
        return 1
        ;;
    esac
  done

  shift $((OPTIND-1))
  # }}}

  OS=$(lsb_release -si)

  dotlink="$dotdir/$OS/$DOT_COMMAND-$1"

  # Load common.sh {{{
  source "$DOT_SCRIPT_ROOTDIR/lib/common.sh"
  trap cleanup_namespace EXIT
  # }}}

  # main command handling {{{
  case "$1" in
    list|check|set|add|edit|unlink|clear|config|cd|hlink|paste)
      subcommand="$1"
      source "$DOT_SCRIPT_ROOTDIR/lib/dot_${subcommand}.sh"
      shift 1
      dot_${subcommand} "$@"
      ;;
    *)
      echo -n "[$(tput bold)$(tput setaf 1)error$(tput sgr0)] "
      echo "run dots -h for help."
      return 1
      ;;
  esac

  # }}}

}

# eval "alias ${DOT_COMMAND:=dots}=dot_main"
dot_main "$@" 
