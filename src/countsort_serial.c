#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <math.h>
#include <omp.h>
#include <libppc.h>

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

    printf("Countsort (Versão Serial)\n");
    printf("Tamanho do vetor: %ld\n", tamanho);
    printf("Arquivo: %s\n", arquivo_vetor);
    printf("\n");

    // Verificar se o vetor existe; se não, gerar valores aleatórios
    int *vetor;
    if (access(arquivo_vetor, F_OK) == 0)
    {
        printf("Carregando vetor do arquivo...\n");
        vetor = load_int_vector(arquivo_vetor, tamanho);
        if (vetor == NULL)
        {
            fprintf(stderr, "Erro ao carregar vetor do arquivo %s\n", arquivo_vetor);
            return 1;
        }
    }
    else
    {
        printf("Gerando novos valores aleatórios para o vetor...\n");
        vetor = generate_random_int_vector(tamanho, 0, 1000);
        if (vetor == NULL)
        {
            fprintf(stderr, "Erro ao gerar vetor\n");
            return 1;
        }
        // Salvar o vetor gerado para uso futuro
        if (save_int_vector(vetor, tamanho, arquivo_vetor) != 0)
        {
            fprintf(stderr, "Erro ao salvar vetor no arquivo %s\n", arquivo_vetor);
            free(vetor);
            return 1;
        }
    }

    // Exibir amostra do vetor original (primeiros 10 elementos)
    printf("\nVetor original (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_int_vector(vetor, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");

    // Início da medição de tempo
    double inicio = omp_get_wtime();

    // Countsort - Encontrar min e max para determinar o range
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

    // Alocar array de contagem
    int *count = (int *)calloc(range, sizeof(int));
    if (count == NULL)
    {
        fprintf(stderr, "Erro ao alocar memória para array de contagem\n");
        free(vetor);
        return 1;
    }

    // Counting Sort - Fase 1: Contar ocorrências
    for (long int i = 0; i < tamanho; i++)
    {
        count[vetor[i] - min_val]++;
    }

    // Counting Sort - Fase 2: Acumular contagens
    for (int i = 1; i < range; i++)
    {
        count[i] += count[i - 1];
    }

    // Counting Sort - Fase 3: Construir vetor ordenado
    int *vetor_ordenado = (int *)malloc(tamanho * sizeof(int));
    if (vetor_ordenado == NULL)
    {
        fprintf(stderr, "Erro ao alocar memória para vetor ordenado\n");
        free(vetor);
        free(count);
        return 1;
    }

    // Preencher vetor ordenado (percorrer de trás para frente para manter estabilidade)
    for (long int i = tamanho - 1; i >= 0; i--)
    {
        int idx = vetor[i] - min_val;
        vetor_ordenado[count[idx] - 1] = vetor[i];
        count[idx]--;
    }

    // Fim da medição de tempo
    double fim = omp_get_wtime();
    double tempo_execucao = fim - inicio;

    // Exibir amostra do vetor ordenado (primeiros 10 elementos)
    printf("Vetor ordenado (primeiros %ld elementos):\n", tamanho < 10 ? tamanho : 10);
    print_int_vector(vetor_ordenado, tamanho < 10 ? tamanho : 10, 10);
    printf("\n");
    printf("Tempo de execucao: %.6f segundos\n", tempo_execucao);

    // Salvar o vetor ordenado
    int resultado_salvamento = save_int_vector(vetor_ordenado, tamanho, "vetor_ordenado.out");
    if (resultado_salvamento != 0)
    {
        fprintf(stderr, "Erro ao salvar vetor ordenado no arquivo vetor_ordenado.out\n");
        free(vetor);
        free(count);
        free(vetor_ordenado);
        return 1;
    }

    printf("Vetor ordenado salvo em: vetor_ordenado.out\n");

    // Liberação da memória
    free(vetor);
    free(count);
    free(vetor_ordenado);

    return 0;
}
