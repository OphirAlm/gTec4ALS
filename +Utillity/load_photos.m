function [Arrow, Idle, Mark] = load_photos()
% Loading the photos for the online Training phase


% load arrow image
Arrow{1} = imread('LoadingPics\Right_0.jpg');
Arrow{2} = imread('LoadingPics\Right_1.jpg');
Arrow{3} = imread('LoadingPics\Right_2.jpg');
Arrow{4} = imread('LoadingPics\Right_3.jpg');

% load idle sign
Idle{1} = imread('LoadingPics\Idle_0.jpg');
Idle{2} = imread('LoadingPics\Idle_1.jpg');
Idle{3} = imread('LoadingPics\Idle_2.jpg');
Idle{4} = imread('LoadingPics\Idle_3.jpg');

% Load the mark
Mark = imread('LoadingPics\Mark.jpg');

end