cd /home/igorcapeletti/libbpf/xdp-tutorial/basic03-map-counter
make

llvm-objdump -S xdp_prog_kern.o

#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

#ativar programa ebpf na interface ens2f0
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_stats1

#visualizar informacao da interface de rede
ip netns exec ns2 ip link show