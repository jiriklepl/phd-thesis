#include <cstddef>
#include <cstdint>
#include <utility>

constexpr size_t N = 1024;
constexpr size_t M = 2048;
constexpr size_t K = 512;

template<typename Condition>
struct if_ {
    template<typename Then>
    struct then_ {
        template<typename Else>
        struct else_impl {
            using type = std::conditional_t<Condition::value, Then, Else>;
        };

        template<typename Else>
        using else_ = typename else_impl<Else>::type;
    };
};

using is_alive = std::true_type;
using has3_or_2 = std::true_type;
using has3 = std::false_type;

using alive = std::true_type;
using dead = std::false_type;

int main()
{
//

enum state { ALIVE, DEAD };

state grid[N][M];

size_t x = 2, y = 3;
size_t neighbors = 0;
state cell = grid[x][y];

if (cell == ALIVE) {
    if (neighbors == 2 || neighbors == 3)
        cell = ALIVE;
    else
        cell = DEAD;
} else if (neighbors == 3)
    cell = ALIVE;
else
    cell = DEAD;

cell = (cell == ALIVE)
    ? ((neighbors == 2 || neighbors == 3) ? ALIVE : DEAD)
    : ((neighbors == 3) ? ALIVE : DEAD);

{
//

using gol_rule =
  if_<is_alive>::then_<
    if_<has3_or_2>::then_<alive>::else_<dead>>::
  else_<
    if_<has3>::then_<alive>::else_<dead>
  >;
}


//
}
