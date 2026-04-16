// SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/in.h>
#include <linux/in6.h>

struct key4 { __u32 ip; __u16 port; __u8 proto; __u8 pad; };
struct key6 { __u32 ip6[4]; __u16 port; __u8 proto; __u8 pad; };

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1024);
    __type(key, struct key4);
    __type(value, __u8);
} allow4 SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1024);
    __type(key, struct key6);
    __type(value, __u8);
} allow6 SEC(".maps");

static __always_inline int allow_connect4(struct bpf_sock_addr *ctx, __u8 proto) {
    struct key4 k = {};
    k.ip = ctx->user_ip4;
    k.port = ctx->user_port;
    k.proto = proto;
    __u8 *v = bpf_map_lookup_elem(&allow4, &k);
    return v ? 1 : 0;
}

static __always_inline int allow_connect6(struct bpf_sock_addr *ctx, __u8 proto) {
    struct key6 k = {};
    __builtin_memcpy(k.ip6, &ctx->user_ip6, sizeof(k.ip6));
    k.port = ctx->user_port;
    k.proto = proto;
    __u8 *v = bpf_map_lookup_elem(&allow6, &k);
    return v ? 1 : 0;
}

SEC("cgroup/connect4")
int on_connect4(struct bpf_sock_addr *ctx) {
    return allow_connect4(ctx, IPPROTO_TCP);
}

SEC("cgroup/udp4_sendmsg")
int on_udp4_send(struct bpf_sock_addr *ctx) {
    return allow_connect4(ctx, IPPROTO_UDP);
}

SEC("cgroup/connect6")
int on_connect6(struct bpf_sock_addr *ctx) {
    return allow_connect6(ctx, IPPROTO_TCP);
}

SEC("cgroup/udp6_sendmsg")
int on_udp6_send(struct bpf_sock_addr *ctx) {
    return allow_connect6(ctx, IPPROTO_UDP);
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
