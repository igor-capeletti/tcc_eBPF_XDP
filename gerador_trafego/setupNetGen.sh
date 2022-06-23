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


/opt/MoonGen/build/MoonGen ./examples/netronome-packetgen/packetgen.lua -tx 1 -rx 0 --dst-ip 200.10.12.3 --dst-ip-vary 0.0.0.0 --dst-mac 00:15:4d:13:63:3c --dst-mac-vary 00:00:00:00:00:00 --src-mac 90:E2:BA:4E:8A:A4 --src-mac-vary 00:00:00:00:00:00 --src-ip 11.11.11.10 --src-ip-vary 0.0.0.0

