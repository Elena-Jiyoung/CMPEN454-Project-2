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

im1 = imread("im1corrected.jpg");
im2 = imread("im2corrected.jpg");


% Select points in im1 and im2 for sanity check
figure(1); imagesc(im); axis image; drawnow;
figure(2); imagesc(im2); axis image; drawnow;

figure(1); [x1,y1] = getpts; pts1 = [x1, y1];
figure(1); imagesc(im); axis image; hold on
for i=1:length(x1)
   h=plot(x1(i),y1(i),'*'); set(h,'Color','g','LineWidth',2);
   text(x1(i),y1(i),sprintf('%d',i));
end
hold off
drawnow;

figure(2); imagesc(im2); axis image; drawnow;
 [x2,y2] = getpts; pts2 = [x2, y2];
figure(2); imagesc(im2); axis image; hold on
for i=1:length(x2)
   h=plot(x2(i),y2(i),'*'); set(h,'Color','g','LineWidth',2);
   text(x2(i),y2(i),sprintf('%d',i));
end
hold off
drawnow;

colors =  'bgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk';
%overlay epipolar lines on im2
L = F * [x1' ; y1'; ones(size(x1'))];
[nr,nc,nb] = size(im2);
figure(2); imagesc(im2); axis image;
hold on; plot(x2,y2,'*'); hold off
for i=1:length(L)
    a = L(1,i); b = L(2,i); c=L(3,i);
    if (abs(a) > (abs(b)))
       ylo=0; yhi=nr; 
       xlo = (-b * ylo - c) / a;
       xhi = (-b * yhi - c) / a;
       hold on
       h=plot([xlo; xhi],[ylo; yhi]);
       set(h,'Color',colors(i),'LineWidth',2);
       hold off
       drawnow;
    else
       xlo=0; xhi=nc; 
       ylo = (-a * xlo - c) / b;
       yhi = (-a * xhi - c) / b;
       hold on
       h=plot([xlo; xhi],[ylo; yhi],'b');
       set(h,'Color',colors(i),'LineWidth',2);
       hold off
       drawnow;
    end
end


%overlay epipolar lines on im1
L = ([x2' ; y2'; ones(size(x2'))]' * F)' ;
[nr,nc,nb] = size(im);
figure(1); imagesc(im); axis image;
hold on; plot(x1,y1,'*'); hold off
for i=1:length(L)
    a = L(1,i); b = L(2,i); c=L(3,i);
    if (abs(a) > (abs(b)))
       ylo=0; yhi=nr; 
       xlo = (-b * ylo - c) / a;
       xhi = (-b * yhi - c) / a;
       hold on
       h=plot([xlo; xhi],[ylo; yhi],'b');
       set(h,'Color',colors(i),'LineWidth',2);
       hold off
       drawnow;
    else
       xlo=0; xhi=nc; 
       ylo = (-a * xlo - c) / b;
       yhi = (-a * xhi - c) / b;
       hold on
       h=plot([xlo; xhi],[ylo; yhi],'b');
       set(h,'Color',colors(i),'LineWidth',2);
       hold off
       drawnow;
    end
end


for j=1:3
    for i=1:3
        fprintf('%10g ',10000*F(j,i));
    end
    fprintf('\n');
end