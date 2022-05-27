cd /home/igorcapeletti/libbpf/xdp-tutorial/basic04-pinning-maps
make

llvm-objdump -S xdp_prog_kern.o

#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

#ativar programa ebpf na interface ens2f0
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_pass
#ou
#ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_drop
#ou
#ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_abort

#visualizar informacao da interface de rede
ip netns exec ns2 ip link show