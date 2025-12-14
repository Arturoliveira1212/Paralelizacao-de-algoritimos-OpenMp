#!/bin/bash

# Script para testar e comparar as implementações de Eliminação Gaussiana
# Uso: ./comparar_triangulacao.sh [ordem]

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Parâmetros
ORDEM=${1:-100}
ARQUIVO_ENTRADA="matriz.in"

echo "===================================================="
echo "TESTE: ELIMINAÇÃO GAUSSIANA (TRIANGULAÇÃO)"
echo "===================================================="
echo ""
echo "Ordem da matriz: ${ORDEM}x${ORDEM}"
echo ""

# Remove arquivos anteriores
rm -f saida.out saida_serial_temp.out saida_paralelo_temp.out

# Executa versão serial
echo "----------------------------------------------------"
echo "Executando versão SERIAL..."
echo "----------------------------------------------------"
./triangulacao_serial $ORDEM $ARQUIVO_ENTRADA
SERIAL_EXIT=$?

if [ $SERIAL_EXIT -ne 0 ]; then
    echo -e "${RED}✗ ERRO: Falha na execução serial!${NC}"
    exit 1
fi

# Renomeia saída serial para comparação
mv saida.out saida_serial_temp.out

echo ""

# Executa versão paralela
echo "----------------------------------------------------"
echo "Executando versão PARALELA..."
echo "----------------------------------------------------"
./triangulacao_paralelo $ORDEM $ARQUIVO_ENTRADA
PARALELO_EXIT=$?

if [ $PARALELO_EXIT -ne 0 ]; then
    echo -e "${RED}✗ ERRO: Falha na execução paralela!${NC}"
    exit 1
fi

# Renomeia saída paralela para comparação
mv saida.out saida_paralelo_temp.out

echo ""
echo "===================================================="
echo "COMPARAÇÃO DE RESULTADOS"
echo "===================================================="

# Verifica se os arquivos de saída existem
if [ ! -f "saida_serial_temp.out" ]; then
    echo -e "${RED}✗ ERRO: Arquivo saida_serial_temp.out não encontrado!${NC}"
    exit 1
fi

if [ ! -f "saida_paralelo_temp.out" ]; then
    echo -e "${RED}✗ ERRO: Arquivo saida_paralelo_temp.out não encontrado!${NC}"
    exit 1
fi

# Compara os resultados
if cmp -s "saida_serial_temp.out" "saida_paralelo_temp.out"; then
    echo -e "${GREEN}✓ SUCESSO: Os resultados são IDÊNTICOS!${NC}"
    echo "  Os arquivos saida_serial_temp.out e saida_paralelo_temp.out são iguais."
    # Mantém uma cópia final
    cp saida_paralelo_temp.out saida.out
else
    echo -e "${RED}✗ FALHA: Os resultados são DIFERENTES!${NC}"
    echo "  Os arquivos saida_serial_temp.out e saida_paralelo_temp.out diferem."
    echo ""
    echo "Primeiras diferenças:"
    diff -u saida_serial_temp.out saida_paralelo_temp.out | head -20
    exit 1
fi

echo ""
echo "===================================================="
echo "ANÁLISE DE DESEMPENHO"
echo "===================================================="
echo ""

# Extrai tempos de execução
TEMPO_SERIAL=$(grep "Tempo de execução:" /tmp/triangulacao_serial.log 2>/dev/null | tail -1 | awk '{print $4}')
TEMPO_PARALELO=$(grep "Tempo de execução:" /tmp/triangulacao_paralelo.log 2>/dev/null | tail -1 | awk '{print $4}')

# Re-executa para capturar tempos se necessário
if [ -z "$TEMPO_SERIAL" ] || [ -z "$TEMPO_PARALELO" ]; then
    echo "Re-executando para capturar tempos de execução..."
    echo ""
    
    TEMPO_SERIAL=$(./triangulacao_serial $ORDEM $ARQUIVO_ENTRADA 2>&1 | grep "Tempo de execução:" | awk '{print $4}')
    TEMPO_PARALELO=$(./triangulacao_paralelo $ORDEM $ARQUIVO_ENTRADA 2>&1 | grep "Tempo de execução:" | awk '{print $4}')
fi

echo "Resumo dos Tempos:"
echo "  Serial:   ${TEMPO_SERIAL} segundos"
echo "  Paralelo: ${TEMPO_PARALELO} segundos"
echo ""

# Calcula speedup se os tempos foram capturados
if [ -n "$TEMPO_SERIAL" ] && [ -n "$TEMPO_PARALELO" ]; then
    SPEEDUP=$(echo "scale=4; $TEMPO_SERIAL / $TEMPO_PARALELO" | bc)
    MELHORIA=$(echo "scale=0; ($SPEEDUP - 1) * 100" | bc)
    
    echo "Análise:"
    echo "  Speedup:  ${SPEEDUP}x"
    echo "  Melhoria: ${MELHORIA}%"
    echo ""
    
    # Verifica se paralelo foi mais rápido
    COMPARACAO=$(echo "$SPEEDUP > 1.0" | bc)
    if [ "$COMPARACAO" -eq 1 ]; then
        echo -e "${GREEN}✓ A versão paralela foi MAIS RÁPIDA!${NC}"
    else
        echo -e "${YELLOW}⚠ A versão serial foi mais rápida (overhead de paralelização)${NC}"
        echo "  Dica: Teste com matrizes maiores (ex: ./comparar_triangulacao.sh 500)"
    fi
fi

echo ""
echo "===================================================="
echo "RESUMO FINAL"
echo "===================================================="
echo ""
echo "Ordem da matriz: ${ORDEM}x${ORDEM}"
echo "Resultados:      CORRETO"
echo "Tempo serial:    ${TEMPO_SERIAL}s"
echo "Tempo paralelo:  ${TEMPO_PARALELO}s"
if [ -n "$SPEEDUP" ]; then
    echo "Speedup:         ${SPEEDUP}x"
fi
echo ""
echo "Arquivos gerados:"
echo "  - ${ARQUIVO_ENTRADA} (matriz de entrada)"
echo "  - saida.out (resultado final)"
echo "  - saida_serial_temp.out (resultado serial para comparação)"
echo "  - saida_paralelo_temp.out (resultado paralelo para comparação)"
echo ""
echo "Para testar com outro tamanho:"
echo "  ./comparar_triangulacao.sh <ordem>"
echo "  Exemplo: ./comparar_triangulacao.sh 500"
echo ""
