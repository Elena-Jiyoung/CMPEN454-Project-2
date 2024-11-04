function [K1, K2, P1, P2] = task1()
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
    focal_length1 = paramsV1.Parameters.foclen;
    focal_length2 = paramsV2.Parameters.foclen;
    

    %Internal scaling parameters that make up Kmat 
    inv_S_X1 = K1(1,1) / focal_length1;
    inv_S_Y1 = K1(2,2) / focal_length1;

    inv_S_X2 = K2(1,1) / focal_length2;
    inv_S_Y2 = K2(2,2) / focal_length2;
    
    O_x1 = K1(1,3);
    O_x2 = K2(1,3);
    O_y1 = K1(2,3);
    O_y2 = K2(2,3);
    film_coords_to_pixels1 = [inv_S_X1 0 O_x1; 0 inv_S_Y1 O_y1; 0 0 1]; 
    film_coords_to_pixels2 = [inv_S_X2 0 O_x2; 0 inv_S_Y2 O_y2; 0 0 1];
    project_camera_coords_to_film1 = [focal_length1 0 0 0 ; 0 focal_length1 0 0; 0 0 1 0];
    project_camera_coords_to_film2 = [focal_length2 0 0 0 ; 0 focal_length2 0 0; 0 0 1 0];
    disp('Internal Parameters:');
    disp('Camera 1:');
    disp('1. Film Coords to Pixels matrix:');
    disp(film_coords_to_pixels1);
    disp('2. Project Camera Coords to Film:');
    disp(project_camera_coords_to_film1);

    disp('Internal Parameters:');
    disp('Camera 2:');
    disp('1. Film Coords to Pixels matrix:');
    disp(film_coords_to_pixels2);
    disp('2. Project Camera Coords to Film:');
    disp(project_camera_coords_to_film2);

    disp('Verify Kmat CAM 1 = Film Coords to Pixels matrix * Project Camera Coords to Film');
    disp(film_coords_to_pixels1 * project_camera_coords_to_film1);
    disp('K1');
    disp(K1);

    disp('Verify Kmat CAM 2 = Film Coords to Pixels matrix * Project Camera Coords to Film');
    disp(film_coords_to_pixels2 * project_camera_coords_to_film2);
    disp('K2');
    disp(K2);

    disp('Camera 1 position')
    disp(paramsV1.Parameters.position)
    
    neg_c_u1 = paramsV1.Parameters.position(1, 1) * -1;
    neg_c_v1 = paramsV1.Parameters.position(1, 2) * -1;
    neg_c_w1 = paramsV1.Parameters.position(1, 3) * -1;
    
    disp('Camera 2 position')
    disp(paramsV2.Parameters.position)

    neg_c_u2 = paramsV2.Parameters.position(1, 1) * -1;
    neg_c_v2 = paramsV2.Parameters.position(1, 2) * -1;
    neg_c_w2 = paramsV2.Parameters.position(1, 3) * -1;

    disp('External Parameters:');
    disp('Camera 1:');

    external1_w2c1 = [R1 zeros(3,1); zeros(1,3) 1];
    disp('1. First matrix of external paramater: external1_w2c1')
    disp(external1_w2c1);

    external2_w2c1 = [1 0 0 neg_c_u1; 0 1 0 neg_c_v1; 0 0 1 neg_c_w1; 0 0 0 1];
    disp('2. Second matrix of external paramater: external2_w2c1')
    disp(external2_w2c1);

    disp('External Parameters:');
    disp('Camera 2:');

    external1_w2c2 = [R2 zeros(3,1); zeros(1,3) 1];
    disp('1. First matrix of external paramater: external1_w2c2')
    disp(external1_w2c2);

    external2_w2c2 = [1 0 0 neg_c_u2; 0 1 0 neg_c_v2; 0 0 1 neg_c_w2; 0 0 0 1];
    disp('2. Second matrix of external paramater: external2_w2c2')
    disp(external2_w2c2);

    disp('Verify P1 = external1_w2c1 * external2_w2c1');
    disp(external1_w2c1 * external2_w2c1);
    disp(P1);

    disp('Verify P2 = external1_w2c2 * external2_w2c2');
    disp(external1_w2c2 * external2_w2c2);
    disp(P2);
    
    
    % disp('Projection matrix for camera 1:');
    % disp(P1);
    % disp('Projection matrix for camera 2:');
    % disp(P2);
end

