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

cont= 0
#vai iterar nos modos combined escolhidos
lista_combined_interface= [1,2,4,8]
for it_combined in lista_combined_interface:
  print(f"\nIniciou experimento {cont}: ---------------------------------------------------------\n")
  #seta combined das filas de tx/rx da interface
  os.system(f"ethtool -L ens2np0 combined {it_combined}")
  print(f"\tCombined = {it_combined}\n")

  #vai iterar nos diferentes algoritmos criados
  lista_experimentos= list(range(cont_inicial, cont_final, cont_intervalo))
  for it_experimento in lista_experimentos:
    #Gera programa eBPF 
    tempo_inicial = timeit.default_timer()
    if(tipo_programa_ebpf == 'for'):
      nome_arq_algoritmo= f'for_{cont_inicial}_a_{it_experimento}.c'
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
      arq_algoritmo.write(f'\tif(var <= {it_experimento})'+'{\n')
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

    #deleta programa ebpf atual da pasta de execucao
    os.system(f'rm /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')
    
    #substitui o programa ebpf atual por um novo que sera executado
    os.system(f'cp {local_scripts_ebpf}/{nome_arq_algoritmo} /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')
    
    ###os.system('echo %s|sudo -S %s' % (senha_server, (f'chmod 777 /home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c')))
    

    #remove e cria pasta de cada algoritmo na maquina de geracao de pacotes para depois armazenar os resultados de cada experimento
    stdin,stdout,stderr= ssh_client.exec_command(f'rm -r {ssh_local_resultados}/{pasta_resultado}')
    stdin,stdout,stderr= ssh_client.exec_command(f'mkdir {ssh_local_resultados}/{pasta_resultado}')

    #envia o arquivo com o programa ebpf criado(para backup) para a pasta dentro da maquina que esta gerando o trafego
    ftp_client = ssh_client.open_sftp()
    ftp_client.put((f'/home/{usuario}/libbpf/xdp-tutorial/basic02-prog-by-name/xdp_prog_kern.c'), (f'{ssh_local_resultados}/{pasta_resultado}/xdp_prog_kern.c'))    #envia arquivo para atacante via sftp


    #3)-Modo de execucao do programa ebpf(normal ou AF_XDP) ----------------------------------------
    if(modo_execucao_programa_ebpf == 'normal'):  #modo exec eBPF normal
      arq_save_resultado= ''
      timeout_gerador= '120'    #numero de execucoes que o gerador ira mandar/receber pacotes
      #lista_modos_exec_xdp= ['xdpgeneric','xdpdrv','xdpoffload']
      lista_modos_exec_xdp= ['xdpgeneric','xdpdrv']
      lista_tam_pacotes_gerar= ['64','128','256','512','1024','1500']
      #lista_variacao_ips= ['0.0.0.0','0.0.0.255','0.0.255.255','0.255.255.255','255.255.255.255']
      lista_variacao_ips= ['0.0.0.255']
      lista_variacao_macs= '00:00:00:00:00:00'  

      #4)-Compila programa e carrega para a interface de rede nos modos xdp que escolher ------------------------------------
      for it_modo_xdp in lista_modos_exec_xdp:   #vai fazer o experimento para cada um dos Hooks do XDP
        os.system(f'echo Experimento do algoritmo {nome_arq_algoritmo}: ---------------------------------------------------------------------')
        os.system('echo %s|sudo %s' % (senha_server, (f'bash {local_scripts_shell}/exec_ebpf_netronome.sh single basic02-prog-by-name 1 {it_modo_xdp} {secao_programa_ebpf}')))
        
        for it_tam_packet in lista_tam_pacotes_gerar:  #vai fazer o experimento para cada um dos tamanhos de pacotes
          for it_var_ip in lista_variacao_ips:           #vai fazer o experimento para cada variacao de IPs
            #5)-Faz acesso ssh com maquina geradora de trafego e cria trafego para os tamanhos de pacotes escolhidos ------------
            #executa o gerador e coleta os dados tx/rx dos espeximento e salva dentro de uma pasta num arquivo especifico
            os.system(f'bash acesso_ssh.sh {usuario_ssh} {server} {senha_server} {it_tam_packet} {it_modo_xdp} {it_var_ip} {it_combined} {timeout_gerador} {pasta_resultado}')

            #6)-Carrega os resultados do experimento e adiciona as medias em novo arquivo para gerar graficos ---------------
            
    elif(modo_execucao_programa_ebpf == 'af_xdp'):   #modo exec eBPF com AF_XDP
      print('Modo de execucao do programa ebpf(af_xdp), ainda nao desenvolvido!')

    tempo_final = timeit.default_timer()
    print (f'\nDuracao dos experimentos {nome_arq_algoritmo} nos hooks XDP {lista_modos_exec_xdp} com tamanho de pacotes {lista_tam_pacotes_gerar} e variacao de IP {lista_variacao_ips} : {(tempo_final-tempo_inicial)} segundos')


tempo_final_geral = timeit.default_timer()
print (f'\nDuracao total das execuções: {(tempo_final_geral-tempo_inicial_geral)} segundos')
ftp_client.close()