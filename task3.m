paramV1 = load("Parameters_V1_1.mat").Parameters;
paramV2 = load("Parameters_V2_1.mat").Parameters;
pixel_points1 = load("pixel_points1.mat").pixel_points1;
pixel_points2 = load("pixel_points2.mat").pixel_points2;



test_point2d = pixel_points1(:, 1);
test_point2d(3) = 1;


R = paramV1.Rmat;
R_T = transpose(R);
T = paramV1.Pmat(1:3, 4);

K = paramV1.Kmat;

camera_position = - R_T * T;

direction_vector = R_T * (K \ test_point2d);
