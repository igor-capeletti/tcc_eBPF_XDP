import os
import platform
import time
import sys
import glob
from pathlib import Path

#importacao da biblioteca paramiko(ssh) e argparse(argumentos)
try:
    import paramiko
    import argparse

except:
    os.system('pip install argparse')
    os.system('pip install paramiko')

#variaveis globais
usuario= 'igorubuntu'
#usuario= 'igorcapeletti'

tipo_programa_ebpf= 'for'
secao_programa_ebpf= 'xdp_test'
cont_inicial= 0
cont_final= 10000
cont_intervalo= 500



#1)-Gera programa eBPF ---------------------------------------------------------
if(tipo_programa_ebpf == 'for'):
  nome_arq_algoritmo= f'for_{cont_inicial}_a_{cont_final}.c'
  arq_algoritmo= open(f'/home/{usuario}/github/tcc_eBPF_XDP/scripts/ebpf/{nome_arq_algoritmo}', 'w')
  
  arq_algoritmo.write(f'\nSEC("{secao_programa_ebpf}")\n')
  arq_algoritmo.write('int  xdp_test_func(struct xdp_md *ctx){\n')
  arq_algoritmo.write('\tint var= 0;\n')
  arq_algoritmo.write('\t__u32 *pkt_count;\n')
  arq_algoritmo.write('\tint index= ctx->rx_queue_index;\n')
  arq_algoritmo.write('\tgoto out;\n\n')
  arq_algoritmo.write('out:\n')
  arq_algoritmo.write(f'\tif(var != {cont_final})'+'{\n')
  arq_algoritmo.write('\t\tvar= var+1;\n')
  arq_algoritmo.write('\t\tpkt_count= bpf_map_lookup_elem(&xdp_stats_map, 0, index);\n')
  arq_algoritmo.write('\t\tgoto out;\n')
  arq_algoritmo.write('\t}\n')
  arq_algoritmo.write('\treturn XDP_TX;\n')
  arq_algoritmo.write('}\n\n\n')
  arq_algoritmo.close()
else:
  print('Ainda não definido outros algoritmos!')


#reescreve novo programa eBPF em novo arquivo a partir de dois outros arquivos
arq_algoritmo= open(f'/home/{usuario}/github/tcc_eBPF_XDP/scripts/ebpf/{nome_arq_algoritmo}', 'r')
programa_ebpf_modificar= open(f'/home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c', 'r')
programa_ebpf_novo= open(f'/home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern_novo.c', 'w')

cont= 0
for i in programa_ebpf_modificar:
  programa_ebpf_novo.write(i)
  if(cont == 15):
    for j in arq_algoritmo:
      programa_ebpf_novo.write(j)
  cont+= 1
arq_algoritmo.close()
programa_ebpf_modificar.close()
programa_ebpf_novo.close()

os.system(f'rm /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')
os.system(f'mv /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern_novo.c /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')

#---------------------------------------------------------------------------------------------------
#2)-Modo de carregamento do programa ebpf(normal ou AF_XDP) ----------------------------------------

#3)-Compila programa e carrega para a interface de rede nos modos xdp que escolher
lista_modos_exec_xdp= ['xdpgeneric','xdpdrv','xdpoffload']

#4)-Faz acesso ssh com maquina geradora de trafego e cria trafego para os tamanhos de pacotes escolhidos
lista_tam_pacotes_gerar= ['64','128','256','512','1024','1500']

#5)-Carrega os resultados e gera os graficos
