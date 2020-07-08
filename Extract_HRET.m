function [HAR_complex,lon,lat,seafloor_result] = Extract_HRET(lon_bound,lat_bound,h)

%% Load the HRET data for M2 in the selected region (see Zaron 2019, Gong et al. 2020)
%  Input: 
%  1) latitude (-90 - 90) and longitude (-180 - 180)
%          e.g. [103 125] for lon_bound; [-24 0] for lat_bound
%       Note: The DFF results would be better if the seleted region is
%       approximately a square.
%  2) Harmonic selection (M2,S2,O1,K1)
%          e.g. h = 1 (M2)
%  Output: 
%  1) Complexed SSHbc in the selected region
%  2) Longitude and latitude of cells in the region
%  3) Bathymetry data in the selected region

%  written by Gong Yankun in July 2020

%% Define the 4 key harmonics
HAR = ['M2';'S2';'K1';'O1'];
T_period = [12.42,12,23.93,25.82]; % unit: hrs

%% Load the HRET dataset and the GEBCO bathymetry dataset 
% Note the GEBCO bathymetry data has been processed to match cells of HRET
HRET_FileList = dir(fullfile('../../', '**', 'HRET_v8.1_compressed.nc'));
Bathy_FileList = dir(fullfile('../../', '**', 'Bathy_HRET.nc'));

ncload([HRET_FileList(1).folder '/' HRET_FileList(1).name],'latitude','longitude');
ncload([Bathy_FileList(1).folder '/' Bathy_FileList(1).name],'Topo');

% Longitude in HRET 0 - 360 degree
% Convert it to -180 - 180 degree
longitude(longitude>180) = longitude(longitude>180) - 360;

HAR_im = ncread([HRET_FileList(1).folder '/' HRET_FileList(1).name],[HAR(h,:) 'im'])';
HAR_re = ncread([HRET_FileList(1).folder '/' HRET_FileList(1).name],[HAR(h,:) 're'])';

[a lon_num(1)] = min(abs(longitude-lon_bound(1)));
[a lon_num(2)] = min(abs(longitude-lon_bound(2)));
[a lat_num(1)] = min(abs(latitude-lat_bound(1)));
[a lat_num(2)] = min(abs(latitude-lat_bound(2)));

lon_num(2) = lon_num(2)-1;
lat_num(2) = lat_num(2)-1;

lon = longitude(lon_num(1):lon_num(2));
lat = latitude(lat_num(1):lat_num(2));

HAR_re_small = HAR_re(lat_num(1):lat_num(2),lon_num(1):lon_num(2));
HAR_im_small = HAR_im(lat_num(1):lat_num(2),lon_num(1):lon_num(2));
seafloor_result = Topo(lat_num(1):lat_num(2),lon_num(1):lon_num(2));
clear Topo

% set the 
seafloor_result(seafloor_result>0)=0;
seafloor_result = seafloor_result';

clear Topo mesh* Lon* Lat* lat_* lon_* 

%% Amplitude and phase of internal tides for the HARMONIC
HAR_theta = atan2d(HAR_im_small , HAR_re_small); % Phase of SSH_bc(unit: degree)
HAR_amp = sqrt(HAR_im_small.^2 + HAR_re_small.^2); % Amplitude of SSH_bc (unit: meter)

HAR_complex = HAR_re_small + i*HAR_im_small;
HAR_complex = HAR_complex'; % size: Lon * Lat

end

