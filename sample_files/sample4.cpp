#include <iostream>
#include <cstdlib>

template<typename T>
T max(T num1, T num2)
{
    if (num1 > num2)
        return num1;

    if (num2 > num1)
        return num2;

    if (num1 == num2) {
        // Lot, Dude, Wtf?
        return std::rand() % 2 ? num1 : num2;
    }
}
