#
# Minimal theme (zimfw version)
#
# Original minimal theme for zsh written by subnixr:
# https://github.com/subnixr/minimal
#

# Global settings
MNML_OK_COLOR="${MNML_OK_COLOR:-green}"
MNML_ERR_COLOR="${MNML_ERR_COLOR:-red}"
# ADDED FOR ZIMFW
MNML_DIV_COLOR="${MNML_DIV_COLOR:-magenta}"

MNML_USER_CHAR="${MNML_USER_CHAR:-λ}"
MNML_INSERT_CHAR="${MNML_INSERT_CHAR:-›}"
MNML_NORMAL_CHAR="${MNML_NORMAL_CHAR:-·}"

[ "${+MNML_PROMPT}" -eq 0 ] && MNML_PROMPT=(mnml_ssh mnml_pyenv mnml_status mnml_keymap)
[ "${+MNML_RPROMPT}" -eq 0 ] && MNML_RPROMPT=('mnml_cwd 2 0' mnml_git)
[ "${+MNML_INFOLN}" -eq 0 ] && MNML_INFOLN=(mnml_err mnml_jobs mnml_uhp mnml_files)

[ "${+MNML_MAGICENTER}" -eq 0 ] && MNML_MAGICENTER=(mnml_me_dirs mnml_me_ls mnml_me_git)

# Components
mnml_status() {
  local output="%F{%(?.${MNML_OK_COLOR}.${MNML_ERR_COLOR})}%(!.#.${MNML_USER_CHAR})%f"

  echo -n "%(1j.%U${output}%u.${output})"
}

mnml_keymap() {
  local kmstat="${MNML_INSERT_CHAR}"
  [ "$KEYMAP" = 'vicmd' ] && kmstat="${MNML_NORMAL_CHAR}"
  echo -n "${kmstat}"
}

mnml_cwd() {
  local segments="${1:-2}"
  local seg_len="${2:-0}"

  if [ "${segments}" -le 0 ]; then
    segments=1
  fi
  if [ "${seg_len}" -gt 0 ] && [ "${seg_len}" -lt 4 ]; then
    seg_len=4
  fi
  local seg_hlen=$((seg_len / 2 - 1))

  local cwd="%${segments}~"
  cwd="${(%)cwd}"
  cwd=("${(@s:/:)cwd}")

  local pi=""
  for i in {1..${#cwd}}; do
    pi="$cwd[$i]"
    if [ "${seg_len}" -gt 0 ] && [ "${#pi}" -gt "${seg_len}" ]; then
      cwd[$i]="%F{244}${pi:0:$seg_hlen}%F{white}..%F{244}${pi: -$seg_hlen}%f"
    fi
  done

  echo -n "%F{244}${(j:/:)cwd//\//%F{white\}/%F{244\}}%f"
}

mnml_git() {
  [[ -n ${git_info} ]] && echo -n " ${(e)git_info[color]}${(e)git_info[rprompt]}"
}

mnml_uhp() {
  local cwd="%~"
  cwd="${(%)cwd}"

  echo -n "%F{244}%n%F{white}@%F{244}%m%F{white}:%F{244}${cwd//\//%F{white\}/%f%F{244\}}%f"
}

mnml_ssh() {
  if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
    echo -n "$(hostname -s)"
  fi
}

mnml_pyenv() {
  if [ -n "${VIRTUAL_ENV}" ]; then
    _venv="$(basename ${VIRTUAL_ENV})"
    echo -n "${_venv%%.*}"
  fi
}

mnml_err() {
  echo -n "%(0?..%F{${MNML_ERR_COLOR}}${MNML_LAST_ERR}%f)"
}

mnml_jobs() {
  echo -n "%(1j.%F{244}%j&%f.)"
}

mnml_files() {
  local a_files="$(ls -1A | sed -n '$=')"
  local v_files="$(ls -1 | sed -n '$=')"
  local h_files="$((a_files - v_files))"

  local output="[%F{244}${v_files:-0}%f"

  if [ "${h_files:-0}" -gt 0 ]; then
    output="$output (%F{244}$h_files%f)"
  fi
  output="${output}]"

  echo -n "${output}"
}

# Magic enter functions
mnml_me_dirs() {
  if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
    local stack="$(dirs)"
    echo -n "%F{244}${stack//\//%F{white\}/%F{244\}}%f"
  fi
}

mnml_me_ls() {
  if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
    COLUMNS=${COLUMNS} CLICOLOR_FORCE=1 ls -C -G -F
  else
    ls -C -F --color="always" -w ${COLUMNS}
  fi
}

mnml_me_git() {
  git -c color.status=always status -sb 2> /dev/null
}

# Wrappers & utils
# join outpus of components
mnml_wrap() {
  local -a arr
  arr=()
  local cmd_out=""
  local cmd
  for cmd in ${(P)1}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      arr+="${cmd_out}"
    fi
  done

  echo -n "${(j: :)arr}"
}

# expand string as prompt would do
mnml_iline() {
  echo "${(%)1}"
}

# display magic enter
mnml_me() {
  local -a output
  output=()
  local cmd_out=""
  local cmd
  for cmd in ${MNML_MAGICENTER}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      output+="${(%)cmd_out}"
    fi
  done
  echo -n "${(j:\n:)output}" | less -XFR
}

# capture exit status and reset prompt
mnml_zle-line-init() {
  MNML_LAST_ERR="$?" # I need to capture this ASAP

  zle reset-prompt
}

# redraw prompt on keymap select
mnml_zle-keymap-select() {
  zle reset-prompt
}

# draw infoline if no command is given
mnml_buffer-empty() {
  if [ -z "${BUFFER}" ] && [ ! "${+MNML_MAGICENTER}" -eq 0 ]; then
    mnml_iline "$(mnml_wrap MNML_INFOLN)"
    mnml_me
    # zle redisplay
    zle zle-line-init
  else
    zle accept-line
  fi
}

# properly bind widgets
# see: https://github.com/zsh-users/zsh-syntax-highlighting/blob/1f1e629290773bd6f9673f364303219d6da11129/zsh-syntax-highlighting.zsh#L292-L356
_mnml_bind_widgets() {
  zmodload zsh/zleparameter

  local -a to_bind
  to_bind=(zle-line-init zle-keymap-select buffer-empty)

  typeset -F SECONDS
  local zle_wprefix="s${SECONDS}-r${RANDOM}"
  local cur_widget
  for cur_widget in ${to_bind}; do
    case "${widgets[$cur_widget]:-""}" in
      user:mnml_*);;
      user:*)
        zle -N ${zle_wprefix}-${cur_widget} ${widgets[$cur_widget]#*:}
        eval "mnml_ww_${(q)zle_wprefix}-${(q)cur_widget}() { mnml_${(q)cur_widget}; zle ${(q)zle_wprefix}-${(q)cur_widget} }"
        zle -N ${cur_widget} mnml_ww_${zle_wprefix}-${cur_widget}
        ;;
      *)
        zle -N ${cur_widget} mnml_${cur_widget}
        ;;
    esac
  done
}

prompt_minimal_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd prompt_minimal_precmd
setopt no_prompt_bang prompt_cr prompt_percent prompt_sp prompt_subst

zstyle ':zim:git-info:branch' format '%b'
zstyle ':zim:git-info:commit' format '%c'
zstyle ':zim:git-info:dirty' format '%F{${MNML_ERR_COLOR}}'
zstyle ':zim:git-info:diverged' format '%F{${MNML_DIV_COLOR}}'
zstyle ':zim:git-info:behind' format '%F{${MNML_DIV_COLOR}}↓ '
zstyle ':zim:git-info:ahead' format '%F{${MNML_DIV_COLOR}}↑ '
zstyle ':zim:git-info:keys' format \
    'rprompt' '%b%c' \
    'color' '$(coalesce "%D" "%V" "%B" "%A" "%F{${MNML_OK_COLOR}}")'

PS1='$(mnml_wrap MNML_PROMPT) '
RPS1='$(mnml_wrap MNML_RPROMPT)'

_mnml_bind_widgets

bindkey -M main "^M" buffer-empty
bindkey -M vicmd "^M" buffer-empty
