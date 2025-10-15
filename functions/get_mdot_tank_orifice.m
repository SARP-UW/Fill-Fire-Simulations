function [m_dot, Fill_Time] = get_mdot_tank_orifice(pressure_tank, orifice_diameter, cylinder_diam)
% This function calculates the mass flow rate of the nitrous filling process
% and the total time it takes to fill.

% Inputs 
% pressure_tank: Final desired pressure of the tank
% orfice_diameter: Size of tubing that will connect to the nitrous tank
% Cylinder Diameter: Size of cylinder output

% Outpus
% m_dot: mass flow rate
% Fill time: time to fill tank
arguments (Input)
    pressure_tank (1,1) double{mustBeReal, mustBeFinite, mustBePositive} %psi
    orifice_diameter (1,1) double{mustBeReal, mustBeFinite, mustBePositive} % in
    cylinder_diam (1,1) double{mustBeReal, mustBeFinite, mustBePositive} % In
end

arguments (Output)
    m_dot (1,1) double{mustBeReal, mustBeFinite, mustBePositive} % lb/s
    Fill_Time (1,1) double{mustBeReal, mustBeFinite, mustBePositive} % s
end 

% Constants
P_Initial = 14.7; %psi
Molar_Density_Initial = 27.958; % mol/l^3
k = 1.27; % Specific heat ratio
Cd = 0.8; % Discharge coefficient for orfices and nozzles 
g = 32.174; % ft/s^2
Vol_Tank = 0.3266606672; %from thrust simulation

% Calculations
density_initial = Molar_Density_Initial * (44.013)/(453.592*0.035315);
% density (lb/ft^3) = Molar_Desnity (mol/L) * (453.592 g / mol) * (1 lb / 453.592 g) * (1 L / 0.035315 ft^3) 
Beta = orifice_diameter/cylinder_diam;
% diameter ratios
P_ratio = pressure_tank/P_Initial;
% Pressure Ratios
Y = (((k * (P_ratio)^(2/k))/(k-1)) * ((1-Beta^4)/((1-Beta^4)*(P_ratio)^(2/k)))...
    *((1-(P_ratio)^((k-1)/(k))) / (1 - P_ratio)))^(0.5);
% net expansion factor for compressible flow through orifices, nozzles, venturi, control valves or pipe (unitless)
C = Cd/sqrt(1-Beta^4);
% flow coefficient for orifices and nozzles
A = pi * (orifice_diameter/2)^2;
% Area
q = Y*C*A * sqrt((2*g*144*pressure_tank - P_Initial)/density_initial);%ft^3/s
% rate of flow at flowing conditions

m_dot = q*density_initial;

Fill_Time = Vol_Tank / q;

end