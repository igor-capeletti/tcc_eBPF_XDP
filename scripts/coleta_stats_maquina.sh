#Execucao (em modo usuario sem sudo):
#bash /home/igorcapeletti/github/tcc_eBPF_XDP/scripts/coleta_stats_maquina.sh


#variaveis globais -----------------------------------------------------
usuario="igorcapeletti"
tipo_programa_ebpf="for"
modo_execucao_programa_ebpf="normal"
ssh_usuario_gerador="igorcapeletti"
ssh_local_resultados="/home/$ssh_usuario_gerador/github/tcc_eBPF_XDP/resultados"
cont_inicial=0
nome_arq_algoritmo=" "
timeout_gerador="60"    #numero de execucoes que o gerador ira mandar/receber pacotes
cont=1

for it_combined in "2" "4"; do
#for it_combined in "1" "2" "4" "8"; do
  if [ $tipo_programa_ebpf = "for" ]; then
    #for it_experimento in "0"; do
    #for it_experimento in {0..10000..500}; do
    for it_experimento in "0" "100" "200" "400" "800" "1600" "3200" "6400" "12800"; do
      nome_arq_algoritmo="for_"$cont_inicial"_a_$it_experimento.c"
      pasta_resultado="for_"$cont_inicial"_a_$it_experimento"

      if [ $modo_execucao_programa_ebpf = "normal" ]; then
        #for it_modo_xdp in "xdpgeneric" "xdpdrv" "xdpoffload"; do
        for it_modo_xdp in "xdpgeneric" "xdpdrv"; do
          #for it_tam_packet in "64"; do
          for it_tam_packet in "64" "128" "256" "512" "1024" "1500"; do
            for it_var_ip in "0.0.0.255"; do
              #coleta informacoes da maquina via sar
              echo $PASS | sudo -S sar -u ALL -P ALL -n DEV 2 -t 20 >> $ssh_local_resultados/stats_sar_combined_$it_combined+algoritmo_$pasta_resultado+pkt_$it_tam_packet+ebpf_$it_modo_xdp+varIP_$it_var_ip+timeout_$timeout_gerador.txt
              
              #coleta informacoes da maquina via perf
              echo $PASS | sudo -S perf stat -ddd sleep 5 >> $ssh_local_resultados/stats_perf_combined_$it_combined+algoritmo_$pasta_resultado+pkt_$it_tam_packet+ebpf_$it_modo_xdp+varIP_$it_var_ip+timeout_$timeout_gerador.txt

              sleep 80
              cont=$((cont+1))
            done
          done
        done
      fi
    done
  fi
done
