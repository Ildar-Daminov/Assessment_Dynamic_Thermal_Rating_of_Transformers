function [PUL_feasible_TOT]=feasible_region_TOT(AMB,TOT_limit)
%% Goal of this function
% This function calculates the admissible loading (PUL_final),corresponding 
% to a limit of top-oil temperature(TOT_limit)at a given ambient temperature 
% profile(AMB) 

%% Syntax of this function
% Input:
% AMB - ambient temperature profile around transformer. Vector [1:N,1]
% Format - vector

% TOT_limit - a top-oil temperature limit in tank
% Format - double 

% Output: 
% PUL_final - admissible loading (PUL)of ONAF power transformer. 
% Format - vector of the same size as AMB

%% Prepare the data  
% Load precalculated matrix ''Temp'' (see below) 
load('TOT_all.mat');

% Table "Temp": size 200x102
% ---------------------------------------------------------
%|    |        |       Ambient temperature range          |
%|  # |Loading |   -50°C   | -49°C | ...| +49°C | +50°C   |
%|    |---------------------------------------------------|
%|  1 |0.01 pu |  TOT1,°C  |  ...  |...|   ... | TOT1,°C  |
%|  2 |0.02 pu |  TOT2,°C  |  ...  |...|   ... | TOT2,°C  |
%|... |  ...   |   ...     |  ...  |...|   ... |   ...    |
%| 200|  2 pu  | TOT200,°C |  ...  |...|   ... | TOT200,°C|
%----------------------------------------------------------  
% Note: ambient temperature range is not included in"Temp"

% Extract table loadings (0.01 pu...2pu)
Table_Loadings=Temp(:,1);

% Ambient temperature range 
Amb_temperature_range=-50:1:50;

% Extract unique values of initial ambient temperature vector 
unique_values=unique(AMB);

%% Reconstructing the vector of PUl_final for given AMB vector
for i=1:length(unique_values)
    % Find index t of the closest value in vector Amb_temperature_range
    [~,t]=min(abs(Amb_temperature_range-unique_values(i)));
    
    if Amb_temperature_range(t)==unique_values(i)% AMB = in table
        
        % Extract HST for given unique_AMB_values(i) from matrix "Temp"
        Extracted_TOT=Temp(:,t+1);
        
        % Extract PUL for given AMB temperature using griddedInterpolant
        [~, index] = sort(Table_Loadings);
        F = griddedInterpolant(Extracted_TOT(index),Table_Loadings(index));
        PUL_steady_state(i)=F(TOT_limit);
        
    else % if  AMB does not match the closest value in vector "Amb_temperature_range" 
        if Amb_temperature_range(t)>unique_values(i) % if the closest value is higher
            
            % Extact the closest AMB from Amb_temperature_range
            AMB1(1:length(Table_Loadings),1)=Amb_temperature_range(t);
            
            % Extact the previous AMB from the closest value in Amb_temperature_range
            AMB2(1:length(Table_Loadings),1)=Amb_temperature_range(t-1);
            
            % Extract corresponding TOT from matrix "Temp"
            TOT1=Temp(:,t+1);% "t+1" in Temp corresponds to "t" in Amb_temperature_range!
            TOT2=Temp(:,t); % "t" in Temp corresponds to "t-1" in Amb_temperature_range!
            
        elseif Amb_temperature_range(t)<unique_values(i) % if the closest value is lower
            % Extract the next AMB after the closest value in Amb_temperature_range
            AMB1(1:length(Table_Loadings),1)=Amb_temperature_range(t+1);
            
            % Extact the closest AMB from Amb_temperature_range.
            AMB2(1:length(Table_Loadings),1)=Amb_temperature_range(t);
            
            % Extract corresponding TOT from matrix "Temp" 
            TOT1=Temp(:,t+2);% t+2 in Temp corresponds to "t+1" in Amb_temperature_range!
            TOT2=Temp(:,t+1);% t+1 in Temp corresponds to "t" in Amb_temperature_range!
            
        end % end of if Amb_temperature_range(t)>unique_AMB_values(i)
        
        % Create vectors of ambient and TOT 
        array_amb=[AMB2 AMB1];
        array_TOT=[TOT2 TOT1]; %[AMB2 AMB1] t+1!
        
        % Create target vectors of given ambient temperature AMB
        array_target=linspace(unique_values(i),unique_values(i),length(Table_Loadings))';
       
        % Find the interpolated TOT (vector)between given vectors TOT and
        % AMB for each value of Table_Loadings
        for j=1:length(Table_Loadings)
            TOT_interpolated(j,1)=interp1(array_amb(j,:),array_TOT(j,:),array_target(j,:));
        end
        
        % Change of variable name
        Extracted_TOT=TOT_interpolated;
        
        % Recreate PUL_steady_state for given HST_limit for a given unique value of AMB
        [~, index] = sort(Table_Loadings);
        F = griddedInterpolant(Extracted_TOT(index),Table_Loadings(index));
        PUL_steady_state(i)=F(TOT_limit);
        
    end % end of "if Amb_temperature_range(t)==unique_AMB_values(i)"
    
end % end of for cycle

% Reconstruct a power limit vector 
for i=1:length(unique_values) % for each unique value of AMB
    index=find(AMB==unique_values(i)); % find the index of the unique value in initial AMB vector
    PUL_feasible_TOT(index)=PUL_steady_state(i); % Save PUL_steady_state for given index
end

% Change from raw vector to a column vector
PUL_feasible_TOT=PUL_feasible_TOT'; % final output

end % end of function 