
#importacao das bibliotecas
import pandas as pd
import numpy as np

import matplotlib.pyplot as plt
import seaborn as sns

plt.style.use('seaborn')
plt.rc('figure', figsize=(16, 12))

raiz= "/home/igorubuntu/Desktop/backup_res"
#raiz= "/home/igorcapeletti/github/tcc_eBPF_XDP/resultados"
#raiz= "/home/igorubuntu/github/tcc_eBPF_XDP/resultados"

df = pd.read_csv(f'{raiz}/resultado_geral.csv', sep=',', engine='python')

grafico_imprimir= 2

#geracao dos graficos ---------------------------------------
print(df.columns)
#Perguntas:

if(grafico_imprimir == 1):
  plt.rc('figure', figsize=(16, 12))
  #1ª) Qual a quantidade de pacotes processados quando utilizar laços for de diferentes tamanhos
  # com diferentes tamanhos de pacotes (mantendo o mesmo modo xdp e o mesmo combined)
  #it_combined= 1
  #it_hook_ebpf= "xdpgeneric"
  #df_pergunta1= df[df.combined == it_combined]
  #df_pergunta1= df_pergunta1[df_pergunta1.hook_ebpf == it_hook_ebpf]
  #df_pergunta1= df_pergunta1.sort_values(by=['algoritmo','packet_size'], ascending=True)
  #df_pergunta1= df_pergunta1[['algoritmo','packet_size','rx_packets','rx_packet_rate_avg','rx_packet_rate']]
#
  #ax = sns.barplot(y="rx_packets", x='algoritmo', hue='packet_size', data=df_pergunta1, palette='Paired');
  #ax.set_title(f'Quantidade de pacotes processados de acordo com o Algoritmo e tamanho de pacotes, com Hook {it_hook_ebpf} e {it_combined} fila tx/rx', fontsize=18, pad=50);
  #ax.set_ylabel('Quantidade de pacotes')
  #ax.set_xlabel('Tamanhos do algoritmo for')
  #ax.legend(title = "Tamanho dos pacotes")
  #save_image= ax.get_figure()
  #save_image.savefig(f'{raiz}/pergunta1.pdf')

elif(grafico_imprimir == 2):
  plt.rc('figure', figsize=(16, 12))
  #2ª) Qual a taxa de vazão de pacotes processados quando utilizar laços for de diferentes tamanhos
  # com diferentes tamanhos de pacotes (mantendo o mesmo modo xdp e o mesmo combined)
  it_combined= 1
  it_hook_ebpf= "xdpgeneric"
  df_pergunta2= df[df.combined == it_combined]
  df_pergunta2= df_pergunta2[df_pergunta2.hook_ebpf == it_hook_ebpf]
  df_pergunta2= df_pergunta2.sort_values(by=['algoritmo','packet_size'], ascending=True)
  df_pergunta2= df_pergunta2[['algoritmo','packet_size','rx_packets','rx_packet_rate_avg','rx_packet_rate']]

  ax = sns.barplot(y="rx_packet_rate", x='algoritmo', hue='packet_size', data=df_pergunta2, palette='Paired');
  ax.set_title(f'Taxa de Vazão de pacotes de acordo com o Algoritmo e tamanho de pacotes, com Hook {it_hook_ebpf} e {it_combined} fila tx/rx', fontsize=18, pad=50);
  ax.set_ylabel("Taxa de vazão")
  ax.set_xlabel('Tamanhos do algoritmo for')
  ax.legend(title = "Tamanho dos pacotes")
  save_image= ax.get_figure()
  save_image.savefig(f'{raiz}/pergunta2.pdf')