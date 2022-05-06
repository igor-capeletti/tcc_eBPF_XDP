cd /home/igorcapeletti/libbpf/xdp-tutorial/packet02-rewriting
make

llvm-objdump -S xdp_prog_kern.o

#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

#ativar programa ebpf na interface ens2f0
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_port_rewrite
#ou
#ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_vlan_swap
#ou
#ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_packet_parser


#visualizar informacao da interface de rede
ip netns exec ns2 ip link show