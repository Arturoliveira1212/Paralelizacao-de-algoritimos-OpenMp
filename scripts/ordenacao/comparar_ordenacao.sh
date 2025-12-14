#!/bin/bash

# Script para comparar resultados dos algoritmos de ordenação

ALGORITMO=$1
TAMANHO=${2:-1000}

if [ -z "$ALGORITMO" ]; then
    echo "Uso: $0 <algoritmo> [tamanho]"
    echo "Algoritmos disponíveis: countsort, quicksort"
    echo "Exemplo: $0 countsort 1000"
    exit 1
fi

case $ALGORITMO in
    countsort)
        PROG_SERIAL="./countsort_serial"
        PROG_PARALELO="./countsort_paralelo"
        ;;
    quicksort)
        PROG_SERIAL="./quicksort_serial"
        PROG_PARALELO="./quicksort_paralelo"
        ;;
    *)
        echo "Algoritmo desconhecido: $ALGORITMO"
        echo "Use: countsort ou quicksort"
        exit 1
        ;;
esac

echo "===================================================="
echo "Comparação: $ALGORITMO (Serial vs Paralelo)"
echo "===================================================="
echo

ARQUIVO_VETOR="comp_vetor_${ALGORITMO}.in"

echo "Tamanho do vetor: $TAMANHO"
echo "Arquivo de entrada: $ARQUIVO_VETOR"
echo

# Limpar arquivos anteriores
rm -f $ARQUIVO_VETOR vetor_ordenado.out vetor_ordenado_serial.out vetor_ordenado_paralelo.out

echo "===================================================="
echo "EXECUÇÃO 1: Versão SERIAL"
echo "===================================================="
echo

TEMPO_SERIAL_START=$(date +%s.%N)
$PROG_SERIAL $TAMANHO $ARQUIVO_VETOR
TEMPO_SERIAL_END=$(date +%s.%N)
TEMPO_SERIAL=$(echo "$TEMPO_SERIAL_END - $TEMPO_SERIAL_START" | bc)

if [ -f "vetor_ordenado.out" ]; then
    mv vetor_ordenado.out vetor_ordenado_serial.out
    echo "✓ Resultado serial gerado: vetor_ordenado_serial.out"
else
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

TEMPO_PARALELO_START=$(date +%s.%N)
$PROG_PARALELO $TAMANHO $ARQUIVO_VETOR
TEMPO_PARALELO_END=$(date +%s.%N)
TEMPO_PARALELO=$(echo "$TEMPO_PARALELO_END - $TEMPO_PARALELO_START" | bc)

if [ -f "vetor_ordenado.out" ]; then
    mv vetor_ordenado.out vetor_ordenado_paralelo.out
    echo "✓ Resultado paralelo gerado: vetor_ordenado_paralelo.out"
else
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
if cmp -s vetor_ordenado_serial.out vetor_ordenado_paralelo.out; then
    echo "✓ SUCESSO: Os resultados são IDÊNTICOS!"
    echo "  Os arquivos vetor_ordenado_serial.out e vetor_ordenado_paralelo.out são iguais."
    echo
    RESULTADO="CORRETO"
else
    echo "✗ ERRO: Os resultados são DIFERENTES!"
    echo "  Os arquivos vetor_ordenado_serial.out e vetor_ordenado_paralelo.out NÃO são iguais."
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
    echo "  Dica: Teste com vetores maiores (ex: $0 $ALGORITMO 10000)"
fi

echo
echo "===================================================="
echo "RESUMO FINAL"
echo "===================================================="
echo
echo "Algoritmo:      $ALGORITMO"
echo "Tamanho vetor:  $TAMANHO"
echo "Resultados:     $RESULTADO"
echo "Tempo serial:   ${TEMPO_SERIAL}s"
echo "Tempo paralelo: ${TEMPO_PARALELO}s"
echo "Speedup:        ${SPEEDUP}x"
echo
echo "Arquivos gerados:"
echo "  - $ARQUIVO_VETOR (vetor de entrada)"
echo "  - vetor_ordenado_serial.out (resultado serial)"
echo "  - vetor_ordenado_paralelo.out (resultado paralelo)"
echo
echo "Para testar com outro tamanho:"
echo "  $0 $ALGORITMO <tamanho>"
echo "  Exemplo: $0 $ALGORITMO 5000"

if [ "$RESULTADO" == "CORRETO" ]; then
    exit 0
else
    exit 1
fi
