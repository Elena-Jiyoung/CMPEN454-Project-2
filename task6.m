
%test eight point algorithm
% Test the Eight-point Algorithm with and without Hartley Preconditioning

im = imread('im1corrected.jpg');
im2 = imread('im2corrected.jpg');

[F_with_hartley, pts1, pts2] = eightpoint_with_hartley(im, im2);
% Save points from `eightpoint_with_hartley`
save('pts1_with_hartley.mat', 'pts1');
save('pts2_with_hartley.mat', 'pts2');

[F_without_hartley, pts1, pts2] = eightpoint_without_hartley(im, im2);
% Save points from `eightpoint_without_hartley`
save('pts1_without_hartley.mat', 'pts1');
save('pts2_without_hartley.mat', 'pts2');

% Save the fundamental matrices for Task 7
save("F_with_Hartley.mat", "F_with_hartley");
save("F_without_Hartley.mat", "F_without_hartley");

% Display results
disp("Fundamental Matrix with Hartley Preconditioning:");
disp(F_with_hartley);

disp("Fundamental Matrix without Hartley Preconditioning:");
disp(F_without_hartley);

%----------Eightpoint Algorithm 1. With Hartley Preconditioning and 
% 2. Without Hartley Preconditionding-------------------------
% First, Compute F using eightpoint algorithm with Hartley
% preconditioning(normalization) as shown in the demo code.
function [F_with_hartley, pts1, pts2] = eightpoint_with_hartley(im, im2)
    
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
    
    %do Hartley preconditioning
    savx1 = x1; savy1 = y1; savx2 = x2; savy2 = y2;
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
    for i=1:length(nx1);
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
    
    %unnormalize F to undo the effects of Hartley preconditioning
    F = T2' * F * T1;
    
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
    
    
    F_with_hartley = F;

end


% Eight-point algorithm without Hartley preconditioning
function [F_without_hartley, pts1, pts2] = eightpoint_without_hartley(im, im2)
        
    
    figure(3); imagesc(im); axis image; drawnow;
    figure(4); imagesc(im2); axis image; drawnow;
    
    
    
    figure(3); [x1,y1] = getpts; pts1 = [x1, y1];
    figure(3); imagesc(im); axis image; hold on
    for i=1:length(x1)
       h=plot(x1(i),y1(i),'*'); set(h,'Color','g','LineWidth',2);
       text(x1(i),y1(i),sprintf('%d',i));
    end
    hold off
    drawnow;
    
    figure(4); imagesc(im2); axis image; drawnow;
     [x2,y2] = getpts; pts2 = [x2, y2];
    figure(4); imagesc(im2); axis image; hold on
    for i=1:length(x2)
       h=plot(x2(i),y2(i),'*'); set(h,'Color','g','LineWidth',2);
       text(x2(i),y2(i),sprintf('%d',i));
    end
    hold off
    drawnow;
    
    %without Hartley preconditioning
    A = [];
    for i = 1:length(x1)
        A(i, :) = [x1(i) * x2(i), x1(i) * y2(i), x1(i), y1(i) * x2(i), y1(i) * y2(i), y1(i), x2(i), y2(i), 1];
    end
    
    %get eigenvector associated with smallest eigenvalue of A' * A
    [u,d] = eigs(A' * A,1,'SM');
    F = reshape(u,3,3);
    
    %make F rank 2
    oldF = F;
    [U,D,V] = svd(F);
    D(3,3) = 0;
    F = U * D * V';
    
    
    colors =  'bgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk';
    %overlay epipolar lines on im2
    L = F * [x1' ; y1'; ones(size(x1'))];
    [nr,nc,nb] = size(im2);
    figure(4); imagesc(im2); axis image;
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
    figure(3); imagesc(im); axis image;
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

    
    
    F_without_hartley = F;
end
