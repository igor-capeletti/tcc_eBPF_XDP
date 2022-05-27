#Exemplos para executar este script:
#bash executa_experimentos.sh 4 test_basic01 default
#bash executa_experimentos.sh 4 test_basic02 default
#bash executa_experimentos.sh 4 test_basic03 default
#bash executa_experimentos.sh 4 test_basic04 default
#bash executa_experimentos.sh 4 test_packet01 default
#bash executa_experimentos.sh 4 test_packet02 default
#bash executa_experimentos.sh 4 test_packet03 default


tipo_exec_prog=$3
endsubrede1I="10.10.10.1/24"
#-------------------------------------------

#desabilita todos os programas xdp das interfaces de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off


#derruba interfaces de rede em cada namespace
ip netns exec ns1 ip link set dev eno1 down
ip netns exec ns1 ip link set dev eno2 down

#deleta namespaces criados
ip netns del ns1
ip netns del ns2

#cria namespaces
ip netns add ns1
ip netns add ns2


#configuracao das interfaces de rede
if [ $tipo_rede = "2" ]; then
    #echo "numero 2"

    #seta interfaces de rede para namespaces
    ip link set eno1 netns ns1
    ip link set eno2 netns ns2

    #ativa links das interfaces de rede em cada namespace
    ip netns exec ns1 ip link set dev eno1 up
    ip netns exec ns2 ip link set dev eno2 up

    #seta ip para cada interface de rede de namespace especificas
    ip netns exec ns1 ifconfig eno1 $endsubrede1I up
    ip netns exec ns2 ifconfig eno2 $endsubrede2I up

elif [ $tipo_rede = "4" ]; then
    #echo "numero 4 "

    #seta interfaces de rede para namespaces
    ip link set eno1 netns ns1
    ip link set eno2 netns ns1
    ip link set ens2f0 netns ns2
    ip link set ens2f1 netns ns2

    #ativa links das interfaces de rede em cada namespace
    ip netns exec ns1 ip link set dev eno1 up
    ip netns exec ns1 ip link set dev eno2 up
    ip netns exec ns2 ip link set dev ens2f0 up
    ip netns exec ns2 ip link set dev ens2f1 up


    #seta ip para cada interface de rede de namespace especificas
    ip netns exec ns1 ifconfig eno1 $endsubrede1I up
    ip netns exec ns1 ifconfig eno2 $endsubrede1O up
    ip netns exec ns2 ifconfig ens2f0 $endsubrede2I up
    ip netns exec ns2 ifconfig ens2f1 $endsubrede2O up

fi

#abre pasta do programa BPF
cd $programa_bpf

#exibe informações da execução do script
echo -e "\n\n\nExecução do experimento: -------------------"
echo "Rede com $tipo_rede interfaces"
echo "Programa: $programa_bpf"
echo "Forma de execução: $tipo_exec_prog"
echo -e "--------------------------------------------\n\n\n"

#falta arrumar forma de executar o programa BPF
#daqui para baixo está funcionando mas falta adicionar 
#segunda opcao de execucao dos programas eBPF -----

#compila, carrega e executa programa eBPF para interface de rede especificada neste outro script
bash comp_exec_prog_ebpf.sh

#abre novo termnal para testes
#gnome-terminal



