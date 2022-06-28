#Exemplos para executar este script:
#<arquivo> <qtd interfaces> <pasta do programa BPF> <tipo execucao> <secao>

#bash down_ambient.sh

#deleta enlaces entre interfaces
ip link del dev client type veth peer name client_router
ip link del dev server type veth peer name server_router


#desativa links das interfaces de rede em cada namespace
ip netns exec ns1 ip link set client down
ip netns exec rt ip link set client_router down
ip netns exec rt ip link set server_router down
ip netns exec ns2 ip link set server down


#derruba interface de rede loopback para todos os namespaces
ip netns exec ns1 ip link set lo down
ip netns exec rt ip link set lo down
ip netns exec ns2 ip link set lo down


#deleta namespaces criados
ip netns del ns1
ip netns del ns2
ip netns del rt

ip netns
ip link show