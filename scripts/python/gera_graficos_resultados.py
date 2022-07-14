
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

#gerancao dos graficos ---------------------------------------
print(df.columns)
#Perguntas:

#1ª) Qual a quantidade de pacotes processados quando utilizar laços for de diferentes tamanhos
# com diferentes tamanhos de pacotes (mantendo o mesmo modo xdp e o mesmo combined)
combined= 1
hook_ebpf= "xdpgeneric"
df_pergunta1= df[df.combined == combined]
df_pergunta1= df_pergunta1[df_pergunta1.hook_ebpf == hook_ebpf]
df_pergunta1= df_pergunta1.sort_values(by=['packet_size','algoritmo'], ascending=True)
df_pergunta1= df_pergunta1[['algoritmo','packet_size','rx_packets','rx_packet_rate_avg','rx_packet_rate']]

ax = sns.barplot(y="rx_packets", x='algoritmo', hue='packet_size', data=df_pergunta1, palette='Paired');
ax.set_title(f'Quantidade de pacotes processados de acordo com o Algoritmo e tamanho de pacotes, com Hook {hook_ebpf} e {combined} fila tx/rx', fontsize=18, pad=50);
ax.set_ylabel('Número de pacotes')
ax.set_xlabel('Tamanho dos pacotes')

save_image= ax.get_figure()
save_image.savefig(f'{raiz}/pergunta1.png')

print(df_pergunta1)