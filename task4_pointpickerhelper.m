image1 = imread('im1corrected.jpg');
image2 = imread('im2corrected.jpg');

% display the first image and select points
figure, imshow(image1);
title('Select point in Image 1');
% Click on points in Image 1
[x1, y1] = ginput;
close;

% display the second image and select corresponding points
figure, imshow(image2);
title('Select corresponding point in Image 2');
% click on points in Image 2
[x2, y2] = ginput;
close;

image1pt = [x1, y1];
image2pt = [x2, y2];

% display selected points
disp('Selected points in Image 1:');
disp(image1pt);

disp('Selected points in Image 2:');
disp(image2pt);

