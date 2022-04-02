function [HST,TOT,AEQ]=ONAF_transformer(PUL,AMB)
%% This function calculates thermal mode for ONAF power transformer per IEC 60076-7
% Input data:
%    PUL - loading of transformer in pu
%    AMB - ambient temperature, degC

% Output data:
%    HST_max - maximal hot-spot temerature of winding, degC
%    TOT_max - maximal top-oil temperature, degC
%    HST - profile of hot spot temperature 
%    TOT - profile of top oil  temperature
%    AEQ - ageing equivalent, pu relatve to normal ageing 
%    Current_ageing - ageing at each moment

%% Constants
% Thermal characteristics of ONAF power transformer per IEC60076-7
delta_theta_or = 52;     % Top-oil (in tank) temperature rise in steady state at rated losses (no-load losses + load losses),K
delta_theta_hr = 26;     % Hot-spot-to-top-oil (in tank) gradient at rated current, K
tao_0 = 150;             % Average oil time constant, min
tao_w = 7;               % Winding time constant, min
R = 6;                   % Ratio of load losses at rated current to no-load losses
x = 0.8;                 % Exponential power of total losses versus top-oil (in tank) temperature rise (oil exponent)
y = 1.3;                 % Exponential power of current versus winding temperature rise (winding exponent)
k11 = 0.5;                 % Thermal model constant
k21 = 2;                 % Thermal model constant
k22 = 2;                 % Thermal model constant

%% Solving the difference equations
% Change the variable
K=PUL;
theta_a=AMB;
Dt=1; % time step 1 minute


% Although the system may not strictly be in the steady state at the start of a calculation period,
% this is usually the best one can assume, and it has little effect on the result
K_0=K(1);
theta_a_0=theta_a(1);
theta_0 = ((1+K_0.^2.*R)./(1+R)).^x.*delta_theta_or+theta_a_0;    % top-oil temperature
delta_theta_h1 = k21*K_0.^y*delta_theta_hr;                       % Hot-spot-to-top-oil (in tank) gradient at start
delta_theta_h2 = (k21-1)*K_0.^y*delta_theta_hr;                   % Hot-spot-to-top-oil (in tank) gradient at start

Loss_of_life = 0;

% Create an array of hot-spot temperature and top-oil temperature
HST=NaN(length(K),1);
TOT=NaN(length(K),1);

% Solving difference (not differentiate!) equations: iterative approach (see
% Annex C in IEC 60076-7 for equations)
for i=1:1:length(K)
    
    D_theta_0 = (Dt./(k11.*tao_0)).*((((1+K(i).^2.*R)./(1+R)).^x).*(delta_theta_or)-(theta_0-theta_a(i)));
    theta_0 = theta_0+D_theta_0;
    
    D_delta_theta_h1 = Dt./(k22.*tao_w).*(k21.*delta_theta_hr.*K(i).^y-delta_theta_h1);
    delta_theta_h1 = delta_theta_h1+D_delta_theta_h1;
    
    D_delta_theta_h2 = Dt./(1./k22.*tao_0).*((k21-1).*delta_theta_hr.*K(i).^y-delta_theta_h2);
    delta_theta_h2 = delta_theta_h2+D_delta_theta_h2;
    
    delta_theta_h = delta_theta_h1-delta_theta_h2;
    
    HST(i,:) = theta_0+delta_theta_h;   % hot spot temperature 
    TOT(i,:)=theta_0; % top oil temperature
end

% Calculating ageing
AAF=NaN(length(K),1);

for i=1:1:length(HST)
%     AAF(i,:) = (exp((15000./(110+273)-15000./(HST(i)+273)))).*Dt;
    AAF(i,:) = (2^((HST(i)-98)/6)).*Dt;
end

Loss_of_life = Loss_of_life+AAF;
ASUM=sum(Loss_of_life); 

% Last outputs
AEQ=ASUM/length(K);
% HST_1=HST(1);
% HST_end=HST(end);
end


