

#exemplo de execucao:
#bash executa_experimentos_AF_XDP.sh igorubuntu ens2f0 "10.10.10.10" "/24" "10.10.10.20" af_xdp_kern.o

#variaveis globais do script ---------------
user=$1
nome_interface=$2

#nome_interface="enp4s0f1"  #iface not igor
#nome_interface="eno1"      #iface lab igor
#nome_interface="eno2"      #iface lab igor
#nome_interface="ens2f0"    #iface lab igor
#nome_interface="ens2f1"    #iface lab igor


end_ipv4_interface=$3
#end_ipv4_interface="10.10.10.10"

mask_24=$4
#mask_24="/24"

end_ipv4_gerador=$5

programa_bpf=$6



#exibe informações da execução do script
echo -e "\n\n\nExecução do experimento: -------------------"
echo "Interface de rede escolhida: $1"
echo "IPv4: $3""$4"
echo "Pasta do Programa BPF: $programa_bpf"
#echo "Forma de execução: $tipo_exec_prog"
#echo "Seção de execução: $secao_exec"
echo -e "--------------------------------------------\n\n\n"

#limpar qualquer programa eBPF que está na interface
ip link set dev $nome_interface xdpgeneric off

#derruba interfaces de rede e levanta novamente
ip link set dev $nome_interface down
ip link set dev $nome_interface up

#configura endereco IPv4 na interface
ifconfig $nome_interface $end_ipv4_interface$mask_24 up

#falta configurar endereco IPv6 na interface


#definir rota dos pacotes para serem redirecionados e devolvidos
route add default gw $end_ipv4_gerador $nome_interface
#ou
#route add default gw $end_ipv4_interface $nome_interface

#adicionar redirecionamento
echo 1 > /proc/sys/net/ipv4/ip_forward

#entra na pasta do programa BPF que executa AF_XDP
cd /home/$user/libbpf/xdp-tutorial/advanced03-AF_XDP

#compila o programa eBPF
make

#ativa AF_XDP na interface escolhida
#sudo ./af_xdp_user -d $nome_interface

#ativa AF_XDP na interface escolhida e executa programa eBPF para retornar os pacotes que chegam na interface
sudo ./af_xdp_user -d $nome_interface --filename $programa_bpf



