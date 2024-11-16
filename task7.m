F = load("Fmatrix.mat").F; %importing F matrix from task 5
F_with_hartley = load("F_with_Hartley.mat").F_with_hartley; % importing F from task 6 Hartley Preconditioning
F_without_hartley = load("F_without_Hartley.mat").F_without_hartley; % importing F from task 6 without Hartley Preconditioning

function calculateSED(F)
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
        SED_numerator1 = (epipolar_line1(1) * point2(1) + epipolar_line1(2) * point2(2) + epipolar_line1(3))^2;
        SED_denominator1 = (epipolar_line1(1)^2 + epipolar_line1(2)^2);
        SED1 = SED_numerator1 / SED_denominator1;
    
        epipolar_line2 = F' * point2;
        SED_numerator2 = (epipolar_line2(1) * point1(1) + epipolar_line2(2) * point1(2) + epipolar_line2(3))^2;
        SED_denominator2 = (epipolar_line2(1)^2 + epipolar_line2(2)^2);
        SED2 = SED_numerator2 / SED_denominator2;
        
        sum1 = sum1 + SED1;
        sum2 = sum2 + SED2;
        fprintf("\nIteration %d: \nLine 1 error: %.30f\nLine 2 error: %.30f\n\n", i, SED1, SED2);
    end
    
    fprintf("\nMean of SED1: %.30f \nMean of SED2: %.30f", sum1/39, sum2/39);
end

calculateSED(F);
disp("Calculate using F from task 6 with Hartley Preconditioning: ")
calculateSED(F_with_hartley);
disp("Calculate using F from task 6 without Hartley Preconditioning: ")
calculateSED(F_without_hartley);