
SEC("xdp_test")
int  xdp_test_func(struct xdp_md *ctx){
	int var= 0;
	__u32 *pkt_count;
	int index= ctx->rx_queue_index;
	goto out;

out:
	if(var != 10000){
		var= var+1;
		pkt_count= bpf_map_lookup_elem(&xdp_stats_map, 0, index);
		goto out;
	}
	return XDP_TX;
}


