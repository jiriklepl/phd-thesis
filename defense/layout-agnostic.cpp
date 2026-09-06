#include <cstddef>
#include <cstdint>
#include <utility>

constexpr size_t N = 1024;
constexpr size_t M = 2048;
constexpr size_t K = 512;

int init(size_t i, size_t j) {
    return static_cast<int>(i + j);
}

// bad code
void foo() {
//

int C[N * M];
int A[N * K];
int B[K * M];

for (size_t I = 0; I < N; I += 16)
    for (size_t J = 0; J < M; J += 16)
        for (size_t i = I; i < I + 16; ++i)
            for (size_t j = J; j < J + 16; ++j)
                for (size_t k = 0; k < K; ++k)
                    C[i * N + j] += A[i * K + k] * B[k * M + j];
//

auto accessC = [&] (size_t i, size_t j) -> int& {
    return C[i * N + j];
};

auto accessA = [&] (size_t i, size_t k) -> int& {
    return A[i * K + k];
};

auto accessB = [&] (size_t k, size_t j) -> int& {
    return B[k * M + j];
};

for (size_t i = 0; i < N; ++i)
    for (size_t j = 0; j < M; ++j)
        for (size_t k = 0; k < K; ++k)
            accessC(i, j) += accessA(i, k) * accessB(k, j);
}


template <char... Dims>
class MultiDimArray {
public:
    template<typename... Indices>
    int &operator[](Indices... indices) {
        // obvious malformed code, but it is not a syntax error
        return std::declval<int*>()[0];
    }
};

class Traversal {
public:
    template<typename... Structures>
    Traversal(Structures &&...structures) {
        // obvious malformed code, but it is not a syntax error
        (void)sizeof...(structures);
    }

    template<typename Func>
    void for_each(Func &&func) {
        (void)(func);
    }

    template<typename Func>
    Traversal &order(Func &&func) {
        (void)(func);
        return *this;
    }
};

template <char... Dims>
class ByTiles {
};

template <char... Dims>
class Idx {
public:
    template<typename... Indices>
    Idx(Indices... indices) {
        (void)sizeof...(indices);
    }
};

// good code
void bar() {
auto RowMajor = MultiDimArray<'N', 'M'>();
auto ColMajor = MultiDimArray<'M', 'N'>();

auto idx = Idx<'N', 'M'>(4, 5);
RowMajor[idx] = ColMajor[idx];

//

auto C = MultiDimArray<'N', 'M'>();
auto A = MultiDimArray<'N', 'K'>();
auto B = MultiDimArray<'K', 'M'>();

Traversal(A, B, C)
    .order(ByTiles<'N', 'M'>{})
    .for_each([&](auto index) {
        C[index] += A[index] * B[index];
    });

//
}
