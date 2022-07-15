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


#end_local_res_gerador= Path.home() / "/home/igorcapeletti/github/tcc_eBPF_XDP/resultados/gerador"
end_local_res_gerador= Path.home() / "/home/igorubuntu/github/tcc_eBPF_XDP/resultados/gerador"

#end_local_res_perf= Path.home() / "/home/igorcapeletti/github/tcc_eBPF_XDP/resultados/perf"
end_local_res_perf= Path.home() / "/home/igorubuntu/github/tcc_eBPF_XDP/resultados/perf"

#end_local_res_sar= Path.home() / "/home/igorcapeletti/github/tcc_eBPF_XDP/resultados/sar"
end_local_res_sar= Path.home() / "/home/igorubuntu/github/tcc_eBPF_XDP/resultados/sar"



#1) analiza arquivos salvos pelo gerador de trafego ----------------------------------------------------------
raiz= end_local_res_gerador

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
arq_resultado_geral= open(f'{raiz}/resultado_geral_gerador.csv', 'w')
arq_resultado_geral.write("combined,algoritmo,packet_size,hook_ebpf,var_ip,timeout,rx_packets,rx_packet_rate_avg,rx_packet_rate\n")

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

    arq_resultado_geral.write(f"{combined},{algoritmo},{packet_size},{hook_ebpf},{var_ip},{timeout},{rx_packets},{rx_packet_rate_avg},{rx_packet_rate}\n")

arq_resultado_geral.close()
print(f"Todos os resultados do gerador foram salvos no arquivo:\n\t'{raiz}/resultado_geral_gerador.csv'\n")


#2) analiza arquivos salvos pelo perf na maquina de execucao dos programas eBPF/XDP ------------------------
pasta= "/home/igorubuntu/github/tcc_eBPF_XDP/resultados/perf"
os.chdir(pasta)
for format_file in glob.glob('*.txt'):
  arquivo_txt= open(f'{pasta}/{format_file}', 'r')
  i= 0
  for linha in arquivo_txt:
    if(i >= 5 and i <= 13):
      dados_linha= linha.replace(' ','')
      print(dados_linha)
    i= i+1
  arquivo_txt.close()
#  arquivo_csv.close()
#
##coletar os dados dos arquivos e salvar em um arquivo principal -----------------
#arq_resultado_geral= open(f'{raiz}/resultado_geral_perf.csv', 'w')
#arq_resultado_geral.write("combined,algoritmo,packet_size,hook_ebpf,var_ip,timeout,rx_packets,rx_packet_rate_avg,rx_packet_rate\n")

