{ writeShellApplication, python3, systemd, coreutils }:
writeShellApplication {
  name = "meshd-linkd";
  runtimeInputs = [ python3 systemd coreutils ];
  text = ''
    set -euo pipefail

    RPC=""
    CONTROL=""

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --rpc)
          RPC="$2"
          shift 2
          ;;
        --control)
          CONTROL="$2"
          shift 2
          ;;
        *)
          shift
          ;;
      esac
    done

    case "$RPC" in
      unix:*) RPC_PATH="${RPC#unix:}" ;;
      *) echo "meshd-linkd: --rpc must be a unix: URI" >&2; exit 2 ;;
    esac

    case "$CONTROL" in
      unix:*) CONTROL_PATH="${CONTROL#unix:}" ;;
      *) echo "meshd-linkd: --control must be a unix: URI" >&2; exit 2 ;;
    esac

    mkdir -p "$(dirname "$RPC_PATH")"

    exec python3 - "$RPC_PATH" "$CONTROL_PATH" <<'PY'
import os
import select
import signal
import socket
import subprocess
import sys
import time

rpc_path = sys.argv[1]
control_path = sys.argv[2]
stop = False

def _stop(*_args):
    global stop
    stop = True

signal.signal(signal.SIGTERM, _stop)
signal.signal(signal.SIGINT, _stop)

for _ in range(30):
    if os.path.exists(control_path):
        break
    time.sleep(1)

try:
    os.unlink(rpc_path)
except FileNotFoundError:
    pass

srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
srv.bind(rpc_path)
srv.listen(8)

if os.environ.get("NOTIFY_SOCKET"):
    subprocess.run([
        "systemd-notify",
        "--ready",
        f"--status=meshd-linkd bootstrap active ({rpc_path})"
    ], check=False)

while not stop:
    ready, _, _ = select.select([srv], [], [], 1.0)
    if srv in ready:
        conn, _ = srv.accept()
        conn.close()

srv.close()
try:
    os.unlink(rpc_path)
except FileNotFoundError:
    pass
PY
  '';
}
