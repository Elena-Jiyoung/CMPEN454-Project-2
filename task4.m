% Load the images
image1 = imread('im1corrected.jpg');
image2 = imread('im2corrected.jpg');

% Display the first image and select points
figure, imshow(image1);
title('Select point in Image 1');
[x1, y1] = ginput;  % Click on points in Image 1
close;

% Display the second image and select corresponding points
figure, imshow(image2);
title('Select corresponding point in Image 2');
[x2, y2] = ginput;  % Click on points in Image 2
close;

% Store the points in matrices
% movingPoints for Image 1, fixedPoints for Image 2
image1pt = [x1, y1];
image2pt = [x2, y2];

% Display selected points
disp('Selected points in Image 1:');
disp(image1pt);

disp('Selected points in Image 2:');
disp(image2pt);

%floor points 1 selected are (409, 716) in cam 1 and (961, 886) in cam 2
%floor points 2 selected are (1051, 954) in cam 1 and (1698, 708) in cam 2
%floor points 3 selected are (1002, 617) in cam 1 and (564, 611) in cam 2

% need to put these in triangulation code
