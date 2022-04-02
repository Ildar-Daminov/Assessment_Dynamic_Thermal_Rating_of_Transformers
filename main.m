clc
clear all
close all

%% Goal of the script
% This scripts reproduces the Figures from the article [1]:

% If you use this code, please cite this article:
% [1] Ildar Daminov, Anton Prokhorov, Raphael Caire, Marie-Cécile Alvarez-Herault,
% “Assessment of dynamic transformer rating, considering current and
% temperature limitations” in International Journal of Electrical Power &
% Energy Systems, 2021, https://doi.org/10.1016/j.ijepes.2021.106886

% Other articles on this topic are available:
% https://www.researchgate.net/profile/Ildar-Daminov-2

% Note that the figures generated in this script and those given in the article
% may differ a little bit as latter had been additionally redrawn for a publication.

% Each section (Plotting the Figure X) is independent from each other. So
% you may launch the entire script (using the button "Run") to get all
% figures at one moment or you may launch a special section (using the button
% "Run Section" at the top)to get a specific figure

% Execution time of entire script ≈ 6-7 min 

tic
%% Plotting the Figure 1
% Figure name: Transformer loadings equal to HST and TOT limits as a
% function of ambient temperatrure.

% Set the range for ambient temperature from -50 °C up to +50°C
Temperature_range=-50:50;%°C

% Set the range of hot spot temperature limits 120°C and 140°C
HST_range=[120;140];%°C

% Set the range of top-oil temperature limits 120°C and 140°C
TOT_range=[95;105];%°C

% Caclulating the data for each HST limit (120°C and 140°C)
for j=1:2
    for i=1:length(Temperature_range)
        % Select the ambient temperature from the range
        AMB=Temperature_range(i);
        
        % Find per unit loading(PUL)corresponding to  given AMB and HST
        PUL_HST(i,j)=feasible_region_HST(AMB,HST_range(j));
        
        % Find per unit loading(PUL)corresponding to  given AMB and TOT
        PUL_TOT(i,j)=feasible_region_TOT(AMB,TOT_range(j));
    end % end of "for i=1:length(Temperature_range)"
end % end of "for j=1:2"

% Caclulating the data for design HST(98°C)
for i=1:length(Temperature_range)
    % Select the ambient temperature from the range
    AMB=Temperature_range(i);
    
    % Find per unit loading(PUL)corresponding to  given AMB and HST=98°C
    PUL_designHST(i)=feasible_region_HST(AMB,98);
    
end % end of "for i=1:length(Temperature_range)"

% Preparing the vector of current limit 1.5 pu
current_limit=linspace(1.5,1.5,length(Temperature_range));

% Ploting the results
% Create figure
figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
    'Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.13 0.120332091169164 0.831282516636419 0.848917601327761]);
hold(axes1,'on');

% Ploting
plot(Temperature_range,PUL_designHST,'LineWidth',2)
hold on
plot(Temperature_range,PUL_HST(:,1),'LineWidth',2)
plot(Temperature_range,PUL_HST(:,2),'LineWidth',2)
plot(Temperature_range,PUL_TOT(:,1),'LineWidth',2)
plot(Temperature_range,PUL_TOT(:,2),'LineWidth',2)
plot(Temperature_range,current_limit,'LineWidth',2)
ylabel('Transformer loading, pu')
xlabel('Ambient temperature,°C')

% Set the remaining axes properties
set(axes1,'FontSize',16,'XGrid','on','YGrid','on');

%% Plotting the Figure 2
% Figure name: Limiting factors in the range of ambient temperature.

% Figure 2 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 3 and Figure 4
% Figure 3 name: Feasible region (yellow area).

% Figure 4 name: Same feasible region, but showing the loadings with normal
% ageing (green area)

clear all % clear workspace

% Load the ambient temperature
load('Fig3_ambient_temperature.mat')

% current and temperature limitations
current_limit=linspace(1.5,1.5,length(AMB))'; % limit of current, per unit
HST_normal=98; % a design temperature of windings, °C
HST_limit=120; % limit of hot spot temperature (of windings), °C
TOT_limit=105; % limit of top-oil temperature,°C

% Finding a power limit for ToT limit
[Power_limit_TOT]=feasible_region_TOT(AMB,TOT_limit);

% Finding a power limit for design HST
[Power_limit_HSTnormal]=feasible_region_HST(AMB,HST_normal);

% Finding a power limit for a HST limit
[Power_limit_HSTlimit]=feasible_region_HST(AMB,HST_limit);

% Selecting the lowest line between three areas (defined above)
top_line=min(min(Power_limit_TOT,Power_limit_HSTlimit),current_limit);

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(2019,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,1,1,23,59,0,'Format','HH:SS');
time = t1:minutes(1):t2;

% Plot the power limits at the left side
yyaxis left
plot(time,Power_limit_TOT,'b','LineWidth',2)
hold on
plot(time,Power_limit_HSTlimit,'y','LineWidth',2)
plot(time,Power_limit_HSTnormal,'g','LineWidth',2)
plot(time,current_limit,'c','LineWidth',2)
plot(time,top_line,'--k','LineWidth',2)
ylabel('Transformer loading,pu')
xlabel('Time')
ylim([0,1.8]) % as in article

% Plot the ambient temperature  at the right side
yyaxis right
plot(time,AMB,':r','LineWidth',1)
ylabel('Ambient temperature,°C')

%% Plotting the Figure 5

% Figure 5 name: Interrelations between transformer loading and
% temperatures, calculated by IEC thermal model

clear all % clear workspace

load('Fig5_PUL_data.mat') % 3 load profiles
AMB=linspace(20,20,1440)'; % rated ambient temperature during 1 day

% Caclualting HST and TOT
[HST_step,TOT_step,~]=ONAF_transformer(PUL_data{3, 1},AMB); % step load
[HST_constant,TOT_constant,~]=ONAF_transformer(PUL_data{2, 1},AMB); % constant load
[HST_specif,TOT_specif,~]=ONAF_transformer(PUL_data{1, 1},AMB); % specific load

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(2019,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,1,1,23,59,0,'Format','HH:SS');
time = t1:minutes(1):t2;

hold on

% plot HST and TOT
plot(time,HST_step,'LineStyle','--','LineWidth',2,'Color',[0 0 1]);
plot(time,HST_constant,'LineStyle','--','LineWidth',2, 'Color',[0.749019622802734 0 0.749019622802734]);
plot(time,HST_specif,'LineStyle','--','LineWidth',2,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403]);

plot(time,TOT_step,'LineStyle',':','LineWidth',2,'Color',[0 0 1]);
plot(time,TOT_constant,'LineStyle',':','LineWidth',2, 'Color',[0.749019622802734 0 0.749019622802734]);
plot(time,TOT_specif,'LineStyle',':','LineWidth',2,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403]);

% Create ylabel
ylabel('Transformer temperature, ℃');
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes1,[40 180]);

% Activate the right side of the axes
yyaxis right

% Plot load profiles
plot(time,PUL_data{3, 1},'LineWidth',5,...
    'Color',[0 0.447058826684952 0.74117648601532]);
plot(time,PUL_data{2, 1},'LineWidth',3,...
    'Color',[0.749019622802734 0 0.749019622802734]);
plot(time,PUL_data{1, 1},'LineWidth',2,...
    'Color',[0.635294139385223 0.0784313753247261 0.184313729405403]);

% Create ylabel
ylabel('Transformer loading','FontSize',17.6);

%% Plotting the Figure 6
% Figure 6 name: Feasible region limited by the current only.

clear all % clear workspace

% Load ambient temperature
load('Fig6_ambient_temperature.mat')

% current and temperature limitations
current_limit=linspace(1.5,1.5,length(AMB))'; % limit of current, per unit
HST_normal=98; % a design temperature of windings, °C
HST_limit=120; % limit of hot spot temperature (of windings), °C
TOT_limit=105; % limit of top-oil temperature,°C

% Finding a power limit for ToT limit
[Power_limit_TOT]=feasible_region_TOT(AMB,TOT_limit);

% Finding a power limit for design HST
[Power_limit_HSTnormal]=feasible_region_HST(AMB,HST_normal);

% Finding a power limit for a HST limit
[Power_limit_HSTlimit]=feasible_region_HST(AMB,HST_limit);

% Selecting the lowest line between three areas (defined above)
top_line=min(min(Power_limit_TOT,Power_limit_HSTlimit),current_limit);

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(2019,1,11,0,0,0,'Format','HH:SS');
t2 = datetime(2019,1,11,23,59,0,'Format','HH:SS');
time = t1:minutes(1):t2;

% Plot the power limits at the left side
yyaxis left
plot(time,Power_limit_TOT,'b','LineWidth',2)
hold on
plot(time,Power_limit_HSTlimit,'y','LineWidth',2)
plot(time,Power_limit_HSTnormal,'g','LineWidth',2)
plot(time,current_limit,'c','LineWidth',2)
plot(time,top_line,'--k','LineWidth',2)
ylabel('Transformer loading,pu')
xlabel('Time')
ylim([0,2]) % as in article

% Plot the ambient temperature  at the right side
yyaxis right
plot(time,AMB,':r','LineWidth',1)
ylabel('Ambient temperature,°C')

%%  Plotting the Figure 7
% Figure 7 name: Feasible region limited by the TOT only.

clear all % clear workspace

% Load ambient temperature
load('Fig7_ambient_temperature.mat')

% current and temperature limitations
current_limit=linspace(1.5,1.5,length(AMB))'; % limit of current, per unit
HST_normal=98; % a design temperature of windings, °C
HST_limit=140; % limit of hot spot temperature (of windings), °C
TOT_limit=95; % limit of top-oil temperature,°C

% Finding a power limit for ToT limit
[Power_limit_TOT]=feasible_region_TOT(AMB,TOT_limit);

% Finding a power limit for design HST
[Power_limit_HSTnormal]=feasible_region_HST(AMB,HST_normal);

% Finding a power limit for a HST limit
[Power_limit_HSTlimit]=feasible_region_HST(AMB,HST_limit);

% Selecting the lowest line between three areas (defined above)
top_line=min(min(Power_limit_TOT,Power_limit_HSTlimit),current_limit);

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(2018,7,7,0,0,0,'Format','HH:SS');
t2 = datetime(2018,7,7,23,59,0,'Format','HH:SS');
time = t1:minutes(1):t2;

% Plot the power limits at the left side
yyaxis left
plot(time,Power_limit_TOT,'b','LineWidth',2)
hold on
plot(time,Power_limit_HSTlimit,'y','LineWidth',2)
plot(time,Power_limit_HSTnormal,'g','LineWidth',2)
plot(time,current_limit,'c','LineWidth',2)
plot(time,top_line,'--k','LineWidth',2)
ylabel('Transformer loading,pu')
xlabel('Time')
ylim([0,2]) % as in article

% Plot the ambient temperature at the right side
yyaxis right
plot(time,AMB,':r','LineWidth',1)
ylabel('Ambient temperature,°C')

%%  Plotting the Figure 8
% Figure 8 name: Feasible region limited by current and HST.

clear all % clear workspace

% Load an ambient temperature
load('Fig8_ambient_temperature.mat')

% current and temperature limitations
current_limit=linspace(1.5,1.5,length(AMB))'; % limit of current, per unit
HST_normal=98; % a design temperature of windings, °C
HST_limit=120; % limit of hot spot temperature (of windings), °C
TOT_limit=105; % limit of top-oil temperature,°C

% Finding a power limit for ToT limit
[Power_limit_TOT]=feasible_region_TOT(AMB,TOT_limit);

% Finding a power limit for design HST
[Power_limit_HSTnormal]=feasible_region_HST(AMB,HST_normal);

% Finding a power limit for a HST limit
[Power_limit_HSTlimit]=feasible_region_HST(AMB,HST_limit);

% Selecting the lowest line between three areas (defined above)
top_line=min(min(Power_limit_TOT,Power_limit_HSTlimit),current_limit);

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(2019,1,15,0,0,0,'Format','HH:SS');
t2 = datetime(2019,1,15,23,59,0,'Format','HH:SS');
time = t1:minutes(1):t2;

% Plot the power limits at the left side
yyaxis left
plot(time,Power_limit_TOT,'b','LineWidth',2)
hold on
plot(time,Power_limit_HSTlimit,'y','LineWidth',2)
plot(time,Power_limit_HSTnormal,'g','LineWidth',2)
plot(time,current_limit,'c','LineWidth',2)
plot(time,top_line,'--k','LineWidth',2)
ylabel('Transformer loading,pu')
xlabel('Time')
ylim([0,2]) % as in article

% Plot the ambient temperature at the right side
yyaxis right
plot(time,AMB,':r','LineWidth',1)
ylabel('Ambient temperature,°C')

%% Plotting the Figure 9
% Figure 9 name: Hourly ambient temperature from 1985 to 2019 in Tomsk
% and Grenoble.

clc;clear all % clear a command window and a workspace

% Load T - historical ambient temperature (among others)
% from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
load('T_history_Tomsk.mat') % in Tomsk, Russia

% Extracting the ambient temperature
AMB_Tomsk=T(:,6);

% Round ambient temperature
AMB_Tomsk=round(AMB_Tomsk);

% Load T - historical ambient temperature (among others)
% from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
load('T_history_Grenoble.mat') % in Grenoble, France

% Extracting the ambient temperature
AMB_Grenoble=T(:,6);

% Round ambient temperature
AMB_Grenoble=round(AMB_Grenoble);


% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(1985,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,3,29,23,59,0,'Format','HH:SS');
time = t1:hours(1):t2;

% plotting the ambient temperature in Tomsk and Grenoble
plot(time,[AMB_Tomsk,AMB_Grenoble],'LineWidth',2)
ylabel('Ambient temperature,°C')
legend('Tomsk','Grenoble')

%% Plotting the Figure 10
% Figure 10 name: Estimation of feasible regions during 34 years.

clc;clear all % clear a command window and a workspace

% Prepare a time vector
t1 = datetime(1985,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,3,29,23,0,0,'Format','HH:SS');
time = t1:hours(1):t2;

for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        
    end % end of if city==1 %  Tomsk
    
    % Extracting the ambient temperature
    AMB=round(T(:,6)); % rounded for acceleration of script execution
    
    % Setting HST and TOT limits
    HST_limit=120; % °C
    TOT_limit=105; % °C
    
    % Calculate a feasible region
    [Power_limit_HSTnormal,Power_limit_HSTlimit,Power_limit_TOT,...
        current_limit,top_line]=feasible_region(AMB,HST_limit,TOT_limit);
    
    % Use a special function to plot a figure
    createfigure_34years(time, [Power_limit_TOT Power_limit_HSTlimit...
        Power_limit_HSTnormal current_limit top_line]);
    
    % Setting HST and TOT limits
    HST_limit=120; % °C
    TOT_limit=95; % °C
    
    % Calculate a feasible region
    [Power_limit_HSTnormal,Power_limit_HSTlimit,Power_limit_TOT,...
        current_limit,top_line]=feasible_region(AMB,HST_limit,TOT_limit);
    
    % Use a special function to plot a figure
    createfigure_34years(time, [Power_limit_TOT Power_limit_HSTlimit...
        Power_limit_HSTnormal current_limit top_line]);
    
    % Setting HST and TOT limits
    HST_limit=140; % °C
    TOT_limit=105; % °C
    
    % Calculate a feasible region
    [Power_limit_HSTnormal,Power_limit_HSTlimit,Power_limit_TOT,...
        current_limit,top_line]=feasible_region(AMB,HST_limit,TOT_limit);
    
    % Use a special function to plot a figure
    createfigure_34years(time, [Power_limit_TOT Power_limit_HSTlimit...
        Power_limit_HSTnormal current_limit top_line]);
    
    % Setting HST and TOT limits
    HST_limit=140; % °C
    TOT_limit=95; % °C
    
    % Calculate a feasible region
    [Power_limit_HSTnormal,Power_limit_HSTlimit,Power_limit_TOT,...
        current_limit,top_line]=feasible_region(AMB,HST_limit,TOT_limit);
    
    % Use a special function to plot a figure
    createfigure_34years(time, [Power_limit_TOT Power_limit_HSTlimit...
        Power_limit_HSTnormal current_limit top_line]);
    
end % end of for city=1:2

%% Plotting the Figure 11
% Figure 11 name: Mean DTR with maximum and minimum deviations during 34 years.

clc;clear all % clear a command window and a workspace

% create figure
figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
    'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1);


hold(axes1,'on');
hold on
    
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        
        load('data_Tomsk.mat') % precalculated data [high;mean;min]
        
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        
        load('data_Grenoble.mat')% precalculated data [high;mean;min]
        
    end % end of if city==1
    
    % Preparing the data for figure
    mean_data=Data(:,2);
    error_max=Data(:,1)-mean_data;
    error_min=mean_data-Data(:,3);
    
    %Ploting the bar chart with errors

    
    ngroups = 5; % total number of formulations
    nbars = 10; % needed for groupwidth
    
    % Calculating the width for each bar group
    groupwidth = min(0.4,nbars/(nbars + 1.5));
    
    
    for i = 1:5 % for each formulation
        if i==1 % HST<98°C TOT<105°C
            
            if city==1 %  Tomsk
                % Setting the x coordinates at x axis
                x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
            else % city==2 Grenoble
                x=x+groupwidth;
            end
            
            % Plot the bar chart
            bar2=bar(x(1),mean_data(1,1),'grouped','BarWidth',groupwidth,'BaseValue',0.8,'Parent',axes1);
            set(bar2,'FaceColor',[0 0.498039215803146 0]);
            
            % Create a errors of green area
            err_green = [error_min(1,1),error_max(1,1)];
            
            % Plot the errors of green area
            er=errorbar(x(1), mean_data(1,1),err_green(1,1),err_green(1,2),'LineStyle','none',...
                'LineWidth',1,'Color',[0 0 0]);
            
        else % for other formulations
            % Plot the bar chart
            bar1=bar(x(i),mean_data(i,1),'grouped','BarWidth',groupwidth,'BaseValue',0.8,'Parent',axes1);
            
            % Create a errors
            err_top = [error_min(i,1),error_max(i,1)];
            
            % Plot the errors
            er=errorbar(x(i), mean_data(i,1), err_top(:,1),err_top(:,2),'LineStyle','none',...
                'LineWidth',1,'Color',[0 0 0]);
            
        end % end of "if i==1 % HST<98°C TOT<105°C
        
    end % end of "for i = 1:5 for each formulation"
end % end of for city=1:2

% Setting the properties of x axis
set(axes1,'FontSize',16,'XTick',[1 2 3 4 5 ],'XTickLabel',...
    {'HST≤98°C  and TOT≤95°C','HST≤120°C and TOT≤105°C','HST≤120°C and TOT≤95°C','HST≤140°C and TOT≤95°C','HST≤140°C and TOT≤105°C'},...
    'YGrid','on')

%  Defining the y label
ylabel('Transformer loading,pu','FontSize',17.6);

% Get a x limits
xlim=get(gca,'xlim');

% Plot the horizontal line
plot(xlim,[1 1],'LineWidth',1,'Color',[0 0 0]);

%% Plotting the Figure 12
% Figure 12 name: Mean DTR with maximum and minimum deviations in each month.

clc;clear all % clear a command window and a workspace

% Calculating the high, ean and min loads per each month
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        AMB=round(T(:,6));
        
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        AMB=round(T(:,6));
        
    end % end of if city==1
    
    for ii=1:4 % for each formulation ii
        if ii==1
            HST_limit=120;%°C
            TOT_limit=105;%°C
        elseif ii==2
            HST_limit=120;%°C
            TOT_limit=95; %°C
        elseif ii==3
            HST_limit=140;%°C
            TOT_limit=95;%°C
        elseif ii==4
            HST_limit=140;%°C
            TOT_limit=105; %°C
        end
        
        %         Finding a feasible region
        [Power_limit_HSTnormal,~,~,~,top_line]=feasible_region...
            (AMB,HST_limit,TOT_limit);
        
        % Correcting the green area (DTR based on 98 degC)
        index=find(Power_limit_HSTnormal>=1.5); % find indexes when DTR is higher 1.5pu
        if length(index)>1 % if exists
            Power_limit_HSTnormal(index)=1.5; % apply current limit (1.5) for those DTR higher 1.5 pu
        end
        
        % Calculating max,mean and min for each month
        for i=1:12 % for each month
            
            %find index of monthes
            ind=find((T(:,2)==i));
            
            % Find the mean values of top line and green area
            mean_month_top(i,ii)=mean(top_line(ind));
            mean_month_green(i,1)=mean(Power_limit_HSTnormal(ind));
            
            % Find the max values of top line and green area
            max_month_top(i,ii)=max(top_line(ind));
            max_month_green(i,1)=max(Power_limit_HSTnormal(ind));
            
            % Find the min values of top line and green area
            min_month_top(i,ii)=min(top_line(ind));
            min_month_green(i,1)=min(Power_limit_HSTnormal(ind));
            
        end % for i=1:12 % for each month
        
    end % for ii=1:5
    
    % plotting the figure for Tomsk
    if city==1 % Tomsk
        % create a figure
        figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
            'Color',[1 1 1]);
        % Create axes
        axes1 = axes('Parent',figure1);
        
    else % Grenoble
        figure2 = figure('InvertHardcopy','off','WindowState','maximized',...
            'Color',[1 1 1]);
        
        % Create axes
        axes1 = axes('Parent',figure2);
        
    end
    
    hold(axes1,'on');
    hold on
    
    ngroups = 12; % number  of months
    nbars = 5; % needed for groupwidth
    
    % Calculating the width for each bar group
    groupwidth = min(0.2, nbars/(nbars + 1.5));
    
    for ii = 1:4 % for each current and temperature formulations
        if ii==1 % if formulation == HST<98°C et HST<120°C TOT<95°C
            % Prepare x coordinates at x-axis
            x = linspace(1,14,12); x=x-0.45;
            
            % Plot bar chart for green area
            bar2=bar(x',mean_month_green,'grouped','BarWidth',groupwidth,'BaseValue',0.8,'Parent',axes1);
            set(bar2,'FaceColor',[0 0.498039215803146 0]);
            
            % Prepare data for errors
            err_tophigh_green(:,1)=max_month_green(:,1)-mean_month_green(:,1);
            err_toplow_green(:,1)=mean_month_green(:,1)-min_month_green(:,1);
            err_green = [err_toplow_green(:,1),err_tophigh_green(:,1)];
            
            % plot errors for green area bars
            er=errorbar(x, mean_month_green(:,1),err_green(:,1),err_green(:,2),'LineStyle','none',...
                'LineWidth',1,'Color',[0 0 0]);
            
            % Shift x cordinates by 0.2
            x = x+0.2;
            
            % Plot bar chart for top line
            bar1=bar(x,mean_month_top(:,ii),'grouped','BarWidth',groupwidth,'BaseValue',0.8,'Parent',axes1);
            set(bar1,'FaceColor',[1 0.843137264251709 0]);
            
            % Prepare data for errors
            err_tophigh_top(:,1)=max_month_top(:,ii)-mean_month_top(:,ii);
            err_toplow_top(:,1)=mean_month_top(:,ii)-min_month_top(:,ii);
            err_top = [err_toplow_top(:,1),err_tophigh_top(:,1)];
            
            % plot errors for top line
            er=errorbar(x', mean_month_top(:,ii), err_top(:,1),err_top(:,2),'LineStyle','none',...
                'LineWidth',1,'Color',[0 0 0]);
            
        else % otherwise if i=2:4
            % Shift x cordinates by 0.2
            x = x+0.22;
            
            % Plot bar chart
            bar1=bar(x,mean_month_top(:,ii),'grouped','BarWidth',groupwidth,'BaseValue',0.8,'Parent',axes1);
            
            % Create low/high errors for top lines
            err_tophigh_top(:,1)=max_month_top(:,ii)-mean_month_top(:,ii);
            err_toplow_top(:,1)=mean_month_top(:,ii)-min_month_top(:,ii);
            err_top = [err_toplow_top(:,1),err_tophigh_top(:,1)];
            
            % Plot errors for top line
            er=errorbar(x', mean_month_top(:,ii), err_top(:,1),err_top(:,2),'LineStyle','none',...
                'LineWidth',1,'Color',[0 0 0]);
            
        end % end of if ii==1 %
        
    end % end of for ii = 1:4
    
    
    % Setting the y label
    ylabel('Transformer loading,pu','FontSize',17.6);
    
    % get x limits
    xlim=get(gca,'xlim');
    
    % Plot the horizontal line (nominal rating)
    plot(xlim,[1 1],'LineWidth',1,'Color',[0 0 0]);
    
    % Set the y limits
    ylim([0.8 1.6])
    
    % Create a vector of x coordinates
    x = linspace(1,14,12)-0.08;
    set(axes1,'FontSize',16,'XTick',x,'XTickLabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'},...
        'YGrid','on');
    
    % Title plotting
    if city==1 % Tomsk
        title('Tomsk')
    else % if city==2
        title('Grenoble')
    end
    
end % for city=1:2

%% Plotting the Figure 13
% Figure 13 name: DTR duration curves

clc;clear all % clear a command window and a workspace

% Constructing the figure
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        AMB=round(T(:,6));
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        AMB=round(T(:,6));
        
    end % end of if city==1
    
    % plotting the figure for Tomsk
    if city==1 % Tomsk
        % create a figure
        figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
            'Color',[1 1 1]);
        % Create axes
        axes1 = axes('Parent',figure1);
        
    else % city==2  Grenoble
        % create a figure
        figure2 = figure('InvertHardcopy','off','WindowState','maximized',...
            'Color',[1 1 1]);
        % Create axes
        axes1 = axes('Parent',figure2);
        
    end
    
    % Preparing the x axis (duration in %)
    Duration_x_axis=[1:length(AMB)]*100/length(AMB);
    Duration_x_axis=Duration_x_axis';
    
    % Create ylabel
    ylabel('Transformer loading, pu');
    
    % Create xlabel
    xlabel('DTR duration, %');
    
    hold on
    
    % Caclulating the duration curves
    for ii=1:4 % for each formulation ii (different HST and TOT limits)
        if ii==1
            HST_limit=120;%°C
            TOT_limit=105;%°C
        elseif ii==2
            HST_limit=120;%°C
            TOT_limit=95; %°C
        elseif ii==3
            HST_limit=140;%°C
            TOT_limit=95; %°C
        elseif ii==4
            HST_limit=140; %°C
            TOT_limit=105; %°C
        end
        
        % Finding a feasible region of transformer loadings
        [Power_limit_HSTnormal,~,~,~,top_line]=feasible_region...
            (AMB,HST_limit,TOT_limit);
        
        % Correcting the green area (DTR based on 98 degC) per current
        % limit
        index=find(Power_limit_HSTnormal>=1.5); % find indexes when DTR is higher 1.5pu
        if length(index)>1 % if exists
            Power_limit_HSTnormal(index)=1.5; % apply current limit (1.5) for those DTR higher 1.5 pu
        end
        
        % Finding the duration curve of top line
        Duration_top_line=sort(top_line,'descend');
        
        % Finding the duration curve of green area (DTR based on 98 degC)
        Duration_green_area=sort(Power_limit_HSTnormal,'descend');
        
        % Ploting the Figure
        plot(Duration_x_axis,[Duration_green_area,Duration_top_line],'LineWidth',2)
        
        
    end % for ii=1:4 % for each formulation ii
    
    % Title plotting
    if city==1 % Tomsk
        title('Tomsk')
    else % if city==2
        title('Grenoble')
    end
    
end % for city=1:2

%% Plotting the Figure 14

% Figure 14 name: Share of limiting factors. based on 34 years analysis
% (% are rounded).

clc;clear all % clear a command window and a workspace

% Pie charts for Current ≤1.5pu HST ≤98°C TOT ≤95°C
% Load "T" -  a history of ambient temperature in Tomsk, Russia
load('T_history_Tomsk.mat')

% Find indexes when current is limiting factor
index_current=find(round(T(:,6))<-39);
% 39°C is a ambient temperature at the intersection of lines corresponding
% to HST and current (see Fig 1 in the article)

% Find indexes when hot spot temperature is limiting factor
index_hst=find(round(T(:,6))>-39);

% Find indexes when hot spot temperature AND current are limiting factors
% at the same time
index_current_hst=find(round(T(:,6))==-39);

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_current_hst);
if ~(checking==0)
    error('Checking failed')
end

% Ploting the pie chart for Tomsk, Russia
t = tiledlayout(1,2);
ax1 = nexttile;
labels = {'Current only','HST only','Current+HST'};
pie(ax1,[length(index_current) length(index_hst) length(index_current_hst)],'%.1f%%')
colormap(ax1,[0 255 255; 0 127 0; 0 0 1]./256);
legend(labels)
title('Tomsk')
%--------------------------------------------------------------------------

% Repeating the same calculations but for Grenoble, France
load('T_history_Grenoble.mat')

% Find indexes when current is a limiting factor
index_current=find(round(T(:,6))<-39);
% Find indexes when hot spot temeprature is a limiting factor
index_hst=find(round(T(:,6))>-39);
% Find indexes when hot spot temeprature and current are equally a
% limiting factor
index_current_hst=find(round(T(:,6))==-39);

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_current_hst);
if ~(checking==0)
    error('Checking failed')
end

% Ploting the pie chart for Grenoble, France
ax2 = nexttile;
pie(ax2,[length(index_current) length(index_hst) length(index_current_hst)],'%.1f%%')
colormap(ax2,[0 255 255; 0 127 0; 0 0 256]./256);
legend(labels)
title('Grenoble')
%--------------------------------------------------------------------------

% Pie charts for  Current ≤1.5pu HST ≤120°C TOT ≤105°C
% create a figure
figure('DefaultAxesFontSize',14)

% Load "T" -  a history of ambient temperature in Tomsk, Russia
load('T_history_Tomsk.mat')

% Finding the intersections (from Fig1)
index_current=find(round(T(:,6))<-17);
index_hst=find(round(T(:,6))>-17);
index_current_hst=find(round(T(:,6))==-17);
% -17°C is a ambient temperature at the intersection of lines corresponding
% to HST and current (see Fig 1 in the article)

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_current_hst);
if ~(checking==0)
    error('Checking failed')
end

t = tiledlayout(1,2);
ax1 = nexttile;
labels = {'Current only','HST only','Current+HST'};
pie(ax1,[length(index_current) length(index_hst) length(index_current_hst)],'%.1f%%')
colormap(ax1,[0 255 255; 0 127 0; 0 0 256]./256);
legend(labels)
title('Tomsk')
%--------------------------------------------------------------------------
% Load "T" -  a history of ambient temperature in Grenoble, France
load('T_history_Grenoble.mat')

index_current=find(round(T(:,6))<-17);
index_hst=find(round(T(:,6))>-17);
index_current_hst=find(round(T(:,6))==-17);
% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_current_hst);
if ~(checking==0)
    error('Checking failed')
end

% Ploting the pie chart for Grenoble, France
ax2 = nexttile;
pie(ax2,[length(index_current) length(index_hst) length(index_current_hst)],'%.1f%%')
colormap(ax2,[0 255 255; 0 127 0; 0 0 256]./256);
legend(labels)
title('Grenoble')
%--------------------------------------------------------------------------
% Pie charts for  Current ≤1.5pu HST ≤120°C TOT ≤95°C
% create a figure
figure('DefaultAxesFontSize',14)

% Load "T" -  a history of ambient temperature in Tomsk, Russia
load('T_history_Tomsk.mat')

% Finding the intersection (from Fig1)
index_current=find(round(T(:,6))<-17);
index_hst=find(round(T(:,6))>-17 & round(T(:,6))<45);
index_tot=find(round(T(:,6))>45);
index_current_hst=find(round(T(:,6))==-17);
index_hst_tot=find(round(T(:,6))==45);
% -17°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and current lines
% +45°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and ToT lines

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_tot)-length(index_current_hst)-length(index_hst_tot);
if ~(checking==0)
    error('Checking failed')
end

t = tiledlayout(1,2);
ax1 = nexttile;
labels = {'Current only','HST only','TOT only','Current+HST','HST+TOT'};
pie(ax1,[length(index_current) length(index_hst) length(index_tot) length(index_current_hst) length(index_hst_tot)],'%.1f%%')
colormap(ax1,[0 255 255; 0 127 0; 0 114 189;0 0 256;0 0 256]./256);
legend(labels)
title('Tomsk')
%--------------------------------------------------------------------------
% Load "T" -  a history of ambient temperature in Grenoble, France
load('T_history_Grenoble.mat')

% Finding the intersection (from Fig1)
index_current=find(round(T(:,6))<-17);
index_hst=find(round(T(:,6))>-17 & round(T(:,6))<45);
index_tot=find(round(T(:,6))>45);
index_current_hst=find(round(T(:,6))==-17);
index_hst_tot=find(round(T(:,6))==45);
% -17°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and current lines
% +45°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and ToT lines

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_tot)-length(index_current_hst)-length(index_hst_tot);
if ~(checking==0)
    error('Checking failed')
end

% Ploting the pie chart for Grenoble, France
ax2 = nexttile;
pie(ax2,[length(index_current) length(index_hst) length(index_tot) length(index_current_hst) length(index_hst_tot)],'%.1f%%')
colormap(ax2,[0 255 255; 0 127 0; 0 114 189;0 0 256;0 0 256]./256);
legend(labels)
title('Grenoble')

% Pie charts for  Current ≤1.5pu HST ≤140°C TOT ≤95°C
% create a figure
figure('DefaultAxesFontSize',14)

% Load "T" -  a history of ambient temperature in Tomsk, Russia
load('T_history_Tomsk.mat')

% Finding the intersection (from Fig1)
index_current=find(round(T(:,6))<2);
index_tot=find(round(T(:,6))>2);
index_current_tot=find(round(T(:,6))==2);
% +2°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and current lines

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_tot)-length(index_current_tot);
if ~(checking==0)
    error('Checking failed')
end

t = tiledlayout(1,2);
ax1 = nexttile;
labels = {'Current only','TOT only','Current+TOT'};
pie(ax1,[length(index_current) length(index_tot) length(index_current_tot)],'%.1f%%')
colormap(ax1,[0 255 255; 0 114 189;0 0 256]./256);
legend(labels)
title('Tomsk')
%--------------------------------------------------------------------------
% Load "T" -  a history of ambient temperature in Grenoble, France
load('T_history_Grenoble.mat')

% Finding the intersections (from Fig1)
index_current=find(round(T(:,6))<2);
index_tot=find(round(T(:,6))>2);
index_current_tot=find(round(T(:,6))==2);

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_tot)-length(index_current_tot);
if ~(checking==0)
    error('Checking failed')
end

% Ploting the pie chart for Grenoble, France
ax2 = nexttile;
pie(ax2,[length(index_current) length(index_tot) length(index_current_tot)],'%.1f%%')
colormap(ax2,[0 255 255; 0 114 189;0 0 256]./256);
legend(labels)
title('Grenoble')

% Pie charts for  Current ≤1.5pu HST ≤140°C TOT ≤105°C
% create a figure
figure('DefaultAxesFontSize',14)

% Load "T" -  a history of ambient temperature in Tomsk, Russia
load('T_history_Tomsk.mat')

% Finding the intersections (from Fig1)
index_current=find(round(T(:,6))<3);
index_hst=find(round(T(:,6))>3 & round(T(:,6))<33);
index_tot=find(round(T(:,6))>33);
index_current_hst=find(round(T(:,6))==3);
index_hst_tot=find(round(T(:,6))==33);
% +3°C is the ambient temperature corresponding to the intersection(in Fig1)
% between HST and current lines
% +33°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and ToT lines

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_tot)-length(index_current_hst)-length(index_hst_tot);
if ~(checking==0)
    error('Checking failed')
end

t = tiledlayout(1,2);
ax1 = nexttile;
labels = {'Current only','HST only','TOT only','Current+HST','HST+TOT'};
pie(ax1,[length(index_current) length(index_hst) length(index_tot) length(index_current_hst) length(index_hst_tot)],'%.1f%%')
colormap(ax1,[0 255 255; 0 127 0; 0 114 189;0 0 256;0 0 256;0 0 256]./256);
legend(labels)
title('Tomsk')

%--------------------------------------------------------------------------
% Load "T" -  a history of ambient temperature in Grenoble, France
load('T_history_Grenoble.mat')

% Finding the intersections (from Fig1)
index_current=find(round(T(:,6))<3);
index_hst=find(round(T(:,6))>3 & round(T(:,6))<33);
index_tot=find(round(T(:,6))>33);
index_current_hst=find(round(T(:,6))==3);
index_hst_tot=find(round(T(:,6))==33);
% +3°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and current lines
% +33°C is ambient temperature corresponding to the intersection (in Fig1)
% between HST and ToT lines

% Checking if the length of temperature array is equal to sum of indexes
checking=length(T(:,6))-length(index_current)-length(index_hst)-length(index_tot)-length(index_current_hst)-length(index_hst_tot);
if ~(checking==0)
    error('Checking failed')
end

% Ploting the pie chart for Grenoble, France
ax2 = nexttile;
pie(ax2,[length(index_current) length(index_hst) length(index_tot) length(index_current_hst) length(index_hst_tot)],'%.1f%%')
colormap(ax2,[0 255 255; 0 127 0; 0 114 189;0 0 256;0 0 256;0 0 256]./256);
legend(labels)

%% Plotting the Figure 15
% Figure 15 name: Exponential dependencies of AAF on HST
% Where AAF is an ageing acceleration factor
%       HST is a hot spot temperature of windings

clc;clear all % clear a command window and a workspace

HST=50:140; % °C Range of hot spot temperature (x-axis)
AAF_Kraft=2.^((HST-98)./6); % AAF of Kraft paper (non-thermally upgraded)
AAF_TUP=exp((15000./(110+273)-15000./(HST+273))); % AAF of thermally-uprated paper

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1],'DefaultAxesFontSize',14);

% Plot figure
plot(HST,[AAF_Kraft; AAF_TUP],'LineWidth',2)

% Set a log scale
set(gca, 'YScale', 'log')

% add y label
ylabel('Ageing Acceleration Factor,pu');

% add x label
xlabel('Hot spot temperature,°C');

% add legend
legend('Design HST 98°C','Design HST 110°C')

%% Plotting the Figure 16
% Figure 16 name: Black lines. transformer loadings corresponding to HST1%
% .Orange and blue bars. PDF of Tamb in Tomsk and in Grenoble based on 34-years history

clc;clear all % clear a command window and a workspace

% Create the vector of ambient temperture
AMB_data=(-45:40)';

% Set the limit of hot spot temperature (HST)
HST_1_lim=58; %°C
TOT_limit=105;%°C needed for executing the feasible_region.m

% Prepare the NaN vector of per unit loading (PUL)
PUL_data=NaN(length(AMB_data),1);

% Find the PUL for each given ambient temperature in the vector "AMB_data"
for j=1:length(AMB_data)
    AMB=linspace(AMB_data(j),AMB_data(j),1440)';
    [~,Power_limit_HSTlimit,~,~,~]=feasible_region(AMB,HST_1_lim,TOT_limit);
    PUL_data(j)=Power_limit_HSTlimit(500);
end

% Ploting the ambient temperature against corresponding PUL
% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.136132315521628 0.11 0.76886768447837 0.855962441314554]);
hold(axes1,'on');

% Activate the left side of the axes
yyaxis(axes1,'left');

% Plot the results for new HST limit (70°C)
plot(AMB_data,PUL_data,'MarkerFaceColor',[0 0 0],'LineWidth',2,...
    'Color',[0 0 0],'DisplayName','Loading?HST_1_%= 58°C','LineStyle','--')

hold on

% Repeat the previous calculations but for new HST limit (70°C)
AMB_data=(-45:40)';
HST_1_lim=70; % HST limit (70°C)
PUL_data=NaN(length(AMB_data),1);
for j=1:length(AMB_data)
    AMB=linspace(AMB_data(j),AMB_data(j),1440)';
    [~,Power_limit_HSTlimit,~,~,~]=feasible_region(AMB,HST_1_lim,TOT_limit);
    PUL_data(j)=Power_limit_HSTlimit(500);
end

plot(AMB_data,PUL_data,'MarkerFaceColor',[0 0 0],'LineWidth',2,...
    'Color',[0 0 0],'DisplayName','Loading?HST_1_%= 70°C','LineStyle','-')

xlabel('Ambient Temperature, °C')
ylabel('Transformer loading, pu')

% Ploting the PDF
%--------------------------------------------------------------------------
% Load a history of ambient temperature(in hour resolutions) for the city
% of Grenoble, France
load('T_history_Grenoble.mat')

% Find the unique values of ambient temperatures
unique_values = unique(T(:,6));

% Prepare the data for histogram
out = [unique_values,histc(T(:,6),unique_values)];
out(:,2)=out(:,2)/length(T(:,6))*100;

% Set the remaining axes properties
set(axes1,'YColor',[0 0 0],'YDir','normal','YMinorTick','off');

% Activate the right side of the axes
yyaxis(axes1,'right');

% Create bar
bar(out(:,1),out(:,2),'DisplayName','PDF of T_a_m_b in Grenoble',...
    'FaceAlpha',0.8,...
    'FaceColor',[0 0.447058826684952 0.74117648601532],...
    'EdgeColor','none');

hold on

% Create ylabel
ylabel('PDF of  T_a_m_b','FontSize',17.6);

% Repeat the the previous calculations but for the city of Tomsk, Russia
load('T_history_Tomsk.mat')
unique_values = unique(T(:,6));
out = [unique_values,histc(T(:,6),unique_values)];
out(:,2)=out(:,2)/length(T(:,6))*100;

% Plot the histogram for Tomsk, Russia
bar(out(:,1),out(:,2),'DisplayName','PDF of T_a_m_b in Tomsk',...
    'FaceAlpha',0.8,...
    'FaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],...
    'EdgeColor','none');

% Set the remaining axes properties
set(axes1,'YColor',[0 0 0]);

box(axes1,'on');

% Set the remaining axes properties
set(axes1,'FontSize',16);

xlim(axes1,[-50 40]);

% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.609015574428516 0.742713202477807 0.263069608888492 0.200557516326367],...
    'EdgeColor',[1 1 1]);

%% Plotting the Figure 17
% Figure 17 name: Loadings which can be used for compensation of accelerated LoL
% (based on historical ambient temperatures)

clc;clear all % clear a command window and a workspace

% Load "descending" -  a sorted (in descending order) ambient temperature 
% in Tomsk, Russia
load('T_history_Tomsk.mat')

% Calcuated the Power vector for HST=58°C
HST_1_lim=58; %°C
TOT_limit=105;%°C
[~,Power_limit_HSTlimit,~,~,~]=feasible_region(descending,HST_1_lim,TOT_limit);

% Estimate the average power limit
mean_power_limit=mean(Power_limit_HSTlimit);

% Prepare the data for histogram
unique_values = unique(Power_limit_HSTlimit);
out = [unique_values,histc(Power_limit_HSTlimit,unique_values)];
out(:,2)=out(:,2)/length(Power_limit_HSTlimit)*100;

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.136132315521628 0.11 0.76886768447837 0.855962441314554]);
hold(axes1,'on');

% Plot the histogram for Tomsk, Russia
bar(out(:,1),out(:,2),'DisplayName','PDF, %',...
    'FaceAlpha',0.8,...
    'FaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],...
    'EdgeColor','none');

hold on

% Load "descending" -  a sorted (in descending order) ambient temperature 
% in Grenoble,France, 
load('T_history_Grenoble.mat')

% Calcuated the Power vector for HST=58°C
HST_1_lim=58; %°C
TOT_limit=105;%°C
[~,Power_limit_HSTlimit,~,~,~]=feasible_region(descending,HST_1_lim,TOT_limit);

% Estimate the average power limit
mean_power_limit=mean(Power_limit_HSTlimit);

% Prepare the data for histogram
unique_values = unique(Power_limit_HSTlimit);
out = [unique_values,histc(Power_limit_HSTlimit,unique_values)];
out(:,2)=out(:,2)/length(Power_limit_HSTlimit)*100;

% Plot the histogram for Grenoble, France
bar(out(:,1),out(:,2),'DisplayName','PDF,%',...
    'FaceAlpha',0.8,...
    'FaceColor',[0 0.447058826684952 0.74117648601532],...
    'EdgeColor','none');

% y-axis label
ylabel('PDF,%')

% x-axis label
xlabel('Loadings at HST_1_%')

% Set a legend
legend('Tomsk','Grenoble')
%--------------------------------------------------------------------------
% Repeat calculations for HST=70°C

% Load "descending" -  a sorted (in descending order) ambient temperature 
% in Tomsk, Russia
load('T_history_Tomsk.mat')

% Calcuated the Power vector for HST=58°C
HST_1_lim=70; %°C
TOT_limit=105;%°C
[~,Power_limit_HSTlimit,~,~,~]=feasible_region(descending,HST_1_lim,TOT_limit);

% Estimate the average power limit
mean_power_limit=mean(Power_limit_HSTlimit);

% Prepare the data for histogram
unique_values = unique(Power_limit_HSTlimit);
out = [unique_values,histc(Power_limit_HSTlimit,unique_values)];
out(:,2)=out(:,2)/length(Power_limit_HSTlimit)*100;

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.136132315521628 0.11 0.76886768447837 0.855962441314554]);
hold(axes1,'on');

% Plot the histogram for Tomsk, Russia
bar(out(:,1),out(:,2),'DisplayName','PDF, %',...
    'FaceAlpha',0.8,...
    'FaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],...
    'EdgeColor','none');

hold on

% Load "descending" -  a sorted (in descending order) ambient temperature 
% in Grenoble,France, 
load('T_history_Grenoble.mat')

% Calcuated the Power vector for HST=58°C
HST_1_lim=70; %°C
TOT_limit=105;%°C
[~,Power_limit_HSTlimit,~,~,~]=feasible_region(descending,HST_1_lim,TOT_limit);

% Estimate the average power limit
mean_power_limit=mean(Power_limit_HSTlimit);

% Prepare the data for histogram
unique_values = unique(Power_limit_HSTlimit);
out = [unique_values,histc(Power_limit_HSTlimit,unique_values)];
out(:,2)=out(:,2)/length(Power_limit_HSTlimit)*100;

% Plot the histogram for Grenoble, France
bar(out(:,1),out(:,2),'DisplayName','PDF,%',...
    'FaceAlpha',0.8,...
    'FaceColor',[0 0.447058826684952 0.74117648601532],...
    'EdgeColor','none');

% y-axis label
ylabel('PDF,%')

% x-axis label
xlabel('Loadings at HST_1_%')

% Set a legend
legend('Tomsk','Grenoble')

Elapsed_time=toc