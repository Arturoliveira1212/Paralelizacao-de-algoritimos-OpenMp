#!/bin/bash

# Script completo para comparar desempenho e resultados entre versão serial e paralela

echo "===================================================="
echo "Comparação Completa: Serial vs Paralela"
echo "===================================================="
echo

# Compilar se necessário
if [ ! -f "matrixmult_serial" ] || [ ! -f "matrixmult_paralelo" ]; then
    echo "Compilando os programas..."
    make
    echo
fi

# Parâmetros do teste
ORDEM=${1:-20}  # Usar argumento ou padrão 20
ARQUIVO_M1="comparacao_m1.in"
ARQUIVO_M2="comparacao_m2.in"

echo "Testando com matrizes ${ORDEM}x${ORDEM}"
echo "Número de threads disponíveis: $(nproc)"
echo

# Limpar arquivos anteriores
rm -f $ARQUIVO_M1 $ARQUIVO_M2 matriz_mult_serial.out matriz_mult_paralelo.out

echo "===================================================="
echo "EXECUÇÃO 1: Versão SERIAL"
echo "===================================================="
echo

# Medir tempo de execução da versão serial
TEMPO_SERIAL_START=$(date +%s.%N)
./matrixmult_serial $ORDEM $ARQUIVO_M1 $ARQUIVO_M2
TEMPO_SERIAL_END=$(date +%s.%N)
TEMPO_SERIAL=$(echo "$TEMPO_SERIAL_END - $TEMPO_SERIAL_START" | bc)

if [ ! -f "matriz_mult_serial.out" ]; then
    echo "✗ Erro: Resultado serial não foi gerado!"
    exit 1
fi

echo
echo "----------------------------------------------------"
echo "Tempo total (serial): ${TEMPO_SERIAL} segundos"
echo "----------------------------------------------------"

echo
echo "===================================================="
echo "EXECUÇÃO 2: Versão PARALELA"
echo "===================================================="
echo

# Medir tempo de execução da versão paralela
TEMPO_PARALELO_START=$(date +%s.%N)
./matrixmult_paralelo $ORDEM $ARQUIVO_M1 $ARQUIVO_M2
TEMPO_PARALELO_END=$(date +%s.%N)
TEMPO_PARALELO=$(echo "$TEMPO_PARALELO_END - $TEMPO_PARALELO_START" | bc)

if [ ! -f "matriz_mult_paralelo.out" ]; then
    echo "✗ Erro: Resultado paralelo não foi gerado!"
    exit 1
fi

echo
echo "----------------------------------------------------"
echo "Tempo total (paralelo): ${TEMPO_PARALELO} segundos"
echo "----------------------------------------------------"

echo
echo "===================================================="
echo "COMPARAÇÃO DE RESULTADOS"
echo "===================================================="

# Comparar os arquivos byte a byte
if cmp -s matriz_mult_serial.out matriz_mult_paralelo.out; then
    echo "✓ SUCESSO: Os resultados são IDÊNTICOS!"
    echo "  Os arquivos matriz_mult_serial.out e matriz_mult_paralelo.out são iguais."
    echo
    RESULTADO="CORRETO"
else
    echo "✗ ERRO: Os resultados são DIFERENTES!"
    echo "  Os arquivos matriz_mult_serial.out e matriz_mult_paralelo.out NÃO são iguais."
    echo
    RESULTADO="INCORRETO"
fi

echo "===================================================="
echo "ANÁLISE DE DESEMPENHO"
echo "===================================================="
echo

# Calcular speedup
SPEEDUP=$(echo "scale=4; $TEMPO_SERIAL / $TEMPO_PARALELO" | bc)
MELHORIA=$(echo "scale=2; ($TEMPO_SERIAL - $TEMPO_PARALELO) / $TEMPO_SERIAL * 100" | bc)

echo "Resumo dos Tempos:"
echo "  Serial:   ${TEMPO_SERIAL} segundos"
echo "  Paralelo: ${TEMPO_PARALELO} segundos"
echo
echo "Análise:"
echo "  Speedup:  ${SPEEDUP}x"
echo "  Melhoria: ${MELHORIA}%"
echo

if (( $(echo "$SPEEDUP > 1" | bc -l) )); then
    echo "✓ A versão paralela foi MAIS RÁPIDA!"
else
    echo "⚠ A versão serial foi mais rápida (overhead de paralelização)"
    echo "  Dica: Teste com matrizes maiores (ex: ./comparar_completo.sh 100)"
fi

echo
echo "===================================================="
echo "RESUMO FINAL"
echo "===================================================="
echo
echo "Matriz testada: ${ORDEM}x${ORDEM}"
echo "Resultados:     $RESULTADO"
echo "Tempo serial:   ${TEMPO_SERIAL}s"
echo "Tempo paralelo: ${TEMPO_PARALELO}s"
echo "Speedup:        ${SPEEDUP}x"
echo
echo "Arquivos gerados:"
echo "  - $ARQUIVO_M1 (matriz de entrada 1)"
echo "  - $ARQUIVO_M2 (matriz de entrada 2)"
echo "  - matriz_mult_serial.out (resultado serial)"
echo "  - matriz_mult_paralelo.out (resultado paralelo)"
echo
echo "Para testar com outra ordem de matriz:"
echo "  ./comparar_completo.sh <ordem>"
echo "  Exemplo: ./comparar_completo.sh 100"

if [ "$RESULTADO" == "CORRETO" ]; then
    exit 0
else
    exit 1
fi
