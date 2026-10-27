# dot-bootstrap

In: the script and public key that put user-level Tailscale + sshd (abruption/dots-tailscale) on a ChatGPT Dot's cloud computer and authorise devbox-codex-dots to ssh in.
Out: anything about the Dot's tasks or repos (those live in the project mirrors); Tailscale policy (admin console).

Public on purpose: the Dot's computer can only fetch from hosts its proxy allows, GitHub among them, and a private repo has no credentials there. Nothing here is secret: `authorized_keys` is a public key.

In the Dot's terminal (bash), one line:

    https_proxy=http://browser-proxy:8889 git clone --depth 1 https://github.com/aaron-chia/dot-bootstrap.git /tmp/b; bash /tmp/b/bootstrap.sh

Approve the Tailscale login URL it prints, then tag the node `tag:dot` in the admin console. After the Dot's VM is replaced: `bash /workspace/.dots-tailscale/start.sh`.
