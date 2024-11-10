% Same code as task2.m, but points are loaded from task3 instead of
% mocapPoints3D.mat

triangulated_points = load("task3_points.mat").points;
paramV1 = load("Parameters_V1_1.mat").Parameters;
paramV2 = load("Parameters_V2_1.mat").Parameters;

% Import P and K matricies for image 1 and image 2 respectively
Pmat1 = paramV1.Pmat;
Kmat1 = paramV1.Kmat;

Pmat2 = paramV2.Pmat;
Kmat2 = paramV2.Kmat;

% Initialize matrices containing the converted pixel coordinates
pixel_points1 = zeros(2,39);
pixel_points2 = zeros(2,39);


for i = 1:length(triangulated_points)
    pt3d = triangulated_points(:, i);
    pt3d(4) = 1; % Make point homogeneous

    pt2d = Pmat1 * pt3d;
    pt2d = pt2d / pt2d(3); % Normalize by scalar

    pixel2d = Kmat1 * pt2d;
    pixel2d = pixel2d / pixel2d(3); % Normalize by scalar
    
    pixel_points1(:, i) = pixel2d(1:2); % Add 2d point to matrix
end

for i = 1:length(triangulated_points)
    pt3d = triangulated_points(:, i);
    pt3d(4) = 1; % Make point homogeneous

    pt2d = Pmat2 * pt3d;
    pt2d = pt2d / pt2d(3); % Normalize by scalar

    pixel2d = Kmat2 * pt2d;
    pixel2d = pixel2d / pixel2d(3); % Normalize by scalar
    
    pixel_points2(:, i) = pixel2d(1:2); % Add 2d point to matrix
end

% Display image 1 with converted pixel points
figure;
img1 = imread('im1corrected.jpg');
imshow(img1);
hold on;
plot(pixel_points1(1, :), pixel_points1(2, :), 'r.', 'MarkerSize', 10);
hold off;

% Display image 2 with converted pixel points
figure;
img2 = imread('im2corrected.jpg');
imshow(img2);
hold on;
plot(pixel_points2(1, :), pixel_points2(2, :), 'r.', 'MarkerSize', 10);
hold off;
