
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>


struct bpf_map_def SEC("maps") xsks_map = {
	.type = BPF_MAP_TYPE_XSKMAP,
	.key_size = sizeof(int),
	.value_size = sizeof(int),
	.max_entries = 64,
};

struct bpf_map_def SEC("maps") xdp_stats_map = {
	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
	.key_size    = sizeof(int),
	.value_size  = sizeof(__u32),
	.max_entries = 64,
};

SEC("xdp_pass")
int xdp_pass_func(struct xdp_md *ctx){
	int var= 0;
	__u32 *pkt_count;
	int index= ctx->rx_queue_index;
	goto out;

out:
	if(var <= 1){
		var= var+1;
		pkt_count = bpf_map_lookup_elem(&xdp_stats_map, &index);
		goto out;
	}
	return XDP_TX;
}


SEC("xdp_drop")
int xdp_drop_func(struct xdp_md *ctx){
	return XDP_DROP;
}

char _license[] SEC("license") = "GPL";
