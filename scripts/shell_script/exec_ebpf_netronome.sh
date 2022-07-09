#Exemplos para executar este script:
#bash <arquivo> <tipo_banda> <pasta_prog_BPF> <tipo_exec> <modo_load> <secao>

#basic02: -----------------------------------------------------------------------
#bash exec_ebpf_netronome.sh single basic02-prog-by-name 1 xdpgeneric xdp_pass
#bash exec_ebpf_netronome.sh single basic02-prog-by-name 1 xdpdrv xdp_pass
#bash exec_ebpf_netronome.sh single basic02-prog-by-name 1 xdpoffload xdp_pass

#bash exec_ebpf_netronome.sh single basic02-prog-by-name 1 xdpgeneric xdp_drop
#bash exec_ebpf_netronome.sh single basic02-prog-by-name 1 xdpdrv xdp_drop
#bash exec_ebpf_netronome.sh single basic02-prog-by-name 1 xdpoffload xdp_drop


#basic03: ----------------------------------------------------------------------
#bash exec_ebpf_netronome.sh single basic03-map-counter 1 xdpgeneric xdp_stats1

#basic04: ----------------------------------------------------------------------
#bash exec_ebpf_netronome.sh single basic04-pinning-maps 1 xdpgeneric xdp_pass
#bash exec_ebpf_netronome.sh single basic04-pinning-maps 1 xdpgeneric xdp_pass
#bash exec_ebpf_netronome.sh single basic04-pinning-maps 1 xdpgeneric xdp_pass
#bash exec_ebpf_netronome.sh single basic04-pinning-maps 1 xdpgeneric xdp_drop
#bash exec_ebpf_netronome.sh single basic04-pinning-maps 1 xdpgeneric xdp_abort

#packet01 ----------------------------------------------------------------------
#bash exec_ebpf_netronome.sh single packet01-parsing 1 xdpgeneric xdp_packet_parser


#nome_interface="enp4s0f1"  #iface not igor
#nome_interface="eno1"      #iface lab igor
#nome_interface="eno2"      #iface lab igor
#nome_interface="ens2f0"    #iface lab igor
#nome_interface="ens2f1"    #iface lab igor
#nome_interface="ens2np0"   #iface lab igor netronome
#nome_interface="ens2np1"   #iface lab igor netronome


#executar ao iniciar a maquina -----------------
#rmmod nfp
#modprobe nfp
#ethtool -L ens2np0 combined 8
#cd /home/igorcapeletti/github/nfp-drv-kmods/tools
#bash set_irq_affinity.sh ens2np0
#--------------------------------------------------------


#variaveis globais do script ---------------
tipo_rede=$1
programa_bpf=$2
tipo_exec_prog=$3
modo_load=$4
secao_exec=$5
endsubredeI="10.10.10.10/24"
endsubredeO="10.10.10.11/24"
#-------------------------------------------


#desabilita todos os programas xdp das interfaces de rede
ip link set dev ens2np0 xdpgeneric off
#ip link set dev ens2np1 xdpgeneric off

ip link set dev ens2np0 xdpdrv off
#ip link set dev ens2np1 xdpdrv off

ip link set dev ens2np0 xdpoffload off
#ip link set dev ens2np1 xdpoffload off


#derruba interfaces de rede
ip link set dev ens2np0 down
#ip link set dev ens2np1 down


#configuracao das interfaces de rede
if [ $tipo_rede = "single" ]; then
    
    #ativa links das interfaces
    ip link set dev ens2np0 up

    #seta ip para interface
    #ifconfig ens2np0 $endsubredeI up
    ip addr add $endsubredeI dev ens2np0

    #route add default gw 10.10.10.10 ens2np0

elif [ $tipo_rede = "dual" ]; then

    #ativa links das interfaces de rede
    ip link set dev ens2np0 up
    ip link set dev ens2np1 up

    #seta ip para cada interface
    #ifconfig ens2np0 $endsubredeI up
    ip addr add $endsubredeI dev ens2np0
    #ifconfig ens2np1 $endsubredeO up
    ip addr add $endsubredeO dev ens2np1

fi

cd /home/igorcapeletti/libbpf/xdp-tutorial/"$programa_bpf"
echo -e "Make"
make
echo -e "\nCarregamento programa ebpf para interface"
if [ $tipo_exec_prog = "1" ]; then
    #llvm-objdump -S xdp_prog_kern.o
    
    #ativar programa ebpf na interface ens2f0
    ip link set dev ens2np0 $modo_load obj xdp_prog_kern.o sec $secao_exec

elif [ $tipo_exec_prog = "2" ]; then
    ./xdp_loader --dev ens2np0 --force --progsec $secao_exec --$modo_load

fi


#exibe informações da execução do script
echo -e "\n\n\nExecução do experimento: -------------------"
echo "Rede com $tipo_rede channel na placa (single= 1 interface, dual= 2 interfaces)"
echo "Pasta do Programa BPF: $programa_bpf"
echo "Forma de execução: $tipo_exec_prog"
echo "Seção de execução: $secao_exec"
echo "Modo Hook XDP: $modo_load"
echo -e "\n"

#visualizar informacao da interface de rede
ip link show ens2np0

echo -e "--------------------------------------------\n\n\n\n\n"