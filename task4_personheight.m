paramV1 = load("Parameters_V1_1.mat").Parameters;
paramV2 = load("Parameters_V2_1.mat").Parameters;

% pixel points for top of head
pixel_points1 = [591; 367];
pixel_points2 = [1107; 339];

% Initialize arrays containing direction vectors for each point
directions1 = zeros(3, 1);
directions2 = zeros(3, 1);

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
    pt2d = pixel_points1;
    pt2d(3) = 1;

    directions1= R1_T * (K1 \ pt2d);

    pt2d = pixel_points2;
    pt2d(3) = 1;

    directions2 = R2_T * (K2 \ pt2d);

% Solve for a, b, and c scalers 
% Variable names mirror slide 31 of Triangulation slides

points = zeros(3, 1);

P_l = directions1;
P_r = directions2;
w = cross(P_l, P_r);
T = camera2 - camera1;

% Create coefficient matrix
coefficients = [P_l, -P_r, w];
% Solve for a, b, and c
solution = coefficients \ T;

a = solution(1);
b = solution(2);
c = solution(3);
    
disp([" error: ", c]);
% Point is the midpoint of the two found points
point = ((camera1 + a * P_l) + (camera2 + b * P_r)) / 2;
points = point;


disp(points);

disp("the person is 1630 mm tall");
