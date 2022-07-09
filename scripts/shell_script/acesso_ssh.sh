#Exemplos para executar este script:
#bash acesso_ssh.sh <user_ssh> <IP_ssh> <senha_ssh> <tam_packet> <modo_xdp> <var_IP> <combined> <time_out> <pasta_resultado>

user_ssh=$1
ip_ssh=$2
senha_ssh=$3
tam_packet=$4
modo_xdp=$5
var_ip=$6
combined=$7
timeout=$8
pasta_resultado=$9

ssh_local_gerador="/home/$user_ssh/github/tcc_eBPF_XDP/gerador_trafego"
ssh_local_resultados="/home/$user_ssh/github/tcc_eBPF_XDP/resultados"
ssh_local_scripts_python= "/home/$user_ssh/github/tcc_eBPF_XDP/scripts/python"

#chama shell script que ativa o gerador para gerar trafego
echo "$senha_ssh|sudo bash $ssh_local_gerador/setupNetGen.sh $tam_packet $modo_xdp $var_ip $combined $timeout $pasta_resultado"

#coleta a media dos resultados obtidos e salva em um arquivo geral da pasta
arq_save_resultado="$ssh_local_resultados/$pasta_resultado/res_combined_$combined+algoritmo_$pasta_resultado+pkt_$tam_packet+ebpf_$modo_xdp+varIP_$var_ip+timeout_$timeout.txt"
echo "python3 $ssh_local_scripts_python/gera_csv_resultado.py --arquivo $arq_save_resultado"

#exibe informações da execução do script
echo -e "Execução do experimento: -------------------"
echo "Rede com $tipo_rede channel na placa (single= 1 interface, dual= 2 interfaces)"
echo "Pasta do Programa BPF: $programa_bpf"
echo "Forma de execução: $tipo_exec_prog"
echo "Seção de execução: $secao_exec"
echo "Modo Hook XDP: $modo_load"
echo -e "-----------------------------------------------------------------------------------------------------------------\n\n\n\n\n\n\n"