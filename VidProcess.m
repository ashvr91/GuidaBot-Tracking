%% White object tracking function - VidProcess()
% This function accepts the videoplayer structure returned by white.m as
% input. It then tracks the white object (End effector) and the base (Green
% object), and returns these details to the calling function.
    
function [centroid,base,bbox] = VidProcess(VidStr)
            
            %Unpacking VidStr
            thresh = VidStr.thresh;
            vidDevice = VidStr.vidDevice;
            hblob = VidStr.hblob;
            
            
            base = 0;%getBase(hblob, vidDevice); %Obtain coordinates of centroid of Base
            hshapeinsWhiteBox = VidStr.hshapeinsWhiteBox; 
            vidInfo = VidStr.vidInfo;
            htextins = VidStr.htextins;
            htextinsCent = VidStr.htextinsCent;
            hVideoIn = VidStr.hVideoIn;
            rgbFrame = step(vidDevice); % Acquire single frame
            
            bwredFrame = im2bw(rgbFrame(:,:,1), thresh); % obtain the white component from red layer
            bwgreenFrame = im2bw(rgbFrame(:,:,2), thresh); % obtain the white component from green layer
            bwblueFrame = im2bw(rgbFrame(:,:,3), thresh); % obtain the white component from blue layer
            binFrame = bwredFrame & bwgreenFrame & bwblueFrame; % get the common region
            binFrame = medfilt2(binFrame, [3 3]); % Filter out the noise by using median filter
            [centroid, bbox] = step(hblob, binFrame); % Get the centroids and bounding boxes of the blobs
            rgbFrame(1:15,1:215,:) = 0; % put a black region on the output stream
            vidIn = step(hshapeinsWhiteBox, rgbFrame, bbox(1,:)); % Instert the white box
            vidIn = step(htextinsCent, vidIn, [centroid(1,1) centroid(1,2)], [centroid(1,1)-6 centroid(1,2)-9]); %Outputs centroid coordinates            
            vidIn = step(htextins, vidIn, uint8(1)); 
            step(hVideoIn, vidIn); % Output video stream
            
end


%% Base detection
%  This function detects the base (green) and returns its pixel coordinates
%  to VidProcess.m
function base = getBase(hblob, vidDevice1) 
    greenThresh= 0.25; %Threshold for detecting green
    rgbFrame1 = step(vidDevice1); % Acquire single frame from video feed
    rgbFrame1 = fliplr(rgbFrame1); % obtain the lateral mirror image for displaying
    diffFrame1 = imsubtract(rgbFrame1(:,:,2), rgb2gray(rgbFrame1)); % Get green component of the image
    diffFrame1 = medfilt2(diffFrame1, [3 3]); % Filter out the noise by using median filter
    binFrame1 = im2bw(diffFrame1, greenThresh); % Convert the image into binary image with the green objects as white
    [centroid1, bbox1] = step(hblob, binFrame1); % Get the centroids and bounding boxes of the blobs
    centroid1 = uint16(centroid1); % Convert the centroids into Integer for further steps 
    rgbFrame1(1:20,1:165,:) = 0; % put a black region on the output stream
%     vidIn = step(hshapeinsWhiteBox, rgbFrame, bbox(1,:)); % Instert the white box
%     vidIn = step(htextinsCent, vidIn, [centroid(1,1) centroid(1,2)], [centroid(1,1)-6 centroid(1,2)-9]); %Outputs centroid coordinates            
%     vidIn = step(htextins, vidIn, uint8(1)); 
%     step(hVideoIn, vidIn); % Output video stream
    centX1=0;
    centY1=0;
    centX1 = centroid1(1,1); centY1 = centroid1(1,2);                
    base=[centX1,centY1]; %Returns pixel coordinates of base
end 
