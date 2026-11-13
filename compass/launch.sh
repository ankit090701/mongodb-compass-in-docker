#!/bin/sh
# Starts one desktop service in the foreground. Called by supervisord.
set -eu

x_socket="/tmp/.X11-unix/X${DISPLAY#:}"

wait_for_x() {
  for _ in $(seq 1 100); do
    [ -S "$x_socket" ] && return 0
    sleep 0.2
  done
  echo "X display $DISPLAY did not come up" >&2
  exit 1
}

case "${1:-}" in
  xvnc)
    if [ -f "$HOME/.vnc/passwd" ]; then
      set -- -SecurityTypes VncAuth -PasswordFile "$HOME/.vnc/passwd"
    else
      set -- -SecurityTypes None
    fi
    # -localhost: the raw VNC port is only reachable inside the container;
    # browsers come in through noVNC on 6080.
    exec Xvnc "$DISPLAY" -geometry "$VNC_RESOLUTION" -depth 24 \
      -rfbport 5901 -localhost -AlwaysShared "$@"
    ;;
  openbox)
    wait_for_x
    exec openbox
    ;;
  compass)
    wait_for_x
    # --no-sandbox: Chromium's sandbox needs privileges a container lacks.
    # --password-store=basic: no desktop keyring in the container.
    # --ignore-additional-command-line-flags: let Chromium-only flags through
    #   Compass's own option validation.
    set -- --no-sandbox --disable-gpu --password-store=basic \
      --ignore-additional-command-line-flags
    if [ -n "${COMPASS_CONNECTION_STRING:-}" ]; then
      # The string comes from our own .env, so skip Compass's "untrusted
      # connection string" confirmation prompt.
      set -- "$@" --trustedConnectionString "$COMPASS_CONNECTION_STRING"
    fi
    exec dbus-run-session -- mongodb-compass "$@"
    ;;
  novnc)
    exec websockify --web /usr/share/novnc 6080 localhost:5901
    ;;
  *)
    echo "usage: launch {xvnc|openbox|compass|novnc}" >&2
    exit 2
    ;;
esac
