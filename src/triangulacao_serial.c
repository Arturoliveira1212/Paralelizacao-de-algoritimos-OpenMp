/**
 * Eliminação Gaussiana (Triangulação de Matrizes) - Versão Serial
 *
 * Este programa implementa o algoritmo de Eliminação Gaussiana para
 * transformar uma matriz em sua forma triangular superior.
 *
 * Uso: ./triangulacao_serial <arquivo_entrada>
 *
 * O programa lê uma matriz do arquivo de entrada e gera a matriz
 * triangularizada no arquivo saida.out
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include "../LibPPC/include/libppc.h"

/**
 * Realiza a eliminação gaussiana (triangulação)
 * Transforma a matriz em forma triangular superior
 */
void eliminacao_gaussiana(double *matriz, int linhas, int colunas)
{
    int i, j, k;
    double fator;

    // Para cada linha pivô
    for (i = 0; i < linhas - 1; i++)
    {
        // Verifica se o pivô é zero (simplificação - não faz pivotamento)
        if (M(i, i, colunas, matriz) == 0.0)
        {
            fprintf(stderr, "Aviso: Pivô zero encontrado na linha %d\n", i);
            continue;
        }

        // Para cada linha abaixo do pivô
        for (j = i + 1; j < linhas; j++)
        {
            // Calcula o fator de multiplicação
            fator = M(j, i, colunas, matriz) / M(i, i, colunas, matriz);

            // Zera o elemento abaixo do pivô
            M(j, i, colunas, matriz) = 0.0;

            // Atualiza os elementos restantes da linha
            for (k = i + 1; k < colunas; k++)
            {
                M(j, k, colunas, matriz) -= fator * M(i, k, colunas, matriz);
            }
        }
    }
}

int main(int argc, char *argv[])
{
    double *matriz = NULL;
    long int ordem;
    struct timeval inicio, fim;
    double tempo_execucao;

    // Verifica argumentos
    if (argc < 3)
    {
        fprintf(stderr, "Uso: %s <ordem> <arquivo_entrada>\n", argv[0]);
        fprintf(stderr, "Exemplo: %s 100 matriz.in\n", argv[0]);
        return 1;
    }

    ordem = atol(argv[1]);
    char *arquivo_entrada = argv[2];

    if (ordem <= 0)
    {
        fprintf(stderr, "Erro: Ordem deve ser um número positivo!\n");
        return 1;
    }

    printf("=== ELIMINAÇÃO GAUSSIANA (SERIAL) ===\n");
    printf("Ordem da matriz: %ld x %ld\n", ordem, ordem);
    printf("Arquivo de entrada: %s\n", arquivo_entrada);

    // Carrega ou gera a matriz
    if (access(arquivo_entrada, F_OK) == 0)
    {
        printf("Carregando matriz do arquivo...\n");
        matriz = load_double_matrix(arquivo_entrada, ordem, ordem);
        if (matriz == NULL)
        {
            fprintf(stderr, "Erro ao carregar matriz!\n");
            return 1;
        }
    }
    else
    {
        printf("Arquivo não encontrado. Gerando matriz aleatória...\n");
        matriz = generate_random_double_matrix(ordem, ordem);
        if (matriz == NULL)
        {
            fprintf(stderr, "Erro ao gerar matriz!\n");
            return 1;
        }
        // Salva matriz gerada
        if (save_double_matrix(matriz, ordem, ordem, arquivo_entrada) != 0)
        {
            fprintf(stderr, "Erro ao salvar matriz!\n");
            free(matriz);
            return 1;
        }
        printf("Matriz salva em %s\n", arquivo_entrada);
    }

    // Exibe a matriz original (se for pequena)
    if (ordem <= 10)
    {
        printf("\nMatriz original:\n");
        print_double_matrix(matriz, ordem, ordem);
    }

    // Inicia contagem de tempo
    gettimeofday(&inicio, NULL);

    // Realiza a eliminação gaussiana
    printf("\nRealizando eliminação gaussiana...\n");
    eliminacao_gaussiana(matriz, ordem, ordem);

    // Finaliza contagem de tempo
    gettimeofday(&fim, NULL);
    tempo_execucao = (fim.tv_sec - inicio.tv_sec) +
                     (fim.tv_usec - inicio.tv_usec) / 1000000.0;

    // Exibe a matriz triangularizada (se for pequena)
    if (ordem <= 10)
    {
        printf("\nMatriz triangularizada:\n");
        print_double_matrix(matriz, ordem, ordem);
    }

    // Salva o resultado
    printf("\nSalvando resultado em saida.out...\n");
    if (save_double_matrix(matriz, ordem, ordem, "saida.out") != 0)
    {
        fprintf(stderr, "Erro ao salvar matriz!\n");
        free(matriz);
        return 1;
    }

    printf("\n=== CONCLUSÃO ===\n");
    printf("Tempo de execução: %.9f segundos\n", tempo_execucao);
    printf("Arquivo de saída: saida.out\n");

    // Libera memória
    free(matriz);

    return 0;
}
