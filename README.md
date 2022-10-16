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
Ambiente experimental com dois servidores Dell T440, ambos com os mesmos componentes descritos abaixo:
Componentes | Especificação
----------- | ------
Processador | Intel Xeon 4214R
Núcleos físicos | 8 
Núcleos lógicos | 16
Memória RAM | 32 GB
Interface de Rede | Netronome SmartNIC Agilio CX 2x10GbE de 10 Gbit/s

Um dos servidores é nosso Device Under Test (DUT) – ou seja, o servidor no qual os programas eBPFs/XDPs são carregados – e o outro é nosso gerador de tráfego. Os servidores são conectados diretamente através de cabos DAC de 10Gbit/s. 
