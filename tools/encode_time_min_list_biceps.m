function [fconn_text, T] = encode_time_min_list_biceps(path_gui_env_list)
%ENCODE_TIME_MIN_LIST_BICEPS Extracts time-related parameters from a BICEPS filename.
%
%   [fconn_text, T] = ENCODE_TIME_MIN_LIST_BICEPS(path_gui_env_list)
%
%   This function parses a BICEPS-formatted file path or filename to extract:
%     - Frame displacement threshold (FD)
%     - Minimum frames
%     - TR in seconds
%   It then computes the total time in minutes and returns a standardized filename
%   and a summary table with the extracted values.
%
%   Input:
%     path_gui_env_list : string
%         A full file path or filename string that includes BICEPS naming
%         components, such as:
%         '...FD_th_0_2_min_frames_180_TRseconds_0_8_min_frames...'
%
%   Output:
%     fconn_text : string
%         A standardized filename in the format:
%         'FD_th_<value>_time_min_<minutes>_TRseconds_<value>.csv'
%
%     T : table
%         A table summarizing the extracted and computed values with columns:
%           - Frame_displacement : FD threshold (numeric, in mm)
%           - Time_in_minutes    : Total scan time (in minutes)
%           - TR_in_seconds      : Temporal resolution (in seconds)
%
%   Example:
%     path = '...FD_th_0_2_min_frames_180_TRseconds_0_8_min_frames...';
%     [fname, summary] = encode_time_min_list_biceps(path);
%
%   See also: extractBetween, str2double, array2table


%%
bef{1}='FD_th_';
bef{2}='min_frames_';
bef{3}='TRseconds_';


aft{1}='_min_frames';
aft{2}='_skip_frames';
aft{3}='.txt';

n=numel(aft);
bet=cell(n,1);
bet_num=nan(n,1);
old='_';
new='.';
T=nan(1,3);

for i=1:n
    bet{i}=extractBetween(path_gui_env_list,bef{i},aft{i});
    temp=replace( bet{i} , old , new );
    bet_num(i)=str2double(temp);
end
time_min=prod(bet_num(2:3))/60;
fconn_text = [bef{1} bet{1}{1} '_time_min_' num2str(time_min) '_' bef{3} bet{3}{1} '.txt'];

%% Make output as table
T=nan(1,3);
T(1)=str2num(replace(bet{1}{1},'_','.'));
T(2)=time_min;
T(3)=str2num(replace(bet{3}{1},'_','.'));
T=array2table(T);
T.Properties.VariableNames{1}='Frame_displacement';
T.Properties.VariableNames{2}='Time_in_minutes';
T.Properties.VariableNames{3}='TR_in_seconds';