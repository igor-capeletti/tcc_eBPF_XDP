#Exemplos para executar este script:
#<arquivo> <qtd interfaces> <pasta do programa BPF> <tipo execucao> <secao>

#bash up_ambient.sh


echo "Esquema do ambiente: ---------------------------------------------------------"
echo "### namespace ns1 ###                               ### namespace ns2 ###"
echo "#       client      #                               #       server      #"
echo "#    192.168.1.1    #                               #     192.168.2.1   #"
echo "#-------------------#                               #-------------------#"
echo "#                     \                            /"
echo "#                      \                          /"
echo "#                    ########## namespace rt ##########"
echo "#                    # client_router | server_router  #"
echo "#                    #  192.168.1.2  |  192.168.2.2   #"
echo "#                    #--------------------------------#"
echo "#------------------------------------------------------------------------------"



#variaveis globais do script ---------------
#interface_rede=$1
ip_end_cli="192.168.1.1"
ip_mask_end_cli="192.168.1.1/24"

ip_end_cli_rt="192.168.1.2"
ip_mask_end_cli_rt="192.168.1.2/24"

ip_end_server_rt="192.168.2.1"
ip_mask_end_server_rt="192.168.2.1/24"

ip_end_server="192.168.2.2"
ip_mask_end_server="192.168.2.2/24"
#-------------------------------------------


#deleta namespaces criados
ip netns del ns1
ip netns del ns2
ip netns del rt


#cria namespaces
ip netns add ns1
ip netns add ns2
ip netns add rt


#cria enlaces entre interfaces
ip link add dev client type veth peer name client_router
ip link add dev server type veth peer name server_router


#interliga as namespaces ns1 com rt
ip link set dev client netns ns1
ip link set dev client_router netns rt

#interliga as namespaces rt com ns2
ip link set dev server_router netns rt
ip link set dev server netns ns2


#ativa links das interfaces de rede em cada namespace
ip netns exec ns1 ip link set client up
ip netns exec rt ip link set client_router up
ip netns exec rt ip link set server_router up
ip netns exec ns2 ip link set server up


#levantar interface de rede loopback para todos os namespaces
ip netns exec ns1 ip link set lo up
ip netns exec rt ip link set lo up
ip netns exec ns2 ip link set lo up


#configurando IP e Rota do namespace ns1(cliente)
ip netns exec ns1 ifconfig client $ip_mask_end_cli
ip netns exec ns1 route add default gw $ip_end_cli_rt client

#configurando IP e Rota do namespace ns2(server)
ip netns exec ns2 ifconfig server $ip_mask_end_server
ip netns exec ns2 route add default gw $ip_end_server_rt server

#configurando IP e Rota do namespace rt(router)
ip netns exec rt ifconfig client_router $ip_mask_end_cli_rt
ip netns exec rt ifconfig server_router $ip_mask_end_server_rt


#ativar redirecionamento de pacotes no namespace (router)
ip netns exec rt echo 1 > /proc/sys/net/ipv4/ip_forward
ip netns exec rt route -n