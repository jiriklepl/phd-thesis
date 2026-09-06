#include <cstddef>
#include <cstdint>
#include <utility>

constexpr auto M = 2048;
constexpr auto N = 1024;
constexpr auto K = 512;

int matrix[M][N]{};

int init(int i, int j) {
    return static_cast<int>(i + j);
}

void unreal() {
//
for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++)
        matrix[i][j] = init(i, j);
}

int A[M][K]{};
int B[K][N]{};
int C[M][N]{};

void foo() {
//
for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++)
        for (int k = 0; k < K; k++)
            C[i][j] += A[i][k] * B[k][j];
}
