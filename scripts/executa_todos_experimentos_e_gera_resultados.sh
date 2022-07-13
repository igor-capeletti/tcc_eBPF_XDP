#Execucao (em modo usuario sem sudo):
#bash /home/igorcapeletti/github/tcc_eBPF_XDP/scripts/executa_todos_experimentos_e_gera_resultados.sh


#executar ao iniciar a maquina -----------------
#rmmod nfp
#modprobe nfp
#ethtool -L ens2np0 combined 8
#cd /home/igorcapeletti/github/nfp-drv-kmods/tools
#bash set_irq_affinity.sh ens2np0
#--------------------------------------------------------


#variaveis globais -----------------------------------------------------
usuario="igorcapeletti"
tipo_programa_ebpf="for"
secao_programa_ebpf="xdp_pass"
modo_execucao_programa_ebpf="normal"
#modo_execucao_programa_ebpf="af_xdp"
local_scripts_shell="/home/$usuario/github/tcc_eBPF_XDP/scripts/shell_script"
local_scripts_ebpf="/home/$usuario/github/tcc_eBPF_XDP/scripts/ebpf"
local_scripts_python="/home/$usuario/github/tcc_eBPF_XDP/scripts/python"


ssh_usuario_gerador="igorcapeletti"
ssh_ip_gerador="200.132.136.84"
ssh_local_scripts_shell="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/scripts/shell_script"
ssh_local_scripts_ebpf="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/scripts/ebpf"
ssh_local_scripts_python="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/scripts/python"
ssh_local_resultados="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/resultados"
ssh_local_gerador="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/gerador_trafego"

#variacao do algoritmo for
cont_inicial=0
cont_final=10500
cont_intervalo=500
nome_arq_algoritmo=" "
timeout_gerador="60"    #numero de execucoes que o gerador ira mandar/receber pacotes
arq_save_resultado=" "
tipo_rede="single"
programa_bpf="basic02-prog-by-name"
tipo_exec_prog="1"
modo_load=" "
secao_exec=" "
endsubredeI="10.10.10.10/24"
endsubredeO="10.10.10.11/24"

#nome_interface="enp4s0f1"  #iface not igor
#nome_interface="eno1"      #iface lab igor
#nome_interface="eno2"      #iface lab igor
#nome_interface="ens2f0"    #iface lab igor
#nome_interface="ens2f1"    #iface lab igor
nome_interface="ens2np0"   #iface lab igor netronome
#nome_interface="ens2np1"   #iface lab igor netronome
 

cont=1

#vai iterar nos modos combined escolhidos
for it_combined in "2" "4"; do
#for it_combined in "1" "2" "4" "8"; do
  echo -e "\n\n"
  echo $PASS | sudo -S ethtool -L $nome_interface combined $it_combined

  if [ $tipo_programa_ebpf = "for" ]; then
    #for it_experimento in "0"; do
    #for it_experimento in {0..10000..500}; do
    for it_experimento in "0" "100" "200" "400" "800" "1600" "3200" "6400" "12800"; do
      nome_arq_algoritmo="for_"$cont_inicial"_a_$it_experimento.c"
      pasta_resultado="for_"$cont_inicial"_a_$it_experimento"

      #gera programa ebpf escolhido
      python3 /home/$usuario/github/tcc_eBPF_XDP/scripts/python/gerador_programas_ebpf.py --instrucao $tipo_programa_ebpf --inicio $cont_inicial --fim $it_experimento
      echo "Gerou novo programa ebpf $nome_arq_algoritmo"

      #deleta programa ebpf atual da pasta de execucao
      rm -r /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c
      echo "Removeu programa ebpf atual"

      #substitui o programa ebpf atual por um novo que sera executado
      cp $local_scripts_ebpf/$nome_arq_algoritmo /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c
      echo "Copiou novo programa para pasta de execucao do programa ebpf"

      #cria pasta de cada algoritmo na maquina de geracao de pacotes para depois armazenar os resultados de cada experimento
      #echo $PASS | ssh $ssh_usuario_gerador@$ssh_ip_gerador "mkdir $ssh_local_resultados/$pasta_resultado"
      ssh $ssh_usuario_gerador@$ssh_ip_gerador "mkdir $ssh_local_resultados/$pasta_resultado"
      echo "Criou nova pasta($pasta_resultado) de resultado na maquina geradora de trafego"

      #envia para maquina dos resultados o programa ebpf que foi executado no teste desta maquina
      #echo $PASS | scp /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c $ssh_usuario_gerador@$ssh_ip_gerador:$ssh_local_resultados/$pasta_resultado/$nome_arq_algoritmo 
      scp /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c $ssh_usuario_gerador@$ssh_ip_gerador:$ssh_local_resultados/$pasta_resultado/$nome_arq_algoritmo 
      echo "Copiou novo programa ebpf para a pasta resultados/$pasta_resultado da maquina geradora de trafego"


      #modo exec eBPF normal ou AF_XDP
      if [ $modo_execucao_programa_ebpf = "normal" ]; then
        #for it_modo_xdp in "xdpgeneric" "xdpdrv" "xdpoffload"; do
        for it_modo_xdp in "xdpgeneric" "xdpdrv"; do
          #desabilita todos os programas xdp das interfaces de rede
          echo $PASS | sudo -S ip link set dev $nome_interface xdpgeneric off
          #ip link set dev ens2np1 xdpgeneric off
          echo $PASS | sudo -S ip link set dev $nome_interface xdpdrv off
          #ip link set dev ens2np1 xdpdrv off
          echo $PASS | sudo -S ip link set dev $nome_interface xdpoffload off
          #ip link set dev ens2np1 xdpoffload off

          #derruba interfaces de rede
          echo $PASS | sudo -S ip link set dev $nome_interface down
          #ip link set dev ens2np1 down

          #configuracao das interfaces de rede
          if [ $tipo_rede = "single" ]; then
            #ativa links das interfaces
            echo $PASS | sudo -S ip link set dev $nome_interface up
            #seta ip para interface
            #ifconfig ens2np0 $endsubredeI up
            echo $PASS | sudo -S ip addr add $endsubredeI dev $nome_interface
            #route add default gw 10.10.10.10 ens2np0
          elif [ $tipo_rede = "dual" ]; then
            #ativa links das interfaces de rede
            echo $PASS | sudo -S ip link set dev $nome_interface up
            echo $PASS | sudo -S ip link set dev $nome_interface up
            #seta ip para cada interface
            #ifconfig ens2np0 $endsubredeI up
            echo $PASS | sudo -S ip addr add $endsubredeI dev $nome_interface
            #ifconfig ens2np1 $endsubredeO up
            echo $PASS | sudo -S ip addr add $endsubredeO dev $nome_interface
          fi

          cd /home/$usuario/libbpf/xdp-tutorial/$programa_bpf
          make

          if [ $tipo_exec_prog = "1" ]; then
            #llvm-objdump -S xdp_prog_kern.o
            #ativar programa ebpf na interface ens2f0
            echo $PASS | sudo -S ip link set dev $nome_interface $it_modo_xdp obj xdp_prog_kern.o sec $secao_programa_ebpf
          elif [ $tipo_exec_prog = "2" ]; then
            if [ $it_modo_xdp = "xdpgeneric" ]; then
              echo $PASS | sudo -S ./xdp_loader --dev $nome_interface --force --progsec $secao_programa_ebpf --skb-mode
            elif [ $it_modo_xdp = "xdpdrv" ]; then
              echo $PASS | sudo -S ./xdp_loader --dev $nome_interface --force --progsec $secao_programa_ebpf --native-mode
            elif [ $it_modo_xdp = "xdpoffload" ]; then
              echo $PASS | sudo -S ./xdp_loader --dev $nome_interface --force --progsec $secao_programa_ebpf --offload-mode
            fi
          fi

          #vai gerar trafego para cada um dos tamanhos de pacotes especificados
          #for it_tam_packet in "64"; do
          for it_tam_packet in "64" "128" "256" "512" "1024" "1500"; do
            #vai fazer o experimento para cada variacao de IPs
            for it_var_ip in "0.0.0.255"; do
              #prints
              echo "Experimento $cont/$((2*9*2*6)): ----------------------------------"
              echo "  Combined =  $it_combined"
              echo "  Algoritmo = $nome_arq_algoritmo"
              echo "  Modo Hook XDP = $it_modo_xdp"
              echo "  Tamanho dos pacotes gerados = $it_tam_packet"
              echo "  Variacao de enderecos IP = $it_var_ip"
              echo "  Outras informacoes: ---------"
              echo "    Execucao do programa eBPF em modo = $modo_execucao_programa_ebpf"
              echo "    Rede com $tipo_rede channel na placa (single= 1 interface, dual= 2 interfaces)"
              echo "    Forma de execução = $tipo_exec_prog"
              echo "    Seção de execução = $secao_programa_ebpf"
              ip link show $nome_interface    #visualizar informacao da interface de rede
              echo -e "\n"


              #faz acesso ssh com maquina geradora de trafego e chama shell script que ativa o gerador para gerar trafego
              #echo "Gerador enviando e recenbendo tráfego..."
              #echo $PASS | ssh $ssh_usuario_gerador@$ssh_ip_gerador "echo $PASS | sudo -S bash $ssh_local_gerador/setupNetGen.sh $it_tam_packet $it_modo_xdp $it_var_ip $it_combined $timeout_gerador $pasta_resultado"
              ssh -t $ssh_usuario_gerador@$ssh_ip_gerador "echo $PASS | sudo -S bash $ssh_local_gerador/setupNetGen.sh $it_tam_packet $it_modo_xdp $it_var_ip $it_combined $timeout_gerador $pasta_resultado" &
              
              echo $PASS | sudo sar -u ALL -P ALL -n DEV 2 -t 25 >> stat_sar.txt
              mv stat_sar.txt $ssh_local_resultados/stats_sar_combined_$it_combined.algoritmo_$pasta_resultado.pkt_$it_tam_packet.ebpf_$it_modo_xdp.varIP_$it_var_ip.timeout_$timeout_gerador.txt

              echo $PASS | sudo -S perf stat -ddd sleep 5 >> stat_perf.txt
              mv stat_perf.txt $ssh_local_resultados/stats_perf_combined_$it_combined.algoritmo_$pasta_resultado.pkt_$it_tam_packet.ebpf_$it_modo_xdp.varIP_$it_var_ip.timeout_$timeout_gerador.txt

              sleep "20"
              

              cont=$((cont+1))
            done
          done
        done
      fi
    done
  fi
done
