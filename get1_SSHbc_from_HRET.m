clc
clear
close all

%% Load the HRET data for M2 in the selected region
%  (see Zaron 2019, Gong et al. 2020)
%  Input: 1) latitude (lat_bound) and longitude (lon_bound)
%         2) Harmonic selection (M2,S2,O1,K1)
%         3) HRET_v8.1_compressed
%         4) Bathymetry: GEBCO Dataset

%  Output: 1) Complexed SSHbc in the selected region
%          2) Bathymetry data in the selected region

%  written by Gong Yankun in July 2020

%% Here we selet the North West Shelf as a template
lon_bound = [103 125];
lat_bound = [-24 0];

%% 4 Harmonics
HAR = ['M2';'S2';'K1';'O1'];
T_period = [12.42,12,23.93,25.82]; % unit: hrs

% select M2 as an example
h = 1; % M2

ncload('./HRET_v8.1_compressed.nc','latitude','longitude');

% Longitude in HRET 0 - 360 degree
% Convert it to -180 - 180 degree
longitude(longitude>180) = longitude(longitude>180) - 360;

HAR_im = ncread('./HRET_v8.1_compressed.nc',[HAR(h,:) 'im'])';
HAR_re = ncread('./HRET_v8.1_compressed.nc',[HAR(h,:) 're'])';

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

% Load the bathymetry data from Gebco

disp('Using GEBCO data')
 if ~exist('gebco_Address','var') || isempty(gebco_Address)
  gebco_Address = '.\gebco_08.nc';
 end
    [Lon Lat Topo]=extract_005_GEBCO(gebco_Address,...
        [max(lon_bound(1)-1,-180) min(lon_bound(end)+1,180)],...
        [max(lat_bound(1)-1,-90) min(lat_bound(end)+1,90)]...
        );

[a Lon_num(1)] = min(abs(Lon-lon_bound(1)));
[a Lon_num(2)] = min(abs(Lon-lon_bound(2)));
[a Lat_num(1)] = min(abs(Lat-lat_bound(1)));
[a Lat_num(2)] = min(abs(Lat-lat_bound(2)));

lon_geo = Lon(Lon_num(1):Lon_num(2));
lat_geo = Lat(Lat_num(1):Lat_num(2));

Topo_geo = Topo(Lon_num(1):Lon_num(2),Lat_num(1):Lat_num(2)); clear Topo
Topo_geo = double(Topo_geo);

[mesh_lon_geo mesh_lat_geo] = meshgrid(lon_geo,lat_geo);
[mesh_lon mesh_lat] = meshgrid(lon,lat);

% 2-D Interpolation of bathymetry
seafloor_result = interp2(mesh_lon_geo,mesh_lat_geo,Topo_geo',...
   mesh_lon,mesh_lat,'linear')';

seafloor_result(seafloor_result>0)=0;
seafloor_result = seafloor_result';

clear Topo mesh* Lon* Lat* lat_* lon_* 

%% Amplitude and phase of internal tides for the HARMONIC
HAR_theta = atan2d(HAR_im_small , HAR_re_small); % Phase of SSH_bc(unit: degree)
HAR_amp = sqrt(HAR_im_small.^2 + HAR_re_small.^2); % Amplitude of SSH_bc (unit: meter)

HAR_complex = HAR_re_small + i*HAR_im_small;

%% Save the complexed value of the HARMONIC
save([HAR(h,:) '_complex.mat'],'HAR_complex','lon','lat','seafloor_result');

