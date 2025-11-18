% This is the main function for Version 1 of the engine simulation.

%% Vector declaration

% Time and Timestep (seconds)
final_t = 15;
dt = 0.001; 
N = final_t / dt + 1;
t = zeros(1, N);

% N2O-tank 
N2O_tank_pressure = zeros(1, N);
N2O_tank_density = zeros(1, N);
N2O_mass = zeros(1, N);
N2O_int_energy = zeros(1, N);
N2O_tank_temp = zeros(1, N);
phase = zeros(1, N);

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
N2O_density = lookup_property("liquid_properties", N2O_tank_pressure, 2, 3);
N2O_abs_visc = lookup_property("liquid_properties", N2O_tank_pressure, 2, 12) * 0.001;


P_inlet_mpa = P_inlet / 145; % psi to mpa because the property sheet is in metric
rho_inlet = lookup_property("liquid_properties", P_inlet_mpa, 2, 3);


%% Inputs and Initial condition management

% N2O-tank 
N2O_tank_pressure(1) = 903.82;
N2O_tank_density(1) = 816.99;
N2O_mass(1) = 6.2; 
%N2O_int_energy(1) = 
%N2O_tank_temp(1) = 
N2O_tank_volume = 602 / 61020; % (m^3)
phase(1) = "liquid";

% N2O-injector
N2O_Cd = 0.6;
N2O_inj_a = ;
N2O_inj_P = zeros(1, N);
N2O_mdot = zeros(1, N);

% Ethanol-tank 
ethanol_mass = zeros(1, N);
n2_ullage_pressure = zeros(1, N);
n2_ullage_volume = zeros(1, N);

% Ethanol-injector 
e_inj_a = 0;
e_Cd = 0;
ethanol_inj_P = zeros(1, N);
ethanol_mdot = zeros(1, N);

% N2O Feed Line
N2O_line_dP = zeros(1, N);
N2O_line_length = ;
N2O_line_id = 0.25; % (in)
N2O_line_abs_rough = ;
N2O_K_loss = ;

% Ethanol Feed Line
ethanol_line_dP = 
ethanol_density = 850; % (kg/m^3)
ethanol_line_abs_rough = ;
ethanol_line_length = ;
ethanol_line_id = 0.25; % (in)
ethanol_K_loss = ;
ethanol_abs_visc = 0;

% Thrust Chamber
chamber_temp = zeros(1, N);
M_exit = zeros(1, N);
P_amb = zeros(1, N);
gamma_cmb = 1.229;
D1 = 
A_throat = 
A_exit = 
expansion_ratio = A_exit / A_throat;
R_cmb = ;
c_star = ;
Cmb_molecular_weight = ;
raw_ch_P = zeros(1, N);
ch_P_ratio = zeros(1, N);
T_exit = zeros(1, N);
dPdT(1) = 0;
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

%% Cluster Iteration

for i = 2:N-1
    properties_file = sprintf("%s_properties", phase);

    % N2O Injector
    % P_inlet_mpa = N2O_inj_P(i) / 145; % psi to mpa because the property sheet is in metric
    % rho_inlet = lookup_property(properties_file, P_inlet_mpa, 2, 3);
    N2O_mdot(i) = get_mass_flow_SPI_N2O(Cd, N2O_inj_a, N2O_tank_density(i-1), N2O_inj_P-chamber_pressure);

    % Ethanol Injector
    N2O_mdot(i) = get_ethanol_mass_flow(e_Cd, e_inj_a, ethanol_density, ethanol_inj_P(i-1) - chamber_pressure(i-1));

    % Nitrous Oxide Tank
    N2O_mass(i) = get_N2O_mass(phase, N2O_mass(i-1), N2O_mdot(i-1), dt, N2O_tank_density(i), N2O_tank_volume);
    N2O_tank_pressure(i) = get_N2O_tank_pressure(phase, N2O_tank_pressure(i-1), dt, N2O_tank_pressure(1), N2O_mass(i-1), N2O_mass(1));
    %N2O_int_energy(i) = lookup_property("liquid_properties", N2O_tank_pressure(i), 2, 5); % (kJ kg)
    N2O_tank_temp(i) = lookup_property(properties_file, P_tank_pressure(i), 2, 1);

    % Ethanol Tank
    ethanol_mass(i) = get_ethanol_mass(ethanol_mass(i-1), ethanol_mdot(i-1), dt);
    n2_ullage_volume(i) = get_ullage_volume(n2_ullagee_volume(i-1), dt, ethanol_density);
    n2_ullage_pressure(i) = get_ethanol_tank_pressure(n2_ullage_pressure(i-1), n2_ullage_volume(i-1), n2_ullage_volume(i));

    % Nitrous Oxide Feed Line
    N2O_line_dP(i) = get_pressuredrop(N2O_mdot(i), N2O_tank_density(i), N2O_a, N2O_K_loss);

    % Ethanol Feed Line
    ethanol_line_dP(i) = get_pressuredrop(ethanol_mdot(i), ethanol_density, ethanol_abs_visc, ethanol_K_loss);

    % Thrust Chamber
    raw_ch_P(i) = get_raw_chamber_pressure_pa(c_star, mdot_total(i), A_throat);
    D1(i) = get_D1_factor(raw_thrust(i-1), raw_thrust(i-2));
    chamber_pressure(i) = get_corrected_chamber_pressure_pa(chamber_pressure(i-1), raw_ch_P(i), D1, phase);
    M_exit(i) = get_exit_mach_number(lookup_property("isentropic_relations", expansion_ratio, 16, 21), lookup_property("isentropic_relations", expansion_ratio, 24, 29), gamma_cmb);
    ch_P_ratio(i) = get_pressure_ratio_P_over_P0(gamma_cmb, M_exit(i));
    T_exit(i) = get_exit_temperature(chamber_temp, gamma_cmb, M_exit(i));
    V_exit(i) = get_exit_velocity(M_exit(i), gamma_cmb, R_cmb, T_exit(i));
    P_exit(i) = get_exit_pessure(chamber_pressure(i), ch_P_ratio);
    raw_thrust(i) = get_raw_thrust(mdot_total(i), V_exit(i), P_exit(i), P_amb(i), A_exit);

end