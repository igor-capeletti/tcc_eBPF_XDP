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
            arq_algoritmo= open(f'{local_scripts_ebpf}/{args.instrucao}_{args.inicio}_a_{args.fim}.c', 'w')
            if(args.fim == '0'):
              arq_algoritmo.write('\n#include <linux/bpf.h>\n')
              arq_algoritmo.write('#include <bpf/bpf_helpers.h>\n\n\n')
              arq_algoritmo.write('SEC("xdp_pass")\n')
              arq_algoritmo.write('int xdp_pass_func(struct xdp_md *ctx){\n')
              arq_algoritmo.write('\treturn XDP_TX;\n')
              arq_algoritmo.write('}\n\n\n')

              arq_algoritmo.write('SEC("xdp_drop")\n')
              arq_algoritmo.write('int xdp_drop_func(struct xdp_md *ctx){\n')
              arq_algoritmo.write('\treturn XDP_DROP;\n}\n\n')
              arq_algoritmo.write('char _license[] SEC("license") = "GPL";\n')

            else:
              arq_algoritmo.write('\n#include <linux/bpf.h>\n')
              arq_algoritmo.write('#include <bpf/bpf_helpers.h>\n\n\n')
              arq_algoritmo.write('struct bpf_map_def SEC("maps") xsks_map = {\n')
              arq_algoritmo.write('\t.type = BPF_MAP_TYPE_XSKMAP,\n')
              arq_algoritmo.write('\t.key_size = sizeof(int),\n')
              arq_algoritmo.write('\t.value_size = sizeof(int),\n')
              arq_algoritmo.write('\t.max_entries = 64,\n};\n\n')
              arq_algoritmo.write('struct bpf_map_def SEC("maps") xdp_stats_map = {\n')
              arq_algoritmo.write('\t.type = BPF_MAP_TYPE_PERCPU_ARRAY,\n')
              arq_algoritmo.write('\t.key_size    = sizeof(int),\n')
              arq_algoritmo.write('\t.value_size  = sizeof(__u32),\n')
              arq_algoritmo.write('\t.max_entries = 64,\n};\n\n')
              arq_algoritmo.write('SEC("xdp_pass")\n')
              arq_algoritmo.write('int xdp_pass_func(struct xdp_md *ctx){\n')
              arq_algoritmo.write('\tint var= 0;\n')
              arq_algoritmo.write('\t__u32 *pkt_count;\n')
              arq_algoritmo.write('\tint index= ctx->rx_queue_index;\n')
              arq_algoritmo.write('\tgoto out;\n\n')
              arq_algoritmo.write('out:\n')
              arq_algoritmo.write(f'\tif(var <= {args.fim})'+'{\n')
              arq_algoritmo.write('\t\tvar= var+1;\n')
              arq_algoritmo.write('\t\tpkt_count = bpf_map_lookup_elem(&xdp_stats_map, &index);\n')
              arq_algoritmo.write('\t\tgoto out;\n')
              arq_algoritmo.write('\t}\n')
              arq_algoritmo.write('\treturn XDP_TX;\n')
              arq_algoritmo.write('}\n\n\n')

              arq_algoritmo.write('SEC("xdp_drop")\n')
              arq_algoritmo.write('int xdp_drop_func(struct xdp_md *ctx){\n')
              arq_algoritmo.write('\treturn XDP_DROP;\n}\n\n')
              arq_algoritmo.write('char _license[] SEC("license") = "GPL";\n')
            
            arq_algoritmo.close()
        
  except:
    print("Erro com parametros passados!")
    exit(-1)