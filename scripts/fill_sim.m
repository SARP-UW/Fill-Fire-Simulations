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
T_aluminum = zeros(size(t));
T_bottle = zeros(size(t)); 
u_run_tank = zeros(size(t)); 
u_bottle = zeros(size(t));
U_tot_run_tank = zeros(size(t));
U_tot_bottle = zeros(size(t));
h_run_tank = zeros(size(t)); 
h_bottle = zeros(size(t)); 
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
m_dot_run_tank_out = zeros(size(t));
m_dot_run_tank_in = zeros(size(t));
q_run_tank = zeros(size(t));
q_run_tank_nitrous = zeros(size(t));
q_bottle = zeros(size(t));

% Initialize temperature of the run tank and bottle straight from the excel
% input sheet
T_run_tank(1) = f_to_k(inputs.VALUE(strcmp(inputs.PARAMETER, "Initial Bottle Temperature (F)"))) - 0.9; % kelvin, estimate slightly less than bottle pressure
T_bottle(1) = f_to_k(inputs.VALUE(strcmp(inputs.PARAMETER, "Initial Bottle Temperature (F)")));
T_aluminum(1) = T_run_tank(1);
T_amb = f_to_k(inputs.VALUE(strcmp(inputs.PARAMETER, "Initial Bottle Temperature (F)")));
wind_speed = 20;
solar_zenith = 0;

% Import variables from the excel input sheet
orifice_diameter = inputs.VALUE(strcmp(inputs.PARAMETER, "Tank Orifice Diameter (in)"));
cyl_diameter = inputs.VALUE(strcmp(inputs.PARAMETER, "Cylinder Diameter (in)"));
vol_bottle = cf.ft3_to_m3 * inputs.VALUE(strcmp(inputs.PARAMETER, "Bottle Volume (ft3)"));
vol_run_tank = cf.ft3_to_m3 * inputs.VALUE(strcmp(inputs.PARAMETER, "Run Tank Volume (ft3)"));

% Initialize bottle properties
m_bottle(1) = cf.lb_to_kg * inputs.VALUE(strcmp(inputs.PARAMETER, "Initial N2O Mass (lb)"));
v_bottle(1) = vol_bottle / m_bottle(1);
x_bottle(1) = get_quality(T_bottle(1), "Volume_m3_kg", v_bottle(1) * cf.ft3lb_to_m3kg);
u_bottle(1) = get_state_variable(T_bottle(1), x_bottle(1), "Internal_Energy_kJ_kg");
U_tot_bottle(1) = u_bottle(1) * m_bottle(1);
h_bottle(1) = get_state_variable(T_bottle(1), x_bottle(1), "Enthalpy_kJ__kg");
P_bottle(1) = get_state_variable(T_bottle(1), x_bottle(1), "Pressure_Mpa") * cf.mpa_to_psi;
q_bottle(1) = 0; % assuming no heat transfer FOR NOW

% Initialize run tank properties
x_run_tank(1) = 1; % assume all vapor at the beginning
P_run_tank(1) = get_state_variable(T_run_tank(1), x_run_tank(1), "Pressure_Mpa") * cf.mpa_to_psi;
v_run_tank(1) = get_state_variable(T_bottle(1), x_run_tank(1), "Volume_m3_kg") / cf.ft3lb_to_m3kg;
disp(v_run_tank(1))
m_run_tank(1) = vol_run_tank / v_run_tank(1);
u_run_tank(1) = get_state_variable(T_bottle(1), x_run_tank(1), "Internal_Energy_kJ_kg");
U_tot_run_tank(1) = u_run_tank(1) * m_run_tank(1);
h_run_tank(1) = get_state_variable(T_bottle(1), x_run_tank(1), "Enthalpy_kJ__kg");
mu_run_tank(1) = get_state_variable(T_bottle(1), 1, "Viscosity_uPa_s");


for n = 2:length(t)-1
    disp(n)
    % Calculate m_dot out of the run tank
    
    [m_dot_run_tank_out(n), fill_time] = get_mdot_tank_orifice(P_run_tank(n - 1), orifice_diameter, cyl_diameter, 1 / v_run_tank(n-1)); % lb/s
    m_dot_run_tank_out(n) = m_dot_run_tank_out(n) * cf.lb_to_kg;
    disp(m_dot_run_tank_out(n))

    % Mass flow into run tank
    v_f_bottle(n) = 1 / get_state_variable(T_bottle(n-1), "f", "Density_kg_m3");
    mu_bottle(n) = get_state_variable(T_bottle(n-1), "f", "Viscosity_uPa_s");
    P1_Pa = P_bottle(n-1) * 6894.76;
    P2_Pa = P_run_tank(n-1) * 6894.76;

    fprintf("P1 is %f\n", P1_Pa)
    fprintf("P2 is %f\n", P2_Pa)
    fprintf("rho is %f\n", 1 / v_f_bottle(n))
    fprintf("mu is %f\n", mu_bottle(n))

    m_dot_run_tank_in(n) = get_mdot_fill(P1_Pa, P2_Pa, (1 / v_f_bottle(n)), mu_bottle(n));

    % Heat transfer to run tank
    q_run_tank_nitrous(n) = nitrousQ(T_run_tank(n-1), T_aluminum(n-1)) * dt;
    q_run_tank(n) = tankQ(T_amb, T_aluminum(n-1), q_run_tank_nitrous(n) / dt, wind_speed, solar_zenith) * dt;
    T_aluminum(n) = tankT(q_run_tank(n) / dt, dt);

    % New mass in run tank
    m_run_tank(n) = m_run_tank(n-1) + (m_dot_run_tank_in(n) - m_dot_run_tank_out(n))*dt;
    disp(m_run_tank(n))
    disp(m_run_tank(n-1))
    v_run_tank(n) = vol_run_tank / m_run_tank(n);

    % New energy in run tank
    dU_run_tank = ( (m_dot_run_tank_in(n) * h_bottle(n-1)) - (m_dot_run_tank_out(n) * h_run_tank(n-1)) +  q_run_tank(n) ) * dt;
    U_tot_run_tank(n) = U_tot_run_tank(n-1) + dU_run_tank;
    u_run_tank(n) = U_tot_run_tank(n) / m_run_tank(n);
    
    % New state in run tank
    disp(1 / v_run_tank(n))
    disp(1 / v_run_tank(n-1))
    disp(u_run_tank(n))
    disp(u_run_tank(n-1))
    disp(T_run_tank(n-1))
    [T_run_tank(n), x_run_tank(n)] = state_density(1 / v_run_tank(n), u_run_tank(n), T_run_tank(n-1));
    P_run_tank(n) = get_state_variable(T_run_tank(n), x_run_tank(n), "Pressure_Mpa") * cf.mpa_to_psi;
    h_run_tank(n) = get_state_variable(T_run_tank(n), x_run_tank(n), "Enthalpy_kJ__kg");
    v_f_run_tank(n) = get_state_variable(T_run_tank(n), "f", "Volume_m3_kg");
    v_g_run_tank(n) = get_state_variable(T_run_tank(n), "g", "Volume_m3_kg");
    mu_run_tank(n) = get_state_variable(T_run_tank(n), x_run_tank(n), "Viscosity_uPa_s");

    % New energy in bottle
    m_bottle(n) = m_bottle(n-1) - (m_dot_run_tank_in(n) * dt);
    q_bottle(n) = q_bottle(n-1); % assume doesn't change from 0
    dU_bottle = ( q_bottle(n) - (m_dot_run_tank_in(n) * h_bottle(n-1)) ) * dt;
    U_tot_bottle(n) = U_tot_bottle(n-1) + dU_bottle;
    u_bottle(n) = U_tot_bottle(n) / m_bottle(n);

    % New state in bottle
    v_bottle(n) = vol_bottle / m_bottle(n);
    [T_bottle(n), x_bottle(n)] = state_density(1 / v_bottle(n), u_bottle(n), T_bottle(n-1));
    P_bottle(n) = get_state_variable(T_bottle(n), x_bottle(n), "Pressure_Mpa") * cf.mpa_to_psi;
    h_bottle(n) = get_state_variable(T_bottle(n), x_bottle(n), "Enthalpy_kJ__kg");
    v_f_bottle(n) = get_state_variable(T_bottle(n), "f", "Volume_m3_kg");
    v_g_bottle(n) = get_state_variable(T_bottle(n), "g", "Volume_m3_kg");
    mu_bottle(n) = get_state_variable(T_bottle(n), x_bottle(n), "Viscosity_uPa_s");

end








