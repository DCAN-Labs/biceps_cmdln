function save_raw_timecourses_flag = ask_save_raw_timecourses(to_do)

%0 = ask, negative = no save, positive = save
%% Promt user to ask about saving raw timecourses
if to_do == 0
    prompt={'Do you want to save timecourses (it requires extra space)?'};
    answer = questdlg(prompt, ...
        'Do you want to save timecourses?', ...
        'Yes','No','No');
elseif to_do > 0
    answer = 'Yes';
else 
    answer = 'No';
end
% Handle response
switch answer
    case 'Yes'
        save_raw_timecourses_flag = 1;
    case 'No'
        save_raw_timecourses_flag = 0;
        %     case 'No thank you'
        %         disp('I''ll bring you your check.')
        %         dessert = 0;
end
save_raw_timecourses_flag=save_raw_timecourses_flag==1;
