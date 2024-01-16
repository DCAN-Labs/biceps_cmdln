function M = cifti2mat(path_to_cifti, varargin)

% M = cifti2mat(path_to_cifti)
% First line of code: Sept 9, 2020
% Oscar Miranda-Dominguez

if nargin == 1
    handles=[];
    handles = validate_path_wb_command(handles);
    path_wb_command=handles.paths.wb_command;
else
    path_wb_command=varargin{1};
end


%% Read cifti and save as double
cii=ciftiopen(path_to_cifti,path_wb_command);
newcii=cii;
X=newcii.cdata;
M=double(X);