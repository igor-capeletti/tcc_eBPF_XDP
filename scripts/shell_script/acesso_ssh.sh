#Exemplos para executar este script:
#bash acesso_ssh.sh <user_ssh> <IP_ssh> <senha_ssh> <tam_packet> <modo_xdp> <var_IP> <var_MAC> <time_out> <pasta_resultado>


user_ssh=$1
ip_ssh=$2
senha_ssh=$3
tam_packet=$4
modo_xdp=$5
var_ip=$6
var_mac=$7
time_out=$8
pasta_resultado=$9

ssh_local_gerador="/home/$user_ssh/github/tcc_eBPF_XDP/gerador_trafego"
ssh_local_resultados="/home/$user_ssh/github/tcc_eBPF_XDP/resultados"
arq_save_resultado="$ssh_local_resultados/$pasta_resultado/res_pkt$tam_packet+ebpf_$modo_xdp+var_ip_$var_ip+var_mac_$var_mac.txt"

"echo $senha_ssh|sudo bash $ssh_local_gerador/setupNetGen.sh $tam_packet $modo_xdp $var_ip $var_mac $time_out $pasta_resultado"

#exibe informações da execução do script
echo -e "Execução do experimento: -------------------"
echo "Rede com $tipo_rede channel na placa (single= 1 interface, dual= 2 interfaces)"
echo "Pasta do Programa BPF: $programa_bpf"
echo "Forma de execução: $tipo_exec_prog"
echo "Seção de execução: $secao_exec"
echo "Modo Hook XDP: $modo_load"
echo -e "-----------------------------------------------------------------------------------------------------------------\n\n\n\n\n\n\n"