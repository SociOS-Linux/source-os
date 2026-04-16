BPF_CLANG ?= clang
BPF_CFLAGS ?= -O2 -g -target bpf -Wall -Werror

all: egress_allowlist.bpf.o

clean:
	rm -f *.o

ebpf: all

egress_allowlist.bpf.o: egress_allowlist.bpf.c
	$(BPF_CLANG) $(BPF_CFLAGS) -c $< -o $@
