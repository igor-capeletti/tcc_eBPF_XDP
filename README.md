# Monografia: Análise de Desempenho de Aplicações eBPF/XDP em Planos de Dados Programáveis

### Autor: Ígor Ferrazza Capeletti

### Universidade: Universidade Federal do Pampa, Alegrete-RS-Brasil

### Ano: 2022/1


O **eBPF** é um subsistema do **kernel** que filtra os pacotes de rede nos dispositivos do plano de dados com o auxílio do *Hook* **XDP**. O *Hook* **XDP** permite que programas **eBPF** realizem o processamento dos pacotes de rede no espaço do usuário, no espaço do **kernel**, no driver das placas e também no hardware das placas de rede. Apesar das iniciativas de avaliar o desempenho de programas **eBPF**, as análises existentes ainda não avaliam a execução de diversos programas **eBPF** processando diferentes tamanhos de pacotes para todas as abordagens existentes do *Hook* **XDP**. 

Este trabalho tem o propósito de analisar as capacidades e limitações que os programas **eBPF** atingem processando pacotes em diferentes abordagens do *Hook* **XDP** com SmartNICs.

Portanto realizamos avaliações de desempenho como Latência, Taxa de Transferência e uso de CPU para as execuções de diversos programas **eBPF** em SmartNICs com suporte à todos os *Hooks** **XDP**. Em nosso trabalho, estudamos o paradigma **SDN** e o plano de dados programável com **eBPF/XDP**. Em seguida, realizamos o levantamento dos principais trabalhos relacionados com **eBPF/XDP** e apresentamos a metodologia utilizada para realização dos experimentos e avaliações. Nossos resultados mostraram que os modos **XDP** *Generic* e *Native* conseguiram manter a Taxa de Transferência máxima da SmartNIC ao processar grandes pacotes com algoritmos de até 3200 acessos à memória. O modo *AF\_XDP* também alcançou boas taxas de transferência ao processar grandes pacotes, mas somente para algoritmos com até 100 acessos à memória. 
%
O modo **XDP** *Generic* consegue manter mínima Latência ao processar pacotes com até 1600 acessos à memória. Os modos **XDP** *Native* e *AF\_XDP* conseguem realizar até 3200 acessos à memória com baixa Latência.

Ao avaliar o uso de CPU, percebemos que ao processar milhões de pacotes pequenos, o uso dos núcleos fica sempre em 100% devido às milhões de interrupções geradas ao CPU. Quando aumentamos o tamanho de cada pacote, a quantidade total de pacotes diminui consideravelmente, mostrando que a porcentagem de uso de todos os núcleos diminui devido a grande diminuição de interrupções geradas ao CPU.

Nas avaliações de número de instruções, número de branches, número de load hits e load misses, os resultados mostraram que não ocorreram diferenças de comportamento entre os diferentes experimentos.
 
**Palavras-chave**: Processamento de Pacotes com **eBPF/XDP**, Hook **XDP**, *Software-Defined Network(SDN)*, Plano de Dados Programável
