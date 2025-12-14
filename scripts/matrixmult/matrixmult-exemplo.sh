#!/bin/bash

# Exemplo de uso dos programas matrixmult_serial e matrixmult_paralelo

echo "===================================================="
echo "Exemplo de Uso: Multiplicação de Matrizes"
echo "===================================================="
echo

# Compilar se necessário
if [ ! -f "matrixmult_serial" ] || [ ! -f "matrixmult_paralelo" ]; then
    echo "Compilando os programas..."
    make
    echo
fi

# Exemplo 1: Primeira execução - Gera arquivos aleatórios
echo "----------------------------------------------------"
echo "Exemplo 1: Primeira execução (matriz 4x4)"
echo "----------------------------------------------------"
echo "Os arquivos m1.in e m2.in não existem ainda."
echo "O programa irá gerar valores aleatórios automaticamente."
echo

# Remover arquivos anteriores para demonstração
rm -f m1.in m2.in matriz_mult.out

echo "$ ./matrixmult_serial 4 m1.in m2.in"
./matrixmult_serial 4 m1.in m2.in

echo
read -p "Pressione Enter para continuar..."
echo

# Exemplo 2: Segunda execução - Reutiliza os mesmos arquivos
echo "----------------------------------------------------"
echo "Exemplo 2: Segunda execução (mesma matriz 4x4)"
echo "----------------------------------------------------"
echo "Os arquivos m1.in e m2.in agora existem."
echo "O programa irá carregá-los ao invés de gerar novos."
echo

echo "$ ./matrixmult_paralelo 4 m1.in m2.in"
./matrixmult_paralelo 4 m1.in m2.in

echo
read -p "Pressione Enter para continuar..."
echo

# Exemplo 3: Comparação de desempenho
echo "----------------------------------------------------"
echo "Exemplo 3: Comparação de desempenho (matriz 100x100)"
echo "----------------------------------------------------"
echo

# Limpar arquivos anteriores
rm -f m1_grande.in m2_grande.in

echo "Executando versão serial com matriz 100x100..."
time ./matrixmult_serial 100 m1_grande.in m2_grande.in > /dev/null 2>&1

echo
echo "Executando versão paralela com matriz 100x100..."
time ./matrixmult_paralelo 100 m1_grande.in m2_grande.in > /dev/null 2>&1

echo
echo "----------------------------------------------------"
echo "Nota: A versão paralela deve ser mais rápida em"
echo "      matrizes grandes e sistemas com múltiplos cores."
echo "----------------------------------------------------"
