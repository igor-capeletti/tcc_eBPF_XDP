cd /home/igorcapeletti/libbpf/xdp-tutorial/basic01-xdp-pass
make

llvm-objdump -S xdp_pass_kern.o

#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

#ativar programa ebpf na interface ens2f0
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_pass_kern.o sec xdp


#visualizar informacao da interface de rede
ip netns exec ns2 ip link show