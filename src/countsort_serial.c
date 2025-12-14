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

    printf("Countsort (Serial)\n");
    printf("Tamanho do vetor: %ld\n", tamanho);
    printf("Arquivo: %s\n", arquivo_vetor);
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
    for (long int i = 1; i < tamanho; i++)
    {
        if (vetor[i] < min_val)
            min_val = vetor[i];
        if (vetor[i] > max_val)
            max_val = vetor[i];
    }

    int range = max_val - min_val + 1;

    int *count = (int *)calloc(range, sizeof(int));
    for (long int i = 0; i < tamanho; i++)
    {
        count[vetor[i] - min_val]++;
    }

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
    printf("Tempo de execucao: %.6f segundos\n", tempo_execucao);

    save_int_vector(vetor_ordenado, tamanho, "vetor_ordenado_serial.out");
    printf("Vetor ordenado salvo em: vetor_ordenado_serial.out\n");

    free(vetor);
    free(count);
    free(vetor_ordenado);

    return 0;
}
