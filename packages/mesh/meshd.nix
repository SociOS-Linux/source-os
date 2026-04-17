{ writeShellApplication, python3, systemd, coreutils }:
writeShellApplication {
  name = "meshd";
  runtimeInputs = [ python3 systemd coreutils ];
  text = ''
    set -euo pipefail

    CONFIG=""
    LISTEN=""

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --config)
          CONFIG="$2"
          shift 2
          ;;
        --listen)
          LISTEN="$2"
          shift 2
          ;;
        *)
          shift
          ;;
      esac
    done

    if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
      echo "meshd: missing or unreadable --config path" >&2
      exit 2
    fi

    case "$LISTEN" in
      unix:*)
        SOCKET_PATH="${LISTEN#unix:}"
        ;;
      *)
        echo "meshd: only unix: listeners are supported by this bootstrap package" >&2
        exit 2
        ;;
    esac

    mkdir -p "$(dirname "$SOCKET_PATH")"

    exec python3 - "$CONFIG" "$SOCKET_PATH" <<'PY'
import os
import select
import signal
import socket
import subprocess
import sys

config_path = sys.argv[1]
socket_path = sys.argv[2]

stop = False

def _stop(*_args):
    global stop
    stop = True

signal.signal(signal.SIGTERM, _stop)
signal.signal(signal.SIGINT, _stop)

try:
    os.unlink(socket_path)
except FileNotFoundError:
    pass

srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
srv.bind(socket_path)
srv.listen(8)

if os.environ.get("NOTIFY_SOCKET"):
    subprocess.run([
        "systemd-notify",
        "--ready",
        f"--status=meshd bootstrap active ({socket_path})"
    ], check=False)

while not stop:
    ready, _, _ = select.select([srv], [], [], 1.0)
    if srv in ready:
        conn, _ = srv.accept()
        conn.close()

srv.close()
try:
    os.unlink(socket_path)
except FileNotFoundError:
    pass
PY
  '';
}
