# Multiplicação de Matrizes - Serial e Paralela

Este projeto implementa duas versões de multiplicação de matrizes:
- **Versão Serial**: Implementação sequencial clássica
- **Versão Paralela**: Implementação usando OpenMP

## Requisitos

- GCC com suporte a OpenMP
- Biblioteca LibPPC (incluída no projeto)
- Python 3 (para o script de teste)

## Compilação

Para compilar ambas as versões:

```bash
make
```

Para compilar apenas a versão serial:

```bash
make matrixmult_serial
```

Para compilar apenas a versão paralela:

```bash
make matrixmult_paralelo
```

## Uso

Ambos os programas seguem a mesma interface de linha de comando:

```bash
./matrixmult_serial <ordem> <arquivo_matriz1> <arquivo_matriz2>
./matrixmult_paralelo <ordem> <arquivo_matriz1> <arquivo_matriz2>
```

### Parâmetros

1. **ordem**: Número inteiro representando a ordem das matrizes quadradas (ex: 3 para 3x3)
2. **arquivo_matriz1**: Caminho para o arquivo contendo a primeira matriz
3. **arquivo_matriz2**: Caminho para o arquivo contendo a segunda matriz

### Formato dos Arquivos

Os arquivos de entrada devem conter valores em formato binário `double` do C.
O resultado é salvo no arquivo `matriz_mult.out`.

**Comportamento Importante**: Na primeira execução, se os arquivos de entrada não existirem, o programa irá **gerar valores aleatórios automaticamente** e salvá-los nos arquivos especificados. Nas execuções seguintes, o programa irá **reutilizar os mesmos arquivos**, permitindo comparar as versões serial e paralela com as mesmas entradas.

### Exemplo

```bash
# Primeira execução - gera valores aleatórios
./matrixmult_serial 3 matriz1.in matriz2.in

# Segunda execução - reutiliza os mesmos arquivos
./matrixmult_paralelo 3 matriz1.in matriz2.in
```

## Teste Automatizado

Execute o script de teste para verificar as implementações:

```bash
./test_matrixmult.sh
```

Este script irá:
1. Compilar a biblioteca LibPPC se necessário
2. Compilar ambas as versões
3. Executar a versão serial (gerando matrizes aleatórias na 1ª vez)
4. Executar a versão paralela (reutilizando as mesmas matrizes)
5. Comparar os resultados
6. Executar novamente para demonstrar a reutilização de arquivos

### Exemplo de Uso Interativo

Para uma demonstração passo a passo:

```bash
./exemplo_uso.sh
```

## Implementação

### Versão Serial

A versão serial ([matrixmult_serial.c](src/matrixmult_serial.c)) implementa o algoritmo clássico de multiplicação de matrizes com três loops aninhados:

```c
for (int i = 0; i < ordem; i++) {
    for (int j = 0; j < ordem; j++) {
        M(i, j, ordem, mR) = 0.0;
        for (int k = 0; k < ordem; k++) {
            M(i, j, ordem, mR) += M(i, k, ordem, m1) * M(k, j, ordem, m2);
        }
    }
}
```

### Versão Paralela

A versão paralela ([matrixmult_paralelo.c](src/matrixmult_paralelo.c)) usa OpenMP para paralelizar os dois loops externos:

```c
#pragma omp parallel for collapse(2)
for (int i = 0; i < ordem; i++) {
    for (int j = 0; j < ordem; j++) {
        M(i, j, ordem, mR) = 0.0;
        for (int k = 0; k < ordem; k++) {
            M(i, j, ordem, mR) += M(i, k, ordem, m1) * M(k, j, ordem, m2);
        }
    }
}
```

A diretiva `collapse(2)` funde os dois primeiros loops, criando um único espaço de iteração maior, o que melhora o balanceamento de carga entre as threads.

### Análise de Desempenho

A versão paralela inclui medição de tempo usando `omp_get_wtime()` para avaliar o speedup obtido com a paralelização.

## Biblioteca LibPPC

Este projeto utiliza a biblioteca LibPPC para:
- Carregar matrizes de arquivos: `load_double_matrix()`
- Salvar matrizes em arquivos: `save_double_matrix()`
- Imprimir matrizes: `print_double_matrix()`
- Acessar elementos de matriz: macro `M(i, j, colunas, matriz)`

Para mais informações sobre a biblioteca, consulte [LibPPC/README.md](LibPPC/README.md).

## Limpeza

Para remover os arquivos compilados:

```bash
make clean
```

Para remover todos os arquivos gerados (incluindo arquivos .dat e .out):

```bash
make distclean
```

## Estrutura do Projeto

```
.
├── Makefile                      # Makefile principal
├── README_MATRIXMULT.md         # Este arquivo
├── test_matrixmult.sh           # Script de teste automatizado
├── exemplo_uso.sh               # Script de demonstração interativa
├── src/
│   ├── matrixmult_serial.c      # Implementação serial
│   └── matrixmult_paralelo.c    # Implementação paralela
└── LibPPC/                       # Biblioteca de suporte
    ├── include/
    │   └── libppc.h
    └── ...
```

## Notas

- **Geração automática de dados**: Na primeira execução, valores aleatórios são gerados e salvos nos arquivos especificados. Execuções subsequentes reutilizam esses arquivos.
- A biblioteca LibPPC trabalha com `double`, não `float` como mencionado no enunciado
- Ambos os programas salvam o resultado em `matriz_mult.out`
- O número de threads OpenMP pode ser controlado pela variável de ambiente `OMP_NUM_THREADS`

## Fluxo de Trabalho Recomendado

1. **Primeira execução (Serial)**: Gera matrizes aleatórias
   ```bash
   ./matrixmult_serial 100 m1.in m2.in
   ```

2. **Segunda execução (Paralela)**: Reutiliza as mesmas matrizes
   ```bash
   ./matrixmult_paralelo 100 m1.in m2.in
   ```

3. **Comparação de resultados**: Os resultados devem ser idênticos
   ```bash
   # Você pode comparar manualmente os tempos de execução
   ```

Isso garante que ambas as versões sejam testadas com exatamente as mesmas entradas, permitindo uma comparação justa de desempenho.
