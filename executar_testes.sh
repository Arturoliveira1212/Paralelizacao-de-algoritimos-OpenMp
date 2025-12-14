#!/bin/bash

# Script simplificado para executar testes e coletar métricas
# Salva apenas: Tempo, Speedup e Eficiência

# Configurar locale para usar ponto decimal
export LC_NUMERIC=C

echo "================================================"
echo "       TESTES DE DESEMPENHO - OpenMP"
echo "================================================"
echo ""

# Criar diretórios
mkdir -p resultados
rm -f resultados/metricas.txt

# Arquivo de saída
RESULT_FILE="resultados/metricas.txt"

# Função para extrair tempo de execução do output
extrair_tempo() {
    local output="$1"
    # Extrair o número usando diferentes padrões (com ou sem acentuação)
    local tempo=$(echo "$output" | grep -oE "Tempo de exec[uú][cç][aã]o[^:]*: [0-9]+\.[0-9]+" | grep -oE "[0-9]+\.[0-9]+" | head -1)
    if [ -z "$tempo" ]; then
        tempo="0.000001"
    fi
    echo "$tempo"
}

# Função para executar teste e coletar métricas
executar_e_medir() {
    local algoritmo=$1
    local tamanho=$2
    local threads=$3
    local args=$4
    
    export OMP_NUM_THREADS=$threads
    
    # Executar e capturar output
    local output
    if [ "$threads" -eq 1 ]; then
        output=$(./${algoritmo}_serial $args 2>&1)
    else
        output=$(./${algoritmo}_paralelo $args 2>&1)
    fi
    
    # Extrair tempo
    local tempo=$(extrair_tempo "$output")
    
    if [ -z "$tempo" ]; then
        tempo="0.000"
    fi
    
    echo "$tempo"
}

# Calcular speedup e eficiência
calcular_metricas() {
    local tempo_serial=$1
    local tempo_paralelo=$2
    local threads=$3
    
    if (( $(echo "$tempo_paralelo > 0" | bc -l) )); then
        local speedup=$(echo "scale=3; $tempo_serial / $tempo_paralelo" | bc -l)
        local eficiencia=$(echo "scale=2; ($speedup / $threads) * 100" | bc -l)
        echo "$speedup $eficiencia"
    else
        echo "0.000 0.00"
    fi
}

# Função principal para testar um algoritmo
testar_algoritmo() {
    local nome=$1
    local algoritmo=$2
    shift 2
    local tamanhos=("$@")
    
    echo "========================================" | tee -a $RESULT_FILE
    echo "  $nome" | tee -a $RESULT_FILE
    echo "========================================" | tee -a $RESULT_FILE
    echo "" | tee -a $RESULT_FILE
    
    for tam_info in "${tamanhos[@]}"; do
        IFS='|' read -r tam_label tam_args <<< "$tam_info"
        
        echo "--- Tamanho: $tam_label ---" | tee -a $RESULT_FILE
        
        # Executar serial (1 thread)
        echo -n "  Executando serial... "
        tempo_serial=$(executar_e_medir "$algoritmo" "$tam_label" 1 "$tam_args")
        printf "%.6f s\n" $tempo_serial
        printf "  Serial (1T):   Tempo=%.6f s\n" $tempo_serial >> $RESULT_FILE
        
        # Executar com 2 threads
        echo -n "  Executando 2 threads... "
        tempo_2t=$(executar_e_medir "$algoritmo" "$tam_label" 2 "$tam_args")
        read speedup_2t efic_2t <<< $(calcular_metricas $tempo_serial $tempo_2t 2)
        printf "%.6f s (Speedup: %.2fx, Efic: %.1f%%)\n" $tempo_2t $speedup_2t $efic_2t
        printf "  Paralelo (2T): Tempo=%.6f s | Speedup=%.2fx | Eficiência=%.1f%%\n" \
               $tempo_2t $speedup_2t $efic_2t >> $RESULT_FILE
        
        # Executar com 4 threads
        echo -n "  Executando 4 threads... "
        tempo_4t=$(executar_e_medir "$algoritmo" "$tam_label" 4 "$tam_args")
        read speedup_4t efic_4t <<< $(calcular_metricas $tempo_serial $tempo_4t 4)
        printf "%.6f s (Speedup: %.2fx, Efic: %.1f%%)\n" $tempo_4t $speedup_4t $efic_4t
        printf "  Paralelo (4T): Tempo=%.6f s | Speedup=%.2fx | Eficiência=%.1f%%\n" \
               $tempo_4t $speedup_4t $efic_4t >> $RESULT_FILE
        
        echo "" | tee -a $RESULT_FILE
    done
}

# Verificar executáveis
if [ ! -f "./matrixmult_serial" ]; then
    echo "ERRO: Executáveis não encontrados. Execute 'make all' primeiro."
    exit 1
fi

# ====================
# MULTIPLICAÇÃO DE MATRIZES
# ====================
tamanhos_matrix=(
    "500×500|500 m1_500.in m2_500.in"
    "1000×1000|1000 m1_1000.in m2_1000.in"
    "2000×2000|2000 m1_2000.in m2_2000.in"
)
testar_algoritmo "MULTIPLICAÇÃO DE MATRIZES" "matrixmult" "${tamanhos_matrix[@]}"

# ====================
# COUNTING SORT
# ====================
tamanhos_count=(
    "100000|100000 vetor_100k.in"
    "200000|200000 vetor_200k.in"
    "400000|400000 vetor_400k.in"
)
testar_algoritmo "COUNTING SORT" "countsort" "${tamanhos_count[@]}"

# ====================
# QUICKSORT
# ====================
tamanhos_quick=(
    "100000|100000 vetor_quick_100k.in"
    "200000|200000 vetor_quick_200k.in"
    "400000|400000 vetor_quick_400k.in"
)
testar_algoritmo "QUICKSORT" "quicksort" "${tamanhos_quick[@]}"

# ====================
# TRIANGULAÇÃO
# ====================
tamanhos_triang=(
    "250×250|250 matriz_250.in"
    "500×500|500 matriz_500.in"
    "1000×1000|1000 matriz_1000.in"
)
testar_algoritmo "TRIANGULAÇÃO (ELIMINAÇÃO GAUSSIANA)" "triangulacao" "${tamanhos_triang[@]}"

# ====================
# RESUMO
# ====================
echo "================================================"
echo "           TESTES CONCLUÍDOS!"
echo "================================================"
echo ""
echo "Resultados salvos em: $RESULT_FILE"
echo ""
echo "Visualizar resultados:"
echo "  cat $RESULT_FILE"
echo ""
