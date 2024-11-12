paramV1 = load("Parameters_V1_1.mat").Parameters;
paramV2 = load("Parameters_V2_1.mat").Parameters;

pixel_points1 = [1205, 1379, 1897; 302, 156, 590];
pixel_points2 = [313, 521, 960; 223, 74, 431];

% Initialize arrays containing direction vectors for each point
directions1 = zeros(3, 3);
directions2 = zeros(3, 3);

% Extract the matrices we need for caluculations
R1 = paramV1.Rmat;
R1_T = transpose(R1);
T1 = paramV1.Pmat(1:3, 4);
K1 = paramV1.Kmat;

R2 = paramV2.Rmat;
R2_T = transpose(R2);
T2 = paramV2.Pmat(1:3, 4);
K2 = paramV2.Kmat;

% Camera positions (defined on slide 26 in Traingulation slides)
camera1 = -R1_T * T1;
camera2 = -R2_T * T2;

% Compute the direction vectors (slide 26)
for i = 1:length(pixel_points1)
    pt2d = pixel_points1(:, i);
    pt2d(3) = 1;

    directions1(:, i) = R1_T * (K1 \ pt2d);
end

for i = 1:length(pixel_points2)
    pt2d = pixel_points2(:, i);
    pt2d(3) = 1;

    directions2(:, i) = R2_T * (K2 \ pt2d);
end

% Solve for a, b, and c scalers 
% Variable names mirror slide 31 of Triangulation slides

points = zeros(3, 3);

for i = 1:length(pixel_points1)
    P_l = directions1(:, i);
    P_r = directions2(:, i);
    w = cross(P_l, P_r);
    T = camera2 - camera1;

    % Create coefficient matrix
    coefficients = [P_l, -P_r, w];
    % Solve for a, b, and c
    solution = coefficients \ T;

    a = solution(1);
    b = solution(2);
    c = solution(3);
    
    disp(["Iteration ", i, " error: ", c]);
    % Point is the midpoint of the two found points
    point = ((camera1 + a * P_l) + (camera2 + b * P_r)) / 2;
    points(:, i) = point;
end

disp(points);
    
% Define the three points
P1 = points(:, 1);
P2 = points(:, 2);
P3 = points(:, 3);

% Calculate two vectors in the plane
v1 = P2 - P1;
v2 = P3 - P1;

% Compute the normal vector to the plane using the cross product
normal = cross(v1, v2);
a = normal(1);
b = normal(2);
c = normal(3);

% Calculate d using point P1
d = -(a * P1(1) + b * P1(2) + c * P1(3));

% Display the plane equation coefficients
fprintf('Plane equation: %.2fx + %.2fy + %.2fz + %.2f = 0\n', a, b, c, d);

check_P1 = a * P1(1) + b * P1(2) + c * P1(3) + d;
check_P2 = a * P2(1) + b * P2(2) + c * P2(3) + d;
check_P3 = a * P3(1) + b * P3(2) + c * P3(3) + d;

fprintf('Check for P1: %.12f\n', check_P1);
fprintf('Check for P2: %.12f\n', check_P2);
fprintf('Check for P3: %.12f\n', check_P3);