function [handles] = subf_checkboxmb_few_frames_Callback(handles,mb_few_frames)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
handles.env.flag(4)=mb_few_frames;
end