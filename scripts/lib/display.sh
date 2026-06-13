#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Display utilities — consistent output across scripts.
#   banner / section / error / success / info / warn / print_pass / print_fail
# ─────────────────────────────────────────────────────────────────────────────

BOLD=$(tput bold 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

banner() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

section() { echo; echo "${BOLD}$1${RESET}"; echo; }
error()   { echo "${RED}❌ Error: $1${RESET}" >&2; }
success() { echo "${GREEN}✅ $1${RESET}"; }
info()    { echo "${BOLD}ℹ️  $1${RESET}"; }
warn()    { echo "${YELLOW}⚠️  $1${RESET}"; }
print_pass() { echo "${GREEN}✓${RESET} $1"; }
print_fail() { echo "${RED}✗${RESET} $1"; }
print_warn() { echo "${YELLOW}⚠${RESET} $1"; }
