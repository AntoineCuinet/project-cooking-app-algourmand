#!/bin/bash

# Include standard Homebrew & user bin directories in PATH for Xcode environment
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$HOME/.local/bin:$PATH"

if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate -C "$SRCROOT" bash --shims)"
elif which mise >/dev/null 2>&1; then
    eval "$(mise activate -C "$SRCROOT" bash --shims)"
fi

if which swiftlint >/dev/null 2>&1; then
    swiftlint --config "$SRCROOT/.swiftlint.yml"
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint or install via mise/brew"
fi
