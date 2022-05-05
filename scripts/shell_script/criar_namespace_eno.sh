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
endsubrede1="10.10.10.1/24"
endsubrede2="10.10.10.2/24"


#criar namespaces
ip netns add ns1
ip netns add ns2


#setar interfaces de rede para namespaces
ip link set eno1 netns ns1
ip link set eno2 netns ns2


#ativar links das interfaces de rede em cada namespace
ip netns exec ns1 ip link set dev eno1 up
ip netns exec ns2 ip link set dev eno2 up


#setar ip para cada interface de rede de namespace especificas
ip netns exec ns1 ifconfig eno1 $endsubrede1 up
ip netns exec ns2 ifconfig eno2 $endsubrede2 up

