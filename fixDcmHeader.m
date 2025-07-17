% CD to image directory and alter FIXME lines prior to run
dcmDir = uigetdir;
dcmFiles = dir(fullfile(dcmDir,'*.MRDC.*')); %gets all MRDC files in directory

for x = 1:length(dcmFiles)
  dcmFileName = dcmFiles(x).name;
  disp(dcmFileName)
  dcmImg = dicomread(dcmFileName);
  dcmInfo = dicominfo(dcmFileName);
  updatedDcmInfo = dicomupdate(dcmInfo,"PatientAge",'077Y'); %FIXME
  updatedDcmInfo = dicomupdate(updatedDcmInfo,"PatientSex",'F'); %FIXME
  dicomwrite(dcmImg, dcmFileName, updatedDcmInfo);
end