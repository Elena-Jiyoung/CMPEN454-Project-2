paramV1 = load("Parameters_V1_1.mat").Parameters;
paramV2 = load("Parameters_V2_1.mat").Parameters;
pixel_points1 = load("pixel_points1.mat").pixel_points1;
pixel_points2 = load("pixel_points2.mat").pixel_points2;
mocap = load("mocapPoints3D.mat").pts3D;

% Initialize arrays containing direction vectors for each point
directions1 = zeros(3, 39);
directions2 = zeros(3, 39);

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

points = zeros(3, 39);

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
    
    fprintf("Iteration %d - Error %.30f\n", i, c);
    % Point is the midpoint of the two found points
    point = ((camera1 + a * P_l) + (camera2 + b * P_r)) / 2;
    points(:, i) = point;
end
    
% Calculate mean square error
MSE = (sum((points - mocap).^2, "all")) / length(pixel_points1);
fprintf("\nMean Square Error: %.30f\n", MSE);