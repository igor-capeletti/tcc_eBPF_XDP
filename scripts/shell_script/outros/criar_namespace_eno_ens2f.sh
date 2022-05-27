#deletar namespaces existentes
#ip netns >> namespaces_existentes.txt
#for i in namespaces_existentes.txt;
#    do ip netns del $i;
#done
#rm -r namespaces_existentes.txt

#deletar namespaces criados
ip netns del ns1
ip netns del ns2

#ip das subredes
endsubrede1I="10.10.10.10/24"
endsubrede1O="10.10.10.11/24"
endsubrede2I="10.10.10.20/24"
endsubrede2O="10.10.10.21/24"


#criar namespaces
ip netns add ns1
ip netns add ns2


#setar interfaces de rede para namespaces
ip link set eno1 netns ns1
ip link set eno2 netns ns1
ip link set ens2f0 netns ns2
ip link set ens2f1 netns ns2


#ativar links das interfaces de rede em cada namespace
ip netns exec ns1 ip link set dev eno1 up
ip netns exec ns1 ip link set dev eno2 up
ip netns exec ns2 ip link set dev ens2f0 up
ip netns exec ns2 ip link set dev ens2f1 up


#setar ip para cada interface de rede de namespace especificas
ip netns exec ns1 ifconfig eno1 $endsubrede1I up
ip netns exec ns1 ifconfig eno2 $endsubrede1O up
ip netns exec ns2 ifconfig ens2f0 $endsubrede2I up
ip netns exec ns2 ifconfig ens2f1 $endsubrede2O up

