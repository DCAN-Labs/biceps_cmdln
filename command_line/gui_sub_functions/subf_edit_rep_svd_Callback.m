function [handles] = subf_edit_rep_svd_Callback(handles, rep_svd)
%UNTITLED16 Summary of this function goes here
%   Detailed explanation goes here

temp = rep_svf;
if temp<0
    temp=0;
end

handles.connectotyping_settings.rep_svd=temp;

end