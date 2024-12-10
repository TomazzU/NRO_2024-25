% Nalaganje datotek
vozlisca_file = 'vozlisca_temperatura_dn2.txt';  % Datoteka za vozlišča
celice_file = 'celice_dn2.txt';                % Datoteka za celice

% Preberi datoteko vozlisca temperature
fid = fopen(vozlisca_file, 'r');  % Poskus odpreti datoteko
header = fgetl(fid); % Prva vrstica (definicija stolpcev)
nx = str2double(fgetl(fid)); % Število koordinat v x-smeri
ny = str2double(fgetl(fid)); % Število koordinat v y-smeri
n_vozlisca = str2double(fgetl(fid)); % Število vseh vozlišč
data = fscanf(fid, '%f, %f, %f', [3, n_vozlisca])'; % Branje podatkov
fclose(fid);

x = data(:, 1); % x-koordinate
y = data(:, 2); % y-koordinate
T = data(:, 3); % Temperature

% Preveri dolžine x, y, T
disp(['Dolžina x: ', num2str(length(x))]);
disp(['Dolžina y: ', num2str(length(y))]);
disp(['Dolžina T: ', num2str(length(T))]);

% Preveri, če so dolžine enake
if length(x) ~= length(y) || length(y) ~= length(T)
    error('Napaka: Dolžine x, y in T niso enake.');
end

% Preberi datoteko celice
fid = fopen(celice_file, 'r');
celice_name = fgetl(fid); % Ime celic
n_celice = str2double(fgetl(fid)); % Število celic
celice = fscanf(fid, '%d', [4, n_celice])'; % Branje podatkov
fclose(fid);

% Koordinata, kjer iščemo temperaturo
query_point = [0.403, 0.503];

%% Metoda 1: scatteredInterpolant
tic;
F_scattered = scatteredInterpolant(x, y, T, 'linear', 'none');
T_scattered = F_scattered(query_point(1), query_point(2));
time_scattered = toc;

%% Metoda 2: griddedInterpolant
tic;
x_unique = linspace(min(x), max(x), nx);
y_unique = linspace(min(y), max(y), ny);
[X_grid, Y_grid] = meshgrid(x_unique, y_unique);

% Preoblikuj podatke
T_grid = griddata(x, y, T, X_grid, Y_grid, 'linear');
F_gridded = griddedInterpolant(X_grid, Y_grid, T_grid, 'linear');
T_gridded = F_gridded(query_point(1), query_point(2));
time_gridded = toc;

%% Metoda 3: Lastna bilinearna interpolacija
tic;
% Poiščemo celico, kjer se nahaja točka
for i = 1:size(celice, 1)
    % Koordinate točk celice
    ids = celice(i, :);
    x_cell = x(ids);
    y_cell = y(ids);
    T_cell = T(ids);

    % Ali je točka znotraj celice (preveri s koordinatami)
    if query_point(1) >= min(x_cell) && query_point(1) <= max(x_cell) && ...
       query_point(2) >= min(y_cell) && query_point(2) <= max(y_cell)
        % Koordinate celice
        xmin = min(x_cell); xmax = max(x_cell);
        ymin = min(y_cell); ymax = max(y_cell);

        % Izračun bilinearne interpolacije
        K1 = (xmax - query_point(1)) / (xmax - xmin) * T_cell(1) + ...
             (query_point(1) - xmin) / (xmax - xmin) * T_cell(2);
        K2 = (xmax - query_point(1)) / (xmax - xmin) * T_cell(4) + ...
             (query_point(1) - xmin) / (xmax - xmin) * T_cell(3);
        T_bilinear = (ymax - query_point(2)) / (ymax - ymin) * K1 + ...
                     (query_point(2) - ymin) / (ymax - ymin) * K2;
        break;
    end
end
time_bilinear = toc;

%% Najbližji sosed
[~, idx_nearest] = min(sqrt((x - query_point(1)).^2 + (y - query_point(2)).^2));
T_nearest = T(idx_nearest);

%% Izpis rezultatov
fprintf('Temperatura z metodo scatteredInterpolant: %.4f (čas: %.4f s)\n', T_scattered, time_scattered);
fprintf('Temperatura z metodo griddedInterpolant: %.4f (čas: %.4f s)\n', T_gridded, time_gridded);
fprintf('Temperatura z lastno metodo: %.4f (čas: %.4f s)\n', T_bilinear, time_bilinear);
fprintf('Temperatura z metodo najbližjega soseda: %.4f\n', T_nearest);

% Največja temperatura
[max_temp, idx_max] = max(T);
fprintf('Največja temperatura: %.4f pri koordinatah (%.4f, %.4f)\n', ...
    max_temp, x(idx_max), y(idx_max));
