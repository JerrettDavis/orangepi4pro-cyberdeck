#!/usr/bin/env bash
set -euo pipefail

session_id=${CODEX_RESUME_SESSION_ID:-019f205e-121e-7aa2-a62e-a949a1c26836}
codex_bin=${CODEX_BIN:-/root/.local/bin/codex}
tmux_session=${CODEX_TMUX_SESSION:-codex-orange}
user_name=${CODEX_DESKTOP_USER:-orangepi}
user_home=${CODEX_DESKTOP_HOME:-/home/orangepi}

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  printf 'ERROR: rerun with sudo/root so systemd and /usr/local files can be installed\n' >&2
  exit 1
fi

install -m 0755 /dev/stdin /usr/local/bin/orangepi-codex-resume <<EOF
#!/usr/bin/env bash
set -euo pipefail

session_name=${tmux_session}
workdir=${user_home}
codex_bin=${codex_bin}
resume_id=${session_id}

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required" >&2
  exit 1
fi

if tmux has-session -t "\$session_name" 2>/dev/null; then
  echo "Codex tmux session already running: \$session_name"
  exit 0
fi

tmux new-session -d -s "\$session_name" -c "\$workdir" \\
  "\$codex_bin --dangerously-bypass-approvals-and-sandbox resume '\$resume_id'; exec bash"
echo "Started Codex tmux session: \$session_name"
EOF

install -m 0755 /dev/stdin /usr/local/bin/codex-attach <<EOF
#!/usr/bin/env bash
set -euo pipefail

if ! sudo -n /usr/bin/tmux has-session -t ${tmux_session} 2>/dev/null; then
  sudo -n /usr/bin/systemctl start orangepi-codex-resume.service || true
fi

exec sudo -n /usr/bin/tmux attach -t ${tmux_session}
EOF

install -m 0755 /dev/stdin /usr/local/bin/codex-terminal-autostart <<'EOF'
#!/usr/bin/env bash
set -u

log_dir=/home/orangepi/.cache/codex-autostart
log_file="$log_dir/autostart.log"
mkdir -p "$log_dir"
{
  printf 'timestamp=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'user=%s display=%s xauthority=%s desktop=%s\n' \
    "$(id -un)" "${DISPLAY:-}" "${XAUTHORITY:-}" "${XDG_CURRENT_DESKTOP:-}"
} >>"$log_file"

import_session_env() {
  local pid=$1
  [ -r "/proc/$pid/environ" ] || return 0
  while IFS= read -r line; do
    case "$line" in
      DISPLAY=*|XAUTHORITY=*|DBUS_SESSION_BUS_ADDRESS=*|SESSION_MANAGER=*|XDG_CURRENT_DESKTOP=*)
        export "$line"
        ;;
    esac
  done < <(tr '\0' '\n' <"/proc/$pid/environ")
}

for proc in xfce4-session xfdesktop xfce4-panel xfsettingsd; do
  pid=$(pgrep -u "$(id -u)" -n "$proc" 2>/dev/null || true)
  if [ -n "$pid" ]; then
    import_session_env "$pid"
    break
  fi
done

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if sudo -n /usr/bin/tmux has-session -t codex-orange 2>/dev/null; then
    break
  fi
  sudo -n /usr/bin/systemctl start orangepi-codex-resume.service >/dev/null 2>&1 || true
  sleep 1
done

run_terminal() {
  {
    printf 'launch=%s display=%s xauthority=%s session_manager=%s dbus=%s\n' \
      "$*" "${DISPLAY:-}" "${XAUTHORITY:-}" "${SESSION_MANAGER:-}" "${DBUS_SESSION_BUS_ADDRESS:-}"
    "$@"
    status=$?
    printf 'exit=%s command=%s\n' "$status" "$*"
    return "$status"
  } >>"$log_file" 2>&1
}

if command -v xfce4-terminal >/dev/null 2>&1; then
  run_terminal xfce4-terminal --disable-server --title="Codex Orange Pi" --hold --command="/bin/bash -lc '/usr/local/bin/codex-attach; status=\$?; echo; echo codex-attach exited with status \$status; exec bash'" &
  exit 0
fi

if command -v x-terminal-emulator >/dev/null 2>&1; then
  run_terminal x-terminal-emulator -e /bin/bash -lc '/usr/local/bin/codex-attach; status=$?; echo; echo codex-attach exited with status $status; exec bash' &
  exit 0
fi

if command -v xterm >/dev/null 2>&1; then
  run_terminal xterm -T "Codex Orange Pi" -e /bin/bash -lc '/usr/local/bin/codex-attach; status=$?; echo; echo codex-attach exited with status $status; exec bash' &
  exit 0
fi

printf 'no supported terminal found\n' >>"$log_file"
exit 1
EOF

cat >/etc/systemd/system/orangepi-codex-resume.service <<'EOF'
[Unit]
Description=Start Codex resume session in tmux
After=multi-user.target network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/orangepi
ExecStart=/usr/local/bin/orangepi-codex-resume

[Install]
WantedBy=multi-user.target
EOF

install -d -m 0755 -o "$user_name" -g "$user_name" "$user_home/.config/autostart"
cat >"$user_home/.config/autostart/codex-orange.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Codex Orange Pi Resume
Comment=Attach to the persistent Codex tmux session
Exec=/usr/local/bin/codex-terminal-autostart
TryExec=/usr/local/bin/codex-terminal-autostart
Terminal=false
Hidden=false
OnlyShowIn=XFCE;
X-XFCE-Autostart-enabled=true
X-GNOME-Autostart-enabled=true
EOF
chown "$user_name:$user_name" "$user_home/.config/autostart/codex-orange.desktop"
chmod 0644 "$user_home/.config/autostart/codex-orange.desktop"

cat >/etc/sudoers.d/orangepi-codex-resume <<EOF
${user_name} ALL=(root) NOPASSWD: /usr/bin/tmux has-session -t ${tmux_session}, /usr/bin/tmux attach -t ${tmux_session}, /usr/bin/systemctl start orangepi-codex-resume.service
EOF
chmod 0440 /etc/sudoers.d/orangepi-codex-resume
visudo -cf /etc/sudoers.d/orangepi-codex-resume >/dev/null

systemctl daemon-reload
systemctl enable --now orangepi-codex-resume.service

printf 'Installed Codex resume service and desktop autostart for session %s\n' "$session_id"
