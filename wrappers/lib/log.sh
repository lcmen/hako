#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prints a debug message when DEBUG=1.
# Arguments:
#   All arguments: Message text.
# Returns:
#   0.
#######################################
log_debug() {
  [[ "${DEBUG:-}" == "1" ]] || return 0
  log_message 2 $'\033[36m' "$*"
}

#######################################
# Prints an error message to stderr.
# Arguments:
#   All arguments: Message text.
# Returns:
#   0.
#######################################
log_error() {
  log_message 2 $'\033[31m' "$*"
}

#######################################
# Prints an informational message to stderr.
# Arguments:
#   All arguments: Message text.
# Returns:
#   0.
#######################################
log_info() {
  log_message 2 '' "$*"
}

#######################################
# Formats and prints a hako-owned message.
# Arguments:
#   $1: Output file descriptor.
#   $2: Optional ANSI color.
#   $3: Message text.
# Returns:
#   0.
#######################################
log_message() {
  local descriptor="${1:?output file descriptor is required}"
  local color="${2:-}"
  local first_character
  local message="${3:?message is required}"

  first_character="$(printf '%.1s' "$message" | tr '[:lower:]' '[:upper:]')"
  message="$first_character${message#?}"
  if [[ -n "$color" && -t "$descriptor" ]]; then
    printf '%s[hako] %s\033[0m\n' "$color" "$message" >&"$descriptor"
  else
    printf '[hako] %s\n' "$message" >&"$descriptor"
  fi
}

#######################################
# Prints a lifecycle or status message to stdout.
# Arguments:
#   All arguments: Message text.
# Returns:
#   0.
#######################################
log_status() {
  log_message 1 '' "$*"
}

#######################################
# Prints a warning message to stderr.
# Arguments:
#   All arguments: Message text.
# Returns:
#   0.
#######################################
log_warn() {
  log_message 2 $'\033[38;5;208m' "$*"
}
