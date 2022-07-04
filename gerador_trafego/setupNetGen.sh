#Ex execucao: 
#bash <nome_exec> <tam_packet> <hook_xdp> <var_IP> <var_MAR> <timeout_exec>
#bash setupNetGen.sh 64 xdpgeneric 0.0.0.10 00:00:00:00:00:00 60

packet_size=$1
modo_hook_xdp=$2
var_dst_IP=$3
var_dst_MAC=$4
timeout=$5

arq_save="../../home/igorcapeletti/github/tcc_eBPF_XDP/resultados/res_pkt"$packet_size"_ebpf_"$modo_hook_xdp"_varIP_"$var_dst_IP"_varMAC_"$var_dst_MAC

cd /opt/MoonGen

#setup hugepages
./setup-hugetlbfs.sh 

#load driver
modprobe uio
insmod /opt/MoonGen/libmoon/deps/dpdk/x86_64-native-linux-gcc/kmod/igb_uio.ko

#attach driver to network interfaface
python libmoon/deps/dpdk/usertools/dpdk-devbind.py -u 0000:23:00.1

python libmoon/deps/dpdk/usertools/dpdk-devbind.py --bind=igb_uio 0000:21:00.0

python libmoon/deps/dpdk/usertools/dpdk-devbind.py --status


#/opt/MoonGen/build/MoonGen ./examples/netronome-packetgen/packetgen.lua -tx 1 -rx 0 --dst-ip 200.10.12.3 --dst-ip-vary 0.0.0.0 --dst-mac 00:15:4d:13:63:3c --dst-mac-vary 00:00:00:00:00:00 --src-mac 90:E2:BA:4E:8A:A4 --src-mac-vary 00:00:00:00:00:00 --src-ip 11.11.11.10 --src-ip-vary 0.0.0.0


#execucao do gerador de trafego a partir dos parametros passados
/opt/MoonGen/build/MoonGen ./examples/netronome-packetgen/packetgen.lua -tx 0 -rx 0 --dst-ip 10.10.10.10 --dst-ip-vary $var_dst_IP --dst-mac 00:15:4d:13:5b:d3 --dst-mac-vary $var_dst_MAC --src-mac 90:E2:BA:4E:8A:A4 --src-mac-vary 00:00:00:00:00:00 --src-ip 10.10.10.1 --src-ip-vary 0.0.0.0 --pkt-size $packet_size --timeout $timeout --file-prefix $arq_save 