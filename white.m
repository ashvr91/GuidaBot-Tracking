%% VideoPlayer object initialization function - White.m

%This script creates VideoPlayer object, sets white detection threshold,
%acquires input stream, defines bounding box and text parameters. Accepts
%VidId as input which represents the deviceID of the camera being used.
%Returns VidStr which is a custom structure data type that stores different
%properties of the VideoPlayer object.
%% Initialization
function [VidStr]=white(VidID)
    
    thresh = 0.9; % Threshold for white detection
    vidDevice = imaq.VideoDevice('winvideo', VidID , 'YUY2_640x480', ... % Acquire input video stream
                        'ROI', [1 1 640 480], ...
                        'ReturnedColorSpace', 'rgb');
    vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
    hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                    'CentroidOutputPort', true, ... 
                                    'BoundingBoxOutputPort', true', ...
                                    'MinimumBlobArea', 400, ...
                                    'MaximumCount', 50);
    hshapeinsWhiteBox = vision.ShapeInserter('BorderColor', 'Custom', ...
                                            'CustomBorderColor', [1 0 0]); % Set white box handling
    htextins = vision.TextInserter('Text', 'Number of White Object(s): %2d', ... % Set text for number of blobs
                                        'Location',  [7 2], ...
                                        'Color', [1 1 1], ... // white color
                                        'Font', 'Courier New', ...
                                        'FontSize', 12);
    htextinsCent = vision.TextInserter('Text', '+      X:%6.2f,  Y:%6.2f', ... % set text for centroid
                                        'LocationSource', 'Input port', ...
                                        'Color', [0 0 0], ... // black color
                                        'FontSize', 12);
    if VidID == 1                                
        hVideoIn = vision.VideoPlayer('Name', 'Camera 1', ... % Output video player for CameraID = 1
                                        'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
    elseif VidID == 2
        hVideoIn = vision.VideoPlayer('Name', 'Camera 2', ... % Output video player  for CameraID = 2
                                        'Position', [vidInfo.MaxWidth+150 100  vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
    elseif VidID == 3
        hVideoIn = vision.VideoPlayer('Name', 'Camera 2', ... % Output video player for CameraID = 3
                                        'Position', [vidInfo.MaxWidth+150 100  vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
    end
                                    
    VidStr = v2struct(thresh,vidDevice,vidInfo, hblob, hshapeinsWhiteBox, htextins, ...
                        htextinsCent, hVideoIn); %v2struct stores the variables inside () and stores them in a custom structure which is returned. 
    
end

