% This is the main function for Version 1 of the engine simulation.

%% Vector allocation

% Time and Timestep
final_t = 6; % (s)
dt = 0.01;   % (s)
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
N2O_inj_dP = zeros(1, N);
N2O_mdot = zeros(1, N);
mdot_SPI = zeros(1, N);
mdot_HEM = zeros(1, N);

% Ethanol-tank 
ethanol_mass = zeros(1, N);
n2_ullage_pressure = zeros(1, N);
n2_ullage_volume = zeros(1, N);

% Ethanol-injector 
ethanol_inj_P = zeros(1, N);
ethanol_mdot = zeros(1, N);

% N2O Feed Line
raw_N2O_line_dP = zeros(1,N);
N2O_line_dP = zeros(1, N);
N2O_line_v = zeros(1, N);

% Ethanol Feed Line
ethanol_line_dP = zeros(1, N);

% Thrust Chamber
mdot_total = zeros(1, N);
chamber_pressure = zeros(1, N);
of_ratio = zeros(1, N);
thrust = zeros(1, N);
thrust_C = zeros(1, N);
total_mass = zeros(1, N);
TWR = zeros(1, N);

%% Inputs and initial conditions

% N2O-tank 
N2O_tank_pressure(1) = 6.205e+6; % (Pa)
N2O_tank_density(1) = 695.24; % (kg/m^3)
N2O_mass(1) = 6.2; % (kg)
N2O_tank_volume = 8.917783787; % (l)
phase(1) = "liquid";
ox_out = 0;

% N2O-injector
N2O_Cd = 0.6;
N2O_inj_a = 0.00004; % m^2  % 0.0000295205 match phase change to eth-out
N2O_CdA = N2O_Cd * N2O_inj_a;
N2O_CdA_HEM = 0.9 * N2O_inj_a;
N2O_inj_P(1) = N2O_tank_pressure(1);
N2O_mdot(1) = mSPI(N2O_CdA, N2O_inj_P(1), 1, "liquid", 'nitrous') * 0.1;
N2O_inj_stiffness = .20;
N2O_inj_dP(1) = N2O_inj_P(1) * N2O_inj_stiffness;

% Ethanol-tank 
ethanol_mass(1) = 1.6; % (kg)
n2_ullage_pressure(1) = 6.205e+6; % (Pa)
n2_ullage_volume(1) = 3.9 / 1000; % (m^3)
n2_mass = n2_ullage_volume(1) * 67; % (kg), N2 density acquired from NIST table
ethanol_density = 850; % (kg/m^3)
den_tran = 0; % Don't change
fuel_out = 0;

% Ethanol-injector 
e_inj_a = 0.00003418; %m^2
e_Cd = 0.2096;
e_CdA = e_inj_a * e_Cd;
ethanol_inj_P(1) = n2_ullage_pressure(1);
ethanol_mdot(1) = mSPI(e_CdA, ethanol_inj_P(1), chamber_pressure(1), 'liquid', 'ethanol');

% N2O Feed Line
N2O_line_length = 0.3556001016; % m
N2O_line_id = 0.0102108; % (m)
N2O_line_abs_rough = 1.500124e-5; % m
N2O_K_loss = 0.3562911503+0.3487562189+0.5+1;
raw_N2O_line_dP(1) = get_pressuredrop(N2O_mdot(1), N2O_tank_density(1), N2O_inj_a, N2O_K_loss, N2O_line_length, N2O_line_id);
[N2O_line_dP(1), N2O_line_v(1)] = get_pressuredrop(N2O_mdot(1), N2O_tank_density(1), N2O_inj_a, N2O_K_loss, N2O_line_length, N2O_line_id);

% Ethanol Feed Line
ethanol_line_abs_rough = 1.500124e-5; % m
ethanol_line_length = 1.12776; % m
ethanol_line_id = 0.007747; % m
ethanol_K_loss = 0.9943489899+0.4278688525+0.5+1;
ethanol_abs_visc = 1.04/1000; % Pa-s

% Thrust Chamber
mdot_total(1) = N2O_mdot(1) + ethanol_mdot(1);
chamber_pressure(1) = 1; % Pa         (1.818955544220220e+05)
of_ratio(1) = N2O_mdot(1) / ethanol_mdot(1);
dry_mass = 42; % (kg)
total_mass(1) = dry_mass + N2O_mass(1) + ethanol_mass(1);

phase_change_i = 0; % Don't change

% Load property tables
liq_props = readmatrix("liquid_properties.xlsx");
vap_props = readmatrix("vapor_properties.xlsx");
props_matrix = liq_props;

%% Cluster Iteration

for i = 2:N-1

    % Update time
    t(i) = t(i-1)+dt;
    
    % Update phase and record when phase change occurs
    phase(i) = get_N2O_phase(N2O_mass(i-1), N2O_mdot(i-1), dt, N2O_tank_volume, ...
        py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i-1), 'Q', 1, 'NitrousOxide'), phase(i-1));
    if phase(i) == 'vapor' && phase(i-1) == 'liquid'
        phase_change_i = i;
        props_matrix = vap_props;
    end

    % Update N2O mass flow
    mdot_SPI(i) = mSPI(N2O_CdA, N2O_inj_P(i-1), chamber_pressure(i-1), phase(i), 'nitrous');
    if phase(i) == 'liquid'
        mdot_HEM(i) = mHEM(N2O_CdA_HEM, N2O_inj_P(i-1), chamber_pressure(i-1), phase(i));
    else
        mdot_HEM(i) = m_HEMc(N2O_inj_P(i-1), N2O_CdA_HEM, phase(i));
    end
    N2O_mdot(i) = 0.5 * mdot_SPI(i) + 0.5 * mdot_HEM(i); % Dyer model with K = 1
    
    if N2O_mdot(i) == 0
        break;
    end

    % Get ethanol mass flow
    ethanol_mdot(i) = mSPI(e_CdA, ethanol_inj_P(i-1), chamber_pressure(i-1), "liquid", 'ethanol');

    % Update N2O mass and pressure
    N2O_mass(i) = N2O_mass(i-1) - dt * N2O_mdot(i);
    if N2O_mass(i) < 0
        N2O_mass(i) = 0;
        ox_out = 1;
        break;
    end

    if phase(i) == 'vapor'
        % Vapor phase: exponential decay of pressure
        N2O_tank_pressure(i) = N2O_tank_pressure(i-1) / exp(0.8 * dt);
    elseif phase(i) == 'liquid'
        % Liquid phase: proportional to mass ratio
        N2O_tank_pressure(i) = N2O_tank_pressure(1) * ((N2O_mass(i) / N2O_mass(1)) * (1 - 0.7) + 0.7);
    end
    if phase(i) == "liquid"
        N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 0, 'NitrousOxide'); 
    end
    
    % Smooth out the density drop when N2O phase changes
    if phase(i) == "vapor" && phase(i-1) == "liquid"
        den_tran = 2;
    end
    if den_tran ~= 0
        N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide') * den_tran; 
        den_tran = den_tran - 1;
    elseif phase(i) == "vapor"
        N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide');
    end

    % Update ethanol mass, nitrogen volume, and nitrogen pressure
    ethanol_mass(i) = ethanol_mass(i-1) - dt * ethanol_mdot(i);
    if ethanol_mass(i) < 0
        ethanol_mass(i) = 0;
        fuel_out = 1;
        break;
    end
    n2_ullage_volume(i) = n2_ullage_volume(i-1) + ethanol_mdot(i) / ethanol_density * dt;
    n2_ullage_pressure(i) = n2_ullage_pressure(i-1) * n2_ullage_volume(i-1) / n2_ullage_volume(i);

    % Update N2O absolute viscosity, line dP, velocity, injector pressure, and injector dP
    N2O_abs_visc = lookup_property(N2O_tank_pressure(i)/1000000, 2, 12, matrix=props_matrix);
    [N2O_line_dP(i), N2O_line_v(i)] = get_pressuredrop(N2O_mdot(i), N2O_tank_density(i), N2O_abs_visc/10^6, N2O_K_loss, N2O_line_length, N2O_line_id);

    % % If the sim is breaking, bound nitrous line dP conditions
    % if N2O_line_dP(i) < 10e5
    %     N2O_line_dP(i) = 10e5;
    % end

    N2O_inj_P(i) = N2O_tank_pressure(i) - N2O_line_dP(i);
    N2O_inj_dP(i) = N2O_inj_P(i) * N2O_inj_stiffness;

    % If the sim is breaking, bound injector pressure conditions
    if N2O_inj_P(i) < chamber_pressure(i-1)
        N2O_inj_P(i) = chamber_pressure(i-1) + 1e6;
    end
    if N2O_inj_P(i) > N2O_tank_pressure(i-1)
        N2O_inj_P(i) = N2O_tank_pressure(i-1) - 1e6;
    end
    % Injector pressure stabilization
    N2O_inj_P(i) = (N2O_inj_P(i-1) + N2O_inj_P(i)) / 2; 

    % Update ethanol line dP and injector pressure
    ethanol_line_dP(i) = get_pressuredrop(ethanol_mdot(i), ethanol_density, ethanol_abs_visc, ethanol_K_loss, ethanol_line_length, ethanol_line_id);
    ethanol_inj_P(i) = n2_ullage_pressure(i) - ethanol_line_dP(i);

    % Update total mass flow, OF ratio, chamber pressure, and thrust
    mdot_total(i) = N2O_mdot(i) + ethanol_mdot(i);
    if mdot_total(i) < 0.2
        break;
    end
    of_ratio(i) = N2O_mdot(i) / ethanol_mdot(i);
    [chamber_pressure(i), thrust(i)] = TransientThrustCurveAnalysis('datatest3.mat', chamber_pressure(i-1), mdot_total(i), of_ratio(i));
    
    % % Bound if needed
    if N2O_inj_P(i) - chamber_pressure(i) < N2O_inj_dP(i)
        chamber_pressure(i) = N2O_inj_P(i) - N2O_inj_dP(i);
    end
        
    % Grow chamber pressure slowly at start
    if i < 3
        chamber_pressure(i) = chamber_pressure(i) * i / 3;
    else
        if chamber_pressure(i) > chamber_pressure(i-1)
            chamber_pressure(i) = chamber_pressure(i-1);
        end
    end

    % Thrust stabilization
    thrust_C(i) = (thrust(i-1) + thrust(i)) / 2; 
    
    % Calculate TWR
    total_mass(i) = dry_mass + N2O_mass(i) + ethanol_mass(i) + n2_mass;
    TWR(i) = thrust_C(i) / (total_mass(i) * 9.8); % assume g is constant
    
    % If OF ratio is too low, combustion will be bad, so end sim
    if of_ratio(i) < 0.405
        ox_out = 1;
        break;
    end
end

%% Plots

% Find the time of the end of burn
t_end = N;
for k = length(t)-1:-1:1
    if t(k+1) == 0
        t_end = k;
    else
        break;
    end
end

% Thrust Curve
newFigure(1, 6, max(thrust_C)+500, gridOn=1, xaxis="Time (s)", yaxis='Thrust (N)', title='Thrust Curve for DC',int=0.25);
plot(t(1:t_end), thrust_C(1:t_end), 'LineWidth', 2, color='r');

% Mass Curves
newFigure(2, 6, N2O_mass(1)+0.5, gridOn=1, xaxis="Time (s)", yaxis='Mass (kg)', title='Mass of Nitrous and Ethanol',int=0.25);
plot(t(1:t_end), N2O_mass(1:t_end), 'LineWidth', 2, color='g');
plot(t(1:t_end), ethanol_mass(1:t_end), 'LineWidth', 2, color='r');
legend('Nitrous', 'Ethanol', 'FontSize', 12);

% Pressure Curves
newFigure(3, 6, N2O_tank_pressure(1)+100000, gridOn=1, xaxis="Time (s)", yaxis='Pressure (Pa)', title='Pressure Curves',int=0.25, y_min=0);
plot(t(1:t_end-1), N2O_tank_pressure(1:t_end-1), 'LineWidth', 2, color='g');
plot(t(1:t_end-1), n2_ullage_pressure(1:t_end-1), 'LineWidth', 2, color='r');
plot(t(1:t_end-1), chamber_pressure(1:t_end-1), 'LineWidth', 2, color='b');
plot(t(1:t_end-1), N2O_inj_P(1:t_end-1), 'LineWidth', 2, color='y');
legend('Nitrous', 'Ethanol', 'Chamber', 'N2O Injector', 'FontSize', 12);

%% Make output file

thrust_lbf = thrust_C / 4.448;
headings = {"Time", "Thrust (N)", "Thrust (lbf)", "N2O Mass Flow Rate (kg/s)", "N2O Mass (kg)", "Ethanol Mass Flow Rate (kg/s)", "Ethanol Mass (kg)", "TWR", "OFR", 'N2O Pressure (psi)', 'Ethanol Pressure (psi)', 'Nitrous Phase'};
writecell(headings, 'outputs.csv');
data = {t', thrust_C', thrust_lbf', N2O_mdot', N2O_mass', ethanol_mdot', ethanol_mass', TWR', of_ratio', N2O_tank_pressure'/6892, n2_ullage_pressure'/6892, phase'};
data = cell2mat(data);
data = data(1:t_end, :);
writematrix(data, "outputs.csv", 'WriteMode','append');


%% Functions

function phase = get_N2O_phase(m_prev, mdot_prev, dt, V_total_Ox, rho_Ox, prev_phase)
    m_remaining = m_prev - mdot_prev * dt;
    m_vapor_equiv = (V_total_Ox / 1000) * rho_Ox; % L → m^3

    if m_remaining < m_vapor_equiv
        phase = 'vapor';
    elseif prev_phase == 'vapor'
        phase = 'vapor';
    else
        phase = 'liquid';
    end
end

function [pressuredrop, v] = get_pressuredrop(mdot, rho, mu, K_total, tubeLength, tubeID)
    % mdot - mass flow rate of nitrous (kg/s)
    % rho - density of nitrous (kg/m^3)
    % mu - absolute visocity of nitrous (Pa * s)
    % K_total - total K value of fittings and valves

    % Define Constants
    d = tubeID/1000; % inner diameter of pipe(mm) 
    D = tubeID; % inner diameter of pipe (m)
    L = tubeLength; % length of piping (m)
    epsilon = 0.015; % absolute roughness of stainless steel pipe (mm)


    % Calculate fluid velocity
    v = (4 * mdot) / (pi * rho * D^2); % m/s

    % Calculate pressure loss from pipes

    % Calculate Reynolds Number
    Re = 353.7 * mdot * 3600 / (d * mu * 1000);

    % Calculate friction factor f with Serghide Approximation    
    f = get_friction_factor(d, epsilon, Re);

    % Calculate equivalent length of of all fittings/valves
    L_eq = (K_total * D) / f;
    
    % Calculate total effective length 
    L_effective = L + L_eq;

    % Calculate pressure loss from pipes
    pressuredrop = (f * L_effective * v^2 * rho) / (D*2);
    
end

function f = get_friction_factor(d, epsilon, Re)
    
    % Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);

end

function mdot = mHEM(CdA, P_inj_inlet, P_chamber, phase)

    x = 0;
    if phase == "vapor"
        x = 1;
    end
    
    if P_chamber == 0
        mdot = 0.1;
        return;
    end

    if P_chamber < 1e5
        P_chamber = 1e5;
    end

    s_in = py.CoolProp.CoolProp.PropsSI('S', 'P', P_inj_inlet, 'Q', x, "NitrousOxide"); %J/(kg*K)
    rho_outlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_chamber, 'S', s_in, 'NitrousOxide');
    enth_in = py.CoolProp.CoolProp.PropsSI('H', 'P', P_inj_inlet, 'Q', x, 'NitrousOxide');
    enth_out = py.CoolProp.CoolProp.PropsSI('H', 'P', P_chamber, 'S', s_in, 'NitrousOxide');

    mdot = CdA * rho_outlet * sqrt( 2 * (enth_in - enth_out) );
end

function m_dot = m_HEMc(N2O_inj_P, CdA, phase)
    % HEMcritical Calculation
    N = 20; %number of outlet pressure range of outlet pressures
    P_chamber_range = N2O_inj_P*(linspace(0.1,1,N)); % the minimum of this range gets too small at a certain pressure, find minimum value that coolprop can take and adjust around that.
    
    if N2O_inj_P < 9e4
        m_dot = 0;
        return;
    end

    if N2O_inj_P < 0 || abs(N2O_inj_P) < 1e-10
        m_dot = 0;
        return;
    end
    
    Q = 0;
    if phase == "vapor"
        Q = 1;
    end
    
    s_tank = py.CoolProp.CoolProp.PropsSI('S', 'P', N2O_inj_P, 'Q', Q, "NitrousOxide"); %J/kg/K
    H_tank = py.CoolProp.CoolProp.PropsSI('H', 'P', N2O_inj_P, 'S', s_tank, "NitrousOxide"); %kJ/kg
    HEMmdots = zeros(1, N);
    
    %Find choked HEM flow rate for an inlet pressure by varying outlet pressure
    for j = 1:N
        P_ch_press_temp = P_chamber_range(j);

        if P_ch_press_temp < 87900
            P_ch_press_temp = 87900;
        end

        H_i_out = py.CoolProp.CoolProp.PropsSI("H", "P", P_ch_press_temp, "S", s_tank, "NitrousOxide");
        rho_i_out = py.CoolProp.CoolProp.PropsSI("D", "P", P_ch_press_temp, "S", s_tank, "NitrousOxide");

        HEMmdots(j) = CdA * rho_i_out * sqrt(2 * (H_tank - H_i_out));
    end
    
    m_dot = max(HEMmdots);
end

function mdot = mSPI(CdA, P_inj_inlet, P_chamber, phase, fluid)
    
    Q = 0;
    if phase == "vapor"
        Q = 1;
    end
    if fluid == 'ethanol'
        rho_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', Q, 'Ethanol');
    else
        rho_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', Q, 'NitrousOxide');
    end

    mdot = CdA * sqrt( 2 * rho_inlet * (P_inj_inlet - P_chamber));

    if imag(mdot) > 0
        mdot = real(mdot);
    end

end

function [P_c_new,F_new] = TransientThrustCurveAnalysis(calibration_data,P_c_sim,m_dot,of_sim,P_0,A_e,A_t)
    arguments (Input)
        calibration_data {mustBeText}
        P_c_sim (1,1) {mustBeReal, mustBePositive} = 3.8 * 10^6 %temp
        m_dot (1,1) {mustBeReal, mustBePositive} = 1.27 % temporary
        of_sim (1,1) {mustBeReal, mustBePositive} = 4 % temp
        P_0 (1,1) {mustBeReal, mustBePositive} = 101325 % optional
        A_e (1,1) {mustBeReal, mustBePositive} = 123.899*(1/100)^2 % optional
        A_t (1,1) {mustBeReal, mustBePositive} = 5.69 * (1/100)^2 % optional
    end

    load(calibration_data);

    of = data.of;
    P_c = data.P_c;
    c_star = data.c_star;
    M_e = data.M_e;
    a_e = data.a_e;
    P_e = data.P_e;
    
    % instantaneous
     if of_sim < of(1)
        of_index = 1;
        %fprintf('warning! of is less than data range!')
    elseif of_sim > of(end)
        of_index = size(of, 2);
        %fprintf('warning! of is higher than data range!')
     else
        of_index = interp1( of(1,1:end), 1:numel(of(1,1:end)), round( of_sim, 1) );
        % of_index_l = floor( interp1( of(1,1:end), 1:numel(of(1,1:end)), round( of_sim, 1) ), 0 );
        % of_index_u = round( interp1( of(1,1:end), 1:numel(of(1,1:end)), round( of_sim, 1) ), 0 );
    end
    
    if P_c_sim < data.P_c(1)
        P_c_index = 1;
        %fprintf('warning! pressure is less than data range!')
    elseif P_c_sim > P_c(end)
        P_c_index = size(P_c);
        %fprintf('warning! pressure is higher than data range!')
    else
        P_c_index = interp1( P_c(1:end,1).', 1:numel(P_c(1:end,1)), round( P_c_sim, 1) );
        % P_c_index_l = floor( interp1( P_c(1:end,1).', 1:numel(P_c(1:end,1)), round( P_c_sim, 1) ) );
        % P_c_index_u = round( interp1( P_c(1:end,1).', 1:numel(P_c(1:end,1)), round( P_c_sim, 1) ) );
    end
    
    c_star_sim = interp2(c_star, of_index, P_c_index, 'linear');
    P_c_new = c_star_sim * m_dot / A_t;
    
    M_e_sim = interp2(M_e, of_index, P_c_index, 'linear' );
    a_e_sim = interp2(a_e, of_index, P_c_index, 'linear' );
    P_e_sim = interp2(P_e, of_index, P_c_index, 'linear' );
    
    v_e_sim = M_e_sim.*a_e_sim;
    F_new = m_dot.*v_e_sim + (P_e_sim - P_0)*A_e;
end

function property = lookup_property(base_val, base_col, search_col, options)
    % Lookup function that finds the corresponding property in a certain
    % column based on a known value, search column, and result column.

    % The file must be organized into column categories and rows for
    % different values. See "liquid_properties.xlsx" for an example.

    arguments
        base_val double;
        base_col double;
        search_col double;
        options.file string = "";
        options.matrix double = 0;
    end

    % Matrix Setup
    if options.matrix == 0
        t = readmatrix(sprintf("%s.xlsx", options.file));
    else
        t = options.matrix;
    end
    t_size = size(t);
    index = 0;
    
    % Isentropic Relations fix, not great but works for now
    if options.file == "isentropic_relations"
        t(1, :) = [];
    end

    % Find row of interest
    prev = t(1,base_col);
    for i = 2:t_size(1)
        if abs(t(i, base_col) - base_val) < 1e-10
            index = i;
            break;
        elseif abs(prev - base_val) < abs(t(i, base_col) - base_val)
            index = i-1;
            break;
        end
        prev = t(i, base_col);
    end     
    
    if index == 0
        error("Likely error in function inputs.");
    end
    
    % Get value from cell of interest
    property = t(index, search_col);

end

function newFigure(figureNum, x_max, y_max, options)
% This function creates a new figure with the specified parameters.
    arguments
        figureNum double
        x_max double
        y_max double
        options.title (1,:) string 
        options.xaxis (1,:) string 
        options.yaxis (1,:) string
        options.xLat (1,1) double = 0
        options.yLat (1,1) double = 0
        options.titleLat (1,1) double = 0
        options.int double = 1
        options.x_min double = 0
        options.y_min double = 0
        options.gridOn double = 0
    end
    figure(figureNum);
    hold on;
    ylim([options.y_min,y_max]);
    xlim([options.x_min,x_max]);
    if options.xLat
        xlabel(options.xaxis, 'Interpreter', 'latex', 'FontSize', 25);
    else
        xlabel(options.xaxis, 'FontSize', 25);
    end
    if options.yLat
        ylabel(options.yaxis, 'Interpreter', 'latex', 'FontSize', 25);
    else
        ylabel(options.yaxis, 'FontSize', 25);
    end
    if options.titleLat
        title(options.title, 'Interpreter', 'latex', 'FontSize', 20);
    else
        title(options.title, 'FontSize', 20);
    end
    if options.gridOn
        xticks(0:options.int:x_max);
        grid("on");
    end
end