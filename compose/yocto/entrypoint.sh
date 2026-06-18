#!/bin/bash
# Runtime git configuration. The token is injected as an env var and written
# only to the container's ephemeral filesystem — it never ends up baked into
# an image layer.
set -e

if [ -n "${GIT_TOKEN}" ]; then
    AUTH_URL="https://${GIT_USER:-oauth2}:${GIT_TOKEN}@github.com/"
    # Rewrite ALL three github.com URL forms to authenticated https, so it
    # also covers recipes fetching with protocol=ssh (ssh://git@github.com/)
    # and scp-style submodule URLs (git@github.com:), not just https://.
    git config --global --replace-all url."${AUTH_URL}".insteadOf "https://github.com/"
    git config --global --replace-all url."${AUTH_URL}".insteadOf "git@github.com:"
    git config --global --replace-all url."${AUTH_URL}".insteadOf "ssh://git@github.com/"
fi

# Fallback for real SSH usage (mounted key or forwarded agent): pre-trust
# GitHub's host key so non-interactive fetches don't die on verification.
mkdir -p ~/.ssh && chmod 700 ~/.ssh
if ! grep -q "^github.com" ~/.ssh/known_hosts 2>/dev/null; then
    ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts 2>/dev/null || true
fi

# The repo lives on a bind mount whose ownership may not match exactly;
# silence git's "dubious ownership" refusal.
git config --global --add safe.directory '*'

exec "$@"
