function [outlon outlat seafloor ]=extract_005_GEBCO(gebco_Address,lonlimit,latlimit)
% read depth from 30 arc-second GECBO data 
% the data can be download from 
% http://www.bodc.ac.uk/data/online_delivery/gebco/
% seafloor is lon*lat


res = 1/120;% resolution in degree
% gebco_Address = which('gebco_SID.nc');
 
fid=netcdf.open(gebco_Address,'NC_NOWRITE');
%----------------- axis ----------------------
XrangeID  = netcdf.inqVarID(fid ,'x_range');
Xrange  = netcdf.getVar(fid ,XrangeID);
YrangeID  = netcdf.inqVarID(fid ,'y_range');
Yrange  = netcdf.getVar(fid ,YrangeID);
YrangeID  = netcdf.inqVarID(fid ,'y_range');
Yrange  = netcdf.getVar(fid ,YrangeID);
dimLengthID = netcdf.inqVarID(fid ,'dimension');
dimLength   = netcdf.getVar(fid ,dimLengthID);

lon = Xrange(1)+res/2:res:Xrange(2)-res/2;
lat = Yrange(1)+res/2:res:Yrange(2)-res/2;

%check dimension
if ~(length(lon) == dimLength(1) && length(lat) == dimLength(2) )
    error('wrong dimension, please reset the resolution') 
end

%----------get the locaiton of what we need------------
outlonloc = find(lon>lonlimit(1) & lon<lonlimit(2));
outlatloc = find(lat>latlimit(1) & lat<latlimit(2));

outlon = lon(outlonloc);
outlat = lat(outlatloc);

%------------ read topography ----------------
seafloorID  = netcdf.inqVarID(fid ,'z');
% seafloor  = netcdf.getVar(fid ,seafloorID,[outlonloc(1) outlatloc(1)],[length(outlonloc) length(outlatloc)],[1 1]);

outlatloc = 180/res - outlatloc  ;
for ii=1:length(outlat)
    
inid1 = outlatloc(ii)*360/res + outlonloc(1);
inid2 = outlatloc(ii)*360/res + outlonloc(end);

seafloor(:,ii)  = netcdf.getVar(fid ,seafloorID,inid1,inid2-inid1+1);
% inid1=sub2ind([length(lon) length(lat)],outlonloc(1),outlatloc(ii));
% inid2=sub2ind([length(lon) length(lat)],outlonloc(end),outlatloc(ii));
% 
% seafloor(:,ii)  = netcdf.getVar(fid ,seafloorID,inid1,inid2-inid1+1);

end

seafloor=double(seafloor);



