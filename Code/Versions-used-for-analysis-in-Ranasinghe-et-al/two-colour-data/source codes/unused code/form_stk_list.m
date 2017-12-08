function form_stk_list()

all_stk = dir('*.stk');
list = {};

for n=3:length(all_stk),
    c=all_stk(n).name;
    name = strcat('if count ==',num2str(n-2),',','fName =','''',c,'''',';','end');
    list{n-2,1}=name;
end

ex2 = cellfun(@ex_func,list,'UniformOutput',0);
size_ex2 = cellfun(@length,ex2,'UniformOutput',0);
str_length = max(max(cell2mat(size_ex2)));
ex3 = cellfun(@(x) ex_func2(x,str_length),ex2,'uniformoutput',0);

ex4 = cell2mat(ex3);
fid = fopen('form_stk_list.txt','wt');
for i = 1:size(ex4,1)
    fprintf(fid,'%s\n',ex4(i,:));
end
fclose(fid);

function [ out ] = ex_func( in )

in_datatype = class(in);

switch in_datatype
    case 'char'
        out = in;
    case 'double'
        out = num2str(in);
end

function [ out ] = ex_func2( in, str_length )

a = length(in);
out = [char(32*ones(1,str_length-a)), in];