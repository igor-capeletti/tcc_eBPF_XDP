

#exemplo de execucao:
#bash executa_experimentos_AF_XDP.sh enp4s0f1 "10.10.10.10" "/24" "10.10.10.20"

#variaveis globais do script ---------------
nome_interface=$1
#nome_interface="ens2f0"
#nome_interface="enp4s0f1"


end_ipv4_interface=$2
#end_ipv4_interface="10.10.10.10"

mask_24=$3
#mask_24="/24"

end_ipv4_gerador=$4

#exibe informações da execução do script
echo -e "\n\n\nExecução do experimento: -------------------"
echo "Interface de rede escolhida: $1"
echo "IPv4: $2""$3"
#echo "Pasta do Programa BPF: $programa_bpf"
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
#route add default gw $end_ipv4_gerador $nome_interface
#ou
route add default gw $end_ipv4_interface $nome_interface

#adicionar redirecionamento
echo 1 > /proc/sys/net/ipv4/ip_forward

