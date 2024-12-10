% Datoteke
datotekaVozlisca = 'vozlisca_temperature_dn2.txt';
datotekaCelice = 'celice_dn2.txt';

% Branje datoteke vozlisca temperature
fid = fopen(datotekaVozlisca, 'r');
glava = fgetl(fid); % Prva vrstica (ime stolpcev)
stX = str2double(extractAfter(fgetl(fid), ':')); % Število koordinat v x-smeri
stY = str2double(extractAfter(fgetl(fid), ':')); % Število koordinat v y-smeri
stVozlisc = str2double(extractAfter(fgetl(fid), ':')); % Število vseh vozlišč
podatki = fscanf(fid, '%f,%f,%f', [3, stVozlisc])';
fclose(fid);

% Ekstrakcija podatkov
koordinateX = podatki(:, 1);
koordinateY = podatki(:, 2);
temperature = podatki(:, 3);

% Branje datoteke celice
fid = fopen(datotekaCelice, 'r');
fgetl(fid); % Prva vrstica (ime stolpcev)
stCelic = str2double(extractAfter(fgetl(fid), ':')); % Število celic
podatkiCelice = fscanf(fid, '%d,%d,%d,%d', [4, stCelic])';
fclose(fid);

% Točka T(0.403, 0.503)
ciljnaTockaX = 0.403;
ciljnaTockaY = 0.503;

%% 1. Interpolacija z "scatteredInterpolant"
tic;
F_razprsen = scatteredInterpolant(koordinateX, koordinateY, temperature, 'linear', 'none');
temp_razprsen = F_razprsen(ciljnaTockaX, ciljnaTockaY);
casRazprsen = toc;

%% 2. Interpolacija z "griddedInterpolant"
tic;
% Pretvorba podatkov v mrežo
[mrezaX, mrezaY] = meshgrid(unique(koordinateX), unique(koordinateY));
mrezaZ = griddata(koordinateX, koordinateY, temperature, mrezaX, mrezaY); % Temperaturna matrika
% Pretvorba v NDGRID format
mrezaX = mrezaX'; mrezaY = mrezaY'; mrezaZ = mrezaZ'; % Transponiranje za NDGRID
F_mrezni = griddedInterpolant(mrezaX, mrezaY, mrezaZ, 'linear', 'none');
temp_mrezni = F_mrezni(ciljnaTockaX, ciljnaTockaY);
casMrezni = toc;

%% 3. Lastna bilinearna interpolacija
tic;
% Najdi celico, v kateri je točka
for i = 1:size(podatkiCelice, 1)
    ids = podatkiCelice(i, :);
    xCelice = koordinateX(ids);
    yCelice = koordinateY(ids);
    if inpolygon(ciljnaTockaX, ciljnaTockaY, xCelice, yCelice)
        % Pridobi temperaturne vrednosti
        T11 = temperature(ids(1));
        T21 = temperature(ids(2));
        T22 = temperature(ids(3));
        T12 = temperature(ids(4));
        % Koordinate celice
        xmin = min(xCelice);
        xmax = max(xCelice);
        ymin = min(yCelice);
        ymax = max(yCelice);
        % Bilinearna interpolacija
        K1 = ((xmax - ciljnaTockaX) / (xmax - xmin)) * T11 + ((ciljnaTockaX - xmin) / (xmax - xmin)) * T21;
        K2 = ((xmax - ciljnaTockaX) / (xmax - xmin)) * T12 + ((ciljnaTockaX - xmin) / (xmax - xmin)) * T22;
        tempBilinearna = ((ymax - ciljnaTockaY) / (ymax - ymin)) * K1 + ((ciljnaTockaY - ymin) / (ymax - ymin)) * K2;
        break;
    end
end
casBilinearna = toc;

%% Izračun največje temperature in pripadajočih koordinat
[najTemp, idxNajTemp] = max(temperature);
najX = koordinateX(idxNajTemp);
najY = koordinateY(idxNajTemp);

%% Izpis rezultatov
fprintf('Temperatura v točki (%.3f, %.3f):\n', ciljnaTockaX, ciljnaTockaY);
fprintf('- Razpršena interpolacija: %.3f (čas: %.6f s)\n', temp_razprsen, casRazprsen);
fprintf('- Mrežna interpolacija: %.3f (čas: %.6f s)\n', temp_mrezni, casMrezni);
fprintf('- Bilinearna interpolacija: %.3f (čas: %.6f s)\n', tempBilinearna, casBilinearna);

fprintf('\nNajvečja temperatura: %.3f\n', najTemp);
fprintf('Koordinate največje temperature: (%.3f, %.3f)\n', najX, najY);
