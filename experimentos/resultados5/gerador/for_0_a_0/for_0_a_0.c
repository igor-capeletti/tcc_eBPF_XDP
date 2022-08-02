
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>


SEC("xdp_pass")
int xdp_pass_func(struct xdp_md *ctx){
	return XDP_TX;
}


SEC("xdp_drop")
int xdp_drop_func(struct xdp_md *ctx){
	return XDP_DROP;
}

char _license[] SEC("license") = "GPL";
