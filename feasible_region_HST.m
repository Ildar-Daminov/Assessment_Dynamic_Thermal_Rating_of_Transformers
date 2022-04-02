function [PUL_final]=feasible_region_HST(AMB,HST_limit)
%% Goal of this function
% This function calculates the admissible loading (PUL_final),corresponding 
% to a limit of hot spot temperature(HST_limit)at a given ambient temperature 
% profile(AMB) 

%% Syntax of this function
% Input:
% AMB - ambient temperature profile around transformer. Vector [1:N,1]
% Format - vector

% HST_limit - a hot spot temperature limit of windings
% Format - double 

% Output: 
% PUL_final - admissible loading (PUL)of ONAF power transformer. 
% Format - vector of the same size as AMB

%% Prepare the data  
% Load precalculated matrix ''Temp'' (see below) 
load('HST_all.mat') 

% Table "Temp": size 200x102
% ---------------------------------------------------------
%|    |        |       Ambient temperature range          |
%|  # |Loading |   -50°C   | -49°C | ...| +49°C | +50°C   |
%|    |---------------------------------------------------|
%|  1 |0.01 pu |  HST1,°C  |  ...  |...|   ... | HST1,°C  |
%|  2 |0.02 pu |  HST2,°C  |  ...  |...|   ... | HST2,°C  |
%|... |  ...   |   ...     |  ...  |...|   ... |   ...    |
%| 200|  2 pu  | HST200,°C |  ...  |...|   ... | HST200,°C|
%----------------------------------------------------------  
% Note: ambient temperature range is not included in"Temp"

% Ambient temperature range 
Amb_temperature_range=-50:1:50;

% Extract table loadings (0.01 pu...2pu)
Table_Loadings=Temp(:,1);

% Extract unique values of initial ambient temperature vector 
unique_AMB_values=unique(AMB);

%% Reconstructing the vector of PUl_final for given AMB vector
for i=1:length(unique_AMB_values)% for each unique value of ambient temperature 
    % Find index t of the closest value in vector Amb_temperature_range 
    [~,t]=min(abs(Amb_temperature_range-unique_AMB_values(i)));
    
    if Amb_temperature_range(t)==unique_AMB_values(i)% if AMB matches the closest value  in vector "Amb_temperature_range" 
        
        % Extract HST for given unique_AMB_values(i) from matrix "Temp"
        Extracted_HST=Temp(:,t+1); % t+1 is required due to t==1 loadings
        
        % Extract PUL for given AMB temperature using griddedInterpolant
        [~, index] = sort(Table_Loadings);
        F = griddedInterpolant(Extracted_HST(index),Table_Loadings(index));
        PUL_steady_state(i)=F(HST_limit);
        
    else % if  AMB does not match the closest value in vector "Amb_temperature_range" 
        if Amb_temperature_range(t)>unique_AMB_values(i) % if the closest value is higher
            % Example: unique_AMB_values(i)= 20.8; and Amb_temperature_range(t)=21;
            
            % Extact the closest AMB from Amb_temperature_range
            AMB1(1:length(Table_Loadings),1)=Amb_temperature_range(t);
            
            % Extact the previous AMB from the closest value in Amb_temperature_range
            AMB2(1:length(Table_Loadings),1)=Amb_temperature_range(t-1);
            
            % Extract corresponding HST from matrix "Temp"
            HST1=Temp(:,t+1);% "t+1" in Temp corresponds to "t" in Amb_temperature_range!
            HST2=Temp(:,t); % "t" in Temp corresponds to "t-1" in Amb_temperature_range!
            
        elseif Amb_temperature_range(t)<unique_AMB_values(i)% if the closest value is lower
            % Example: unique_AMB_values(i)= 21.3; and Amb_temperature_range(t)=21;

            % Extract the next AMB after the closest value in Amb_temperature_range
            AMB1(1:length(Table_Loadings),1)=Amb_temperature_range(t+1);
            
            % Extact the closest AMB from Amb_temperature_range. 
            AMB2(1:length(Table_Loadings),1)=Amb_temperature_range(t);
            
            % Extract corresponding HST from matrix "Temp" 
            HST1=Temp(:,t+2);% t+2 in Temp corresponds to "t+1" in Amb_temperature_range!
            HST2=Temp(:,t+1);% t+1 in Temp corresponds to "t" in Amb_temperature_range!
        
        end % end of if Amb_temperature_range(t)>unique_AMB_values(i)
        
        % Create vectors of ambient and HST 
        array_amb=[AMB2 AMB1];
        array_HST=[HST2 HST1]; %[AMB2 AMB1] t+1!
        
        % Create target vectors of given ambient temperature AMB
        array_target=linspace(unique_AMB_values(i),unique_AMB_values(i),length(Table_Loadings))';
        
        % Find the interpolated HST (vector)between given vectors HST and
        % AMB for each value of Table_Loadings
        for j=1:length(Table_Loadings)
            HST_interpolated(j,1)=interp1(array_amb(j,:),array_HST(j,:),array_target(j,:));
        end
        
        % Change of variable name
        Extracted_HST=HST_interpolated;
        
        % Recreate PUL_steady_state for given HST_limit for a given unique value of AMB  
        [~, index] = sort(Table_Loadings);
        F = griddedInterpolant(Extracted_HST(index),Table_Loadings(index));
        PUL_steady_state(i)=F(HST_limit);
        
    end % end of "if Amb_temperature_range(t)==unique_AMB_values(i)"
    
end % end of for cycle

% Reconstruct  a power limit vector 
for i=1:length(unique_AMB_values) % for each unique value of AMB
    index=find(AMB==unique_AMB_values(i)); % find the index of the unique value in initial AMB vector
    PUL_final(index)=PUL_steady_state(i); % Save PUL_steady_state for given index
end

% Change from raw vector  to a column vector
PUL_final=PUL_final'; % final output

end % end of function 