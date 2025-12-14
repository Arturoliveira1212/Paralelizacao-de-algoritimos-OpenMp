# Eliminação Gaussiana (Triangulação de Matrizes)

## Descrição

Implementação do algoritmo de Eliminação Gaussiana (Gaussian Elimination) para transformar uma matriz em sua forma triangular superior. O algoritmo é implementado em duas versões:

- **Serial**: Versão sequencial do algoritmo
- **Paralelo**: Versão paralela usando OpenMP

## Algoritmo

A Eliminação Gaussiana transforma uma matriz em forma triangular superior (escalonada) através de operações elementares de linha. O algoritmo funciona da seguinte forma:

1. Para cada linha pivô `i` (de 0 a n-1):
   - Para cada linha `j` abaixo do pivô (j > i):
     - Calcular fator = matriz[j][i] / matriz[i][i]
     - Zerar o elemento abaixo do pivô: matriz[j][i] = 0
     - Para cada coluna `k` (de i+1 a n):
       - Atualizar: matriz[j][k] -= fator * matriz[i][k]

**Referência**: [Gaussian Elimination - Wikipedia](https://en.wikipedia.org/wiki/Gaussian_elimination)

## Paralelização

A versão paralela usa OpenMP para distribuir o trabalho de atualização das linhas:

- **Loop externo (linhas pivô)**: Executado sequencialmente (dependência de dados)
- **Loop das linhas abaixo do pivô**: Paralelizado com `#pragma omp parallel for`
- **Loop de atualização dos elementos**: Executado em paralelo por cada thread

Cada thread processa um subconjunto das linhas abaixo do pivô, atualizando independentemente os elementos de cada linha.

## Compilação

```bash
make triangulacao_serial triangulacao_paralelo
```

Ou para compilar tudo:

```bash
make
```

## Uso

### Uso Individual

Os programas recebem dois argumentos:
1. **Ordem**: Dimensão da matriz quadrada (n x n)
2. **Arquivo de entrada**: Nome do arquivo contendo a matriz

```bash
# Versão serial
./triangulacao_serial <ordem> <arquivo_entrada>

# Versão paralela
./triangulacao_paralelo <ordem> <arquivo_entrada>
```

### Exemplos

```bash
# Gera matriz.in aleatória 100x100 e triangulariza (serial)
./triangulacao_serial 100 matriz.in

# Reutiliza matriz.in e triangulariza (paralelo)
./triangulacao_paralelo 100 matriz.in

# Usar matriz de entrada diferente
./triangulacao_serial 500 minha_matriz.in
./triangulacao_paralelo 500 minha_matriz.in
```

## Comportamento

### Primeira Execução
- Se o arquivo de entrada **não existir**: o programa gera uma matriz aleatória, salva no arquivo especificado e processa
- Valores aleatórios entre 0 e `ordem`

### Execuções Subsequentes
- Se o arquivo de entrada **existir**: o programa carrega a matriz do arquivo e processa
- Permite comparar as versões serial e paralela com os mesmos dados

## Arquivos

### Entrada
- **matriz.in** (ou nome especificado): Arquivo binário contendo a matriz a ser triangularizada

### Saída
- **saida.out**: Matriz triangularizada (forma triangular superior)

## Scripts de Teste

### 1. Comparação Serial vs Paralelo

```bash
./comparar_triangulacao.sh [ordem]
```

Executa ambas as versões, compara os resultados e calcula o speedup.

**Exemplo:**
```bash
./comparar_triangulacao.sh 500
```

**Saída:**
- Valida se os resultados são idênticos
- Calcula tempo de execução de cada versão
- Calcula speedup (aceleração)
- Gera arquivos temporários para comparação

### 2. Exemplo de Uso

```bash
./exemplo_triangulacao.sh
```

Demonstra o uso básico dos programas com matriz 100x100.

## Análise de Desempenho

### Resultados dos Testes

| Ordem | Serial (s) | Paralelo (s) | Speedup | Threads |
|-------|-----------|--------------|---------|---------|
| 10    | 0.000004  | 0.062304     | 0.00x   | 4       |
| 100   | 0.000797  | 0.017194     | 0.05x   | 4       |
| 500   | 0.132383  | 0.122633     | 1.08x   | 4       |
| 1000  | 1.359253  | 0.819735     | 1.66x   | 4       |

### Observações

- **Matrizes pequenas (< 200)**: Overhead de paralelização supera os ganhos
- **Matrizes médias (200-500)**: Começa a haver benefício da paralelização
- **Matrizes grandes (> 500)**: Speedup significativo (~1.6x com 4 threads)

### Fatores que Afetam o Desempenho

1. **Dependência de dados**: O pivô deve ser processado sequencialmente
2. **Overhead de threads**: Criação e sincronização de threads
3. **Tamanho da matriz**: Matrizes maiores amortizam o overhead
4. **Número de threads**: Depende do hardware (cores/threads disponíveis)

## Formato dos Arquivos

Os arquivos de entrada/saída seguem o formato da LibPPC:
- Binário (double precision)
- Dimensões armazenadas no início do arquivo
- Elementos em ordem row-major (linha por linha)

## Visualização

Para matrizes pequenas (≤ 10x10), os programas exibem:
- Matriz original
- Matriz triangularizada

Para matrizes maiores, apenas informações de processamento são exibidas.

## Exemplos de Saída

### Matriz 10x10

```
=== ELIMINAÇÃO GAUSSIANA (SERIAL) ===
Ordem da matriz: 10 x 10
Arquivo de entrada: matriz.in
Arquivo não encontrado. Gerando matriz aleatória...
Matriz salva em matriz.in

Matriz original:

83.000  86.000  77.000  15.000  93.000  35.000  86.000  92.000  49.000  21.000
62.000  27.000  90.000  59.000  63.000  26.000  40.000  26.000  72.000  36.000
...

Realizando eliminação gaussiana...

Matriz triangularizada:

83.000  86.000  77.000  15.000  93.000  35.000  86.000  92.000  49.000  21.000
0.000  -37.241  32.482  47.795  -6.470  -0.145 -24.241 -42.723  35.398  20.313
0.000    0.000 106.164  99.656  59.841  25.142  13.759 -54.127 114.307  63.091
...

Salvando resultado em saida.out...

=== CONCLUSÃO ===
Tempo de execução: 0.000004000 segundos
Arquivo de saída: saida.out
```

## Limitações

- Não implementa pivotamento parcial ou total
- Assume que os pivôs não são zero
- Se encontrar pivô zero, exibe aviso e continua

## Referências

- [Gaussian Elimination - Wikipedia](https://en.wikipedia.org/wiki/Gaussian_elimination)
- [OpenMP Specification](https://www.openmp.org/specifications/)
- LibPPC - Library for Parallel Programming in C

## Autores

Implementação para o projeto de Paralelização de Algoritmos com OpenMP.
