% Main function for running the fill sim



this_file = mfilename('fullpath');
this_folder = fileparts(this_file);
main_folder = fileparts(this_folder);
addpath(fullfile(main_folder, 'functions'));
cf = c();

inputs = readtable(fullfile(main_folder, 'data/fill_inputs.xlsx'), 'Sheet', 'Sheet1');
liquid_properties = readtable(fullfile(main_folder, 'data/liquid_properties.xlsx'), 'Sheet', 'Sheet1');
vapor_properties = readtable(fullfile(main_folder, 'data/vapor_properties.xlsx'), 'Sheet', 'Sheet1');

T = 30 * 60; % Total sim time in seconds
dt = 1; % Time step in seconds
t = 0:dt:T; % Define time variable

P_run_tank = zeros(size(t)); 
P_bottle = zeros(size(t)); 
T_run_tank = zeros(size(t)); 
T_bottle = zeros(size(t)); 
u_run_tank = zeros(size(t)); 
u_bottle = zeros(size(t)); 
v_run_tank = zeros(size(t)); 
v_bottle = zeros(size(t)); 
v_f_run_tank = zeros(size(t)); 
v_f_bottle = zeros(size(t));
v_g_run_tank = zeros(size(t)); 
v_g_bottle = zeros(size(t)); 
mu_run_tank = zeros(size(t));
mu_bottle = zeros(size(t));
vel_n2o = zeros(size(t));
m_run_tank = zeros(size(t));
m_bottle = zeros(size(t));
x_run_tank = zeros(size(t));
x_bottle = zeros(size(t));

% Initialize temperature of the run tank and bottle straight from the excel
% input sheet
T_run_tank(1) = f_to_k(inputs.VALUE(strcmp(inputs.PARAMETER, "Initial Bottle Temperature (F)")));
T_bottle(1) = f_to_k(inputs.VALUE(strcmp(inputs.PARAMETER, "Initial Bottle Temperature (F)")));

% Import variables from the excel input sheet
orifice_diameter = inputs.VALUE(strcmp(inputs.PARAMETER, "Tank Orifice Diameter (in)"));
cyl_diameter = inputs.VALUE(strcmp(inputs.PARAMETER, "Cylinder Diameter (in)"));
vol_bottle = cf.ft3_to_m3 * inputs.VALUE(strcmp(inputs.PARAMETER, "Bottle Volume (ft3)"));
vol_run_tank = cf.ft3_to_m3 * inputs.VALUE(strcmp(inputs.PARAMETER, "Run Tank Volume (ft3)"));

% Initialize bottle properties
m_bottle(1) = cf.lb_to_kg * inputs.VALUE(strcmp(inputs.PARAMETER, "Initial N2O Mass (lb)"));
v_bottle(1) = vol_bottom / m_bottle(1);
x_bottle(1) = get_quality(T_bottle(1), "Volume_m3_kg", v_bottle(1) * cf.ft3lb_to_m3kg);
u_bottle(1) = get_state_variable(T_bottle(1), x_bottle(1), "Internal_Energy_kJ_kg");

% Initialize run tank properties
x_run_tank(1) = 1; % assume all vapor at the beginning
T_run_tank(1) = T_bottle(1); % assume temperature is equal
v_run_tank(1) = get_state_variable(T_bottle(1), x, "Volume_m3_kg");
m_run_tank(1) = vol_run_tank / v_run_tank(1);
u_run_tank(1) = get_state_variable(T_bottle(1), x, "Internal_Energy_kJ_kg");
mu_run_tank(1) = get_state_variable(T_bottle(1), 1, "Viscosity_uPa_s");











for n = 1:length(t)-1
    % Calculate m_dot out of the run tank
    
end








