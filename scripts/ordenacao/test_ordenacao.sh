#!/bin/bash

# Script para testar os algoritmos de ordenação

echo "===================================================="
echo "Teste de Algoritmos de Ordenação"
echo "===================================================="
echo

TAMANHO=${1:-100}
ARQUIVO_VETOR="teste_vetor.in"

echo "Tamanho do vetor: $TAMANHO"
echo

# Limpar arquivos anteriores
rm -f $ARQUIVO_VETOR vetor_ordenado.out

echo "----------------------------------------------------"
echo "1. COUNTSORT SERIAL"
echo "----------------------------------------------------"
./countsort_serial $TAMANHO $ARQUIVO_VETOR
echo

echo "----------------------------------------------------"
echo "2. COUNTSORT PARALELO"
echo "----------------------------------------------------"
./countsort_paralelo $TAMANHO $ARQUIVO_VETOR
echo

# Limpar arquivo de saída para próximo teste
rm -f vetor_ordenado.out

echo "----------------------------------------------------"
echo "3. QUICKSORT SERIAL"
echo "----------------------------------------------------"
./quicksort_serial $TAMANHO $ARQUIVO_VETOR
echo

echo "----------------------------------------------------"
echo "4. QUICKSORT PARALELO"
echo "----------------------------------------------------"
./quicksort_paralelo $TAMANHO $ARQUIVO_VETOR
echo

echo "===================================================="
echo "Testes concluídos!"
echo "===================================================="
