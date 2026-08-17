#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds the deterministic Docker container name.
# Globals:
#   TOOL
#   VERSION
# Arguments:
#   $1: Namespace.
# Outputs:
#   Container name.
# Returns:
#   0.
#######################################
container_name() {
  local namespace="${1:?namespace is required}"
  local tool="${TOOL:?TOOL is required}"
  local version="${VERSION:?VERSION is required}"
  printf 'hako-%s-%s-%s\n' "$tool" "$(version_tag "$version")" "$namespace"
}

#######################################
# Builds the persistent host data directory path.
# Globals:
#   HOME
#   TOOL
#   VERSION
#   XDG_DATA_HOME
# Arguments:
#   $1: Namespace.
# Outputs:
#   Data directory path.
# Returns:
#   0.
#######################################
data_dir() {
  local namespace="${1:?namespace is required}"
  local base="${XDG_DATA_HOME:-$HOME/.local/share}"
  printf '%s/hako/%s/%s/%s\n' "$base" "$TOOL" "$VERSION" "$namespace"
}

#######################################
# Converts a version string into a Docker-name-safe tag segment.
# Globals:
#   VERSION
# Arguments:
#   $1: Version string. Defaults to VERSION.
# Outputs:
#   Sanitized version tag.
# Returns:
#   0.
#######################################
version_tag() {
  local version="${1:-${VERSION:-}}"
  printf '%s' "$version" | sed -E 's/[^A-Za-z0-9]+/-/g; s/^-+//; s/-+$//'
}
