cd /home/igorcapeletti/libbpf/xdp-tutorial/basic02-prog-by-name
make

llvm-objdump -S xdp_prog_kern.o


#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off


#ativar programa ebpf na interface ens2f0
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_pass
#ou 
#ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec xdp_drop


ip netns exec ns2 ./xdp_loader --dev ens2f0 --force --progsec xdp_pass --auto-mode
ip netns exec ns2 ./xdp_loader --dev ens2f0 --force --progsec xdp_drop --auto-mode


#visualizar informacao da interface de rede
ip netns exec ns2 ip link show