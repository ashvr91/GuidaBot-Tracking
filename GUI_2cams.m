function varargout = GUI_2cams(varargin)
% GUI_2CAMS MATLAB code for GUI_2cams.fig
%      This is the main GUI function that allows for initialization of
%      Videoplayer objects, start/pause video stream, image processing,
%      plotting and deleting all variables when closed.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_2cams_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_2cams_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_2cams is made visible.
function GUI_2cams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_2cams (see VARARGIN)

% Choose default command line output for GUI_2cams
handles.output = hObject;
handles.flag = 0; %Flag variable to check for starting/pausing video stream
handles.mapdata = zeros(1,3); %Creates zero vector for storing End Effector (EE) position data later in the program
handles.i = 1; %Index variable to denote row number while appending EE data to handles.mapdata

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_2cams wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_2cams_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in "Initialize"
function Init_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Init_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.VidID1 = 1; %Assigns cameraID for cam1
handles.VidID2 = 3; %Assigns cameraID for cam2
handles.V1 = white(handles.VidID1); %Calls initialization function and stores returned Videoplayer structure object
handles.V2 = white(handles.VidID2); %Calls initialization function and stores returned Videoplayer structure object
guidata(hObject,handles);


% --- Executes on button press in "Start/Pause".
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
button_state = get(hObject, 'Value');

%Code block for when "Start"/"Restart" button is clicked
if button_state == get(hObject,'Max') %Video acquisition is on
        uiresume(); %Resumes video feed when "Start" button is clicked after pausing
        %plot3(handles.axes1,nan,nan,nan);
        h = animatedline(handles.axes1,nan,nan,nan,'Marker','o','Color','red'); %Creates empty animated line plot
        view(handles.axes1,3); %Forces 3D view of animated line plot
        grid on 
        
        %Setting limits for axes
        set(handles.axes1,'XLim',[-25 25]); 
        set(handles.axes1,'YLim',[-25 25]);
        set(handles.axes1,'ZLim',[-25 25]);
        
        %Changes button name to "Pause" when video feed has started
        set(handles.togglebutton1,'String','Pause');
        
        %Executes video stream & processing till "Pause" button is hit.
        %Image acquisition, processing and plotting is all done
        %frame-by-frame.
        while (handles.flag == 0)
                 drawnow();
                 if isvalid(hObject)
                    [centroid_XY,base_XY,bbox_XY] = VidProcess(handles.V1); %Returns pixel locations of centroid and base, bbox details from CAM 1
                    [centroid_YZ,base_YZ,bbox_YZ] = VidProcess(handles.V2); %Returns pixel locations of centroid and base, bbox details from CAM 2
                    %if handles.i == 1
                        baseXY_final = [250,340];
                        baseYZ_final = [190,361];
                    %end
                    [coord,map] = plotee(h,centroid_XY,centroid_YZ,bbox_XY,bbox_YZ,baseXY_final,baseYZ_final); %Plots and returns EE location w.r.t base, in inches
                    handles.mapdata(handles.i,:) = map; %Stores EEcoordinate data in inches for each frame
                    set(handles.text2,'String',coord); %Displays coordinates on top-right corner of 3D plot in GUI
                    handles.i = handles.i + 1; 
                    guidata(hObject,handles);
                    drawnow();
                 else
                    return;
                 end
        end
        guidata(hObject,handles);
     
%Code block for when "Pause" button is clicked        
elseif button_state == get(hObject,'Min') %Video acquisition turned off
    set(handles.togglebutton1,'String','Restart');
    uiwait(); %Pauses video stream and plotting till further user input
end

% --- Executes on button press in "Close video"
function Close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

EEdata = handles.mapdata; 
save('mapdata.mat','EEdata'); %Saves final EE position data w.r.t base for each frame, in inches
set(handles.figure1, 'HandleVisibility', 'off');
close all;
set(handles.figure1, 'HandleVisibility', 'on');

%Closes camera feeds and deletes videoplayer objects
delete(handles.V1.vidDevice); 
delete(handles.V1.hVideoIn);
delete(handles.V2.vidDevice);
delete(handles.V2.hVideoIn);
guidata(hObject,handles);
clear all;


% --- Executes on button press in CloseGUI_Pushbutton.
function CloseGUI_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseGUI_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all; %Closes GUI
clc;
