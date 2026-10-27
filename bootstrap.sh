#!/usr/bin/env bash
# Run inside the ChatGPT Dot's cloud computer (bash):
#   https_proxy=http://browser-proxy:8889 git clone --depth 1 https://github.com/aaron-chia/dot-bootstrap.git /tmp/b; bash /tmp/b/bootstrap.sh
# Installs user-level Tailscale + sshd from abruption/dots-tailscale v0.6.0 under /workspace/.dots-tailscale, authorises
# devbox-codex-dots' public key, starts the Tailscale login and prints: the login URL to approve, the sshd host-key
# fingerprint, the node's Tailscale IP and the user name. Re-running is safe. After a VM replacement run only:
#   bash /workspace/.dots-tailscale/start.sh
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export HTTPS_PROXY=${HTTPS_PROXY:-http://browser-proxy:8889} HTTP_PROXY=${HTTP_PROXY:-http://browser-proxy:8889}
D=/workspace/.dots-tailscale
cd /workspace || exit 1
if [ ! -d /workspace/dots-tailscale ]; then
  git clone --branch v0.6.0 --depth 1 https://github.com/abruption/dots-tailscale.git || exit 1
fi
if [ ! -f "$D/installed" ]; then
  (cd /workspace/dots-tailscale && bash tailscale-setup.sh check && bash tailscale-setup.sh install) || exit 1
fi
mkdir -p "$D/sshd"
touch "$D/sshd/authorized_keys"
grep -qF "$(cat "$here/authorized_keys")" "$D/sshd/authorized_keys" || cat "$here/authorized_keys" >> "$D/sshd/authorized_keys"
chmod 600 "$D/sshd/authorized_keys"
echo "== authorized_keys: $(wc -l < "$D/sshd/authorized_keys") key(s), cksum $(cksum < "$D/sshd/authorized_keys")"
echo "== starting tailscale login (approve the URL it prints; it waits up to 3 minutes)"
bash "$D/start.sh" login; rc=$?
echo "== start.sh exit $rc (0 running, 10 needs auth, 13 needs admin approval)"
echo "== host key fingerprint:"; ssh-keygen -lf "$D/sshd/ssh_host_ed25519_key.pub" 2>/dev/null || echo "no host key yet"
echo "== tailscale ip:"; "$D/tailscale" --socket="/tmp/dots-tailscale-$(id -u)/tailscaled.sock" ip -4 2>/dev/null || echo "not up yet"
echo "== user: $(id -un)"
