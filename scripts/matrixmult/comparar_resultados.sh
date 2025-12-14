#!/bin/bash

# Script para comparar resultados entre versão serial e paralela

echo "===================================================="
echo "Comparação: Serial vs Paralela"
echo "===================================================="
echo

# Compilar se necessário
if [ ! -f "matrixmult_serial" ] || [ ! -f "matrixmult_paralelo" ]; then
    echo "Compilando os programas..."
    make
    echo
fi

# Parâmetros do teste
ORDEM=${1:-10}  # Usar argumento ou padrão 10
ARQUIVO_M1="teste_m1.in"
ARQUIVO_M2="teste_m2.in"

echo "Testando com matrizes ${ORDEM}x${ORDEM}"
echo

# Limpar arquivos anteriores
rm -f $ARQUIVO_M1 $ARQUIVO_M2 matriz_mult_serial.out matriz_mult_paralelo.out

echo "----------------------------------------------------"
echo "Passo 1: Executando versão SERIAL"
echo "----------------------------------------------------"
echo "$ ./matrixmult_serial $ORDEM $ARQUIVO_M1 $ARQUIVO_M2"
./matrixmult_serial $ORDEM $ARQUIVO_M1 $ARQUIVO_M2

# Verificar se o resultado da versão serial foi gerado
if [ -f "matriz_mult_serial.out" ]; then
    echo "✓ Resultado serial gerado: matriz_mult_serial.out"
else
    echo "✗ Erro: Resultado serial não foi gerado!"
    exit 1
fi

echo
echo "----------------------------------------------------"
echo "Passo 2: Executando versão PARALELA"
echo "----------------------------------------------------"
echo "$ ./matrixmult_paralelo $ORDEM $ARQUIVO_M1 $ARQUIVO_M2"
./matrixmult_paralelo $ORDEM $ARQUIVO_M1 $ARQUIVO_M2

# Verificar se o resultado da versão paralela foi gerado
if [ -f "matriz_mult_paralelo.out" ]; then
    echo "✓ Resultado paralelo gerado: matriz_mult_paralelo.out"
else
    echo "✗ Erro: Resultado paralelo não foi gerado!"
    exit 1
fi

echo
echo "----------------------------------------------------"
echo "Passo 3: Comparando resultados"
echo "----------------------------------------------------"

# Comparar os arquivos byte a byte
if cmp -s matriz_mult_serial.out matriz_mult_paralelo.out; then
    echo "✓ SUCESSO: Os resultados são IDÊNTICOS!"
    echo "  Os arquivos matriz_mult_serial.out e matriz_mult_paralelo.out são iguais."
    EXIT_CODE=0
else
    echo "✗ ERRO: Os resultados são DIFERENTES!"
    echo "  Os arquivos matriz_mult_serial.out e matriz_mult_paralelo.out NÃO são iguais."
    
    # Mostrar diferenças se houver
    echo
    echo "Tentando mostrar diferenças (se os arquivos forem legíveis):"
    diff matriz_mult_serial.out matriz_mult_paralelo.out 2>/dev/null || echo "  (Arquivos binários - diferenças não exibíveis em texto)"
    EXIT_CODE=1
fi

echo
echo "===================================================="
echo "Teste concluído!"
echo "===================================================="
echo
echo "Arquivos gerados:"
echo "  - $ARQUIVO_M1 (matriz de entrada 1)"
echo "  - $ARQUIVO_M2 (matriz de entrada 2)"
echo "  - matriz_mult_serial.out (resultado serial)"
echo "  - matriz_mult_paralelo.out (resultado paralelo)"
echo
echo "Para testar com outra ordem de matriz, use:"
echo "  ./comparar_resultados.sh <ordem>"
echo "  Exemplo: ./comparar_resultados.sh 50"

exit $EXIT_CODE
