% This function accepts the EE coordinates, bounding boxes, base
% coordinates (all in pixels). Using measurements, calculations and assumed distances
% between the camera and the base, we have obtained the variation of
% pixels/inch w.r.t distance of object from the camera. The slope of this
% graph represents the magnification factor. The pixels/inch at a
% particular depth from the camera is used to calculate the distance
% between the EE and the robot base in inches, using the coordinate
% information in pixels. The EE coordinates w.r.t the base, in inches, are
% plotted in an animated line plot. Finally, the coordinates are returned
% to the calling function.

function [coord,map] = plotee(h, centroidXY,centroidYZ,bboxXY,bboxYZ,baseXY,baseYZ)
   baseXY=double(baseXY); %Pixel locations of base centroid from CAM 1
   baseYZ=double(baseYZ); %Pixel locations of base centroid from CAM 2
   
   bboxXY=double(bboxXY); %Bounding box details of EE from CAM 1
   bboxYZ=double(bboxYZ); %Bounding box details of EE from CAM 2
   
   centroidXY=double(centroidXY); %Pixel locations of EE centroid from CAM 1
   centroidYZ=double(centroidYZ); %Pixel locations of EE centroid from CAM 2
   
   PPIbase = 22.77; %Pixels per inch at the distance the base is from both the cameras (Both d = 60 cm)
   
   mapX=((320-baseXY(1,1))/PPIbase)-((320-centroidXY(1,1))/(0.643*bboxXY(1,4))); % X distance of EE from base in inches
   mapY=-((240-baseXY(1,2))/PPIbase)-((240-centroidXY(1,2))/(0.643*bboxXY(1,4))); % Y distance of EE from base in inches
   mapZ=((320-baseYZ(1,1))/PPIbase)-((320-centroidYZ(1,1))/(0.643*bboxYZ(1,4))); % Z distance of EE from base in inches
   addpoints(h,mapZ,mapX,mapY); %Adds points to the animated plot
   drawnow;
%     set(h,'Ydata',mapY);
%     set(h,'Xdata',mapX);
%     set(h,'Zdata',mapZ);
   coord = ['X=',num2str(mapX),';',' Y=',num2str(mapY),';',' Z=',num2str(mapZ),' (inches)']; %Returns coordinates as a string to display above graph
   map = [mapX,mapY,mapZ]; %Returns coordinates for saving in .mat file
    
end 