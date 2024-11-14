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
% 2) Solve for the relative rotation between them: R = R_2*R_1^T
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

%------------------Sanity Check Below----------------------------------------------------------------------------------

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
sanity_check(im1, im2, F, pts1, pts2);

% Sanity Check functions
function sanity_check(im1, im2, F, pts1, pts2)
    % Sanity check for F by plotting epipolar lines

    % Display epipolar lines in Image 2 for points from Image 1
    figure(1); imagesc(im1); axis image; drawnow;
    figure(2); imagesc(im2); axis image; drawnow;
    if nargin > 2
       x1 = pts1(:,1);
       y1 = pts1(:,2);
    else
       figure(1); imagesc(im1); axis image; drawnow;
       [x1,y1] = getpts;
    end
    figure(1); imagesc(im1); axis image; hold on
    for i=1:length(x1)
      h=plot(x1(i),y1(i),'*'); set(h,'Color','g','LineWidth',2);
      text(x1(i),y1(i),sprintf('%d',i));
    end
    hold off
    drawnow;

    % Display epipolar lines in Image 2
    if nargin > 3
       x2 = pts2(:,1);
       y2 = pts2(:,2);
    else
       figure(2); imagesc(im2); axis image; drawnow;
       [x2,y2] = getpts;
    end
    figure(2); imagesc(im2); axis image; hold on
    for i=1:length(x2)
      h=plot(x2(i),y2(i),'*'); set(h,'Color','g','LineWidth',2);
      text(x2(i),y2(i),sprintf('%d',i));
    end
    hold off
    drawnow;

    % Display epipolar lines in Image 2
    figure(2); imagesc(im2); axis image; hold on;
    plot(pts2(:,1), pts2(:,2), 'go', 'MarkerSize', 5, 'LineWidth', 1.5);
    title('Image 2 with corresponding epipolar lines');
    overlay_epipolar_lines(F, pts1, im2, 2);
  
    % Display epipolar lines in Image 1 for points from Image 2
    figure(1); hold on;
    title('Image 1 with epipolar lines');
    overlay_epipolar_lines(F', pts2, im1, 1);
    hold off;
end

function overlay_epipolar_lines(F, pts, img, figureNum)
    % generalized function to overlay epipolar lines given F, points, and figure
    colors = 'bgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk';
    L = F * [pts(:, 1)'; pts(:, 2)'; ones(1, size(pts, 1))]; %pts rows = number of points
    [nr, nc, ~] = size(img);
    figure(figureNum); imagesc(img); axis image;
    hold on; plot(pts(:, 1), pts(:, 2), '*r'); 

    
    for i = 1:size(L, 2) %number of columns in L(=number of epipolar lines)
        a = L(1, i); b = L(2, i); c = L(3, i);
        if abs(a) > abs(b)
            ylo=0; yhi = nr;
            xlo = (-b * ylo - c) / a;
            xhi = (-b * yhi - c) / a;
            h=plot([xlo; xhi],[ylo; yhi]);
            set(h,'Color',colors(i),'LineWidth',2);
            
        else
            xlo = 0; xhi = nc;
            ylo = (-a * xlo - c) / b;
            yhi = (-a * xhi - c) / b;
            h=plot([xlo; xhi],[ylo; yhi],'b');
            set(h,'Color',colors(i),'LineWidth',2);

        end
    end
    hold off;
end

