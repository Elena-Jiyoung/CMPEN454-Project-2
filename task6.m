% First, Compute F using eightpoint algorithm with Hartley
% preconditioning(normalization) as shown in the demo code.
function [F_normalized, pts1, pts2] = eightpoint_with_Hartley(im1, im2)
    % Load and display images
    figure, imshow(im1);
    title('Select points in Image 1, then press Enter');
    [x1, y1] = getpts;
    pts1 = [x1, y1];
    
    figure, imshow(im2);
    title('Select corresponding points in Image 2, then press Enter');
    [x2, y2] = getpts;
    pts2 = [x2, y2];
    
    % Call the eight-point algorithm demo function with normalization
    [F_normalized, pts1, pts2] = eightpoint_democodes(im1, im2, pts1, pts2);
    
    % Display epipolar lines for sanity check
    sanity_check_epipolar_lines(im1, im2, F_normalized, pts1, pts2);
end

function F = eightpoint_democodes(im1, im2, pts1, pts2)
    % Extract x and y coordinates
    x1 = pts1(:, 1);
    y1 = pts1(:, 2);
    x2 = pts2(:, 1);
    y2 = pts2(:, 2);

    % Calculate normalization matrices T1 and T2 for Hartley preconditioning
    mux = mean(x1);
    muy = mean(y1);
    stdxy = (std(x1) + std(y1)) / 2;
    T1 = [1 0 -mux; 0 1 -muy; 0 0 stdxy] / stdxy;
    nx1 = (x1 - mux) / stdxy;
    ny1 = (y1 - muy) / stdxy;

    mux = mean(x2);
    muy = mean(y2);
    stdxy = (std(x2) + std(y2)) / 2;
    T2 = [1 0 -mux; 0 1 -muy; 0 0 stdxy] / stdxy;
    nx2 = (x2 - mux) / stdxy;
    ny2 = (y2 - muy) / stdxy;

    % Construct matrix A based on normalized points
    A = [];
    for i = 1:length(nx1)
        A(i,:) = [nx1(i) * nx2(i), nx1(i) * ny2(i), nx1(i), ny1(i) * nx2(i), ny1(i) * ny2(i), ny1(i), nx2(i), ny2(i), 1];
    end

    % Get eigenvector associated with smallest eigenvalue of A' * A
    [u,d] = eigs(A' * A,1,'SM');
    F = reshape(u,3,3);
    

    % Make F rank 2
    [U, D, V] = svd(F);
    D(3, 3) = 0;
    F = U * D * V';
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

function [F_normalized, pts1, pts2] = eightpoint_with_Hartley(im1, im2)