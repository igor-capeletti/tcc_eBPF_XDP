#Execucao:
#python3 gera_csv_resultado.py


import os
import platform
import time
import sys
import glob
from pathlib import Path

#importacao das bibliotecas que necessitam instalacao
try:
  import pandas as pd
  import numpy as np
  import matplotlib.pyplot as plt
  import seaborn as sns

except:
  os.system('pip install pandas')
  os.system('pip install numpy')
  os.system('pip install matplotlib')
  os.system('pip install seaborn')



#variaveis globais -------------------------------------------
pasta_raiz= ""
lista_arquivos= []
lista_pastas= []

#1) analiza arquivos salvos pelo gerador de trafego ----------------------------------------------------------
raiz= Path.home() / "/home/igorubuntu/github/tcc_eBPF_XDP/resultados/gerador"

for nomes_pastas in os.walk(raiz):
  lista_pastas.append(nomes_pastas[0])

lista_pastas= lista_pastas[1:]

#normalizar os arquivos para formato csv -----------------
for pasta in lista_pastas:
  #print(f"\nPasta: {pasta}")
  os.chdir(pasta)
  for format_file in glob.glob('*.txt'):
    nome_arquivo= (f'{pasta}/{format_file}').split('/')[8]
    nome_arquivo= nome_arquivo.split('.txt')[0]
    #print(nome_arquivo)

    arquivo_txt= open(f'{pasta}/{format_file}', 'r')
    arquivo_csv= open(f'{pasta}/{nome_arquivo}.csv', 'w')

    i= 0
    for linha in arquivo_txt:
      if(i == 0):
        titulo= linha.replace(' ','')
        titulo= titulo.replace('Time','Time,')
        titulo= titulo.replace('TXPackets','TXPackets,')
        titulo= titulo.replace('TXPacketRateAvg','TXPacketRateAvg,')
        titulo= titulo.replace('RateRXPackets','Rate,RXPackets,')
        titulo= titulo.replace('RXPacketRateAvg','RXPacketRateAvg,')
        titulo= titulo.replace('RateCore','Rate,Core,')
        titulo= titulo.lower()
        arquivo_csv.write(titulo)
        #print(titulo)
      else:
        titulo= linha.replace(' ','')
        arquivo_csv.write(titulo)
      
      i= i+1

    arquivo_txt.close()
    arquivo_csv.close()


#coletar os dados dos arquivos e salvar em um arquivo principal -----------------
arq_resultado_geral_gerador= open(f'{raiz}/resultado_geral_gerador.csv', 'w')
arq_resultado_geral_gerador.write("combined,algoritmo,packet_size,hook_ebpf,var_ip,timeout,rx_packets,rx_packet_rate_avg,rx_packet_rate\n")

for pasta in lista_pastas:
  os.chdir(pasta)
  for file in glob.glob('*.csv'):
    df_novo = pd.read_csv(f'{pasta}/{file}', sep=',', engine='python')
    #print(f'{pasta}/{file}')
    #print(df_novo.head(1))
    combined= file.split('combined_')[1]
    combined= combined.split('+')[0]
    algoritmo= file.split('algoritmo_')[1]
    algoritmo= algoritmo.split('+')[0]
    packet_size= file.split('pkt_')[1]
    packet_size= packet_size.split('+')[0]
    hook_ebpf= file.split('ebpf_')[1]
    hook_ebpf= hook_ebpf.split('+')[0]
    var_ip= file.split('varIP_')[1]
    var_ip= var_ip.split('+')[0]
    timeout= file.split('timeout_')[1]
    timeout= timeout.split('.csv')[0]

    df_novo= df_novo.tail(2)
    df_novo.reset_index(drop=True, inplace=True)
    rx_packets= df_novo.rxpackets[0]
    rx_packet_rate_avg= df_novo.rxpacketrateavg[0]
    rx_packet_rate= df_novo.rxpacketrate[0]

    arq_resultado_geral_gerador.write(f"{combined},{algoritmo},{packet_size},{hook_ebpf},{var_ip},{timeout},{rx_packets},{rx_packet_rate_avg},{rx_packet_rate}\n")
arq_resultado_geral_gerador.close()
print(f"Todos os resultados do gerador foram salvos no arquivo:\n\t'{raiz}/resultado_geral_gerador.csv'\n")


#2) analiza arquivos salvos pelo perf na maquina de execucao dos programas eBPF/XDP ------------------------
pasta= "/home/igorubuntu/github/tcc_eBPF_XDP/resultados/perf"
arq_resultado_geral_perf= open(f'{pasta}/resultado_geral_perf.csv', 'w')
arq_resultado_geral_perf.write("task_clock,context_switches,cpu_migrations,page_faults,cycles,instructions,branches,branch_misses,L1_dcache_loads,L1_dcache_load_misses,LLC_loads,LLC_load_misses,L1_icache_load_misses,dTLB_loads,dTLB_load_misses,iTLB_loads,iTLB_load_misses\n")

os.chdir(pasta)
for format_file in glob.glob('*.txt'):
  arquivo_txt= open(f'{pasta}/{format_file}', 'r')
  i= 0
  for linha in arquivo_txt:
    dados_linha= linha.replace(' ','')
    if(i == 5):
      task_clock= dados_linha.split("msectask-clock")[0]
    if(i == 6):
      context_switches= dados_linha.split("context-switches")[0]
    if(i == 7):
      cpu_migrations= dados_linha.split("cpu-migrations")[0]
    if(i == 8):
      page_faults= dados_linha.split("page-faults")[0]
    if(i == 9):
      cycles= dados_linha.split("cycles")[0]
    if(i == 10):
      instructions= dados_linha.split("instructions")[0]
    if(i == 11):
      branches= dados_linha.split("branches")[0]
    if(i == 12):
      branch_misses= dados_linha.split("branch-misses")[0]
    if(i == 13):
      L1_dcache_loads= dados_linha.split("L1-dcache-loads")[0]
    if(i == 14):
      L1_dcache_load_misses= dados_linha.split("L1-dcache-load-misses")[0]
    if(i == 15):
      LLC_loads= dados_linha.split("LLC-loads")[0]
    if(i == 16):
      LLC_load_misses= dados_linha.split("LLC-load-misses")[0]

    if(i == 18):
      L1_icache_load_misses= dados_linha.split("L1-icache-load-misses")[0]
    if(i == 19):
      dTLB_loads= dados_linha.split("dTLB-loads")[0]
    if(i == 20):
      dTLB_load_misses= dados_linha.split("dTLB-load-misses")[0]
    if(i == 21):
      iTLB_loads= dados_linha.split("iTLB-loads")[0]
    if(i == 22):
      iTLB_load_misses= dados_linha.split("iTLB-load-misses")[0]

    i= i+1
  arquivo_txt.close()
  arq_resultado_geral_perf.write(f"{task_clock},{context_switches},{cpu_migrations},{page_faults},{cycles},{instructions},{branches},{branch_misses},{L1_dcache_loads},{L1_dcache_load_misses},{LLC_loads},{LLC_load_misses},{L1_icache_load_misses},{dTLB_loads},{dTLB_load_misses},{iTLB_loads},{iTLB_load_misses}\n")
arq_resultado_geral_perf.close()
print(f"Todos os resultados do perf foram salvos no arquivo:\n\t'{pasta}/resultado_geral_perf.csv'\n")


#3) analiza arquivos salvos pelo sar na maquina de execucao dos programas eBPF/XDP ------------------------