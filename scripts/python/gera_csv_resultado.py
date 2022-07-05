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
cols = ['Time', 'TX Packets', 'Packet Rate Avg', 'Packet Rate', 'RX Packets','Packet Rate Avg.1','Packet Rate.1',
       'Core', 'Port']


#Carregamento dos arquivos de resultados dos experimentos com o gerador de trafego:
df = pd.read_fwf(name_file)
df= df[cols]
df.rename(columns = {'Time':'time', 'TX Packets':'tx_packets', 'Packet Rate Avg':'tx_packet_rate_avg','Packet Rate':'tx_packet_rate', 
                      'RX Packets':'rx_packets','Packet Rate Avg.1':'rx_packet_rate_avg','Packet Rate.1':'rx_packet_rate',
                      'Core':'core', 'Port':'port'}, inplace = True)

#print(df.time[0]) #transformar strings de numeros para valores numericos

print(df.head())




plt.style.use('seaborn')
plt.rc('figure', figsize=(16, 12))

print('Olá mundo')