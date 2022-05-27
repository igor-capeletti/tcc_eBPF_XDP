#Exemplos para executar este script:
#<arquivo> <qtd interfaces> <pasta do programa BPF> <tipo execucao> <secao>

#basic01: 
#bash executa_experimentos.sh 4 basic01-xdp-pass 1 xdp

#basic02:
#bash executa_experimentos.sh 4 basic02-prog-by-name 1 xdp_pass
#bash executa_experimentos.sh 4 basic02-prog-by-name 1 xdp_drop

#basic03:
#bash executa_experimentos.sh 4 basic03-map-counter 1 xdp_stats1

#basic04:
#bash executa_experimentos.sh 4 basic04-pinning-maps 1 xdp_pass
#bash executa_experimentos.sh 4 basic04-pinning-maps 1 xdp_drop
#bash executa_experimentos.sh 4 basic04-pinning-maps 1 xdp_abort

#packet01
#bash executa_experimentos.sh 4 packet01-parsing 1 xdp_packet_parser


#falta arrumar
#bash executa_experimentos.sh 4 packet02-rewriting 1 default
#bash executa_experimentos.sh 4 packet03-redirecting 1 default


#variaveis globais do script ---------------
tipo_rede=$1
programa_bpf=$2
tipo_exec_prog=$3
secao_exec=$4
endsubrede1I="10.10.10.10/24"
endsubrede1O="10.10.10.11/24"
endsubrede2I="10.10.10.20/24"
endsubrede2O="10.10.10.21/24"
#-------------------------------------------

#exibe informações da execução do script
echo -e "\n\n\nExecução do experimento: -------------------"
echo "Rede com $tipo_rede interfaces"
echo "Pasta do Programa BPF: $programa_bpf"
echo "Forma de execução: $tipo_exec_prog"
echo "Seção de execução: $secao_exec"
echo -e "--------------------------------------------\n\n\n"

#desabilita todos os programas xdp das interfaces de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off
#ip netns exec ns2 ip link set dev ens2f1 xdpgeneric off
#ip netns exec ns1 ip link set dev eno1 xdpgeneric off
#ip netns exec ns1 ip link set dev eno2 xdpgeneric off

#ip netns exec ns2 ip link set dev eno2 xdpgeneric off


#derruba interfaces de rede em cada namespace
ip netns exec ns1 ip link set dev eno1 down
ip netns exec ns1 ip link set dev eno2 down
ip netns exec ns2 ip link set dev ens2f0 down
ip netns exec ns2 ip link set dev ens2f1 down


#deleta namespaces criados
ip netns del ns1
ip netns del ns2


#cria namespaces
ip netns add ns1
ip netns add ns2


#configuracao das interfaces de rede
if [ $tipo_rede = "2" ]; then
    #seta interfaces de rede nas namespaces
    ip link set eno1 netns ns1
    ip link set eno2 netns ns2

    #ativa links das interfaces de rede em cada namespace
    ip netns exec ns1 ip link set dev eno1 up
    ip netns exec ns2 ip link set dev eno2 up

    #seta ip para cada interface de rede de namespace especificas
    ip netns exec ns1 ifconfig eno1 $endsubrede1I up
    ip netns exec ns2 ifconfig eno2 $endsubrede2I up

elif [ $tipo_rede = "4" ]; then
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

cd /home/igorcapeletti/libbpf/xdp-tutorial/"$programa_bpf"

#remover programa xdp da interface de rede
ip netns exec ns2 ip link set dev ens2f0 xdpgeneric off

if [ $tipo_exec_prog = "1" ]; then
    make
    llvm-objdump -S xdp_prog_kern.o
    
    #ativar programa ebpf na interface ens2f0
    ip netns exec ns2 ip link set dev ens2f0 xdpgeneric obj xdp_prog_kern.o sec $secao_exec

elif [ $tipo_exec_prog = "2" ]; then
    ip netns exec ns2 ./xdp_loader --dev ens2f0 --force --progsec $secao_exec --auto-mode

fi

#visualizar informacao da interface de rede
ip netns exec ns2 ip link show
