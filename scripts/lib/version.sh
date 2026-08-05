#!/usr/bin/env bash
# Version facts for the independently released Flux package. version.env is
# deliberately simple dotenv syntax, so mise and this shell library share it.

load_flux_version() {
  local version_file="${1:?version.env path required}"
  [ -f "$version_file" ] || { echo "❌ version file not found: $version_file" >&2; return 1; }

  unset FLUX_VERSION CUR8S_FLUX_REVISION FLUX_TAG CUR8S_FLUX_VERSION
  # shellcheck disable=SC1090 # The caller supplies the explicit release-unit file.
  source "$version_file"

  [[ "${FLUX_VERSION:-}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    echo "❌ FLUX_VERSION must be a stable SemVer (for example 2.9.0)" >&2
    return 1
  }
  [[ "${CUR8S_FLUX_REVISION:-}" =~ ^[1-9][0-9]*$ ]] || {
    echo "❌ CUR8S_FLUX_REVISION must be a positive integer" >&2
    return 1
  }

  FLUX_TAG="v${FLUX_VERSION}"
  CUR8S_FLUX_VERSION="$FLUX_TAG"
  if [ "$CUR8S_FLUX_REVISION" -gt 1 ]; then
    CUR8S_FLUX_VERSION="${FLUX_TAG}-${CUR8S_FLUX_REVISION}"
  fi
  export FLUX_VERSION CUR8S_FLUX_REVISION FLUX_TAG CUR8S_FLUX_VERSION
}
