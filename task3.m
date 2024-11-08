paramV1 = load("Parameters_V1_1.mat").Parameters;
paramV2 = load("Parameters_V2_1.mat").Parameters;
pixel_points1 = load("pixel_points1.mat");
pixel_points2 = load("pixel_points2.mat");

Pmat1 = paramV1.Pmat;
Kmat1 = paramV1.Kmat;
Rmat1 = Pmat1(1:3, 1:3);
Tmat1 = Pmat1(1:3, 4);

Pmat2 = paramV2.Pmat;
Kmat2 = paramV2.Kmat;
Rmat2 = Pmat2(1:3, 1:3);
Tmat2 = Pmat2(1:3, 4);

Pw_array1 = zeros(num_points, 3);
Pw_array2 = zeros(num_points, 3);

for i = 1:length(pixel_points1)
    Pm = pixel_points1(i, :)';
    P1 = -Rmat1' * Tmat1 + Rmat1' * Kmat1 \ Pm;
    Pw_array1(i, :) = Pw';
end

for i = 1:length(pixel_points2)
    Pm = pixel_points2(i, :)';
    P1 = -Rmat2' * Tmat2 + Rmat2' * Kmat2 \ Pm;
    Pw_array2(i, :) = Pw';
end