import argparse

#Execucao:
#python3 --instrucao for --inicio 0 --fim 0 --intervalo 0

#variaveis globais
usuario= 'igorcapeletti'
local_scripts_ebpf= f'/home/{usuario}/github/tcc_eBPF_XDP/scripts/ebpf'

#main -----------------------------------------------------------------------------------
if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument("--instrucao", help="algo")
  parser.add_argument("--inicio", help="algo")
  parser.add_argument("--fim", help="algo")
  args = parser.parse_args()

  try: 
    if args.instrucao: 
      if(args.instrucao == "for"):
        if args.inicio: 
          if args.fim:
            arq_af_xdp_original= open(f'{local_scripts_ebpf}/af_xdp_user.c', 'r')
            arq_algoritmo= open(f'{local_scripts_ebpf}/{args.instrucao}_{args.inicio}_a_{args.fim}.c', 'w')
            
            i=0
            for linha_arq_orig in arq_af_xdp_original:
              if(i == 295):
                arq_algoritmo.write('\tint i=0;\n')
                arq_algoritmo.write('\tint j=0;\n')
                arq_algoritmo.write(f'\tfor(i={args.inicio}; i<{args.fim}; i++)')
                arq_algoritmo.write('\t{\n')
                arq_algoritmo.write('\t\tj= i+2;\n')
                arq_algoritmo.write('\t}\n\tj+=10;\n')
              else:
                arq_algoritmo.write(linha_arq_orig)
              i= i+1
            arq_af_xdp_original.close()
            arq_algoritmo.close()
        
  except:
    print("Erro com parametros passados!")
    exit(-1)