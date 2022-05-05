tipo_rede=$1
programa_bpf=$2
tipo_exec_prog=$3

endsubrede1I="10.10.10.10/24"
endsubrede1O="10.10.10.11/24"
endsubrede2I="10.10.10.20/24"
endsubrede2O="10.10.10.21/24"

#desabilita todos os programas xdp das interfaces de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off
#ip netns exec ns2 ip link set dev ens2f1 xdpgeneric off
#ip netns exec ns1 ip link set dev eno1 xdpgeneric off
#ip netns exec ns1 ip link set dev eno2 xdpgeneric off

#ip netns exec ns2 ip link set dev eno2 xdpgeneric off

#deletar namespaces criados
ip netns del ns1
ip netns del ns2

#criar namespaces
ip netns add ns1
ip netns add ns2


#configuracao das interfaces de rede
if [ $tipo_rede = "2" ]; then
    #echo "numero 2"

    #setar interfaces de rede para namespaces
    ip link set eno1 netns ns1
    ip link set eno2 netns ns2

    #ativar links das interfaces de rede em cada namespace
    ip netns exec ns1 ip link set dev eno1 up
    ip netns exec ns2 ip link set dev eno2 up

    #setar ip para cada interface de rede de namespace especificas
    ip netns exec ns1 ifconfig eno1 $endsubrede1I up
    ip netns exec ns2 ifconfig eno2 $endsubrede2I up

elif [ $tipo_rede = "4" ]; then
    #echo "numero 4 "

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

fi

#abrir pasta do programa BPF
cd $programa_bpf

echo -e "\n\n\nExecução do experimento: -------------------"
echo "Rede com $tipo_rede interfaces"
echo "Programa: $programa_bpf"
echo "Forma de execução: $tipo_exec_prog"
echo -e "--------------------------------------------\n\n\n"

#falta arrumar forma de executar o programa BPF
bash comp_exec_prog_ebpf.sh

gnome-terminal



