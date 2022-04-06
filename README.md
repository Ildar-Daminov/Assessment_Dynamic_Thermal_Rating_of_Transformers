# Assessment of dynamic transformers rating, considering the current and temperature limitations
<img align="left" alt="Coding" width="65" src="https://ars.els-cdn.com/content/image/1-s2.0-S0142061521X00026-cov200h.gif">

  
This repository shares the MATLAB code and data for the research article 📋:\
I. Daminov, A. Prokhorov, R. Caire, M-C Alvarez-Herault, [“Assessment of dynamic transformer rating, considering current and temperature limitations”](https://www.sciencedirect.com/science/article/abs/pii/S0142061521001265?via%3Dihub) in International Journal of Electrical Power & Energy Systems (IF: 3,588, Q1), 2021
  
  
## Article's abstract
Nowadays, transformers can be operated close to their thermal limits. The state of the art in transformer thermal limits are Dynamic Thermal Rating (DTR). DTR can be based on two temperature limits: either a design temperature or maximal-permissible temperature. However, many papers estimate DTR with the design temperature only. Therefore, the true DTR is still underestimated since temperature limit is ignored as well as current limits (in some papers). Moreover, many papers rely on the conservative assumption of typical historical load profile or net load profile (considering the distributed generation, storage, electric vehicles). However, modern DSO can control the shape of (net) load profile. This can make a DTR estimation, assuming some typical (net) load profile, valuable only for a particular shape of (net) load profile but not for its modifications. This paper suggests a DTR feasible region which is constructed from current and temperature limitations and does not rely on typical load profiles. As a case study, we investigate DTR in cold and warm climates: one case in Russia with a continental climate and another in France with a temperate climate. In these climates, we assess DTR for the most common combinations of current and temperature limitations, used in standards and literature. As a result, DTR can ensure an additional capacity up to 45%. DTR, based on temperature limits, are 100% of time higher than nominal rating. Moreover, the limiting factors of DTR are quantified based on analysis of 34-year ambient temperature data. Finally, comprehensive recommendations for transformer overloading are formulated.

## How to run a code 
There are two ways how you may run this code:
  
I. Launching all calculations at once. This will reproduce all figures in the article but it would take 6-7 minutes:
1. Copy this repository to your computer 
2. Open the script main.m
3. Launch the script "main.m" by clicking on the button "Run" (usually located at the top of MATLAB window).\
As alternative, you may type ```main``` 
in Command Window to launch the entire script. 


II. Launching the specific section of the code to reproduce the particular figure: 
1. Copy this repository to your computer 
2. Open the script main.m 
3. Find the section (Plotting the Figure XX) corresponding to the Figure you would like to reproduce. 
4. Put the cursor at any place of this section and click on the button "Run Section" (usually located at the top of MATLAB window)


## Files description
Main script:
* main.m - the principal script which launches all calculations
  
Additional functions: 
* createfigure_34years.m - this function creates a figure in special section of the code. 
* feasible_region.m - this function calculates the feasible region of transformer loadings for given ambient temperature 
* feasible_region_HST.m - this function computes the fesaible region per limitation of hot-spot temperature of windings
* feasible_region_TOT.m - this function calculates the feasible region per the limitation of top-oil temperature in the tank
* ONAF_transformer.m - a thermal model of ONAF power transformer (up to 100 MVA) per the loading guide IEC 60076-7. ONAF stand for a cooling system : Oil Natural Air Forced
  
More details are given inside of functions and script "main.m"

Initial data:
* data_Grenoble.mat - precalculated data [high loadings;mean loadings ;min loadings] in the city of Grenoble, France
* data_Tomsk.mat - precalculated data [high loadings;mean loadings ;min loadings] in the city of Tomsk, Russia
* Fig3_ambient_temperature.mat - a profile of ambient temperature used in Fig.3 
* Fig5_PUL_data.mat - 3 profiles of transformer loadings used in Fig.5 
* Fig6_ambient_temperature.mat - a profile of ambient temperature used in Fig.6 
* Fig7_ambient_temperature.mat - a profile of ambient temperature used in Fig.7
* Fig8_ambient_temperature.mat - a profile of ambient temperature used in Fig.8 
* HST_all.mat - precalculated hot spot temperature between transformer loadings (0.01:2 pu) and ambient temperatures(-50 °C : +50 °C)
* T_history_Grenoble.mat - historical ambient temperature in Grenoble, France (source: [MeteoBlue](https://www.meteoblue.com/fr/historyplus))
* T_history_Tomsk.mat - historical ambient temperature in Tomsk, Russia (source: [MeteoBlue](https://www.meteoblue.com/fr/historyplus))
* TOT_all.mat precalculated top-oil temperature between transformer loadings (0.01:2 pu) and ambient temperatures(-50 °C : +50 °C)

## How to cite this article 
Ildar Daminov, Anton Prokhorov, Raphael Caire, Marie-Cécile Alvarez-Herault, Assessment of dynamic transformer rating, considering current and temperature limitations,
International Journal of Electrical Power & Energy Systems, Volume 129, 2021, 106886, ISSN 0142-0615, https://doi.org/10.1016/j.ijepes.2021.106886.
