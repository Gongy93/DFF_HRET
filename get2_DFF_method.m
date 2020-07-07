clc
clear
close all

%% The directional Fourier Filter method (see Mercier et al. 2008, Gong et al. 2020)

%  Input: 1) A complexed 2D matrix of the variable (m*n), 
%            for example SSH_bc, including both amplitude and phase. 
%            m: longitude size
%            n: latitude size
%         2) Filtered band/ angle (alpha1, alpha2)
%            alpha1: the lower band of angle filter (0-360 degree)
%            alpha2: the upper band of angle filter (0-360 degree)
%            Note: the filtering band is from alpha1 to alpha2 (counterclockwise)
%         3) Bathymetry data to mask out those regions shallower than 200 m

%  Output: The wave signal propagating in a certain direction (alpha1 - alpha2),
%            including amplitude and phase.

%  written by Gong Yankun in July 2020

%% An simple example to show the method performance (Australian NWS)

% Load the SSHbc induced by M2 and the bathymetry
HAR = ['M2';'S2';'K1';'O1'];
% select M2 as an example
h = 1; % M2

load([HAR(h,:) '_complex.mat']); HAR_complex = HAR_complex';
% land regions are mask out as zeros

depth = seafloor_result'; clear seafloor_result

% Mask the locations of land
HAR_complex(depth==0) = 0;
mask_land = HAR_complex;

%% Angle filter band (0 - 360 degree, start from the eastward)
% make sure counter-clockwise
alpha1 = 90; % unit: degree
alpha2 = 200; % unit: degree

% Do the 2D spatial Fourier filter to get the variables in wavenumber space     
Y0 = fft2(HAR_complex); % in the wavenumber space

%% Calculate the filtering function (m*m)
%  We will 2D interpolate back to m*n
x=linspace(-1,1,max(size(Y0)));
y=fliplr(linspace(-1,1,max(size(Y0))));
[X,Y]=meshgrid(x,y);

%% Coordinates to polarcoordinates
[phi, rho]=cart2pol(X,Y);
phi=rad2deg(phi);
% phi(phi<0)=-phi(phi<0);
phi(phi<0)=360+phi(phi<0);
phi = 360-phi; % make sure the angle is couterclockwise

%% Generate mask function
%  There are two conditions: alpha1<alpha2 and alpha1>alpha2
if alpha1<alpha2
mask = phi>alpha1 & phi<alpha2;
end

if alpha1>alpha2
mask = (phi>alpha1 & phi<360) |  (phi>=0 & phi<alpha2);
end

%% interpolate back to m*n matrix
[x_interp,y_interp] = meshgrid(linspace(1,max(size(Y0)),size(Y0,1)),...
    linspace(1,max(size(Y0)),size(Y0,2)));
x_interp = x_interp';
y_interp = y_interp';

mask_interp = interp2(1:max(size(Y0)),1:max(size(Y0)),double(mask),...
    x_interp,y_interp);

Y0_alpha1_alpha2 = Y0.*mask_interp;

% Filtered amplitude and phase
Amp_alpha1_alpha2 = abs(ifft2(Y0_alpha1_alpha2));
Gph_alpha1_alpha2 = atan2d(real(ifft2(Y0_alpha1_alpha2)),...
     imag(ifft2(Y0_alpha1_alpha2)));

% Mask out the land region
Amp_alpha1_alpha2(mask_land==0) = nan; 
Gph_alpha1_alpha2(mask_land==0) = nan; 
 
%% Plot the figure of the filtered results
ratio_lola = length(lon)/length(lat);

color1 = dlmread('colormap_ZeorAtBegin.txt');

figure('visible','off','position',[100 100 1000*(ratio_lola+0.25) 1000]);
  
 a1 = axes('position',[.1 .1 .8 .8]);
 
 m_proj('miller','long',[lon(10) lon(end-10)],'lat',[lat(10) lat(end-98)]); 
 m_pcolor(lon(10:end-10),lat(10:end-10),Amp_alpha1_alpha2(10:end-10,10:end-10)'*100); 
  shading interp
 hold on;
 m_gshhs_h('patch',[.8 .8 .8],'edgecolor','k');
 m_grid('linewidth',2,'tickdir','out','fontsize',16);
 m_contour(lon(10:end-10),lat(10:end-10),depth(10:end-10,10:end-10)',...
  'LevelList',[0],'linecolor',[0 0 0],'linewidth',1.8)  
  hold on
 m_contour(lon(10:end-10),lat(10:end-10),depth(10:end-10,10:end-10)',...
  'LevelList',[-200 -1000 -2000],'linecolor',[0.6 0.6 0.6],'linewidth',1.5) 

caxis([0 4]);
 colormap(a1,color1(5:5:end-40,:));
 hold on;
title([' SSH_{bc} - ' HAR(h,:) ' [ Angle ranging from ' num2str(alpha1) ...
    ' ^o to ' num2str(alpha2) ' ^o ]'],'fontsize',17,'FontAngle','oblique');
 % m_text(118,-22,'North West Shelf','fontsize',17,'FontAngle','oblique'); 
 
 cb1 = colorbar(a1,'FontSize',16,'position',[.92 .1 .01 .8],'fontangle','oblique');
 set(get(cb1,'Title'),'string',' cm','fontsize',16,'fontangle','oblique');
 
 set(a1,'fontsize',16,'linewidth',2);
 
 saveas(gca,[HAR(h,:) '_Amp_' num2str(alpha1,'%03i') '_' ...
     num2str(alpha2,'%03i') 'deg.tif'],'tif');
 close all


