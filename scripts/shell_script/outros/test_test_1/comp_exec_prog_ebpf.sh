cd /home/igorcapeletti/libbpf/xdp-tutorial/test_1
make

llvm-objdump -S xdp_prog_kern.o

#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

#carregar programa eBPF para interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_router

#visualizar informacao da interface de rede
ip netns exec ns2 ip link show