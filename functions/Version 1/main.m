addpath("columns_AAtoAZ/", "columns_BAtoBZ/", "columns_AtoZ/","columns_CAtoCZ/","data/");

% This is the main function for Version 1 of the engine simulation.

%% Vector declaration

% Time and Timestep (seconds)
final_t = 5;
dt = 0.001; 
N = final_t / dt + 1;
t = zeros(1, N);

% N2O-tank 
N2O_tank_pressure = zeros(1, N);
N2O_tank_density = zeros(1, N);
N2O_mass = zeros(1, N);
N2O_int_energy = zeros(1, N);
N2O_tank_temp = zeros(1, N);
phase = strings([1, N]);

% N2O-injector 
N2O_inj_P = zeros(1, N);
N2O_mdot = zeros(1, N);

% Ethanol-tank 
ethanol_mass = zeros(1, N);
n2_ullage_pressure = zeros(1, N);
n2_ullage_volume = zeros(1, N);

% Ethanol-injector 
ethanol_inj_P = zeros(1, N);
ethanol_mdot = zeros(1, N);

% N2O Feed Line
N2O_line_dP = zeros(1, N);

% Ethanol Feed Line
ethanol_line_dP = zeros(1, N);

% Thrust Chamber
chamber_temp = zeros(1, N);
M_exit = zeros(1, N);
P_amb = zeros(1, N);
raw_ch_P = zeros(1, N);
ch_P_ratio = zeros(1, N);
T_exit = zeros(1, N);
dPdT = zeros(1, N);
V_exit = zeros(1, N);
inst_delta_V = zeros(1, N);
chamber_pressure = zeros(1, N);
P_exit = zeros(1, N);
mdot_total = zeros(1, N);
OF_ratio = zeros(1, N);
raw_thrust = zeros(1, N);
thrust_Gradient = zeros(1, N);
thrust = zeros(1, N);
impulse = zeros(1, N);

%% Var. Lookup

% N2O Feed Line
% N2O_density = lookup_property("liquid_properties", N2O_tank_pressure, 2, 3);
% N2O_abs_visc = lookup_property("liquid_properties", N2O_tank_pressure, 2, 12) * 0.001;


%P_inlet_mpa = P_inlet / 145; % psi to mpa because the property sheet is in metric
%rho_inlet = lookup_property("liquid_properties", P_inlet_mpa, 2, 3);


%% Inputs and Initial condition management

% N2O-tank 
N2O_tank_pressure(1) = 903.82 * 6895; % (Pa)
N2O_tank_density(1) = 695.24; % (kg/m^3)
%N2O_tank_density_v(1) = 227.26105; % (kg/m^3)
N2O_mass(1) = 6.2; % (kg)
%N2O_int_energy(1) = 
%N2O_tank_temp(1) = 
N2O_tank_volume = 602 / 61.024; % (l)
phase(1) = "liquid";

% N2O-injector
N2O_Cd = 1.901546;
N2O_inj_a = 1.57e-5;
N2O_inj_P(1) = N2O_tank_pressure(1);
N2O_mdot(1) = get_mass_flow_SPI_N2O(N2O_Cd, N2O_inj_a, N2O_tank_density(1), N2O_inj_P(1)) * 0.1;

% Ethanol-tank 
ethanol_mass(1) = 1.6;
n2_ullage_pressure(1) = 4385067;
n2_ullage_volume(1) = 3.9;
ethanol_density = 850; % (kg/m^3)

% Ethanol-injector 
e_inj_a = 0.00003418; %m^2
e_Cd = 0.2096;
ethanol_inj_P(1) = n2_ullage_pressure(1);
ethanol_mdot(1) = get_ethanol_mass_flow(e_Cd, e_inj_a, ethanol_density, ethanol_inj_P(1));

% N2O Feed Line
N2O_line_length = 0.3556001016; % m
N2O_line_id = 0.0102108; % (m)
N2O_line_abs_rough = 1.500124e-5; % m
N2O_K_loss = 0.3562911503+0.3487562189+0.5+1;
N2O_line_dP(1) = get_pressuredrop(N2O_mdot(1), N2O_tank_density(1), N2O_inj_a, N2O_K_loss, N2O_line_length, N2O_line_id);

% Ethanol Feed Line
ethanol_line_dP = zeros(1, N);
ethanol_line_abs_rough = 1.500124e-5; % m
ethanol_line_length = 1.12776; % m
ethanol_line_id = 0.007747; % m
ethanol_K_loss = 0.9943489899+0.4278688525+0.5+0.5;
ethanol_abs_visc = 1.04/1000; % Pa-s

% Thrust Chamber
%chamber_temp = zeros(1, N);
chamber_temp = 3091;
M_exit = zeros(1, N);
P_amb = zeros(1, N);
gamma_cmb = 1.229;
D1(1) = 1; 
D1(2) = 0.75;
A_throat = 0.000568321965;
A_exit = 0.003097482;
expansion_ratio = A_exit / A_throat;
R_cmb = 281.304; %J/kg/K
c_star = 1558.7; %m/s
Cmb_molecular_weight = 29.55522; %g/mol
raw_ch_P = zeros(1, N);
ch_P_ratio = zeros(1, N);
T_exit = zeros(1, N);
dPdT(1) = 0;
V_exit = zeros(1, N);
inst_delta_V = zeros(1, N);
chamber_pressure = zeros(1, N);
P_exit = zeros(1, N);
mdot_total(1) = get_total_mass_flow(N2O_mdot(1), ethanol_mdot(1));
OF_ratio = zeros(1, N);
raw_thrust = zeros(1, N);
thrust_Gradient = zeros(1, N);
thrust = zeros(1, N);
impulse = zeros(1, N);
M_120 = lookup_property(expansion_ratio, 15, 20, file="isentropic_relations");
M_125 = lookup_property(expansion_ratio, 22, 27, file="isentropic_relations");
properties_file = sprintf("%s_properties", phase(1));

liq_props = readmatrix("liquid_properties.xlsx");
vap_props = readmatrix("vapor_properties.xlsx");

props_matrix = liq_props;


%% Cluster Iteration

for i = 2:N-1
    t(i) = t(i-1)+dt;
    
    if phase(i) == "vapor" && phase(i-1) == "liquid"
        props_matrix = vap_props;
    end

    % N2O Injector

    % P_inlet_mpa = N2O_inj_P(i) / 145; % psi to mpa because the property sheet is in metric
    % rho_inlet = lookup_property(properties_file, P_inlet_mpa, 2, 3);
    if i < 10
        N2O_mdot(i) = get_mass_flow_SPI_N2O(N2O_Cd, N2O_inj_a, N2O_tank_density(i-1), N2O_inj_P(i-1)-chamber_pressure(i-1)) * i / 10;
    else
        N2O_mdot(i) = get_mass_flow_SPI_N2O(N2O_Cd, N2O_inj_a, N2O_tank_density(i-1), N2O_inj_P(i-1)-chamber_pressure(i-1));
    end


    % P_inlet_mpa = N2O_inj_P(i) / 145; % psi to mpa because the property sheet is in metric
    % rho_inlet = lookup_property("liquid_properties", P_inlet_mpa, 2, 3);

    %test

    % Ethanol Injector
    % Startup
    ethanol_mdot(i) = get_ethanol_mass_flow(e_Cd, e_inj_a, ethanol_density, ethanol_inj_P(i-1) - chamber_pressure(i-1));
    
    % Nitrous Oxide Tank
% Lookup table version    phase(i) = get_N2O_phase(N2O_mass(i-1), N2O_mdot(i-1), dt, N2O_tank_volume, lookup_property(N2O_tank_pressure(i-1)/1000000, 2, 3, matrix=vap_props), phase(i-1));
    phase(i) = get_N2O_phase(N2O_mass(i-1), N2O_mdot(i-1), dt, N2O_tank_volume, py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i-1), 'Q', 1, 'NitrousOxide'), phase(i-1));
    N2O_mass(i) = get_N2O_mass(phase(i), N2O_mass(i-1), N2O_mdot(i-1), dt, N2O_tank_density(i-1), N2O_tank_volume);
    N2O_tank_pressure(i) = get_N2O_tank_pressure(phase(i), N2O_tank_pressure(i-1), dt, N2O_tank_pressure(1), N2O_mass(i-1), N2O_mass(1));
% Lookup table version    N2O_tank_density(i) = lookup_property(N2O_tank_pressure(i)/1000000, 2, 3, matrix=props_matrix);
    N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 0, 'NitrousOxide');
    %N2O_tank_density_v(i) = lookup_property(N2O_tank_pressure(i)/1000000, 2, 3, matrix=vap_props);
    %N2O_int_energy(i) = lookup_property("liquid_properties", N2O_tank_pressure(i), 2, 5); % (kJ kg)
    %N2O_tank_temp(i) = lookup_property(properties_file, N2O_tank_pressure(i), 2, 1);

    % Ethanol Tank
    ethanol_mass(i) = get_ethanol_mass(ethanol_mass(i-1), ethanol_mdot(i-1), dt);
    n2_ullage_volume(i) = get_ullage_volume(n2_ullage_volume(i-1), dt, ethanol_density);
    n2_ullage_pressure(i) = get_ethanol_tank_pressure(n2_ullage_pressure(i-1), n2_ullage_volume(i-1), n2_ullage_volume(i));

    % Nitrous Oxide Feed Line
    N2O_line_dP(i) = get_pressuredrop(N2O_mdot(i), N2O_tank_density(i), N2O_inj_a, N2O_K_loss, N2O_line_length, N2O_line_id);
    N2O_inj_P(i) = get_N2O_injector_inlet_pressure(N2O_tank_pressure(i), N2O_line_dP(i));

    % Ethanol Feed Line
    ethanol_line_dP(i) = get_pressuredrop(ethanol_mdot(i), ethanol_density, ethanol_abs_visc, ethanol_K_loss, ethanol_line_length, ethanol_line_id);
    ethanol_inj_P(i) = get_ethanol_injector_inlet_pressure(n2_ullage_pressure(i), ethanol_line_dP(i));

    % Thrust Chamber
    mdot_total(i) = get_total_mass_flow(N2O_mdot(i), ethanol_mdot(i));
    raw_ch_P(i) = get_raw_chamber_pressure_pa(c_star, mdot_total(i), A_throat);
    if i > 2
        D1(i) = get_D1_factor(raw_thrust(i-1), raw_thrust(i-2));
    end
    chamber_pressure(i) = get_corrected_chamber_pressure_pa(chamber_pressure(i-1), raw_ch_P(i), D1(i), phase(i));
    M_exit(i) = get_exit_mach_number(M_120, M_125, gamma_cmb);
    ch_P_ratio(i) = get_pressure_ratio_P_over_P0(gamma_cmb, M_exit(i));
    T_exit(i) = get_exit_temperature(chamber_temp, gamma_cmb, M_exit(i));
    V_exit(i) = get_exit_velocity(M_exit(i), gamma_cmb, R_cmb, T_exit(i));
    P_exit(i) = get_exit_pressure(chamber_pressure(i), ch_P_ratio(i));
    raw_thrust(i) = get_raw_thrust(mdot_total(i), V_exit(i), P_exit(i), P_amb(i), A_exit);
    
end


plot(t(1:end-1), raw_thrust(1:end-1), t, N2O_mass, t, ethanol_mass);