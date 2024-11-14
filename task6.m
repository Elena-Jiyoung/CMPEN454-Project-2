% Load the images
im1 = imread("im1corrected.jpg");
im2 = imread("im2corrected.jpg");

figure, imshow(im1);
title('Select points in Image 1, then press Enter');
[x1, y1] = getpts;
pts1 = [x1, y1];

figure, imshow(im2);
title('Select corresponding points in Image 2, then press Enter');
[x2, y2] = getpts;
pts2 = [x2, y2];

eightpoint_with_hartley(im1, im2, pts1, pts2, 1, 2);
eightpoint_without_hartley(im1, im2, pts1, pts2, 3, 4);


% First, Compute F using eightpoint algorithm with Hartley
% preconditioning(normalization) as shown in the demo code.
function [F_normalized, pts1, pts2] = eightpoint_with_hartley(im1, im2, pts1, pts2, fig1, fig2)

    %do Hartley preconditioning
    % Extract x and y coordinates
    x1 = pts1(:, 1);
    y1 = pts1(:, 2);
    x2 = pts2(:, 1);
    y2 = pts2(:, 2);
    mux = mean(x1);
    muy = mean(y1);
    stdxy = (std(x1)+std(y1))/2;
    T1 = [1 0 -mux; 0 1 -muy; 0 0 stdxy]/stdxy;
    nx1 = (x1-mux)/stdxy;
    ny1 = (y1-muy)/stdxy;
    mux = mean(x2);
    muy = mean(y2);
    stdxy = (std(x2)+std(y2))/2;
    T2 = [1 0 -mux; 0 1 -muy; 0 0 stdxy]/stdxy;
    nx2 = (x2-mux)/stdxy;
    ny2 = (y2-muy)/stdxy;
    A = [];
    for i=1:length(nx1)
       A(i,:) = [nx1(i)*nx2(i) nx1(i)*ny2(i) nx1(i) ny1(i)*nx2(i) ny1(i)*ny2(i) ny1(i) nx2(i) ny2(i) 1];
    end
    %get eigenvector associated with smallest eigenvalue of A' * A
    [u,d] = eigs(A' * A,1,'SM');
    F = reshape(u,3,3);
    %make F rank 2
    oldF = F;
    [U,D,V] = svd(F);
    D(3,3) = 0;
    F = U * D * V';
    F_normalized = T2' * F * T1;
    disp("Fundamental matrix F from Hartley preconditioning is: ");
    disp(F_normalized);
    
    % Draw epipolar lines for sanity check
    sanity_check(im1, im2, F_normalized, pts1, pts2, fig1, fig2);
end


% Eight-point algorithm without Hartley preconditioning
function [F, pts1, pts2] = eightpoint_without_hartley(im1, im2, pts1, pts2, fig1, fig2)
    x1 = pts1(:, 1);
    y1 = pts1(:, 2);
    x2 = pts2(:, 1);
    y2 = pts2(:, 2);
    A = [];
    for i=1:length(x1)
       A(i,:) = [x1(i)*x2(i) x1(i)*y2(i) x1(i) y1(i)*x2(i) y1(i)*y2(i) y1(i) x2(i) y2(i) 1];
    end
    %get eigenvector associated with smallest eigenvalue of A' * A
    [u,d] = eigs(A' * A,1,'SM');
    F = reshape(u,3,3);
    %make F rank 2
    oldF = F;
    [U,D,V] = svd(F);
    D(3,3) = 0;
    F = U * D * V';
    
    disp("Fundamental matrix F without Hartley preconditioning is: ");
    disp(F);
    
    sanity_check(im1, im2, F, pts1, pts2, fig1, fig2);
end

function sanity_check(im1, im2, F, pts1, pts2, fig1, fig2)
    % Draw epipolar lines in Image 1 for points from Image 2
    figure(fig1); imagesc(im1); axis image; hold on;
    for i = 1:size(pts1, 1)
        plot(pts1(i, 1), pts1(i, 2), 'og', 'MarkerSize', 8, 'LineWidth', 2); % Display points in green
        text(pts1(i, 1), pts1(i, 2), sprintf('%d', i), 'Color', 'g', 'FontSize', 8); % Label points
    end
    hold off;

    % Draw epipolar lines in Image 2 for points from Image 1
    figure(fig2); imagesc(im2); axis image; hold on;
    for i = 1:size(pts2, 1)
        plot(pts2(i, 1), pts2(i, 2), 'og', 'MarkerSize', 8, 'LineWidth', 2); % Display points in green
        text(pts2(i, 1), pts2(i, 2), sprintf('%d', i), 'Color', 'g', 'FontSize', 8); % Label points
    end
    hold off;
    overlay_epipolar_lines(F, pts1, im2, fig2);
    overlay_epipolar_lines(F', pts2, im1, fig1);
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