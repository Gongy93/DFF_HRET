function [HAR_filter] = DFF_HRET(HAR_complex,angle1,angle2,seafloor_result)

%% The directional Fourier Filter method (see Mercier et al. 2008, Gong et al. 2020)

%  Input: 
%  1) A complexed 2D matrix of the variable (m*n), 
%     for example SSH_bc, including both amplitude and phase. 
%     m: longitude size; n: latitude size
%  2) Filtered band/ angle (alpha1, alpha2)
%     angle1: the lower band of angle filter (0-360 degree)
%     angle2: the upper band of angle filter (0-360 degree)
%     Note: the filtering band is from alpha1 to alpha2 (counter-clockwise)
%      Angle filter band (0 - 360 degree, start from the eastward)
%     e.g. angle1 = 90; angle2 = 200; % unit: degree
%  3) Bathymetry data in the selected region

%  Output: 
%  1) The wave signal propagating in a certain direction (angle1 - angle2),
%            including amplitude and phase.

%  written by Gong Yankun in July 2020

%% Mask out the locations of land
HAR_complex(seafloor_result==0) = 0;
mask_land = HAR_complex;

% Do the 2D spatial Fourier filter to get the variables in wavenumber space     
Y0 = fft2(HAR_complex); % in the wavenumber space

%% Calculate the filtering function (m*m)
%  We will 2D interpolate back to m*n
x=linspace(-1,1,max(size(HAR_complex)));
y=fliplr(linspace(-1,1,max(size(HAR_complex))));
[X,Y]=meshgrid(x,y);

%% Coordinates to polarcoordinates
[phi, rho]=cart2pol(X,Y);
phi=rad2deg(phi);
% phi(phi<0)=-phi(phi<0);
phi(phi<0)=360+phi(phi<0);
phi = 360-phi; % make sure the angle is couterclockwise

%% Generate mask function
%  There are two conditions: angle1<angle2 and angle1>angle2
if angle1<angle2
mask = phi>angle1 & phi<angle2;
end

if angle1>angle2
mask = (phi>angle1 & phi<360) |  (phi>=0 & phi<angle2);
end

%% interpolate back to m*n matrix
[x_interp,y_interp] = meshgrid(linspace(1,max(size(Y0)),size(Y0,1)),...
    linspace(1,max(size(Y0)),size(Y0,2)));
x_interp = x_interp';
y_interp = y_interp';

mask_interp = interp2(1:max(size(Y0)),1:max(size(Y0)),double(mask),...
    x_interp,y_interp);

HAR_filter = ifft2(Y0.*mask_interp);
HAR_filter(mask_land==0) = nan; 

% Filtered amplitude and phase
% Amp_filter = abs(ifft2(HAR_filter));
% Gph_filter = atan2d(real(ifft2(HAR_filter)),imag(ifft2(HAR_filter)));
% 
% % Mask out the land region
% Amp_filter(mask_land==0) = nan; 
% Gph_filter(mask_land==0) = nan; 
 

end
