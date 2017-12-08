function [isbatch,path] = run_batch
qstring = 'Run Batch version?';
choice = questdlg(qstring,'Mode of Program',...
    'Yes','No','Yes');
switch choice
    case 'Yes'
        isbatch = 1;
        
        prompt={'Please enter full path to data directory:'};
        defans = {'C:\Users\Kristina\Dropbox\MeRFISH paper all FISH data\Version 17 -- three colour version for revision - for submission'};
        info = inputdlg(prompt,'path',1,defans);
        path = info{1};
        
    case 'No'
        isbatch = 0;
        
end