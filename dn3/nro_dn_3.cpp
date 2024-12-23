#include <iostream>
#include <cmath>

constexpr double PI = 3.14159265358979323846;

double izracunAtan(double* x, int* steviloKorakov) {
    double rezultat = 0.0;
    double clen = *x;
    double x_na_kvadrat = (*x) * (*x);

    for (int n = 0; n < *steviloKorakov; ++n) {
        if (n > 0) {
            clen *= -x_na_kvadrat;
        }
        rezultat += clen / (2 * n + 1);
    }

    return rezultat;
}

double funkcija(double x, int steviloKorakov) {
    double atanRezultat = izracunAtan(&x, &steviloKorakov);
    return std::exp(3 * x) * atanRezultat * atanRezultat;
}

double trapeznaMetoda(double zacetek, double konec, int steviloDelitev, int steviloKorakov) {
    double korak = (konec - zacetek) / steviloDelitev;
    double integral = 0.0;

    integral += funkcija(zacetek, steviloKorakov) / 2.0;
    integral += funkcija(konec, steviloKorakov) / 2.0;

    for (int i = 1; i < steviloDelitev; ++i) {
        double x = zacetek + i * korak;
        integral += funkcija(x, steviloKorakov);
    }

    integral *= korak;
    return integral;
}

int main() {
    double zacetek = 0.0;
    double konec = PI / 4;
    int steviloDelitev = 1000;
    int steviloKorakov = 20;
    double rezultat = trapeznaMetoda(zacetek, konec, steviloDelitev, steviloKorakov);
    std::cout << "Priblizna vrednost integrala je: " << rezultat << std::endl;
    return 0;
}
