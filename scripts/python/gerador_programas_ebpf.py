import os
import sys
import string
import argparse

#tipos de blocos de código
# 0- NADA ou null
# 1- IF
# 2- WHILE
# 3- FOR
# 4- CALC
# 5- ALOC_EST
# 6- ALOC_DIN

#variaveis globais
lst_instrucoes= []
string_struction= ""
arq_dest= ""
repeticoes= 1

#main -----------------------------------------------------------------------------------
if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument("--arq_af_xdp", help="Arquivo AF_XDP para inserir instrucoes dentro")
  parser.add_argument("--arq_dest", help="Novo arquivo com AF_XDP e instrucoes geradas")
  parser.add_argument("--instruction", help="Qualquer instrucao, mas não pode conter espacos")
  #parser.add_argument("--form", help="rolled, sequential")
  parser.add_argument("--repeat", help="1...N")
  args = parser.parse_args()
  
  try: 
    
    #le todas as instrucoes do arquivo AF_XDP(Ex: af_xdp_user.c)
    if args.arq_af_xdp: 
      arquivo_af_xdp = open(args.arq_af_xdp, 'rb')
      for i in arquivo_af_xdp:
        nome = i.decode()
        nome = nome.split("\r\n")[0]
        lst_instrucoes.append(nome)
      print("\nInstruções arquivo AF_XDP: ", lst_instrucoes) 
      arquivo_af_xdp.close()
    else: 
      print("\nNão definido arquivo AF_XDP para ler instruções! Ver --arq_af_xdp")
      exit(-1)


    #usuario definiu um arquivo de destino
    if args.arq_dest: 
      arq_dest= args.arq_dest      
    else: 
      print("\nNão definido arquivo para salvar as instruções! Ver --arq_dest")
      exit(-1)


    #usuario definiu uma instrucao para ser adicionado dentro do arquivo AF_XDP
    if args.instruction:    
      string_struction= args.instruction
    else:
      print("\nNão definida instrução! Ver --instruction")
      exit(-1)


    #usuario definiu quantidade de instrucoes repetidas de maneira sequencial
    if args.repeat:
      repeticoes= args.repeat
    else:
      print("\nNão definido repetiçoes para instrução, default= 1! Ver --repeat")
      
  except:
      print("Erro com parametros passados!")
      exit(-1)
  
  #se nao ocorreram erros na leitura dos argumentos, 
  #segue os proximos passos para geracao de instrucoes dentro do AF_XDP

  #escrever as novas instrucoes a partir da linha 305 e depois 
  # ao terminar continuar escrevendo as instrucoes restantes do arquivo AF_XDP
  
  #serao criadas as intrucoes escolhilas
  string_instruction= f'{args.instruction}'
  arquivo_intrucoes = open(args.arq_dest, 'rb') 
  for i in lst_instrucoes:
    arquivo_intrucoes.write(i)    
    
  arquivo_intrucoes.close()