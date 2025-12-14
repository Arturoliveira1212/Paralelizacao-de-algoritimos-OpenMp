#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <omp.h>
#include "../LibPPC/include/libppc.h"

void eliminacao_gaussiana(double *matriz, int linhas, int colunas)
{
    int i, j, k;
    double fator;

    for (i = 0; i < linhas - 1; i++)
    {
        if (M(i, i, colunas, matriz) == 0.0)
        {
            fprintf(stderr, "Aviso: Pivô zero encontrado na linha %d\n", i);
            continue;
        }

        for (j = i + 1; j < linhas; j++)
        {
            fator = M(j, i, colunas, matriz) / M(i, i, colunas, matriz);

            M(j, i, colunas, matriz) = 0.0;

            for (k = i + 1; k < colunas; k++)
            {
                M(j, k, colunas, matriz) -= fator * M(i, k, colunas, matriz);
            }
        }
    }
}

int main(int argc, char *argv[])
{
    // Valida argumentos passados via terminal
    if (argc < 3)
    {
        fprintf(stderr, "Uso: %s <ordem> <arquivo_entrada>\n", argv[0]);
        fprintf(stderr, "Exemplo: %s 100 matriz.in\n", argv[0]);
        return 1;
    }

    int ordem = atol(argv[1]);
    char *arquivo_entrada = argv[2];

    printf("Eliminação Gaussiana (Serial)\n");
    printf("Ordem da matriz: %dx%d\n", ordem, ordem);
    printf("Matriz: %s\n", arquivo_entrada);
    printf("Número de threads disponíveis: %d\n", omp_get_max_threads());
    printf("\n");

    double *matriz;
    if (access(arquivo_entrada, F_OK) == 0)
    {
        printf("Carregando matriz do arquivo...\n");
        matriz = load_double_matrix(arquivo_entrada, ordem, ordem);
    }
    else
    {
        printf("Gerando matriz aleatória...\n");
        matriz = generate_random_double_matrix(ordem, ordem);
        save_double_matrix(matriz, ordem, ordem, arquivo_entrada);
    }

    printf("\nMatriz original:\n");
    print_double_matrix(matriz, ordem, ordem);
    printf("\n");

    // Início da medição de tempo
    double inicio = omp_get_wtime();

    eliminacao_gaussiana(matriz, ordem, ordem);

    // Fim da medição de tempo
    double fim = omp_get_wtime();
    double tempo_execucao = fim - inicio;

    printf("Matriz Resultado:\n");
    print_double_matrix(matriz, ordem, ordem);
    printf("\n");
    printf("Tempo de execução (multiplicação): %.6f segundos\n", tempo_execucao);

    save_double_matrix(matriz, ordem, ordem, "saida_serial.out");
    printf("Matriz resultado salva em: saida_serial.out\n");

    free(matriz);

    return 0;
}
