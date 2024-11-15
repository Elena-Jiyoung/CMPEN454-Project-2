F = load("Fmatrix.mat").F; %importing F matrix from task 5
F_normalized = load("F_with_Hartley.mat").F_normalized; % importing F from task 6 Hartley Preconditioning
F_without_hartley = load("F_without_Hartley.mat").F_without_hartley; % importing F from task 6 without Hartley Preconditioning

% F normalized matrix:
% 1.27822472162297e-07	4.43925010447522e-08	-7.97293632020215e-05
%-1.89346911608591e-06	-3.20078232769076e-06	0.00202293370394392
% 0.000457527463997337	0.00277736044401169	-1.15218358263831

% F_without_hartley matrix:
% -1.41176525100667e-06	-5.09295256169469e-07	0.00120723619407356
% 2.99849065367248e-06	5.45316585463336e-06	-0.00343662763185998
% -0.000127571890209574	-0.00450941818639676	0.999983190360241
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
disp("Calculate using F from task 6 with Hartley Preconditioning: ")
calculateSGD(F_normalized);
disp("Calculate using F from task 6 without Hartley Preconditioning: ")
calculateSGD(F_without_hartley);