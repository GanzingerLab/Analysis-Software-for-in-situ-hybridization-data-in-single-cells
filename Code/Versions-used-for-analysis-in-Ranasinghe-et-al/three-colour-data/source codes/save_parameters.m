function save_parameters(save_dir,parameters,setup)

fid = fopen(strcat(save_dir,'/', setup.directory,'_parameters.dat'),'w');

fprintf(fid, 'Parameters\n');
fprintf(fid, 'Initial Threshold\t%f\n',parameters.initialthreshold);
fprintf(fid, 'Bpass parameter lnoise\t%f\n',parameters.lnoise);
fprintf(fid, 'Bpass parameter lobject\t%f\n',parameters.lobject);
fprintf(fid, 'SNR threshold\t%f\n',parameters.SNR);
fprintf(fid, 'Pkfnd parameter\t%f\n',parameters.pkfnd_sz);
fprintf(fid, 'Cntrd parameter\t%f\n',parameters.cntrd_sz);
fprintf(fid, 'mean_in_spot parameter\t%f\n',parameters.mean_in_spot);
fprintf(fid, 'skewness parameter\t%f\n',parameters.skewness);
fprintf(fid, 'size parameter\t%f\n',parameters.size);

fprintf(fid, 'minimum track length\t%f\n',parameters.minLength);
fprintf(fid, 'memory\t%f\n',parameters.memory);
fprintf(fid, 'max step\t%f\n',parameters.max_step);
%fprintf(fid, 'max_step\t%f\n',parameters.max_step);

fclose(fid);