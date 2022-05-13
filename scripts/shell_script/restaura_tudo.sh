#desabilita todos os programas xdp das interfaces de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

#derruba interfaces de rede em cada namespace
ip netns exec ns1 ip link set dev eno1 down
ip netns exec ns1 ip link set dev eno2 down
ip netns exec ns2 ip link set dev ens2f0 down
ip netns exec ns2 ip link set dev ens2f1 down

#deleta namespaces criados
ip netns del ns1
ip netns del ns2


sleep 3
ifconfig