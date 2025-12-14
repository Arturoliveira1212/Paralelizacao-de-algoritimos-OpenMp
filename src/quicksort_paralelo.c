#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <omp.h>
#include <libppc.h>

// Função auxiliar para trocar dois elementos
void swap(double *a, double *b)
{
    double temp = *a;
    *a = *b;
    *b = temp;
}

// Função de partição para o Quicksort
long int partition(double *vetor, long int low, long int high)
{
    double pivot = vetor[high]; // Escolhe o último elemento como pivô
    long int i = low - 1;       // Índice do menor elemento

    for (long int j = low; j < high; j++)
    {
        // Se o elemento atual é menor ou igual ao pivô
        if (vetor[j] <= pivot)
        {
            i++;
            swap(&vetor[i], &vetor[j]);
        }
    }
    swap(&vetor[i + 1], &vetor[high]);
    return i + 1;
}

// Função recursiva do Quicksort paralelo
void quicksort_parallel(double *vetor, long int low, long int high, int depth)
{
    if (low < high)
    {
        // pi é o índice de partição
        long int pi = partition(vetor, low, high);

        // Paralelizar se o subarranjo for grande o suficiente e não estivermos muito profundos
        // Limitar a profundidade de paralelização para evitar overhead excessivo
        if (depth > 0 && (high - low) > 1000)
        {
#pragma omp task shared(vetor)
            quicksort_parallel(vetor, low, pi - 1, depth - 1);

#pragma omp task shared(vetor)
            quicksort_parallel(vetor, pi + 1, high, depth - 1);

#pragma omp taskwait
        }
        else
        {
            // Para subproblemas pequenos, executar sequencialmente
            quicksort_parallel(vetor, low, pi - 1, depth - 1);
            quicksort_parallel(vetor, pi + 1, high, depth - 1);
        }
    }
}

int main(int argc, char **argv)
{
    // Verificação dos argumentos de entrada
    if (argc != 3)
    {
        fprintf(stderr, "Uso: %s <tamanho> <arquivo_vetor>\n", argv[0]);
        fprintf(stderr, "Exemplo: %s 10 vetor.in\n", argv[0]);
        return 1;
    }

    // Inicializa o gerador de números aleatórios
    srand(time(NULL));

    // Leitura dos parâmetros
    long int tamanho = atol(argv[1]);
    const char *arquivo_vetor = argv[2];

    if (tamanho <= 0)
    {
        fprintf(stderr, "Erro: O tamanho do vetor deve ser um número positivo.\n");
        return 1;
    }

    printf("Quicksort (Versão Paralela com OpenMP)\n");
    printf("Tamanho do vetor: %ld\n", tamanho);
    printf("Arquivo: %s\n", arquivo_vetor);
    printf("Número de threads disponíveis: %d\n", omp_get_max_threads());
    printf("\n");

    // Verificar se o vetor existe; se não, gerar valores aleatórios
    double *vetor;
    if (access(arquivo_vetor, F_OK) == 0)
    {
        printf("Carregando vetor do arquivo...\n");
        vetor = load_double_vector(arquivo_vetor, tamanho);
        if (vetor == NULL)
        {
            fprintf(stderr, "Erro ao carregar vetor do arquivo %s\n", arquivo_vetor);
            return 1;
        }
    }
    else
    {
        printf("Gerando novos valores aleatórios para o vetor...\n");
        vetor = generate_random_double_vector(tamanho, 0.0, 1000.0);
        if (vetor == NULL)
        {
            fprintf(stderr, "Erro ao gerar vetor\n");
            return 1;
        }
        // Salvar o vetor gerado para uso futuro
        if (save_double_vector(vetor, tamanho, arquivo_vetor) != 0)
        {
            fprintf(stderr, "Erro ao salvar vetor no arquivo %s\n", arquivo_vetor);
            free(vetor);
            return 1;
        }
    }

    // Exibir amostra do vetor original (primeiros 10 elementos)
    printf("\nVetor original (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_double_vector(vetor, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");

    // Início da medição de tempo
    double inicio = omp_get_wtime();

    // Executar Quicksort paralelo
    // Profundidade máxima de paralelização (baseado no número de threads)
    int max_depth = 0;
    int num_threads = omp_get_max_threads();
    while ((1 << max_depth) < num_threads)
    {
        max_depth++;
    }

#pragma omp parallel
    {
#pragma omp single
        quicksort_parallel(vetor, 0, tamanho - 1, max_depth);
    }

    // Fim da medição de tempo
    double fim = omp_get_wtime();
    double tempo_execucao = fim - inicio;

    // Exibir amostra do vetor ordenado (primeiros 10 elementos)
    printf("Vetor ordenado (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_double_vector(vetor, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");
    printf("Tempo de execução (ordenação): %.6f segundos\n", tempo_execucao);

    // Salvar o vetor ordenado
    int resultado_salvamento = save_double_vector(vetor, tamanho, "vetor_ordenado.out");
    if (resultado_salvamento != 0)
    {
        fprintf(stderr, "Erro ao salvar vetor ordenado no arquivo vetor_ordenado.out\n");
        free(vetor);
        return 1;
    }

    printf("Vetor ordenado salvo em: vetor_ordenado.out\n");

    // Liberação da memória
    free(vetor);

    return 0;
}
