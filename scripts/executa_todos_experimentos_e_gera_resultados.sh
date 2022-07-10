#Execucao:
#bash /home/igorcapeletti/github/tcc_eBPF_XDP/scripts/executa_todos_experimentos_e_gera_resultados.sh

#variaveis globais -----------------------------------------------------
#usuario="igorubuntu"
usuario="igorcapeletti"
tipo_programa_ebpf="for"
secao_programa_ebpf="xdp_pass"
modo_execucao_programa_ebpf="normal"
#modo_execucao_programa_ebpf="af_xdp"
local_scripts_shell="/home/$usuario/github/tcc_eBPF_XDP/scripts/shell_script"
local_scripts_ebpf="/home/$usuario/github/tcc_eBPF_XDP/scripts/ebpf"
local_scripts_python="/home/$usuario/github/tcc_eBPF_XDP/scripts/python"


ssh_usuario_gerador=$usuario
ssh_ip_gerador="200.132.136.84"
ssh_senha_gerador="12345678"
ssh_local_scripts_shell="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/scripts/shell_script"
ssh_local_scripts_ebpf="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/scripts/ebpf"
ssh_local_scripts_python="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/scripts/python"
ssh_local_resultados="/home/$ssh_usuario_gerador/tcc_eBPF_XDP/resultados"
ssh_local_gerador="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/gerador_trafego"

#variacao do algoritmo for
cont_inicial=0
cont_final=10500
cont_intervalo=500
nome_arq_algoritmo=" "
timeout_gerador="120"    #numero de execucoes que o gerador ira mandar/receber pacotes
arq_save_resultado=" "
tipo_rede="single"
programa_bpf="basic02-prog-by-name"
tipo_exec_prog="1"
modo_load=" "
secao_exec=" "
endsubredeI="10.10.10.10/24"
endsubredeO="10.10.10.11/24"
 

cont_a=1
cont_b=1
cont_c=1
cont_d=1
cont_e=1

#vai iterar nos modos combined escolhidos
for it_combined in "1" "2" "4" "8"; do
  ethtool -L ens2np0 combined $it_combined

  if [ $tipo_programa_ebpf = "for" ]; then
    for it_experimento in {0..10000..500}; do
      nome_arq_algoritmo="for_"$cont_inicial"_a_$it_experimento.c"
      pasta_resultado=$nome_arq_algoritmo

      #gera programa ebpf escolhido
      python3 /home/$usuario/github/tcc_eBPF_XDP/scripts/python/gerador_programas_ebpf.py --instrucao $tipo_programa_ebpf --inicio $cont_inicial --fim $it_experimento

      #deleta programa ebpf atual da pasta de execucao
      rm /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c

      #substitui o programa ebpf atual por um novo que sera executado
      cp $local_scripts_ebpf/$nome_arq_algoritmo /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c

      #remove e cria pasta de cada algoritmo na maquina de geracao de pacotes para depois armazenar os resultados de cada experimento
      rm -r $ssh_local_resultados/$pasta_resultado
      mkdir $ssh_local_resultados/$pasta_resultado

      #envia para maquina dos resultados o programa ebpf que foi executado no teste desta maquina
      scp /home/$usuario/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c $ssh_usuario_gerador@$ssh_ip_gerador:$ssh_local_resultados/$pasta_resultado/xdp_prog_kern.c

      #modo exec eBPF normal ou AF_XDP
      if [ $modo_execucao_programa_ebpf = "normal" ]; then
        #4)-Compila programa e carrega para a interface de rede nos modos xdp que escolher
        for it_modo_xdp in "xdpgeneric" "xdpdrv"; do
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

          cd /home/igorcapeletti/libbpf/xdp-tutorial/$programa_bpf
          make

          if [ $tipo_exec_prog = "1" ]; then
            #llvm-objdump -S xdp_prog_kern.o
            #ativar programa ebpf na interface ens2f0
            ip link set dev ens2np0 $it_modo_xdp obj xdp_prog_kern.o sec $secao_programa_ebpf
          elif [ $tipo_exec_prog = "2" ]; then
            if [ $it_modo_xdp = "xdpgeneric" ]; then
              ./xdp_loader --dev ens2np0 --force --progsec $secao_programa_ebpf --skb-mode
            elif [ $it_modo_xdp = "xdpdrv" ]; then
              ./xdp_loader --dev ens2np0 --force --progsec $secao_programa_ebpf --native-mode
            elif [ $it_modo_xdp = "xdpoffload" ]; then
              ./xdp_loader --dev ens2np0 --force --progsec $secao_programa_ebpf --offload-mode
            fi
          fi

          #vai gerar trafego para cada um dos tamanhos de pacotes especificados
          for it_tam_packet in "64" "128" "256" "512" "1024" "1500"; do 
            #vai fazer o experimento para cada variacao de IPs
            for it_var_ip in "0.0.0.0" "0.0.0.255" "0.0.255.255" "0.255.255.255" "255.255.255.255"; do
              #faz acesso ssh com maquina geradora de trafego e cria trafego para os tamanhos de pacotes escolhidos
              #chama shell script que ativa o gerador para gerar trafego
              #ssh -t $ssh_usuario_gerador@$ssh_ip_gerador sudo bash $ssh_local_gerador/setupNetGen.sh $it_tam_packet $it_modo_xdp $it_var_ip $it_combined $timeout_gerador $pasta_resultado
              
              #coleta a media dos resultados obtidos e salva em um arquivo geral da pasta
              #arq_save_resultado="$ssh_local_resultados/$pasta_resultado/res_combined_$combined+algoritmo_$pasta_resultado+pkt_$tam_packet+ebpf_$modo_xdp+varIP_$var_ip+timeout_$timeout.txt"
              #echo "python3 $ssh_local_scripts_python/gera_csv_resultado.py --arquivo $arq_save_resultado"
              
              
              #6)-Carrega os resultados do experimento e adiciona as medias em novo arquivo para gerar graficos ---------------
              
          
              #prints
              echo "Experimento $cont_a.$cont_b.$cont_c.$cont_d.$cont_e: ----------------------------------"
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
              ip link show ens2np0    #visualizar informacao da interface de rede
              echo -e "\n"
              cont_e=$((cont_e+1))
            done
            cont_e=$((0))
            cont_d=$((cont_d+1))
          done
          cont_d=$((0))
          cont_c=$((cont_c+1))
        done
      fi
      cont_c=$((0))
      cont_b=$((cont_b+1))
    done
  fi
  cont_b=$((0))
  cont_a=$((cont_a+1))
done