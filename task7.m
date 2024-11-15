F = load("Fmatrix.mat").F; %importing F matrix from task 5
F_normalized = load("F_with_Hartley.mat").F_normalized; % importing F from task 6 Hartley Preconditioning
F_without_hartley = load("F_without_Hartley.mat").F_without_hartley; % importing F from task 6 without Hartley Preconditioning


function calculateSGD(F)
    % 39 2D points from task 3.2
    pixel_points1 = load("pixel_points1.mat").pixel_points1;
    pixel_points2 = load("pixel_points2.mat").pixel_points2;
    sum1 = 0;
    sum2 = 0;
    for i = 1:size(pixel_points1, 2)
        point1 = pixel_points1(:,i);
        point1(3) = 1;
    
        point2 = pixel_points2(:,i);
        point2(3) = 1;
        
        epipolar_line1 = F * point1;
        SGD_numerator1 = (epipolar_line1(1) * point2(1) + epipolar_line1(2) * point2(2) + epipolar_line1(3))^2;
        SGD_denominator1 = (epipolar_line1(1)^2 + epipolar_line1(2)^2);
        SGD1 = SGD_numerator1 / SGD_denominator1;
    
        epipolar_line2 = F' * point2;
        SGD_numerator2 = (epipolar_line2(1) * point1(1) + epipolar_line2(2) * point1(2) + epipolar_line2(3))^2;
        SGD_denominator2 = (epipolar_line2(1)^2 + epipolar_line2(2)^2);
        SGD2 = SGD_numerator2 / SGD_denominator2;
        
        sum1 = sum1 + SGD1;
        sum2 = sum2 + SGD2;
        fprintf("\nIteration %d: \nLine 1 error: %.30f\nLine 2 error: %.30f\n\n", i, SGD1, SGD2);
    end
    
    fprintf("\nMean of SGD1: %.30f \nMean of SGD2: %.30f", sum1/39, sum2/39);
end

calculateSGD(F);
calculateSGD(F_normalized);
calculateSGD(F_without_hartley);