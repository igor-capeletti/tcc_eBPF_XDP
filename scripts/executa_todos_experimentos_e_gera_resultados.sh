#Execucao:

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
nome_arq_algoritmo=""

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



      #prints
      echo "Experimento $cont_a.$cont_b.$cont_c.$cont_d.$cont_e: ----------------------------------"
      echo "  Combined =  $it_combined"
      echo "  Algoritmo = $nome_arq_algoritmo"
      cont_b=$((cont_b+1))
    done
  fi
  cont_a=$((cont_a+1))
done