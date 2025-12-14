#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <omp.h>
#include <libppc.h>

int main(int argc, char **argv)
{

    // Verificação dos argumentos de entrada
    if (argc != 4)
    {
        fprintf(stderr, "Uso: %s <ordem> <arquivo_matriz1> <arquivo_matriz2>\n", argv[0]);
        fprintf(stderr, "Exemplo: %s 3 matriz1.in matriz2.in\n", argv[0]);
        return 1;
    }

    // Inicializa o gerador de números aleatórios
    srand(time(NULL));

    // Leitura da ordem das matrizes
    int ordem = atoi(argv[1]);
    const char *arquivo_m1 = argv[2];
    const char *arquivo_m2 = argv[3];

    if (ordem <= 0)
    {
        fprintf(stderr, "Erro: A ordem da matriz deve ser um número positivo.\n");
        return 1;
    }

    printf("Multiplicação de Matrizes (Versão Serial)\n");
    printf("Ordem das matrizes: %dx%d\n", ordem, ordem);
    printf("Matriz 1: %s\n", arquivo_m1);
    printf("Matriz 2: %s\n", arquivo_m2);
    printf("\n");

    // Verificar se a matriz 1 existe; se não, gerar valores aleatórios
    double *m1;
    if (access(arquivo_m1, F_OK) == 0)
    {
        printf("Carregando Matriz 1 do arquivo...\n");
        m1 = load_double_matrix(arquivo_m1, ordem, ordem);
        if (m1 == NULL)
        {
            fprintf(stderr, "Erro ao carregar matriz 1 do arquivo %s\n", arquivo_m1);
            return 1;
        }
    }
    else
    {
        printf("Gerando novos valores aleatórios para Matriz 1...\n");
        m1 = generate_random_double_matrix(ordem, ordem);
        if (m1 == NULL)
        {
            fprintf(stderr, "Erro ao gerar matriz 1\n");
            return 1;
        }
        // Salvar a matriz gerada para uso futuro
        if (save_double_matrix(m1, ordem, ordem, arquivo_m1) != 0)
        {
            fprintf(stderr, "Erro ao salvar matriz 1 no arquivo %s\n", arquivo_m1);
            free(m1);
            return 1;
        }
    }

    // Verificar se a matriz 2 existe; se não, gerar valores aleatórios
    double *m2;
    if (access(arquivo_m2, F_OK) == 0)
    {
        printf("Carregando Matriz 2 do arquivo...\n");
        m2 = load_double_matrix(arquivo_m2, ordem, ordem);
        if (m2 == NULL)
        {
            fprintf(stderr, "Erro ao carregar matriz 2 do arquivo %s\n", arquivo_m2);
            free(m1);
            return 1;
        }
    }
    else
    {
        printf("Gerando novos valores aleatórios para Matriz 2...\n");
        m2 = generate_random_double_matrix(ordem, ordem);
        if (m2 == NULL)
        {
            fprintf(stderr, "Erro ao gerar matriz 2\n");
            free(m1);
            return 1;
        }
        // Salvar a matriz gerada para uso futuro
        if (save_double_matrix(m2, ordem, ordem, arquivo_m2) != 0)
        {
            fprintf(stderr, "Erro ao salvar matriz 2 no arquivo %s\n", arquivo_m2);
            free(m1);
            free(m2);
            return 1;
        }
    }

    printf("Matriz 1 carregada:\n");
    print_double_matrix(m1, ordem, ordem);
    printf("\n");

    printf("Matriz 2 carregada:\n");
    print_double_matrix(m2, ordem, ordem);
    printf("\n");

    // Alocação da matriz resultado
    double *mR = (double *)malloc(sizeof(double) * ordem * ordem);
    if (mR == NULL)
    {
        fprintf(stderr, "Erro ao alocar memória para matriz resultado\n");
        free(m1);
        free(m2);
        return 1;
    }

    // Início da medição de tempo
    double inicio = omp_get_wtime();

    // Multiplicação de matrizes (versão serial)
    // mR[i,j] = soma(m1[i,k] * m2[k,j]) para k de 0 a ordem-1
    for (int i = 0; i < ordem; i++)
    {
        for (int j = 0; j < ordem; j++)
        {
            // Inicializa o elemento da matriz resultado
            M(i, j, ordem, mR) = 0.0;

            // Calcula o produto escalar da linha i de m1 pela coluna j de m2
            for (int k = 0; k < ordem; k++)
            {
                M(i, j, ordem, mR) += M(i, k, ordem, m1) * M(k, j, ordem, m2);
            }
        }
    }

    // Fim da medição de tempo
    double fim = omp_get_wtime();
    double tempo_execucao = fim - inicio;

    printf("Matriz Resultado:\n");
    print_double_matrix(mR, ordem, ordem);
    printf("\n");
    printf("Tempo de execucao: %.6f segundos\n", tempo_execucao);

    // Salvar a matriz resultado no arquivo matriz_mult_serial.out
    int resultado_salvamento = save_double_matrix(mR, ordem, ordem, "matriz_mult_serial.out");
    if (resultado_salvamento != 0)
    {
        fprintf(stderr, "Erro ao salvar matriz resultado no arquivo matriz_mult_serial.out\n");
        free(m1);
        free(m2);
        free(mR);
        return 1;
    }

    printf("Matriz resultado salva em: matriz_mult_serial.out\n");

    // Liberação da memória
    free(m1);
    free(m2);
    free(mR);

    return 0;
}
