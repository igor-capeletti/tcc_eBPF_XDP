
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

df_caregamento = pd.read_csv(f'{raiz}/resultado_geral.csv', sep=',', engine='python')

print(df_caregamento)