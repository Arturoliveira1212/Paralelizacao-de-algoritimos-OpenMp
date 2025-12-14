#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <math.h>
#include <omp.h>
#include <libppc.h>

int main(int argc, char **argv)
{
    // Valida argumentos passados via terminal
    if (argc != 3)
    {
        fprintf(stderr, "Uso: %s <tamanho> <arquivo_vetor>\n", argv[0]);
        fprintf(stderr, "Exemplo: %s 10 vetor.in\n", argv[0]);
        return 1;
    }

    srand(time(NULL));

    long int tamanho = atol(argv[1]);
    const char *arquivo_vetor = argv[2];

    if (tamanho <= 0)
    {
        fprintf(stderr, "Erro: O tamanho do vetor deve ser um número positivo.\n");
        return 1;
    }

    printf("Countsort (Paralelo)\n");
    printf("Tamanho do vetor: %ld\n", tamanho);
    printf("Arquivo: %s\n", arquivo_vetor);
    printf("Número de threads disponíveis: %d\n", omp_get_max_threads());
    printf("\n");

    int *vetor;
    if (access(arquivo_vetor, F_OK) == 0)
    {
        printf("Carregando vetor do arquivo...\n");
        vetor = load_int_vector(arquivo_vetor, tamanho);
    }
    else
    {
        printf("Gerando novos valores aleatórios para o vetor...\n");
        vetor = generate_random_int_vector(tamanho, 0, 1000);
        save_int_vector(vetor, tamanho, arquivo_vetor);
    }

    printf("\nVetor original (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_int_vector(vetor, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");

    // Início da medição de tempo
    double inicio = omp_get_wtime();

    int min_val = vetor[0];
    int max_val = vetor[0];

    #pragma omp parallel
    {
        int local_min = vetor[0];
        int local_max = vetor[0];

        #pragma omp for nowait
        for (long int i = 0; i < tamanho; i++)
        {
            if (vetor[i] < local_min)
                local_min = vetor[i];
            if (vetor[i] > local_max)
                local_max = vetor[i];
        }

        #pragma omp critical
        {
            if (local_min < min_val)
                min_val = local_min;
            if (local_max > max_val)
                max_val = local_max;
        }
    }

    int range = max_val - min_val + 1;

    int *count = (int *)calloc(range, sizeof(int));
    int num_threads = omp_get_max_threads();
    int **local_counts = (int **)malloc(num_threads * sizeof(int *));
    for (int t = 0; t < num_threads; t++)
    {
        local_counts[t] = (int *)calloc(range, sizeof(int));
    }

    #pragma omp parallel
    {
        int tid = omp_get_thread_num();
        #pragma omp for
        for (long int i = 0; i < tamanho; i++)
        {
            local_counts[tid][vetor[i] - min_val]++;
        }
    }

    #pragma omp parallel for
    for (int i = 0; i < range; i++)
    {
        for (int t = 0; t < num_threads; t++)
        {
            count[i] += local_counts[t][i];
        }
    }

    for (int t = 0; t < num_threads; t++)
    {
        free(local_counts[t]);
    }
    free(local_counts);

    for (int i = 1; i < range; i++)
    {
        count[i] += count[i - 1];
    }

    int *vetor_ordenado = (int *)malloc(tamanho * sizeof(int));

    for (long int i = tamanho - 1; i >= 0; i--)
    {
        int idx = vetor[i] - min_val;
        vetor_ordenado[count[idx] - 1] = vetor[i];
        count[idx]--;
    }

    // Fim da medição de tempo
    double fim = omp_get_wtime();
    double tempo_execucao = fim - inicio;

    printf("Vetor ordenado (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_int_vector(vetor_ordenado, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");
    printf("Tempo de execução (ordenação): %.6f segundos\n", tempo_execucao);

    save_int_vector(vetor_ordenado, tamanho, "vetor_ordenado_paralelo.out");
    printf("Vetor ordenado salvo em: vetor_ordenado_paralelo.out\n");

    free(vetor);
    free(count);
    free(vetor_ordenado);

    return 0;
}
