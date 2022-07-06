import os
import sys
from datetime import datetime

#importacao da biblioteca pandas, numpy, matplotlib, seaborn
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


name_file= 'res_pkt64_ebpf_xdpgeneric+AF_XDP_varIP_255.255.255.255_varMAC_00:00:00:00:00:00.txt'
cols= ['Time', 'TX Packets', 'Packet Rate Avg', 'Packet Rate', 'RX Packets','Packet Rate Avg.1','Packet Rate.1',
       'Core', 'Port']
cols_result= ['tx_packet/rx_packet', 'tx_rate/rx_rate', 'tx_rate_avg/rx_rate_avg']


#Carregamento do arquivo de resultados dos experimentos com o gerador de trafego:
df= pd.read_fwf(name_file)
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


i= 0
j= 0
while(i < int((len(df.index))/2)):
  df_result['tx_packet/rx_packet'][j]= df.tx_packets[i]-df.rx_packets[i+1]
  print(f'{df.tx_packets[i]}-{df.rx_packets[i+1]}= {df_result["tx_packet/rx_packet"][j]}')
  i+=2
  j+=1


print(df_result)