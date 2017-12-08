function [cdata, cdatamapping, clim, map, xdata, ydata, ...
          initial_mag, style, filename] = ...
    imageDisplayParseInputs(varargin)
%imageDisplayParseInputs Parse inputs for IMSHOW and IMTOOL.
%
%   Valid syntaxes:
%   IMSHOW/IMTOOL - no arguments 
%   IMSHOW/IMTOOL(I)
%   IMSHOW/IMTOOL(I,[LOW HIGH]) 
%   IMSHOW/IMTOOL(RGB)
%   IMSHOW/IMTOOL(BW) 
%   IMSHOW/IMTOOL(X,MAP)
%   IMSHOW/IMTOOL(FILENAME) 
%
%   IMSHOW/IMTOOL(...,PARAM1,VAL1,PARAM2,VAL2,...)  
%   Parameters include:
%      'DisplayRange', RANGE
%      'InitialMagnification', INITIAL_MAG   
%      'XData',X                  
%      'YData',Y 
%      'WindowStyle',STYLE

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 1.1.8.2 $  $Date: 2004/12/18 07:36:36 $

% I/O Spec
%   I            2-D, real, full matrix of class:
%                uint8, uint16, int16, single, or double.
%
%   BW           2-D, real full matrix of class logical.
%
%   RGB          M-by-N-by-3 3-D real, full array of class:
%                uint8, uint16, int16, single, or double.
%
%   X            2-D, real, full matrix of class:
%                uint8, uint16, double
%                if isa(X,'uint8') || isa(X,'uint16'): X <= size(MAP,1)-1
%                if isa(X,'double'): 1 <= X <= size(MAP,1)
%  
%   MAP          2-D, real, full matrix
%                if isa(X,'uint8'): size(MAP,1) <= 256
%                if isa(X,'uint16') || isa(X,'double'): size(MAP,1) <= 65536
%
%   RANGE        2 element vector or empty array, double
%
%   FILENAME     String of a valid filename that is on the path.
%                File must be readable by IMREAD or DICOMREAD.
%
%   INITIAL_MAG  'adaptive', 'fit'
%                numeric scalar
%  
%   X,Y          2-element vector, can be more than 2 elements but only
%                first and last are used.
%
%   STYLE        'docked', 'normal'
% 
%   H            image object (possibly subclass of HG image object with
%                access to more navigational API)

% Defaults
filename      = '';
cdata         = [];
clim          = []; % stays empty for indexed and RGB
map           = [];
xdata         = [];
ydata         = [];
style         = ''; % let imshow/imtool decide their own default
initial_mag   = []; % let imshow/imtool decide their own default mag

num_args = length(varargin);
params_to_parse = false;

eid_invalid =  sprintf('Images:%s:invalidInputs',mfilename);
msg_invalid = 'Invalid input arguments.';

% See if there are parameter-value pairs
% IMSHOW/IMTOOL(...,'DisplayRange',...
%                   'InitialMagnification', INITIAL_MAG,...
%                   'XData', x, ...
%                   'YData', y, ...
%                   'WindowStyle',STYLE,...
string_indices = find(cellfun('isclass',varargin,'char'));
valid_params = {'DisplayRange','InitialMagnification',...
                'XData','YData','WindowStyle'};
if ~isempty(string_indices) && num_args > 1
    params_to_parse = true;
    
    is_first_string_first_arg = (string_indices(1)==1);

    nargs_after_first_string = num_args - string_indices(1);
    even_nargs_after_first_string = ~mod(nargs_after_first_string,2);

    if is_first_string_first_arg && even_nargs_after_first_string
        % IMSHOW/IMTOOL(FILENAME,PARAM,VALUE,...)
        param1_index = string_indices(2);
    else                              
        % IMSHOW/IMTOOL(PARAM,VALUE,...)
        % IMSHOW/IMTOOL(...,PARAM,VALUE,...)
        param1_index = string_indices(1); 
        
        % Make sure first string is a real parameter, if not
        % error here with generic message because user could
        % be trying IMSHOW/IMTOOL(FILENAME,[]).
        matches = strncmpi(varargin{param1_index},valid_params,...
                           length(varargin{param1_index}));
        if ~any(matches) %i.e. none
            error(eid_invalid, msg_invalid);
        end  
    end    
end

if params_to_parse
    num_pre_param_args = param1_index-1;
    num_args = num_pre_param_args;
end

iptchecknargin(0,2,num_args,mfilename);

switch num_args
case 1
    % IMSHOW/IMTOOL(FILENAME)
    % IMSHOW/IMTOOL(I)
    % IMSHOW/IMTOOL(RGB)
    
    if (ischar(varargin{1}))
        % IMSHOW/IMTOOL(FILENAME)
        filename = varargin{1};
        [cdata,map] = getImageFromFile(filename);    
    else
        % IMSHOW/IMTOOL(I)
        % IMSHOW/IMTOOL(RGB)       
        cdata = varargin{1};
    end
    
case 2
    % IMSHOW/IMTOOL(I,[])
    % IMSHOW/IMTOOL(I,[a b])
    % IMSHOW/IMTOOL(X,map)

    cdata = varargin{1};    

    if (isempty(varargin{2}))
        % IMSHOW/IMTOOL(I,[])
        clim = getAutoCLim(cdata); 
    
    elseif isequal(numel(varargin{2}),2)
        % IMSHOW/IMTOOL(I,[a b])
        clim = varargin{2};
            
    elseif (size(varargin{2},2) == 3)
        % IMSHOW/IMTOOL(X,map)        
        map = varargin{2};
        
    else
        error(eid_invalid, msg_invalid);
        
    end

end

% Make sure CData is numeric before going any further.
iptcheckinput(cdata, {'numeric','logical'},...
              {'nonsparse'}, ...
              mfilename, 'I', 1);

if params_to_parse 
    args = parseParamValuePairs(varargin(param1_index:end),valid_params,...
                                num_pre_param_args,...
                                mfilename);

    if isfield(args,'XData')
        xdata = args.XData;
    end

    if isfield(args,'YData')
        ydata = args.YData;
    end

    if isfield(args,'InitialMagnification')
        initial_mag = args.InitialMagnification;
    end
  
    if isfield(args,'DisplayRange')
        clim = args.DisplayRange;
        if isempty(clim)
            clim = getAutoCLim(cdata);
        end
    end
  
    if isfield(args,'WindowStyle')
        style = args.WindowStyle;
    end

end

if isempty(xdata) 
    xdata = [1 size(cdata,2)];
end

if isempty(ydata)
    ydata = [1 size(cdata,1)];
end

image_type = findImageType(cdata,map);
cdata = validateCData(cdata,image_type);

cdatamapping = getCDataMapping(image_type);

if strcmp(cdatamapping,'scaled')
    map = gray(256);

    if isempty(clim) || (clim(1) == clim(2)) 
        clim = getrangefromclass(cdata);
    end    
end

clim = checkDisplayRange(clim);

%----------------------------------------------------
function [cdatamapping] = getCDataMapping(image_type)

cdatamapping = 'direct'; 

% cdatamapping is not relevant for RGB images, but we set it to something so
% we can call IMAGE with one set of arguments no matter what image type.

% May want to treat binary images as 'direct'-indexed images for display
% in HG which requires no map.
%
% For now, they are treated as 'scaled'-indexed images for display in HG.

switch image_type
  case {'intensity','binary'}
    cdatamapping = 'scaled';
    
  case 'indexed'
    cdatamapping = 'direct';    
    
end

%---------------------------------
function clim = getAutoCLim(cdata)

clim = double([min(cdata(:)) max(cdata(:))]);

%-----------------------------------------------
function cdata = validateCData(cdata,image_type)

if ((ndims(cdata) > 3) || ((size(cdata,3) ~= 1) && (size(cdata,3) ~= 3)))
    eid = sprintf('Images:%s:unsupportedDimension',mfilename);
    error(eid, '%s', 'Unsupported dimension')
end

if islogical(cdata) && (ndims(cdata) > 2)
    eid = sprintf('Images:%s:expected2D',mfilename);
    error(eid, '%s', 'If input is logical (binary), it must be two-dimensional.');
end

% RGB images can be only be uint8, uint16, single, or double
if ( (ndims(cdata) == 3)   && ...
     ~isa(cdata, 'double') && ...
     ~isa(cdata, 'uint8')  && ...
     ~isa(cdata, 'uint16') && ...
     ~isa(cdata, 'single') )
    eid = sprintf('Images:%s:invalidRGBClass',mfilename);
    msg = 'RGB images must be uint8, uint16, single, or double.';
    error(eid,'%s',msg);
end

if strcmp(image_type,'indexed') && isa(cdata,'int16')
    eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
    msg1 = 'An indexed image can be uint8, uint16, double, single, or ';
    msg2 = 'logical.';
    error(eid,'%s %s',msg1, msg2);
end

% Clip double and single RGB images to [0 1] range
if ndims(cdata) == 3 && ( isa(cdata, 'double') || isa(cdata,'single') )
    cdata(cdata > 1) = 1;
    cdata(cdata < 0) = 0;
end

% Catch complex CData case
if (~isreal(cdata))
    wid = sprintf('Images:%s:displayingRealPart',mfilename);
    warning(wid, '%s', 'Displaying real part of complex input.');
    cdata = real(cdata);
end

%------------------------------------------------
function display_range = checkDisplayRange(display_range)

if isempty(display_range)
    return
end

if numel(display_range) ~= 2
    eid = sprintf('Images:%s:not2ElementVector',mfilename);
    error(eid,'%s','[LOW HIGH] must be a 2-element vector.')
end

iptcheckinput(display_range, {'numeric'},...
              {'real' 'nonsparse' 'vector'}, ...
              mfilename, '[LOW HIGH]', 2);

if display_range(2) <= display_range(1)
  eid = sprintf('Images:%s:badRangeValues', mfilename);
  error(eid,'%s','HIGH must be greater than LOW.');
end

display_range = double(display_range);

%----------------------------------------------
function [img,map] = getImageFromFile(filename)

if ~exist(filename, 'file')
  eid = sprintf('Images:%s:fileDoesNotExist',mfilename);
  msg = sprintf('Cannot find the specified file: "%s"', filename);
  error(eid,'%s',msg);
end

wid = sprintf('Images:%s:multiframeFile',mfilename);

try
  [img,map] = imread(filename);
  info = imfinfo(filename);
  if numel(info) > 1
      warning(wid,'Can only display one frame from this multiframe file: %s.', filename);
  end
  
catch
    try
        info = dicominfo(filename);
        if isfield(info,'NumberOfFrames')
            [img,map] = dicomread(info,'Frames',1);
            warning(wid,'Can only display one frame from this multiframe file: %s.',filename);
        else
            [img,map] = dicomread(info);
        end
        
    catch
        eid = sprintf('Images:%s:couldNotReadFile',mfilename); 
        error(eid,'Could not read this file: "%s"', filename);
    end
end    

%------------------------------------------------------------------------
function args = parseParamValuePairs(in,valid_params,num_pre_param_args,...
                                     function_name)

if rem(length(in),2)~=0
    eid = sprintf('Images:%s:oddNumberArgs',function_name);
    msg = sprintf(...
        'Function %s expected an even number of parameter/value arguments.',...
        upper(function_name));
    error(eid,msg)
end    

for k = 1:2:length(in)
    prop_string = iptcheckstrs(in{k}, valid_params, function_name,...
                               'PARAM', num_pre_param_args + k);
    
    switch prop_string
      case 'DisplayRange'
        args.(prop_string) = checkDisplayRange(in{k+1});
        
      case 'InitialMagnification'
       args.(prop_string) = in{k+1};
       
      case {'XData','YData'}
        args.(prop_string) = in{k+1};
        checkCoords(in{k+1},upper(prop_string),num_pre_param_args+k+1)        

      case {'WindowStyle'}
        args.(prop_string) = in{k+1};
        if ischar(in{k+1})
            args.(prop_string) = iptcheckstrs(in{k+1}, {'docked','normal'},...
                                              function_name, 'STYLE',...
                                              num_pre_param_args + k + 1);
        else
            eid = sprintf('Images:%s:invalidWindowStyle',function_name);
            error(eid,'%s',...
                  'STYLE must be either ''docked'' or ''normal''.');
        
        end
        
        if (~desktop('-inuse') || ~isJavaFigure) && strcmp(args.WindowStyle,'docked')
            args.WindowStyle = 'normal';
            wid = sprintf('Images:%s:unableToDock',mfilename);
            warning(wid, '%s', 'Unable to dock figure.');
        end
        
      otherwise
        eid = sprintf('Images:%s:unrecognizedParameter',function_name);
        error(eid,'%s','The parameter, %s, is not recognized by %s',...
              prop_string,function_name);
        
    end
end

%------------------------------------------------
function checkCoords(coords,coord_string,arg_pos)

iptcheckinput(coords, {'numeric'}, {'real' 'nonsparse' 'finite' 'vector'}, ...
              mfilename, coord_string, arg_pos);

if numel(coords) < 2
  eid = sprintf('Images:%s:need2Coords', mfilename);
  error(eid,'%s must be a 2-element vector.',coord_string);
end

%----------------------------------------
function imgtype = findImageType(img,map)

if (isempty(map))
  if (ndims(img) == 3) 
    imgtype = 'truecolor';
  elseif strcmp(class(img),'logical')
    imgtype = 'binary';
  else
    imgtype = 'intensity';
  end    
else
  imgtype = 'indexed';            
end

