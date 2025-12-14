CFLAGS =
ALL_CFLAGS = -O0 -g $(CFLAGS) -I. -Iinclude -ILibPPC/include -fopenmp

LDFLAGS =
ALL_LDFLAGS = $(LDFLAGS) LibPPC/lib/static/libppc.a -fopenmp -lm

CC=gcc
LD=gcc

# passar como parametro do Makefile o nome do codigo fonte
HEADERS = LibPPC/include/libppc.h
LIBRARIES = LibPPC/lib/static/libppc.a

VPATH = src

.PHONY: all clean distclean

all: matrixmult_serial matrixmult_paralelo countsort_serial countsort_paralelo quicksort_serial quicksort_paralelo triangulacao_serial triangulacao_paralelo

# Multiplicação de Matrizes
matrixmult_serial: src/matrixmult_serial.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

matrixmult_paralelo: src/matrixmult_paralelo.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

# Countsort
countsort_serial: src/countsort_serial.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

countsort_paralelo: src/countsort_paralelo.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

# Quicksort
quicksort_serial: src/quicksort_serial.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

quicksort_paralelo: src/quicksort_paralelo.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

# Triangulação (Eliminação Gaussiana)
triangulacao_serial: src/triangulacao_serial.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

triangulacao_paralelo: src/triangulacao_paralelo.c $(LIBRARIES) $(HEADERS)
	$(CC) $(ALL_CFLAGS) $< -o $@ $(ALL_LDFLAGS)

LibPPC/lib/static/libppc.a:
	make -C LibPPC static

clean:
	rm -f *.o src/*.o matrixmult_serial matrixmult_paralelo countsort_serial countsort_paralelo quicksort_serial quicksort_paralelo triangulacao_serial triangulacao_paralelo

distclean: clean
	rm -f *.dat *.out *.in
	make -C LibPPC clean


