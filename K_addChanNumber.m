% [FileName,PathName] = uigetfile();

clear;close all;clc;


%% Choose the text file containing chantitle and channumber
FileName = 'ExportAsMat_chan.txt';
PathName = 'Z:\\Work';



load('Z:\Work\kjx145f01.mat');
mname = 'kjx145f01';


cd(PathName)
listing = dir('*.mat');
mnames = {listing.name}';

for i=1:length(mnames)
    channels = K_ %TODO
    obj = K_setChanNumber(obj, PathName, mnames(i));
end

%TODO
% "for" loop for a folder
% load .mat files and convert them into channels object
% delete the original (optional)
% add channumber into Header of each Chan object
% 
% INPUT 
% folderpathin
% folderpathout
%
% OUTPUT
% list of .mat file names in cell array
% folder path