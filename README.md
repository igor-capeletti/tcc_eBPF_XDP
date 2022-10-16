## Monografia apresentada ao Curso de Ciência da Computação da Universidade Federal do Pampa, como requisito parcial para obtenção do Título de Bacharel em Ciência da Computação 
* ### Título: Análise de Desempenho de Aplicações eBPF/XDP em Planos de Dados Programáveis
* ### Autor: Ígor Ferrazza Capeletti
* ### [Universidade Federal do Pampa](https://unipampa.edu.br/alegrete/), Alegrete-RS-Brasil - 2022/1

O trabalho completo pode ser acessado [aqui](https://github.com/igor-capeletti/tcc_eBPF_XDP/blob/main/Monografia.pdf).


## Tecnologias utilizadas

Linguagem de programação | Utilização
------------------------ | --- 
Python                   | Automatizar a criação de programas eBPF(em linguagem C); <br> Automatizar a execução dos experimentos; <br> Tratamentos dos dados
Shell Script             | Configurar a rede, acessos ssh e as interfaces dos experimentos; <br> Carregar e executar os programas eBPF nas interfaces de rede; <br> Coletar os dados dos experimentos via ferramenta [Perf](https://perf.wiki.kernel.org/) e [Sar](https://github.com/sysstat/sysstat);
C                        | Criação dos programas para realizar o tratamento dos dados. Os programas escritos em C são compilados para programas eBPF;
Lua                      | Geração dos pacotes de rede; <br> Coleta de alguns sobre os pacotes enviados e recebidos;


## Sobre o eBPF
O **eBPF** é um subsistema do **kernel** que filtra os pacotes de rede nos dispositivos do plano de dados com o auxílio do *Hook* **XDP**. O *Hook* **XDP** permite que programas **eBPF** realizem o processamento dos pacotes de rede no espaço do usuário, no espaço do **kernel**, no driver das placas e também no hardware das placas de rede. Apesar das iniciativas de avaliar o desempenho de programas **eBPF**, as análises existentes ainda não avaliam a execução de diversos programas **eBPF** processando diferentes tamanhos de pacotes para todas as abordagens existentes do *Hook* **XDP**. 

## Estudos Realizados
* Paradigma **SDN** 
* Plano de dados programável com **eBPF/XDP**
* Levantamento dos principais trabalhos relacionados com **eBPF/XDP**

## Objetivos do Trabalho
Este trabalho tem o propósito de **analisar** as **capacidades** e **limitações** de **Latência**, **Taxa de Transferência** e **uso de CPU** que os programas **eBPF** atingem processando pacotes em diferentes abordagens do *Hook* **XDP** com SmartNICs.


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


## Resultados
