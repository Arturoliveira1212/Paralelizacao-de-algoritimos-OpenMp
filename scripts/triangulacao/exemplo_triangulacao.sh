#!/bin/bash

# Script de exemplo para usar os programas de triangulação

echo "======================================================"
echo "EXEMPLO DE USO: ELIMINAÇÃO GAUSSIANA"
echo "======================================================"
echo ""

# Define parâmetros
ORDEM=100
ARQUIVO_ENTRADA="matriz.in"

# Remove arquivos anteriores
rm -f $ARQUIVO_ENTRADA saida.out saida_serial.out saida_paralelo.out

echo "1. Executando versão SERIAL"
echo "   Comando: ./triangulacao_serial $ORDEM $ARQUIVO_ENTRADA"
echo ""
./triangulacao_serial $ORDEM $ARQUIVO_ENTRADA
echo ""

# Renomeia saída para o padrão especificado
mv saida_serial.out saida.out
echo "   Resultado salvo em: saida.out"
echo ""

echo "----------------------------------------------------"
echo ""

echo "2. Executando versão PARALELA (reutilizando matriz.in)"
echo "   Comando: ./triangulacao_paralelo $ORDEM $ARQUIVO_ENTRADA"
echo ""
./triangulacao_paralelo $ORDEM $ARQUIVO_ENTRADA
echo ""

# Renomeia saída para o padrão especificado
mv saida_paralelo.out saida.out
echo "   Resultado salvo em: saida.out"
echo ""

echo "======================================================"
echo "CONCLUSÃO"
echo "======================================================"
echo ""
echo "Os programas leem matriz.in e geram saida.out"
echo ""
echo "Uso individual:"
echo "  ./triangulacao_serial <ordem> <arquivo_entrada>"
echo "  ./triangulacao_paralelo <ordem> <arquivo_entrada>"
echo ""
echo "Exemplos:"
echo "  ./triangulacao_serial 100 matriz.in"
echo "  ./triangulacao_paralelo 500 matriz.in"
echo ""
