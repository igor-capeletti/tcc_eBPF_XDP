# Monografia: Análise de Desempenho de Aplicações eBPF/XDP em Planos de Dados Programáveis

### Autor: Ígor Ferrazza Capeletti

### Universidade: Universidade Federal do Pampa, Alegrete-RS-Brasil

### Ano: 2022/1

    O ebpf é um subsistema do **kernel** que filtra os pacotes de rede nos dispositivos do plano de dados com o auxílio do **Hook** **XDP**. O **Hook** **XDP** permite que programas **eBPF** realizem o processamento dos pacotes de rede no espaço do usuário, no espaço do **kernel**, no driver das placas e também no hardware das placas de rede. Apesar das iniciativas de avaliar o desempenho de programas **eBPF**, as análises existentes ainda não avaliam a execução de diversos programas **eBPF** processando diferentes tamanhos de pacotes para todas as abordagens existentes do **Hook** **XDP**. 

    Este trabalho tem o propósito de analisar as capacidades e limitações que os programas **eBPF** atingem processando pacotes em diferentes abordagens do **Hook** **XDP** com SmartNICs, além de servir como objeto de estudo para a área.
    
    Portanto realizamos avaliações de desempenho como Latência, Taxa de Transferência e uso de CPU para as execuções de diversos programas **eBPF** em SmartNICs com suporte à todos os **Hook** **XDP**. 
    
    Em nosso trabalho, estudamos o paradigma **SDN** e o plano de dados programável com **eBPF**/**XDP**. Em seguida, realizamos o levantamento dos principais trabalhos relacionados com **eBPF**/**XDP** e apresentamos a metodologia utilizada para realização dos experimentos e avaliações. 
    
    Nossos resultados mostraram que todos os modos **XDP** avaliados conseguem excelentes taxas de transferência ao processar grandes pacotes de rede. Para a métrica de Latência nossos resultados mostraram que em todos os modos **XDP** e para a maioria dos tamanhos de pacotes, ao aumentarmos a quantidade de acessos à memória, o tempo de Latência também aumenta. Quanto ao uso de CPU, todos os modos **XDP** tiveram baixas taxas de uso dos núcleos ao utilizar mais filas TX/RX para processar tráfegos com grandes pacotes de rede. Nas avaliações de número de instruções, número de branches, número de load hits e load misses, os resultados mostraram que não ocorreram diferenças de comportamento entre os diferentes experimentos.
