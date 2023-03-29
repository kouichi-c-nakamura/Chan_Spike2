function chanSpec = K_getChanSpec_afterSyncSmrXlsxMat(smrdir, matdir, excelmasterpath)
%
% chanSpec = K_getChanSpec_afterSyncSmrXlsxMat(smrdir, matdir, excelmasterpath)
% 
% K_getChanSpec_afterSyncSmrXlsxMat is a wrapper function of
% K_syncSmrXlsxMat. You can use this function to make *.smr files in
% smrdir, **_info.xlsx and *_m.mat files in matdir updated and
% synchronized. 
% 
% chanSpec = K_getChanSpec_afterSyncSmrXlsxMat(smrdir, matdir, excelmasterpath)
%
% INPUT ARGUMENTS
% smrdir      Directory path for *.smr files
%
% matdir      Directory path for *m.mat files. This folder can also contain
%               *m.mat files, *_mk_mat files, *_sp.mat files,
%               *_info.xlsx files.
%
% excelmasterpath
%               The full file path for the master Excel file that contains
%               extra information about each channel of recordings.
%
% OUTPUT ARGUMENT
% chanSpec      a ChanSpecifier object.
%
%
% See also
% K_syncSmrXlsxMat, ChanSpecifier, K_checkmerge

dbstop if error;

cd(matdir);

isemptyall = false;

k = 0;
while ~isemptyall 
    [~, Saft] = K_syncSmrXlsxMat(smrdir, matdir, excelmasterpath);
    
    isemptyall = all([isempty(Saft.smr_updateMat), isempty(Saft.smr_addXlsxupdateMat),...
        isempty(Saft.smr_addMat), isempty(Saft.xlsx_rmXlsx), isempty(Saft.mat_rmMat)]);
    k = k + 1;
    
    if k > 10
       error('K:processSpksandEEGs',...
           'More than 10 cycles of K_syncSmrXlsxMat have not successfully synced files. Something is wrong!');
        
    end
end
clear k

chanSpec = ChanSpecifier(matdir);

end







