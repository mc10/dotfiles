## Basic variables
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="open"
fi

export EDITOR="vim"

export VISUAL="$EDITOR"
export PAGER="less"

if [[ -z "$LANG" ]]; then
  export LANG="en_US.UTF-8"
fi

## Paths
# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)

## Less
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS="-F -g -i -M -R -S -w -x4 -X -z-4"

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# Disable the Less history file that stores search and shell commands.
export LESSHISTFILE=-

## Temporary files
# Set TMPDIR if the variable is not set/empty or the directory doesn't exist
if [[ -z "${TMPDIR}" ]]; then
  export TMPDIR="/tmp/zsh-${UID}"
fi

if [[ ! -d "${TMPDIR}" ]]; then
  mkdir -m 700 "${TMPDIR}"
fi

## Local changes
if [[ -f "$HOME/.zprofile-local" ]]; then
  source "$HOME/.zprofile-local"
fi

## Custom programs
if (( $+commands[gpg] )); then
  export GPG_TTY="$(tty)"
fi

# fzf
if [[ -d "/usr/local/opt/fzf" ]]; then
  path+=("/usr/local/opt/fzf/bin")
fi

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd --type f --color=always"
  export FZF_DEFAULT_OPTS="--ansi"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Load rbenv automatically
if (( $+commands[rbenv] )); then
  eval "$(rbenv init -)"
fi

# Opam
if [[ "$no_opam" != "true" ]]; then
  if (( $+commands[opam] )); then
    eval "$(opam env)"
  fi
fi

if [[ "$no_sudo" = "true" ]]; then
  # npm
  if (( $+commands[npm] )); then
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    path+=("$NPM_CONFIG_PREFIX/bin")
  fi
fi

# Set `RUST_SRC_PATH` for Racer.
if (( $+commands[rustc] )); then
  export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

# Set up after `rustup-init`:
# 1. Create `~/.zfunc`.
# 2. Run `rustup completions zsh > ~/.zfunc/_rustup`.
if [[ -d "$HOME/.cargo" ]]; then
  path+=("$HOME/.cargo/bin")
  fpath+=("$HOME/.zfunc")
fi
