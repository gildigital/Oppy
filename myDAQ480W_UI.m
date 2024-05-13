function [ ] = myDAQ480W_UI()
%CREATEDATACAPTUREUI Create a graphical user interface for data capture.
%   HGUI = CREATEDATACAPTUREUI(S) returns a structure of graphics
%   components handles (HGUI) and creates a graphical user interface, by
%   programmatically creating a figure and adding required graphics
%   components for visualization of data acquired from a DAQ session (S).

% Positionning Nomenclature:  [LEFT BOTTOM WIDTH HEIGHT]
% Callbacks Require 2 Arguments: "src", "event".
%   use a cell-array with a callback to include additional inputs to
%   functions.

% Store the DAQ Device name:
hGui.DeviceName = 'myDAQ1';
% Initialize the GUI Enviornment.
hGui = buildGui(hGui);
% Update the Status-Text.
set(hGui.StatusText,'String','Initialization Required', ...
    'ForegroundColor',[0.5 0 0]);
end

function hGui = buildGui(hGui)
% Create a Figure Enviornment.
hGui.Fig = figure('Name','Software-analog triggered data capture', ...
    'NumberTitle', 'off', 'Resize', 'on', 'Position', [100 100 920 720]);
% Create an axis for the logo.
hGui.LogoAxes = axes;
set(hGui.LogoAxes, 'Units', 'Pixels', 'Position',  [170 365 100 100]);
try
    logo = imread('USDLogo.png','BackgroundColor',[0.94 0.94 0.94]);
    imshow(logo);
catch
    warning('USD Logo.png Has not been found in the present directory.')
    hGui = rmfield(hGui,'LogoAxes');
end
% Create the continuous data plot axes with legend
hGui.Axes1 = axes;
hGui.CapturePlot = plot(NaN, NaN);
set(hGui.Axes1, 'Units', 'Pixels', 'Position',  [357 371 488 290]);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Data Stream');
% Create the captured data plot axes - To be configured later
hGui.Axes2 = axes('Units', 'Pixels', 'Position', [357 79 488 216]);
hGui.CapturePlot = plot(NaN, NaN);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Captured Data');

% Init the special controls like the pop-up menu and the status texts
hGui = initSpecial(hGui);

% Initialize all the button-type objects in another function
hGui = initButtons(hGui);

% Initialize many of the DAQ settings
hGui = initGeneralSettings(hGui);

% Initialize the trigger-mode-specific settings.
vis = 'off';
hGui = initTriggerSettings(hGui,vis);

% We set the call-back functions at the end to ensure that they have the
% most up-to-date version of the hGui structure containing all of the
% uicontrols available.
disp('Setting Callback Functions')
set(hGui.acquisitionTypeMenu,'CallBack',{@acquisitionTypeMenuCallback, hGui});
set(hGui.DAQButton_Init,'CallBack',{@initCallback,hGui});
set(hGui.Duration,'CallBack',{@acquisitionTypeMenuCallback,hGui});
set(hGui.AcquisitionRate,'CallBack',{@acquisitionTypeMenuCallback,hGui});
set(hGui.PlotTimeSpan,'CallBack',{@acquisitionTypeMenuCallback,hGui});
set(hGui.DAQButton_SaveAs,'CallBack',{@saveAsCallback, hGui});
set(hGui.DAQButton_Export,'CallBack',{@exportCallback, hGui});

% Now we are done with all of the GUI-building, all the functionality is
% set-up and the callback functions are active.

end

function hGui = initSpecial(hGui)
% The initSpecial function initializes several of the custom utilities in
% the DAQ GUI. 
%       Primary Status Text Box
%       Trigger Status Text Box
%       Credit Text Box
%       Data-Acquisition Type Pop-up Menu.

% Grab the figure color.
uiBackgroundColor = get(hGui.Fig, 'Color');
% Create some status text fields
hGui.StatusText = uicontrol('style', 'text', 'string', '',...
    'units', 'pixels', 'position', [80 680 225 24],...
    'HorizontalAlignment', 'left', 'BackgroundColor', uiBackgroundColor, ...
        'FontSize',12,'FontWeight','bold');
hGui.TrigStatusText = uicontrol('style', 'text', 'string', '',...
    'units', 'pixels', 'position', [67 40 225 24],...
    'HorizontalAlignment', 'left', 'BackgroundColor', uiBackgroundColor);
% Give myself credit for making this thing...
hGui.CreditText = uicontrol('style', 'text', 'string', ...
    'myDAQ 480W Ver. 4.0 - Author: Quinn Pratt - Date: 2018',...
    'units', 'pixels', 'position', [67 15 275 24],...
    'HorizontalAlignment', 'left', 'BackgroundColor', uiBackgroundColor);

% Create a pop-up control for the type of data acquisition.
hGui.acquisitionTypeMenu = uicontrol('Style','popup','String', ...
    {'1 Channel AI', '2 Channel AI', '1 Channel Trigger', '2 Channel Trigger'}, ...
    'Position',[80 640 180 30]);
end

function hGui = initButtons(hGui)
% The initButtons function initializes the buttons in the GUI. The
% callbacks are assigned later.
%       Initialize-DAQ Button
%       Start Button
%       Stop Button
%       Capture Button
%       Export Button
%       Save-As Button

button_width = 81; button_height = 38;
button_bottom = 550;
sett_bottom = 460;
% Create an init acquisition button - To be configured later
hGui.DAQButton_Init = uicontrol('style', 'pushbutton', 'string', 'Initialize DAQ',...
    'units', 'pixels', 'position', [130 (button_bottom + 1.2*button_height) button_width button_height]);
% Create a Start acquisition button - To be configured later
hGui.DAQButton_Start = uicontrol('style', 'pushbutton', 'string', 'Start DAQ',...
    'units', 'pixels', 'position', [80 button_bottom button_width button_height]);
% Create a stop acquisition button - To be configured later
hGui.DAQButton_Stop = uicontrol('style', 'pushbutton', 'string', 'Stop DAQ',...
    'units', 'pixels', 'position', [180 button_bottom button_width button_height]);

% Create a data capture button.
hGui.DAQButton_Capture = uicontrol('style', 'togglebutton', 'string', 'Capture',...
    'units', 'pixels', 'position', [130 sett_bottom-5*button_height button_width button_height]);
% Create a data export button.
hGui.DAQButton_Export = uicontrol('style', 'togglebutton', 'string', 'Export',...
    'units', 'pixels', 'position', [180 sett_bottom-6.2*button_height button_width button_height]);
% Create a save-as button.
hGui.DAQButton_SaveAs = uicontrol('style', 'togglebutton', 'string', 'Save As...',...
    'units', 'pixels', 'position', [80 sett_bottom-6.2*button_height button_width button_height]);
end

function hGui = initGeneralSettings(hGui)
% The initGeneralSettings function initializes other general elements of
% the GUI including:
%       Duration Box
%       Rate Box
%       Plot Time Box
%       File Type Menu for Exporting
%       Export File Path
%       Export File Name


sett_width = 56; sett_height = 24;
sett_bottom = 460;
uiBackgroundColor = get(hGui.Fig, 'Color');
% Create an editable text field for the SessionDuration
hGui.Duration = uicontrol('style', 'edit', 'string', '1',...
    'units', 'pixels', 'position', [89 sett_bottom sett_width sett_height]);
hGui.txtDuration = uicontrol('Style', 'text', 'String', 'Duration', ...
    'Position', [37 sett_bottom+2 sett_width-13 sett_height-9], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
% Create an editable text field for the Session Rate
hGui.AcquisitionRate = uicontrol('style', 'edit', 'string', '100',...
    'units', 'pixels', 'position', [89 sett_bottom+1.2*sett_height sett_width sett_height]);
hGui.txtAcquisitionRate = uicontrol('Style', 'text', 'String', 'Rate', ...
    'Position', [37 sett_bottom+1.2*sett_height+2 sett_width-13 sett_height-9], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
% Create an editable text field for the Plot Time Span
hGui.PlotTimeSpan = uicontrol('style', 'edit', 'string', '5',...
    'units', 'pixels', 'position', [212 sett_bottom+1.2*sett_height sett_width sett_height]);
hGui.txtPlotTimeSpan = uicontrol('Style', 'text', 'String', 'Plot Time', ...
    'Position', [152 sett_bottom+1.2*sett_height+2 sett_width-3 sett_height-9], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);

hGui.exportFileTypeMenu = uicontrol('Style','popup','String', ...
    {'Comma-Separated (.csv)', 'Tab-Delimited (.txt)', 'Excel (.xls)', 'Mat File (.mat)'}, ...
    'Position',[80 140 180 30]);
hGui.ExportFilepath = uicontrol('style', 'edit', 'string', 'C:\Users\Physics\Desktop\',...
    'units', 'pixels', 'position', [89 115 200 sett_height]);
hGui.txtExportFilepath = uicontrol('Style', 'text', 'String', 'Filepath', ...
    'Position', [37 115+2 sett_width-10 sett_height-9], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
hGui.ExportFilename = uicontrol('style', 'edit', 'string', 'yourData',...
    'units', 'pixels', 'position', [89 80 200 sett_height]);
hGui.txtExportFilename = uicontrol('Style', 'text', 'String', 'Filename', ...
    'Position', [37 80+2 sett_width-10 sett_height-9], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);

end

function hGui = initTriggerSettings(hGui,vis)
% The initTriggerSettings function initializes the trigger-related controls
% in the GUI.
%       Trigger Channel
%       Trigger Level
%       Trigger Slope


sett_width = 56; sett_height = 24;
sett_bottom = 370;
uiBackgroundColor = get(hGui.Fig, 'Color');
% Create an editable text field for the trigger channel
hGui.TrigChannel = uicontrol('style', 'edit', 'string', '0',...
    'units', 'pixels', 'position', [89 sett_bottom+2.4*sett_height sett_width sett_height]);
% Create an editable text field for the trigger signal level
hGui.TrigLevel = uicontrol('style', 'edit', 'string', '1.0',...
    'units', 'pixels', 'position', [89 sett_bottom+1.2*sett_height sett_width sett_height]);
% Create an editable text field for the trigger signal slope
hGui.TrigSlope = uicontrol('style', 'edit', 'string', '200.0',...
    'units', 'pixels', 'position', [89 sett_bottom sett_width sett_height]);
% Create text labels
hGui.txtTrigChannel = uicontrol('Style', 'text', 'String', 'Trig. Channel', ...
    'Position', [20 sett_bottom+2.4*sett_height sett_width+10 sett_height-6], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
hGui.txtTrigLevel = uicontrol('Style', 'text', 'String', 'Level (V)', ...
    'Position', [27 sett_bottom+1.2*sett_height sett_width-5 sett_height-6], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
hGui.txtTrigSlope = uicontrol('Style', 'text', 'String', 'Slope (V/s)', ...
    'Position', [23 sett_bottom sett_width+5 sett_height-6], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);

set(hGui.TrigChannel,'Visible',vis);set(hGui.txtTrigChannel,'Visible',vis);
set(hGui.TrigLevel,'Visible',vis);set(hGui.txtTrigLevel,'Visible',vis);
set(hGui.TrigSlope,'Visible',vis);set(hGui.txtTrigSlope,'Visible',vis);
end

function hGui = initCallback(~,~,hGui)
% The initCallback function is activated by the Initialize DAQ button and
% sets most of the DAQ-session configurations.

disp('Now Initializing')
set(hGui.DAQButton_Init,'BackgroundColor','y')
% Create the NI Session - configure channels accordinglyy
s = daq.createSession('ni');
switch get(hGui.acquisitionTypeMenu,'Value');
    % 1 Channel AI
    case 1
        addAnalogInputChannel(s,hGui.DeviceName,'ai0','Voltage');
        s.Rate = str2double(get(hGui.AcquisitionRate,'String'));
        s.DurationInSeconds = str2double(get(hGui.Duration,'String'));
    % 2 Channel AI
    case 2
        addAnalogInputChannel(s,hGui.DeviceName,'ai0','Voltage');
        addAnalogInputChannel(s,hGui.DeviceName,'ai1','Voltage');
        s.Rate = str2double(get(hGui.AcquisitionRate,'String'));
        s.DurationInSeconds = str2double(get(hGui.Duration,'String'));
    % 1 Channel Trigger
    case 3
        addAnalogInputChannel(s,hGui.DeviceName,'ai0','Voltage');
        s.Rate = str2double(get(hGui.AcquisitionRate,'String'));
    % 2 Channel Trigger
    case 4
        addAnalogInputChannel(s,hGui.DeviceName,'ai0','Voltage');
        addAnalogInputChannel(s,hGui.DeviceName,'ai1','Voltage');
        s.Rate = str2double(get(hGui.AcquisitionRate,'String'));
end
% Create the continuous data plot axes with legend
% (one line per acquisition channel)
axes(hGui.Axes1)
hGui.LivePlot = plot(0, zeros(1, numel(s.Channels)));
legend(get(s.Channels, 'ID'), 'Location', 'northeast')
xlabel('Time (s)'); ylabel('Signal (Volts)')
title('Data Stream');
axes(hGui.Axes2)
hGui.CapturePlot = plot(0, zeros(1, numel(s.Channels)));
legend(get(s.Channels, 'ID'), 'Location', 'northeast')
xlabel('Time (s)'); ylabel('Signal (Volts)')
title('Captured Data');

% Set the capture callback function
set(hGui.DAQButton_Capture,'CallBack',{@startCapture, hGui});

set(hGui.Fig, 'DeleteFcn', {@endDAQ, s, hGui});
% Specify the desired parameters for data capture and live plotting.
% The data capture parameters are grouped in a structure data type,
% as this makes it simpler to pass them as a function argument.

% Specify triggered capture timespan, in seconds
capture.TimeSpan = s.DurationInSeconds;
% Specify continuous data plot timespan, in seconds
capture.plotTimeSpan = str2double(get(hGui.PlotTimeSpan,'String'));
% Determine the timespan corresponding to the block of samples supplied
% to the DataAvailable event callback function.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
% Determine required buffer timespan, seconds
capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan * 3, callbackTimeSpan * 3]);
% Determine data buffer size
capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);
% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters and the handles to the UI graphics
% elements are passed as additional arguments to the callback function.
mode = get(hGui.acquisitionTypeMenu,'Value');
if mode == 3 || mode == 4
    % Software-Trigger is being used
    capture.dataListener = addlistener(s, 'DataAvailable', ...
        @(src,event) myDAQ480W_Capture_Trig(src, event, capture, hGui));
else
    % Software-Trigger is not being used
    capture.dataListener = addlistener(s, 'DataAvailable', ...
        @(src,event) myDAQ480W_Capture(src, event, capture, hGui));

end

% Add a listener for acquisition error events which might occur during background acquisition
capture.errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));
% Start continuous background data acquisition
s.IsContinuous = true;
set(hGui.StatusText,'String','Ready To Acquire','ForegroundColor',[0 0.5 0.1])
set(hGui.DAQButton_Init,'BackgroundColor',[0 0.9 0.1])

% Store the session in the hGui structure and activate the callback for the
% start button.
hGui.s = s;
set(hGui.DAQButton_Start,'CallBack',{@DAQButtonStart_Callback,capture,hGui})
set(hGui.DAQButton_Stop,'CallBack',{@endDAQ,s,hGui});

disp('Initialization Complete')
end


function hGui = DAQButtonStart_Callback(~,~,capture,hGui)
disp('Start Button Callback')
set(hGui.DAQButton_Start,'BackgroundColor','y')
set(hGui.StatusText,'String','Streaming Data','ForegroundColor',[0.6 0.6 0]);
% Start Continuous Data stream in Background
s = hGui.s;
startBackground(s);
% Wait until session s is stopped from the UI
while s.IsRunning
    pause(0.5);
end

delete(capture.dataListener);
delete(capture.errorListener);
delete(hGui.s);
end

function hGui = acquisitionTypeMenuCallback(~,~,hGui)
disp('Mode Menu Callback')

set(hGui.DAQButton_Init,'BackgroundColor',[0.94 0.94 0.94])
set(hGui.DAQButton_Start,'BackgroundColor',[0.94 0.94 0.94])
set(hGui.StatusText,'String','Initialization Required', ...
    'ForegroundColor',[0.5 0 0]);
set(hGui.TrigStatusText,'String','')
mode = get(hGui.acquisitionTypeMenu,'Value');
if mode == 3
    vis = 'on';
    set(hGui.TrigChannel,'Visible','off');set(hGui.txtTrigChannel,'Visible','off');
elseif mode == 4
    vis = 'on';
    set(hGui.TrigChannel,'Visible',vis);set(hGui.txtTrigChannel,'Visible',vis);
else
    vis = 'off';
end
    set(hGui.TrigChannel,'Visible',vis);set(hGui.txtTrigChannel,'Visible',vis);
    set(hGui.TrigLevel,'Visible',vis);set(hGui.txtTrigLevel,'Visible',vis);
    set(hGui.TrigSlope,'Visible',vis);set(hGui.txtTrigSlope,'Visible',vis);

end

function startCapture(hObject, ~, hGui)
disp('Capture Callback')
if get(hObject, 'value')
    % If button is pressed clear data capture plot
    for ii = 1:numel(hGui.CapturePlot)
        set(hGui.CapturePlot(ii), 'XData', NaN, 'YData', NaN);
    end
end
end

function endDAQ(~, ~, s, hGui)
disp('Stop Callback')
if isvalid(s)
    if s.IsRunning
        stop(s);
    end
end
acquisitionTypeMenuCallback([],[],hGui);

end

function saveAsCallback(~,~,hGui)
AllowableFileExtn = {'*.csv';'*.txt';'*.xlsx';'*.mat'};
AllowableFileExtn_NoStar = {'.csv';'.txt';'.xlsx';'.mat'};

[filename, pathname] = uiputfile(AllowableFileExtn,...
    'Specify Imported Data File Properties');

[~,Filename,FileExt] = fileparts(filename);
Indx = cellfun(@(str) strcmp(str,FileExt),AllowableFileExtn_NoStar);

FileExtIndx = find(Indx == 1);
set(hGui.exportFileTypeMenu,'Value',FileExtIndx);
set(hGui.ExportFilepath,'String',pathname);
set(hGui.ExportFilename,'String',[Filename FileExt]);

end

function exportCallback(~,~,hGui)
disp('Export Callback')
set(hGui.StatusText,'String','Exporting Data...','ForegroundColor','k');

CollectedData = evalin('base', 'CollectedData');
FileName = get(hGui.ExportFilename,'String');
[~,filename] = fileparts(FileName);

Index = isstrprop(filename,'alphanum');
if any(Index == 0) == 1 && ...
        any(arrayfun(@(str) strcmp(str,'_'),filename(~Index)) == 0) == 1
    c = clock;
    % c = [year month day hour minute seconds]
    filename = ['myData_' num2str(c(2)) ...
        '_' num2str(c(3)) '_h' num2str(c(4)) '_m' num2str(c(5)) ...
        '_s' num2str(round(c(6)))];  
end

switch get(hGui.exportFileTypeMenu,'Value')
    case 1
        % In this case the user selected CSV...
        csvwrite([filename '.csv'], CollectedData);
    case 2
        % In this case the user selected DLM...
        dlmwrite([filename '.txt'],CollectedData,'delimiter','\t');
    case 3
        % In this case the user selected XLS...
        xlswrite([filename '.xls'],CollectedData);
    case 4
        % In this case the user selected MAT...
        MatObj = matfile([filename '.mat']);
        MatObj.CollectedData = CollectedData;
    otherwise
        % default to csv
        csvwrite([filename '.csv'],CollectedData);
end

set(hGui.StatusText,'String','Data Saved','ForegroundColor',[0 0.5 0]);
end
