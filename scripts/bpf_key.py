#!/usr/bin/env python3
import ipaddress
import struct
import sys

if len(sys.argv) < 4:
    print("usage: bpf_key.py <ip> <port> <proto: tcp|udp>")
    sys.exit(1)

ip_s, port_s, proto_s = sys.argv[1], sys.argv[2], sys.argv[3].lower()
proto = 6 if proto_s == 'tcp' else 17

try:
    ip = ipaddress.ip_address(ip_s)
except ValueError:
    print("bad ip", file=sys.stderr)
    sys.exit(2)

port = int(port_s)

if isinstance(ip, ipaddress.IPv4Address):
    key = struct.pack('!IHBx', int(ip), port, proto)
else:
    hi = int(ip)
    parts = [(hi >> (96 - 32*i)) & 0xffffffff for i in range(4)]
    key = struct.pack('!4IHBx', *parts, port, proto)

print(' '.join(f"{b:02x}" for b in key))
