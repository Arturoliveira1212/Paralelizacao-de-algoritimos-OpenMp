#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <omp.h>
#include <libppc.h>

void trocar_elementos(double *a, double *b)
{
    double temp = *a;
    *a = *b;
    *b = temp;
}

long int particao(double *vetor, long int low, long int high)
{
    double pivot = vetor[high];
    long int i = low - 1;

    for (long int j = low; j < high; j++)
    {
        if (vetor[j] <= pivot)
        {
            i++;
            trocar_elementos(&vetor[i], &vetor[j]);
        }
    }
    trocar_elementos(&vetor[i + 1], &vetor[high]);
    return i + 1;
}

void quicksort(double *vetor, long int low, long int high)
{
    if (low < high)
    {
        long int pi = particao(vetor, low, high);

        quicksort(vetor, low, pi - 1);
        quicksort(vetor, pi + 1, high);
    }
}

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

    printf("Quicksort (Serial)\n");
    printf("Tamanho do vetor: %ld\n", tamanho);
    printf("Arquivo: %s\n", arquivo_vetor);
    printf("\n");

    double *vetor;
    if (access(arquivo_vetor, F_OK) == 0)
    {
        printf("Carregando vetor do arquivo...\n");
        vetor = load_double_vector(arquivo_vetor, tamanho);
    }
    else
    {
        printf("Gerando novos valores aleatórios para o vetor...\n");
        vetor = generate_random_double_vector(tamanho, 0.0, 1000.0);
        save_double_vector(vetor, tamanho, arquivo_vetor);
    }

    printf("\nVetor original (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_double_vector(vetor, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");

    // Início da medição de tempo
    double inicio = omp_get_wtime();

    quicksort(vetor, 0, tamanho - 1);

    // Fim da medição de tempo
    double fim = omp_get_wtime();
    double tempo_execucao = fim - inicio;

    printf("Vetor ordenado (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_double_vector(vetor, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");
    printf("Tempo de execucao: %.6f segundos\n", tempo_execucao);

    save_double_vector(vetor, tamanho, "vetor_ordenado_serial.out");
    printf("Vetor ordenado salvo em: vetor_ordenado_serial.out\n");

    free(vetor);

    return 0;
}
