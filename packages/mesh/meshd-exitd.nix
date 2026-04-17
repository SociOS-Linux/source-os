{ writeShellApplication, coreutils }:
writeShellApplication {
  name = "meshd-exitd";
  runtimeInputs = [ coreutils ];
  text = ''
    set -euo pipefail

    CONFIG=""
    NFT=""

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --config)
          CONFIG="$2"
          shift 2
          ;;
        --nft)
          NFT="$2"
          shift 2
          ;;
        *)
          shift
          ;;
      esac
    done

    if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
      echo "meshd-exitd: missing or unreadable --config path" >&2
      exit 2
    fi

    if [ -z "$NFT" ] || [ ! -f "$NFT" ]; then
      echo "meshd-exitd: missing or unreadable --nft path" >&2
      exit 2
    fi

    exec sleep infinity
  '';
}
