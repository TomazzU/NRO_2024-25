#define _USE_MATH_DEFINES
#include <vector>
#include <cmath>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>
#include <omp.h>

using namespace std;

int main() {

    // inicializiramo matriko A
    vector<vector<double>> A;

    // inicializiramo vektor b;
    vector<double> b;

    // podamo ime datoteke
    std::string filename = "./datoteka_A_b.txt";

    // preberemo datoteko
    std::ifstream infile;
    infile.open(filename);

    if (!infile.is_open()) {
        cerr << "Napaka pri odpiranju datoteke!" << endl;
        return 1;
    }

    // preberemo prvo vrstico, v kateri imamo podano velikost matrike A 
    std::string string_first_line;
    std::getline(infile, string_first_line);

    // string_first_line je enak 'A: n=256'
    std::replace(string_first_line.begin(), string_first_line.end(), '=', ' ');

    // definiramo stringstream za razdelitev vrstice
    std::istringstream iss(string_first_line);
    std::string nepomemben_del1; // 'A:'
    std::string nepomemben_del2; // 'n'
    int n; // velikost matrike A

    iss >> nepomemben_del1;
    iss >> nepomemben_del2;
    iss >> n;

    std::cout << "Velikost matrike A: " << n << "x" << n << std::endl;;

    // V naslednjih n vrsticah imamo elemente matrike A
    for (int iiA = 0; iiA < n; iiA++) {
        std::string line;
        std::getline(infile, line);
        std::replace(line.begin(), line.end(), ';', ' ');

        std::istringstream iss_column(line);
        vector<double> row;

        for (int column = 0; column < n; column++) {
            double element_a = 0;
            iss_column >> element_a;
            row.push_back(element_a);
        }

        A.push_back(row);
    }

    // Naslednja vrstica je prazna, zato jo preskoèimo
    std::string empty_line;
    std::getline(infile, empty_line);

    // preberemo vektor b
    std::string string_line_b;
    std::getline(infile, string_line_b);
    std::replace(string_line_b.begin(), string_line_b.end(), '>', ' ');
    std::istringstream iss_b(string_line_b);

    int n_b;
    iss_b >> nepomemben_del1;
    iss_b >> nepomemben_del2;
    iss_b >> n_b;

    std::cout << "Velikost vektorja b: " << n_b << std::endl;;

    for (int iib = 0; iib < n_b; iib++) {
        std::string line_b_element;
        std::getline(infile, line_b_element);
        std::istringstream iss_b_element(line_b_element);

        double b_element = 0;
        iss_b_element >> b_element;
        b.push_back(b_element);
    }

    // Inicializiramo vektor resitve T
    vector<double> T(n_b, 100.0);

    // Zaènemo merjenje èasa
    auto start_time = std::chrono::high_resolution_clock::now();

    // Implementacija Gauss-Seidel brez paralelizacije
    for (int iter = 0; iter < 2000; iter++) {
        for (int jj = 0; jj < n; jj++) {
            double sum = b[jj];
            for (int ii = 0; ii < n; ii++) {
                if (ii != jj) {
                    sum -= A[jj][ii] * T[ii];
                }
            }
            T[jj] = sum / A[jj][jj];
        }
    }

    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> time_duration = end_time - start_time;

    std::cout << "Èas izvajanja Gauss-Seidel metode (brez OpenMP): " << time_duration.count() << " sekund" << std::endl;

    // Izraèun maksimalne vrednosti vektorja T
    double max_T = *std::max_element(T.begin(), T.end());
    std::cout << "Maksimalna temperatura: " << max_T << " °C" << std::endl;
    // Implementacija Gauss-Seidel z paralelizacijo in uporabo OpenMp
    // Paralelizacije je mogoèa, kljub temu da se temperatura izraèuna iterativno na podlagi trenutnega stanja raširjene matrike A_b,
    // èe jo izvedemo po vrsticah, torej v našem primeru je izvedena na zunanji for zanki kode. Tako vsaka nit obdeluje svojo vrstico 
    // prej omenjene matrike, kar rezultira v krajšem èasu izvajanja kode  
 
    omp_set_num_threads(8); // Eksplicitno nastavljanje števila niti za paralelizacijo na 8

    // Resetiramo vektor T
    std::fill(T.begin(), T.end(), 100.0);

    // Ponovno merjenje èasa za paralelizirano metodo
    start_time = std::chrono::high_resolution_clock::now();

    // Implementacija Gauss-Seidel metode z OpenMP
    for (int iter = 0; iter < 2000; iter++) {
#pragma omp parallel for
        for (int jj = 0; jj < n; jj++) {
            double sum = b[jj];
            for (int ii = 0; ii < n; ii++) {
                if (ii != jj) {
                    sum -= A[jj][ii] * T[ii];
                }
            }
            T[jj] = sum / A[jj][jj];
        }
    }

    end_time = std::chrono::high_resolution_clock::now();
    time_duration = end_time - start_time;

    std::cout << "Èas izvajanja Gauss-Seidel metode (z OpenMP): " << time_duration.count() << " sekund" << std::endl;

    // Izraèun maksimalne vrednosti vektorja T po paralelizirani metodi
    max_T = *std::max_element(T.begin(), T.end());
    std::cout << "Maksimalna temperatura (z OpenMP): " << max_T << " °C" << std::endl;

    return 0;
}
