%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LIST STACKS FOR TRACKING
%% 
%% This folder forms a list of stack files suitable for input into 
%% getFluorescentImages_batch.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function list_stacks_for_tracking()

directory = uigetdir();

all_stk = dir(directory);

prompt=('Experiment Name');
info = inputdlg(prompt,'Choose an experiment name');
exp_name = info{1}; 

list = {};

for n=3:length(all_stk),
    c=all_stk(n).name;
    name = strcat('if count ==',num2str(n-2),',','fName =','''',c,'''',';','end');
    list{n-2,1}=name;
end

fName = strcat(exp_name,'_stack_batch_list.txt');

file_output = fopen(fName, 'w');

for n=1:length(list),

        r = list{n};
        fprintf(file_output, '%s\n',r);

end

fclose(file_output);
 
