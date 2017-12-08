function excel_export_bacs(ratio4axis,lnZ_AND_ampli,lnZ_SUM,new_red_ampli_collected,all_red_ampli_collected,all_blue_ampli_collected,save_name)
    
    
    [ratio4axis_sorted, index_sort] = sort(ratio4axis);
    
    columns = {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'; 'I'; 'J' ;'K' ;'L'; 'M'; 'N'; 'O'; 'P'; 'Q' ;'R'; 'S'; 'T'; 'U'; 'V'; 'W'; 'X'; 'Y' ;'Z'; 'AA'; 'AB'; 'AC';'AD'; 'AE' ;'AF';'AG';'AH' ;'AI' ;'AJ' ;'AK';'AL';'AM'; 'AN'; 'AO'; 'AP'; 'AQ' ;'AR'; 'AS'; 'AT'; 'AU'; 'AV'; 'AW'; 'AX'; 'AY' ;'AZ'; 'BA'; 'BB'; 'BC'; 'BD'; 'BE'; 'BF'; 'BG'; 'BH'; 'BI'; 'BJ' ;'BK' ;'BL'; 'BM'; 'BN'; 'BO'; 'BP'; 'BQ' ;'BR'; 'BS'; 'BT'; 'BU'; 'BV'; 'BW'; 'BX'; 'BY' ;'BZ'; 'CA'; 'CB'; 'CC'; 'CD'; 'CE'; 'CF'; 'CG'; 'CH'; 'CI'; 'CJ' ;'CK' ;'CL'; 'CM'; 'CN'; 'CO'; 'CP'; 'CQ' ;'CR'; 'CS'; 'CT'; 'CU'; 'CV'; 'CW'; 'CX'; 'CY' ;'CZ'; 'DA'; 'DB'; 'DC'; 'DD'; 'DE'; 'DF'; 'DG'; 'DH'; 'DI'; 'DJ' ;'DK' ;'DL'; 'DM'; 'DN'; 'DO'; 'DP'; 'DQ' ;'DR'; 'DS'; 'DT'; 'DU'; 'DV'; 'DW'; 'DX'; 'DY' ;'DZ'; 'EA'; 'EB'; 'EC'; 'ED'; 'EE'; 'EF'; 'EG'; 'EH'; 'EI'; 'EJ' ;'EK' ;'EL'; 'EM'; 'EN'; 'EO'; 'EP'; 'EQ' ;'ER'; 'ES'; 'ET'; 'EU'; 'EV'; 'EW'; 'EX'; 'EY' ;'EZ'};
  
    
    
    count = 1;
    for n5=1:length(index_sort)
        
        col = columns{count};
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),ratio4axis_sorted(n5),strcat(col,'1:',col,'1'))
        
        
        lnZ_AND_sorted{n5} = lnZ_AND_ampli{index_sort(n5)};
        
        length_excelsheet = length(lnZ_AND_sorted{n5});
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),{'LnZ'},strcat(col,'2:',col,'2'));
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),lnZ_AND_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
        
        new_red_ampli_collected_sorted{n5} = new_red_ampli_collected{index_sort(n5)};
        
        col = columns{count+1};
        length_excelsheet = length(new_red_ampli_collected_sorted{n5});
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),{'red int normalised'},strcat(col,'2:',col,'2'));
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),new_red_ampli_collected_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
        
        
        
        all_red_ampli_collected_sorted{n5} = all_red_ampli_collected{index_sort(n5)};
        
        col = columns{count+2};
        length_excelsheet = length(all_red_ampli_collected_sorted{n5});
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),{'red int'},strcat(col,'2:',col,'2'));
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),all_red_ampli_collected_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
        
        
        
        all_blue_ampli_collected_sorted{n5} = all_blue_ampli_collected{index_sort(n5)};
        
        col = columns{count+3};
        length_excelsheet = length(all_blue_ampli_collected_sorted{n5});
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),{'blue int'},strcat(col,'2:',col,'2'));
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),all_blue_ampli_collected_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
        
         lnZ_SUM_sorted{n5} = lnZ_SUM{index_sort(n5)};
        
        col = columns{count+4};
        length_excelsheet = length(lnZ_SUM_sorted{n5});
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),{'LnZ SUM'},strcat(col,'2:',col,'2'));
        xlswrite1(strcat(save_name,'collected_data_ampli.xls'),lnZ_SUM_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
        
        count = count + 5;
    end
    
    
    
    
    
    %statistics
    fid = fopen(strcat(save_name,'_results_ttest.dat'),'a');
    for n4=1:length(lnZ_AND_sorted)-1
        
        getstats_vs7(lnZ_AND_sorted{n4},lnZ_AND_sorted{n4+1},ratio4axis_sorted(n4),ratio4axis_sorted(n4+1),'AND',' integrated intensity',fid);
        getstats_vs7(lnZ_SUM_sorted{n4},lnZ_SUM_sorted{n4+1},ratio4axis_sorted(n4),ratio4axis_sorted(n4+1),'SUM',' integrated intensity',fid);
    end
    fclose(fid);
    
    
    
%       count = 1;
%     for n5=1:length(index_sort)
%         
%         col = columns{count}
%         xlswrite1(strcat(save_name,'collected_data.xls'),ratio4axis_sorted(n5),strcat(col,'1:',col,'1'))
%         
%         
%         lnZ_SUM_sorted{n5} = lnZ_SUM{index_sort(n5)};
%         
%         length_excelsheet = length(lnZ_SUM_sorted{n5});
%         xlswrite1(strcat(save_name,'collected_data.xls'),{'LnZ'},strcat(col,'2:',col,'2'))
%         xlswrite1(strcat(save_name,'collected_data.xls'),lnZ_SUM_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
%         
%         new_red_int_collected_sorted{n5} = new_red_int_collected{index_sort(n5)};
%         
%         col = columns{count+1}
%         length_excelsheet = length(new_red_int_collected_sorted{n5});
%         xlswrite1(strcat(save_name,'collected_data.xls'),{'red int normalised'},strcat(col,'2:',col,'2'))
%         xlswrite1(strcat(save_name,'collected_data.xls'),new_red_int_collected_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
%         
%         
%         
%         all_red_int_collected_sorted{n5} = all_red_int_collected{index_sort(n5)};
%         
%         col = columns{count+2}
%         length_excelsheet = length(all_red_int_collected_sorted{n5});
%         xlswrite1(strcat(save_name,'collected_data.xls'),{'red int'},strcat(col,'2:',col,'2'))
%         xlswrite1(strcat(save_name,'collected_data.xls'),all_red_int_collected_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
%         
%         
%         
%         all_blue_int_collected_sorted{n5} = all_blue_int_collected{index_sort(n5)};
%         
%         col = columns{count+3}
%         length_excelsheet = length(all_blue_int_collected_sorted{n5});
%         xlswrite1(strcat(save_name,'collected_data.xls'),{'blue int'},strcat(col,'2:',col,'2'))
%         xlswrite1(strcat(save_name,'collected_data.xls'),all_blue_int_collected_sorted{n5},strcat(col,'3:',col,num2str(length_excelsheet)))
%         
%         
%         count = count + 4;
%         
%     end
end