## Monografia apresentada ao Curso de Ciência da Computação da Universidade Federal do Pampa, como requisito parcial para obtenção do Título de Bacharel em Ciência da Computação 
* ### Título: Análise de Desempenho de Aplicações eBPF/XDP em Planos de Dados Programáveis
* ### Autor: Ígor Ferrazza Capeletti
* ### [Universidade Federal do Pampa](https://unipampa.edu.br/alegrete/), Alegrete-RS-Brasil - 2022/1


## Tecnologias utilizadas

Linguagem de programação | Utilização
:------------------------: | --- 
Python (Jupyter Notebook) | Automatizar a criação de programas eBPF(em linguagem C); <br> Automatizar a execução dos experimentos; <br> Organização e normalização dos resultados; <br> Geração dos gráficos a partir dos resultados;
Shell Script             | Configurar a rede, acessos ssh e as interfaces dos experimentos; <br> Carregar e executar os programas eBPF nas interfaces de rede; <br> Coletar os dados dos experimentos via ferramenta [Perf](https://perf.wiki.kernel.org/) e [Sar](https://github.com/sysstat/sysstat);
C                        | Criação dos programas para realizar o tratamento dos dados. Os programas escritos em C são compilados para programas eBPF;
Lua                      | Geração dos pacotes de rede; <br> Coleta de alguns sobre os pacotes enviados e recebidos;


## Sobre o eBPF
O **eBPF** é um subsistema do **kernel** que filtra os pacotes de rede nos dispositivos do plano de dados com o auxílio do *Hook* **XDP**. O *Hook* **XDP** permite que programas **eBPF** realizem o processamento dos pacotes de rede no espaço do usuário, no espaço do **kernel**, no driver das placas e também no hardware das placas de rede. Apesar das iniciativas de avaliar o desempenho de programas **eBPF**, as análises existentes ainda não avaliam a execução de diversos programas **eBPF** processando diferentes tamanhos de pacotes para todas as abordagens existentes do *Hook* **XDP**. 

Na figura a seguir são ilustrados os fluxos de tratamento dos pacotes de rede para os diferentes Hooks XDP. Primeiro, o pacote de rede chega na entrada RX da SmartNIC e é encaminhado diretamente para o XDP que está ativo na interface. Esse pacote é processado pelo programa eBPF que está carregado no XDP e em seguida é encaminhado para a próxima camada de processamento, ou é encaminhado para a saída TX da SmartNIC. Caso o pacote não foi encaminhado para a saída TX da interface, este vai ser direcionado para as pilhas de rede do kernel e posteriormente encaminhado para as aplicações no espaço do usuário. Se o modo AF_XDP estiver ativo, o programa XDP encaminha o pacote direto para o espaço do usuário, sem passar pelas pilhas de rede do kernel.

<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/imagens/processamento_do_pacote.png' width=400/>


## Objetivos do Trabalho
Este trabalho tem o propósito de **analisar** as **capacidades** e **limitações** de **Latência**, **Taxa de Transferência** e **uso de CPU** que os programas **eBPF** atingem processando pacotes em diferentes abordagens do *Hook* **XDP** com SmartNICs.


## Estudos Realizados
* Paradigma **SDN** 
* Plano de dados programável com **eBPF/XDP**
* Levantamento dos principais trabalhos relacionados com **eBPF/XDP**


## Metodologia dos Experimentos
### 1. Ambiente de Avaliação
Ambiente experimental com dois servidores Dell T440, ambos com os componentes descritos abaixo:

Componentes | Especificação
----------- | ------
Processador | Intel Xeon 4214R
Núcleos físicos | 8 
Núcleos lógicos | 16
Memória RAM | 32 GB
Interface de Rede | Netronome SmartNIC Agilio CX 2x10GbE de 10 Gbit/s

<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/imagens/ambiente.png' width=500/>

Um dos servidores é nosso Device Under Test (DUT) – ou seja, o servidor no qual os programas eBPFs/XDPs são carregados – e o outro é nosso gerador de tráfego. Os servidores são conectados diretamente através de cabos DAC de 10Gbit/s. 

### 2. Criação e execução de um programa eBPF
Para realização da avaliação de desempenho, utilizou-se os programas disponíveis no tutorial do [XDP-Project](https://github.com/xdp-project/xdp-tutorial) como base de desenvolvimento. A partir dos exemplos
desenvolvidos pelo tutorial, dois programas eBPF genéricos e dois programas para espaço do usuário foram desenvolvidos e utilizados ao longo dos experimentos. Como base de comparação (baseline), utilizou-se um programa eBPF cujo objetivo é apenas receber pacotes da rede pela fila RX (entrada) e encaminhar esses pacotes para a fila TX (saída) da interface de rede, sem realizar qualquer tipo de tratamento dos pacotes.

<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/imagens/execucao_experimento.png' width=900/>


### 3. Execução dos Experimentos
Em nossa avaliação, foram executados dois conjuntos de experimentos, com 5 repetições cada. Executamos 480 experimentos para programas eBPF e 240 experimentos
para programas AF_XDP.

Nosso ambiente de avaliação suporta utilizar uma até oito filas TX/RX para processar os pacotes de rede. Com isso, variamos nossos experimentos para processar pacotes
com 1, 2, 4 e 8 filas de processamento, sempre dobrando a quantidade de filas até chegar no limite máximo suportado pelo ambiente. Utilizamos essa variação de configuração das filas para avaliar o desempenho obtido quando dobramos a quantidade de filas de processamento no servidor.

Nossos programas eBPF e AF_XDP foram desenvolvidos para realizar diferentes quantidades de acesso à memória ao processar cada pacote de rede. Alguns testes prelimi-
nares foram executados a fim de encontrar um limite máximo de quantidades de acesso à memória até a Taxa de Transferência zerar. Este limite foi alcançado para um algoritmo com 12800 acessos à memória ao processar pacotes de 64 Bytes com 1 fila TX/RX de processamento. A partir desses testes preliminares, desenvolvemos os programas eBPF e AF_XDP para realizar diferentes acessos à memória com variação entre 1, 100, 200, 400, 800, 1600, 3200, 6400 e 12800 acessos à memória. 

Utilizamos os valores 1 e 100 como algoritmos iniciais a fim de verificar diferenças entre poucos acessos à memória. A partir do algoritmo com 100 acessos à memória, escolhemos dobrar a quantidade de acessos à memória para cada algoritmo, como forma de analisar o desempenho dos modos XDP ao dobrarmos a quantidade de instruções que acessam à memória.

<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/imagens/execucao_experimentos.png' width=700/>

A ferramenta Netronome Packet Generator do gerador MoonGen utilizado no ambiente de avaliação consegue gerar tráfego de pacotes que variam entre 64 Bytes até 1500
Bytes. A partir destas informações, escolhemos gerar tráfegos com os tamanhos de pacotes mais comuns utilizados na internet, ou seja, pacotes de 64B, 128B, 256B, 512B, 1024B e 1500B.

### 4. Coleta dos Dados
Durante cada experimento, os dados dos dois servidores são coletados. No servidor responsável pela geração do tráfego são coletados os dados referente a quantidade de
pacotes enviados/recebidos, a taxa de envio/recepção, a taxa média de envio/recepção e a Latência média dos pacotes. O próprio MoonGen coleta esses dados a cada segundo que o gerador enviou/recebeu o tráfego de pacotes e salva em um arquivo de logs.

No servidor DUT, em que executamos os programas eBPF e AF_XDP, utilizase as ferramentas Perf 10 e Sar11 para coletar as informações durante o processamento dos pacotes recebidos. Com a ferramenta Sar, coleta-se os dados relacionados à porcentagem de uso dos núcleos do processador. Similarmente, por meio da ferramenta Perf, coleta-se as informações como número de instruções por ciclo, número de acertos/erros de desvios (branches) e número de acertos/erros de acesso à cache L1.

## Resultados
Tivemos muitos resultados para mostrar e analisar, por isso, para melhor analise e compreensão dos resultados, direcionamos você para acessar o trabalho completo disponibilizado [aqui](https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/Monografia.pdf) ou somente visualização dos gráficos [aqui](https://github.com/igor-capeletti/tcc_eBPF_XDP/tree/main/graficos).

### 1. Latência: 
* Melhores quantidades de filas de processamento para cada Hook XDP (1 fila para modo AF_XDP, 8 filas para os modos Native e Generic).
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/latencia_melhores_filas_para_cada_hook_xdp.png' width=700/>

### 2. Taxa de Transferência:
* Melhores quantidades de filas de processamento para cada Hook XDP (1 fila para modo AF_XDP, 8 filas para os modos Native e Generic):
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/vazao_packet_size_x_algoritmo%40combined_melhor_por_xdp.png' width=700/>

---

* Pacotes de tamanho pequeno (64 Bytes):
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/vazao_combined_x_algoritmo%4064.png' width=700/>

---

* Pacotes de tamanho médio (1024 Bytes):
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/vazao_combined_x_algoritmo%401024.png' width=700/>

---

* Pacotes de tamanho grande (1500 Bytes):
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/vazao_combined_x_algoritmo%401500.png' width=700/>

---

* Algoritmo Baseline (algoritmo que obtêm os melhores desempenhos para todos os casos, ou seja, somente reencaminha os pacote para a origem):
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/vazao_XDP_x_packet_size%40baseline.png' width=800/>


### 3. Uso de CPU: 
* Pacotes de tamanho pequeno (64 Bytes) sendo processados com 8 filas:
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/uso_CPU_ID_CPU_x_algoritmo%4064_combined_8.png' width=700/>

---

* Pacotes de tamanho médio (1024 Bytes) sendo processados com 8 filas:
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/uso_CPU_ID_CPU_x_algoritmo%401024_combined_8.png' width=700/>

---

* Pacotes de tamanho grande (1500 Bytes) sendo processados com 8 filas:
<img src='https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/graficos/png/uso_CPU_ID_CPU_x_algoritmo%401500_combined_8.png' width=700/>

---
# Tutorial para reprodução de todos os processos realizados
Em desenvolvimento ...
