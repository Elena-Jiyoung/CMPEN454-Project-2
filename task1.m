function [P1, P2] = task1()
%TASK1 
    paramsV1= load('Parameters_V1_1.mat');
    paramsV2= load('Parameters_V2_1.mat');
    
    %Extract intrinsic and extrinsic parameters
    K1 = paramsV1.Parameters.Kmat; % Intrinsic matrix
    K2 = paramsV2.Parameters.Kmat;
    R1 = paramsV1.Parameters.Rmat; % Rotation matrix
    R2 = paramsV2.Parameters.Rmat;
    P1 = paramsV1.Parameters.Pmat;
    P2 = paramsV2.Parameters.Pmat;
    % Compute K^-1 * P to isolate the extrinsic part [R | -R * t]
    KRt1 = K1 \ P1; % Equivalent to inv(Kmat) * Pmat
    KRt2 = K2 \ P2; % Equivalent to inv(Kmat) * Pmat
    % Extract -R * t from the last column of KRt
    Rt_column1 = KRt1(:, 4);
    Rt_column2 = KRt2(:, 4);
    % Calculate t by inverting -R
    t_extracted1 = -R1' * Rt_column1;
    t_extracted2 = -R2' * Rt_column2;
    % Display the extracted translation vector
    disp('Extracted Translation Vector t:');
    disp(t_extracted1);
    disp(t_extracted2);
    disp('Projection matrix for camera 1:');
    disp(P1);
    disp('Projection matrix for camera 2:');
    disp(P2);
end

