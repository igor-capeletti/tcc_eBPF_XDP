#Ex execucao: 
#bash <nome_exec> <tam_packet> <hook_xdp> <var_IP> <combined> <timeout_exec> <nome_pasta_salvar>
#bash setupNetGen.sh 64 xdpgeneric 0.0.0.10 8 60 pasta

packet_size=$1
modo_hook_xdp=$2
var_dst_IP=$3
combined=$4
timeout=$5
nome_pasta_resultados=$6

arq_save="/home/igorcapeletti/github/tcc_eBPF_XDP/resultados/$nome_pasta_resultados/res_combined_$combined+algoritmo_$nome_pasta_resultados+pkt_$tam_packet+ebpf_$modo_xdp+varIP_$var_ip+timeout_$timeout.txt"

cd /opt/MoonGen

#setup hugepages
/opt/MoonGen/ ./setup-hugetlbfs.sh 

#load driver
modprobe uio
insmod libmoon/deps/dpdk/x86_64-native-linux-gcc/kmod/igb_uio.ko

#attach driver to network interfaface
python libmoon/deps/dpdk/usertools/dpdk-devbind.py -u 0000:23:00.1

python libmoon/deps/dpdk/usertools/dpdk-devbind.py --bind=igb_uio 0000:21:00.0

python libmoon/deps/dpdk/usertools/dpdk-devbind.py --status


#/opt/MoonGen/build/MoonGen ./examples/netronome-packetgen/packetgen.lua -tx 1 -rx 0 --dst-ip 200.10.12.3 --dst-ip-vary 0.0.0.0 --dst-mac 00:15:4d:13:63:3c --dst-mac-vary 00:00:00:00:00:00 --src-mac 90:E2:BA:4E:8A:A4 --src-mac-vary 00:00:00:00:00:00 --src-ip 11.11.11.10 --src-ip-vary 0.0.0.0


#execucao do gerador de trafego a partir dos parametros passados
/opt/MoonGen/build/MoonGen ./examples/netronome-packetgen/packetgen.lua -tx 0 -rx 0 --dst-ip 10.10.10.10 --dst-ip-vary $var_dst_IP --dst-mac 00:15:4d:13:5b:d3 --dst-mac-vary 00:00:00:00:00:00 --src-mac 90:E2:BA:4E:8A:A4 --src-mac-vary 00:00:00:00:00:00 --src-ip 10.10.10.1 --src-ip-vary 0.0.0.0 --pkt-size $packet_size --timeout $timeout --file-prefix $arq_save 

echo "Executou gerador!"