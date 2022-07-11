#Execucao:
#python3 gera_csv_resultado.py --arquivo nome_arquivo
import os
import sys
from datetime import datetime

#importacao da biblioteca pandas, numpy, matplotlib, seaborn
try:
  import argparse
  import pandas as pd
  import numpy as np
  import matplotlib.pyplot as plt
  import seaborn as sns

except:
  os.system('pip install argparse')
  os.system('pip install pandas')
  os.system('pip install numpy')
  os.system('pip install matplotlib')
  os.system('pip install seaborn')

#variaveis globais -------------------------------------------
endereco_file= ''
cols= ['Time', 'TX Packets', 'Packet Rate Avg', 'Packet Rate', 'RX Packets','Packet Rate Avg.1','Packet Rate.1',
       'Core', 'Port']
cols_result= ['tx_packet/rx_packet', 'tx_rate/rx_rate', 'tx_rate_avg/rx_rate_avg']


#tratamento de argumento -------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--arquivo", help="Define nome do arquivo para calcular o valor dos resultados.")
args = parser.parse_args()

try:    
    if args.arquivo:
        endereco_file = args.arquivo
    else:
        print("\nNao definido nome do arquivo para calcular o resultado! Ver comando --arquivo")
        exit(-1)
except:
    print("Erro com parametros passados!")
    exit(-1)


#Carregamento do arquivo de resultados dos experimentos com o gerador de trafego:
df= pd.read_fwf(endereco_file)
df= df[cols]


#normalizacao do dataframe(transformado todas as colunas para sring, 
# retirado as virgulas e depois transformado tipo de dados para float)
for i in cols:
  df[i]= df[i].astype(str)
  df[i]= df[i].str.replace(',','')
  df[i]= df[i].astype(float)


#renomeacao das colunas do dataframe
df.rename(columns = {'Time':'time', 'TX Packets':'tx_packets', 'Packet Rate Avg':'tx_packet_rate_avg','Packet Rate':'tx_packet_rate', 
                      'RX Packets':'rx_packets','Packet Rate Avg.1':'rx_packet_rate_avg','Packet Rate.1':'rx_packet_rate',
                      'Core':'core', 'Port':'port'}, inplace = True)


#criando novo dataframe para os resultados das médias obtidas
df_result= pd.DataFrame(np.zeros(shape=(30,3)), columns=cols_result)



#calcular media para cada passo executado do teste
i= 0
j= 0
while(i < int((len(df.index))/2)):
  #calculo da relacao em cada passo de packets tx-rx
  df_result['tx_packet/rx_packet'][j]= df.tx_packets[i]-df.rx_packets[i+1]
  #print(f'{df.tx_packets[i]}-{df.rx_packets[i+1]}= {df_result["tx_packet/rx_packet"][j]}')

  #calculo da relacao em cada passo da taxa de packets tx-rx
  df_result['tx_rate/rx_rate'][j]= df.tx_packet_rate[i]-df.rx_packet_rate[i+1]
  #print(f'{df.tx_packet_rate[i]}-{df.rx_packet_rate[i+1]}= {df_result["tx_rate/rx_rate"][j]}')

  #calculo da relacao em cada passo da media da taxa de packets tx-rx
  df_result['tx_rate_avg/rx_rate_avg'][j]= df.tx_packet_rate_avg[i]-df.rx_packet_rate_avg[i+1]
  #print(f'{df.tx_packet_rate_avg[i]}-{df.rx_packet_rate_avg[i+1]}= {df_result["tx_rate_avg/rx_rate_avg"][j]}')
  i+=2
  j+=1


#calcula a media geral de cada coluna do dataframe
media_packets_tx_rx= df_result['tx_packet/rx_packet'].mean()
media_rate_packets_tx_rx= df_result['tx_rate/rx_rate'].mean()
media_avg_rate_packets_tx_rx= df_result['tx_rate_avg/rx_rate_avg'].mean()


#salva essas medias calculadas acima, em um arquivo que contera o resultado de todos os testes
local_end= endereco_file.split('/')
end_pasta= f'{local_end[0]}/{local_end[1]}/{local_end[2]}/{local_end[3]}/{local_end[4]}/{local_end[5]}/{local_end[6]}'
arq_resultados= open(f'{end_pasta}/resultado_final.txt', 'a')
lista_variaveis= local_end[7].split('_')

combined= lista_variaveis.split('combined_')[1]
combined= combined.split('+')[0]
algoritmo= lista_variaveis.split('algoritmo_')[1]
algoritmo= algoritmo.split('+')[0]
tam_packet= lista_variaveis.split('pkt_')[1]
tam_packet= tam_packet.split('+')[0]
ebpf= lista_variaveis.split('ebpf_')[1]
ebpf= ebpf.split('+')[0]
varIP= lista_variaveis.split('varIP_')[1]
varIP= varIP.split('+')[0]
timeout= lista_variaveis.split('timeout_')[1]
timeout= timeout.split('.txt')[0]

arq_resultados.write(f'{combined}\t{algoritmo}\t{tam_packet}\t{ebpf}\t{varIP}\t{timeout}\t{media_packets_tx_rx}\t{media_rate_packets_tx_rx}\t{media_avg_rate_packets_tx_rx}\n')
arq_resultados.close()


#print(df_result)
#print(f'Media de pacotes tx-rx= \t\t{media_packets_tx_rx}')
#print(f'Media de taxa pacotes tx-rx= \t\t{media_rate_packets_tx_rx}')
#print(f'Media do AVG da taxa pacotes tx-rx= \t{media_avg_rate_packets_tx_rx}')