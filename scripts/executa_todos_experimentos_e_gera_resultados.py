import os
import platform
import time
import sys
import glob
from pathlib import Path
import getpass

#importacao da biblioteca paramiko(ssh) e argparse(argumentos)
try:
    import paramiko
    import argparse
    import timeit

except:
    os.system('pip install argparse')
    os.system('pip install paramiko')

#implementacao -----------------------------------------------------------------------------------------------
tempo_inicial_geral = timeit.default_timer()


#variaveis globais ----------------------------
#usuario= 'igorubuntu'
usuario= 'igorcapeletti'
tipo_programa_ebpf= 'for'
secao_programa_ebpf= 'xdp_pass'
modo_execucao_programa_ebpf= 'normal'
#modo_execucao_programa_ebpf= 'af_xdp'


#variaveis da conexao ssh ----------------------------
usuario_ssh= usuario
server= '200.132.136.84'
senha_server= getpass.getpass('\nSenha do usuario SSH: ')
ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh_client.connect(hostname= server, username= usuario_ssh, password= senha_server)

cont_inicial= 0
cont_final= 10500
cont_intervalo= 500
local_scripts_shell= f'/home/{usuario}/github/tcc_eBPF_XDP/scripts/shell_script'
local_scripts_ebpf= f'/home/{usuario}/github/tcc_eBPF_XDP/scripts/ebpf'
local_scripts_python= f'/home/{usuario}/github/tcc_eBPF_XDP/scripts/python'
ssh_local_scripts_shell= f'/home/{usuario_ssh}/github/tcc_eBPF_XDP/scripts/shell_script'
ssh_local_scripts_ebpf= f'/home/{usuario_ssh}/github/tcc_eBPF_XDP/scripts/ebpf'
ssh_local_scripts_python= f'/home/{usuario_ssh}/github/tcc_eBPF_XDP/scripts/python'
ssh_local_resultados= f'/home/{usuario_ssh}/github/tcc_eBPF_XDP/resultados'
ssh_local_gerador= f'/home/{usuario_ssh}/github/tcc_eBPF_XDP/gerador_trafego'


lista_experimentos= list(range(cont_inicial, cont_final, cont_intervalo))
for experimento in lista_experimentos:
  #1)-Gera programa eBPF ---------------------------------------------------------------------------------------------
  tempo_inicial = timeit.default_timer()
  if(tipo_programa_ebpf == 'for'):
    nome_arq_algoritmo= f'for_{cont_inicial}_a_{experimento}.c'
    pasta_resultado= nome_arq_algoritmo
    arq_algoritmo= open(f'{local_scripts_ebpf}/{nome_arq_algoritmo}', 'w')
    
    arq_algoritmo.write('\n#include <linux/bpf.h>\n')
    arq_algoritmo.write('#include <bpf/bpf_helpers.h>\n\n\n')
    arq_algoritmo.write('struct bpf_map_def SEC("maps") xsks_map = {\n')
    arq_algoritmo.write('\t.type = BPF_MAP_TYPE_XSKMAP,\n')
    arq_algoritmo.write('\t.key_size = sizeof(int),\n')
    arq_algoritmo.write('\t.value_size = sizeof(int),\n')
    arq_algoritmo.write('\t.max_entries = 64,\n};\n\n')
    arq_algoritmo.write('struct bpf_map_def SEC("maps") xdp_stats_map = {\n')
    arq_algoritmo.write('\t.type = BPF_MAP_TYPE_PERCPU_ARRAY,\n')
    arq_algoritmo.write('\t.key_size    = sizeof(int),\n')
    arq_algoritmo.write('\t.value_size  = sizeof(__u32),\n')
    arq_algoritmo.write('\t.max_entries = 64,\n};\n\n')

    arq_algoritmo.write('SEC("xdp_pass")\n')
    arq_algoritmo.write('int xdp_pass_func(struct xdp_md *ctx){\n')
    arq_algoritmo.write('\tint var= 0;\n')
    arq_algoritmo.write('\t__u32 *pkt_count;\n')
    arq_algoritmo.write('\tint index= ctx->rx_queue_index;\n')
    arq_algoritmo.write('\tgoto out;\n\n')
    arq_algoritmo.write('out:\n')
    arq_algoritmo.write(f'\tif(var <= {experimento})'+'{\n')
    arq_algoritmo.write('\t\tvar= var+1;\n')
    arq_algoritmo.write('\t\tpkt_count = bpf_map_lookup_elem(&xdp_stats_map, &index);\n')
    arq_algoritmo.write('\t\tgoto out;\n')
    arq_algoritmo.write('\t}\n')
    arq_algoritmo.write('\treturn XDP_TX;\n')
    arq_algoritmo.write('}\n\n\n')
    
    arq_algoritmo.write('SEC("xdp_drop")\n')
    arq_algoritmo.write('int xdp_drop_func(struct xdp_md *ctx){\n')
    arq_algoritmo.write('\treturn XDP_DROP;\n}\n\n')
    arq_algoritmo.write('char _license[] SEC("license") = "GPL";\n')
    arq_algoritmo.close()
  else:
    print('Ainda não definido outros algoritmos!')


  #2)reescreve novo programa eBPF para o arquivo de execucao --------------------------------------

  #os.system('echo %s|sudo -S %s' % (senha_server, (f'chmod 777 /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')))

  os.system(f'rm /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')
  os.system(f'cp {local_scripts_ebpf}/{nome_arq_algoritmo} /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')
  #os.system('echo %s|sudo -S %s' % (senha_server, (f'chmod 777 /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')))
  

  #cria pasta para depois armazenar os resultados de cada experimento do gerador
  stdin,stdout,stderr= ssh_client.exec_command(f'rm -r {ssh_local_resultados}/{pasta_resultado}')
  stdin,stdout,stderr= ssh_client.exec_command(f'mkdir {ssh_local_resultados}/{pasta_resultado}')

  #envia o arquivo ebpf criado(para backup) para a pasta dentro da maquina que esta gerando o trafego
  ftp_client = ssh_client.open_sftp()
  ftp_client.put((f'/home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c'), (f'{ssh_local_resultados}/{pasta_resultado}/xdp_prog_kern.c'))    #envia arquivo para atacante via sftp
  ftp_client.close()


  #3)-Modo de execucao do programa ebpf(normal ou AF_XDP) ----------------------------------------
  if(modo_execucao_programa_ebpf == 'normal'):  #modo exec eBPF normal
    arq_save_resultado= ''
    timeout_gerador= 120
    #lista_modos_exec_xdp= ['xdpgeneric','xdpdrv','xdpoffload']
    lista_modos_exec_xdp= ['xdpgeneric','xdpdrv']
    lista_tam_pacotes_gerar= ['64','128','256','512','1024','1500']
    lista_variacao_ips= ['0.0.0.0','0.0.0.255','0.0.255.255','0.255.255.255','255.255.255.255']
    lista_variacao_macs= '00:00:00:00:00:00'  

    #4)-Compila programa e carrega para a interface de rede nos modos xdp que escolher ------------------------------------
    for modo_xdp in lista_modos_exec_xdp:   #vai fazer o experimento para cada um dos Hooks do XDP
      os.system(f'echo \nExperimento {nome_arq_algoritmo}, modo xdp {modo_xdp}! ---------------------------------------------------------------------')
      os.system('echo %s|sudo %s' % (senha_server, (f'bash {local_scripts_shell}/exec_ebpf_netronome.sh single basic02-prog-by-name 1 {modo_xdp} {secao_programa_ebpf}')))
      
#      #5)-Faz acesso ssh com maquina geradora de trafego e cria trafego para os tamanhos de pacotes escolhidos ------------
#      for tam_packet in lista_tam_pacotes_gerar:  #vai fazer o experimento para cada um dos tamanhos de pacotes
#        for var_ip in lista_variacao_ips:           #vai fazer o experimento para cada variacao de IPs
#          #executa o gerador e coleta os dados tx/rx dos espeximento e salva dentro de uma pasta num arquivo especifico
#          stdin,stdout,stderr= ssh_client.exec_command('echo %s|sudo %s' % (senha_server, (f'bash {ssh_local_gerador}/setupNetGen.sh {tam_packet} {modo_xdp} {var_ip} 00:00:00:00:00:00 {timeout_gerador} {pasta_resultado}')))
#          
#          #6)-Carrega os resultados do experimento e adiciona as medias em novo arquivo para gerar graficos ---------------
#          arq_save_resultado=f"{ssh_local_resultados}/{pasta_resultado}/res_pkt{tam_packet}_ebpf_{modo_xdp}+{modo_execucao_programa_ebpf}_varIP_{var_ip}_varMAC_{lista_variacao_macs}.txt"
#          stdin,stdout,stderr= ssh_client.exec_command('echo %s|sudo %s' % (senha_server, (f'python3 {ssh_local_scripts_python}/gera_csv_resultado.py --arquivo {arq_save_resultado}')))
#
#  elif(modo_execucao_programa_ebpf == 'af_xdp'):   #modo exec eBPF com AF_XDP
#    print('Modo de execucao do programa ebpf(af_xdp), ainda nao desenvolvido!')
#
#  tempo_final = timeit.default_timer()
#  print (f'\nDuracao dos experimentos {nome_arq_algoritmo} nos hooks XDP {lista_modos_exec_xdp} com tamanho de pacotes {lista_tam_pacotes_gerar} e variacao de IP {lista_variacao_ips} : {(tempo_final-tempo_inicial)} segundos')
#
#ssh_client.close()
#
#tempo_final_geral = timeit.default_timer()
#print (f'\nDuracao total das execuções: {(tempo_final_geral-tempo_inicial_geral)} segundos')