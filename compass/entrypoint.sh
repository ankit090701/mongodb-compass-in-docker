#!/bin/sh
# Container entrypoint: prepares VNC auth, then hands over to supervisord.
set -eu

# Clean up a stale X lock left behind by a previous run of this container.
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

if [ -n "${VNC_PASSWORD:-}" ]; then
  printf '%s\n' "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
  chmod 600 "$HOME/.vnc/passwd"
else
  rm -f "$HOME/.vnc/passwd"
  echo "WARNING: VNC_PASSWORD is empty - the Compass web UI has no password." >&2
fi

exec /usr/bin/supervisord -n -c /etc/supervisor/compass.conf
