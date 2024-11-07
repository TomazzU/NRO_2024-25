% 1 naloga

        % Odpiranje datoteke za branje
        ime_dat_1 = fopen('naloga1_1.txt', 'r');
        
        % Preskočimo prvo vrstico (ime stolpca)
        fgets(ime_dat_1);
        
        % Preberi drugo vrstico, ki vsebuje število vrstic in podatkov na vrstico
        info_vrstica_1 = fgets(ime_dat_1);
        vrednosti_1 = sscanf(info_vrstica_1, 'stevilo preostalih vrstic: %d; stevilo podatkov v vrstici: %d');
        st_vrstic = vrednosti_1(1);
        st_stolpcev = vrednosti_1(2);
        
        % Preberi preostale podatke in jih shrani v vektor t
        t = fscanf(ime_dat_1, '%f', [st_stolpcev, st_vrstic]);
        
        % Zapri datoteko
        fclose(ime_dat_1);
        
        % Preoblikuj podatke v enodimenzionalni vektor
        t = t(:);

% 2 naloga
        
        % Odpiranje datoteke za branje
        ime_dat_2 = fopen('naloga1_2.txt', 'r');
        
        % Preberi prvo vrstico, ki vsebuje število vrednosti
        info_vrstica_2 = fgets(ime_dat_2);
        vrednosti_2 = sscanf(info_vrstica_2, 'stevilo_podatkov_P: %d');
        
        % Inicializiraj vektor P za shranjevanje podatkov
        P = zeros(vrednosti_2, 1);
        
        % Preberi vsako vrednost posebej z `for` zanko
        for i = 1:vrednosti_2
            P(i) = fscanf(ime_dat_2, '%f', 1);
        end
        
        % Zapri datoteko
        fclose(ime_dat_2);
        
        % Risanje grafa P(t)
        figure;
        plot(t, P, '-r', 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 3);
        xlabel('t[s]');
        ylabel('P[W]');
        title('graf P(t)');
        grid on;

% 3 naloga

        % Vektorja P(t) in t vzamemo iz prejšnjih nalog

        % Korak med zaporednimi točkami v `t`
        delta_t = t(2) - t(1);
        
        % Inicializacija spremenljivke za seštevek
        vrednost_integrala = 0;
        
        % Uporaba trapezne formule za izračun integrala z uporabo for zanke
        n = length(P);
        for i = 2:n
            % Vsota trapezov
            vrednost_integrala = vrednost_integrala + (P(i) + P(i-1)) * delta_t / 2;
        end
        
        % Primerjava z rezultatom funkcije trapz
        vrednost_integrala_trapz = trapz(t, P);
        
        % Prikaz rezultatov
        fprintf('Izračunana vrednost integrala z lastno trapezno metodo: %.5f\n', vrednost_integrala);
        fprintf('Vrednost integrala z uporabo trapz: %.5f\n', vrednost_integrala_trapz);


        