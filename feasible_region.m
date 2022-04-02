function [Power_limit_HSTnormal,Power_limit_HSTlimit,Power_limit_TOT,current_limit,top_line]=feasible_region(AMB,HST_limit,TOT_limit)
%% Goal of this function
% This function creates a feasible region of transformer loadings in 
% accordance with temperature and current limitations from IEC 60076-7

% SYNTAX of this function:
% Input of this function:
% AMB - a vector of ambient temperature; 
% HST_limit - a value of hot spot temperature limit;
% TOT_limit - a value of top-oil temperature limit; 

% Output of this function:
% Power_limit_HSTnormal - a vector of power limits corresponding to normal 
%                         hot spot temperature of windings; 

% Power_limit_HSTlimit -  a vector of power limits corresponding to a limit 
%                         of  hot spot temperature of windings; 
%                        
% Power_limit_TOT      -  a vector of power limits corresponding to a limit 
%                         of top-oil temperature oin the tank;

% current_limit         - a current limitation of transformer; 

% top_line -            - a top line of feasible region. This is a vector 
%                         of the lowest values among three lines:
%                         Power_limit_HSTlimit, Power_limit_TOT,
%                         current_limit;
%% Setting the thermal and current constraints according to IEC 60076-7 2018
current_limit=linspace(1.5,1.5,length(AMB))'; % limit of current, per unit
HST_normal=98; % a design temperature of windings, °C

%% Finding the feasible regions of ONAF transformer
% Finding a power limit for ToT limit
[Power_limit_TOT]=feasible_region_TOT(AMB,TOT_limit);

% Finding a power limit for design HST 
[Power_limit_HSTnormal]=feasible_region_HST(AMB,HST_normal);

% Finding a power limit for a HST limit
[Power_limit_HSTlimit]=feasible_region_HST(AMB,HST_limit);

% Selecting the lowest line between three areas (defined above)
top_line=min(min(Power_limit_TOT,Power_limit_HSTlimit),current_limit);

end % end of function