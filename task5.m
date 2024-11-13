R_cam1_wrt_world = load("Parameters_V1_1.mat").Parameters.Rmat;
R_cam2_wrt_world = load("Parameters_V2_1.mat").Parameters.Rmat;
location_cam1 = load("Parameters_V1_1.mat").Parameters.position;
location_cam2 = load("Parameters_V2_1.mat").Parameters.position;
K_cam1 = load("Parameters_V1_1.mat").Parameters.Kmat;
K_cam2 = load("Parameters_V2_1.mat").Parameters.Kmat;

% 1) Solve for what the location of camera2 is with respect to the coordinate system of camera1 (or vice versa)
c2_minus_c1 = location_cam2 - location_cam1;
% Reshape c2_minus_c1 into a 3x1 column vector
c2_minus_c1 = c2_minus_c1';  % Transpose to make it a 3x1 column vector
% [Tx Ty Tz](as a 3x1 column) = R1 * (loc_c2 - loc_c1)
T_xyz = R_cam1_wrt_world * c2_minus_c1;
T_x = T_xyz(1,1);
T_y = T_xyz(2,1);
T_z = T_xyz(3,1);
% Construct S
S = [0 -T_z T_y; T_z 0 -T_x; -T_y T_x 0;];
disp("S:");
disp(S);
% 2) Solve for the relative rotation between them
R = R_cam2_wrt_world * R_cam1_wrt_world';
disp("R:");
disp(R);

% 3) Compute E = RS
E = R*S;
disp("E:");
disp(E);

% 4) Multiply E by appropriate Kmat to make into F matrix: 
% F = K2^(-T)*E*K1^(-1) from the lecture 17 slide page 20
F = inv(K_cam2)' * E * inv(K_cam1);
disp("Fundamental Matrix F:");
disp(F);

% Load the images
im1 = imread("im1corrected.jpg");
im2 = imread("im2corrected.jpg");


% Select points in im1 and im2 for sanity check
% Select points in Image 1
figure, imshow(im1);
title('Click to select points in Image 1, then press Enter');
[x1, y1] = getpts;
pts1 = [x1, y1];

% Select corresponding points in Image 2
figure, imshow(im2);
title('Click to select corresponding points in Image 2, then press Enter');
[x2, y2] = getpts;
pts2 = [x2, y2];

% Perform Sanity check

sanity_check_epipolar_lines(im1, im2, F, pts1, pts2);

% Sanity Check functions
function sanity_check_epipolar_lines(im1, im2, F, pts1, pts2)
    % Sanity check for the fundamental matrix F by plotting epipolar lines

    % Display epipolar lines in Image 2 for points from Image 1
    figure(1); imagesc(im1); axis image; hold on;
    plot(pts1(:,1), pts1(:,2), 'ro', 'MarkerSize', 5, 'LineWidth', 1.5);
    title('Image 1 with points');
    
    % Display epipolar lines in Image 2
    figure(2); imagesc(im2); axis image; hold on;
    plot(pts2(:,1), pts2(:,2), 'go', 'MarkerSize', 5, 'LineWidth', 1.5);
    title('Image 2 with corresponding epipolar lines');
    draw_epipolar_lines(F, pts1, im2, 2);
    
    % Display epipolar lines in Image 1 for points from Image 2
    figure(1); hold on;
    draw_epipolar_lines(F', pts2, im1, 1);
    hold off;
end

function draw_epipolar_lines(F, pts, img, figNum)
    % Helper function to draw epipolar lines given F, points, and figure
    colors = 'bgrcmyk';
    L = F * [pts(:, 1)'; pts(:, 2)'; ones(1, size(pts, 1))]; % Epipolar lines
    
    % Get image dimensions
    [nr, nc, ~] = size(img);
    figure(figNum); hold on;
    
    for i = 1:size(L, 2)
        a = L(1, i); b = L(2, i); c = L(3, i);
        
        % Determine if the line is more vertical or horizontal
        if abs(a) > abs(b)
            ylo = 1; yhi = nr;
            xlo = (-b * ylo - c) / a;
            xhi = (-b * yhi - c) / a;
            plot([xlo, xhi], [ylo, yhi], colors(mod(i, length(colors)) + 1), 'LineWidth', 1.5);
        else
            xlo = 1; xhi = nc;
            ylo = (-a * xlo - c) / b;
            yhi = (-a * xhi - c) / b;
            plot([xlo, xhi], [ylo, yhi], colors(mod(i, length(colors)) + 1), 'LineWidth', 1.5);
        end
    end
    hold off;
end

