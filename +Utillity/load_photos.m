function [Arrow, Idle, Mark] = load_photos()
% LOAD_PHOTOS Loads the photos for the online training phase
%
% OUTPUT:
%     - Arrow - Cell-array containing the arrow pictures names
%     - Idle - Cell-array containing the idle-sign pictures names
%     - Mark - The mark picture name
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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