% This is the main function for Version 1 of the engine simulation.

%addpath("ThroatAnalysis/");

%% Vector allocation

% Time and Timestep
final_t = 9; % (s)
dt = 0.01;   % (s)
N = final_t / dt + 1;
t = zeros(1, N);

% N2O-tank 
N2O_tank_pressure = zeros(1, N);
N2O_tank_density = zeros(1, N);
N2O_tank_density_V = zeros(1, N);
N2O_mass = zeros(1, N);
N2O_int_energy = zeros(1, N);
N2O_tank_temp = zeros(1, N);
N2O_vapor_volume = zeros(1, N);
N2O_liquid_volume = zeros(1, N);
N2O_COM = zeros(1, N); % measured from the bottom of the tank
phase = strings([1, N]);

% Tank COM
pistonPosition = zeros(1, N);
tankCOM = zeros(1, N);

% N2O-injector 
N2O_inj_P = zeros(1, N);
N2O_inj_dP = zeros(1, N);
N2O_mdot = zeros(1, N);
mdot_SPI = zeros(1, N);
mdot_SPC = zeros(1, N);
mdot_HEM = zeros(1, N);
N2O_ldot = zeros(1, N);

% Ethanol-tank 
ethanol_mass = zeros(1, N);
n2_ullage_pressure = zeros(1, N);
%n2_ullage_volume = zeros(1, N);
ethanol_tank_volume = zeros(1, N);
ethanol_COM = zeros(1, N);

% Ethanol-injector 
ethanol_inj_P = zeros(1, N);
ethanol_mdot = zeros(1, N);
ethanol_ldot = zeros(1, N);

% N2O Feed Line
raw_N2O_line_dP = zeros(1,N);
N2O_line_dP = zeros(1, N);
N2O_line_v = zeros(1, N);

% Ethanol Feed Line
ethanol_line_dP = zeros(1, N);

% Thrust Chamber
mdot_total = zeros(1, N);
chamber_pressure = zeros(1, N);
chamber_temp = zeros(1,N);
of_ratio = zeros(1, N);
thrust = zeros(1, N);
thrust_C = zeros(1, N);
total_mass = zeros(1, N);
TWR = zeros(1, N);
impulse = zeros(1, N);
ISP = zeros(1, N);
choke_condition = strings([1, N]);

% Load property tables
liq_props = readmatrix("liquid_properties.xlsx");
vap_props = readmatrix("vapor_properties.xlsx");
props_matrix = liq_props;

%% Inputs and initial conditions

% Outside Temp (will set tank pressures)
temp = 50; % degrees F
tempK = ((temp-32) * 5/9) + 273.15; % convert to kelvin

% N2O-tank 
% 50 degrees - 4.0043078e+6, 85 degrees - 6.205e+6
N2O_tank_pressure(1) = lookup_property(tempK, 1, 2, matrix=liq_props) * 10^6; % (Pa)
N2O_tank_density(1) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(1), 'Q', 0, 'NitrousOxide'); % (kg/m^3)
N2O_tank_density_V(1) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(1), 'Q', 1, 'NitrousOxide'); % (kg/m^3)
N2O_mass(1) = 6.2; % (kg)
N2O_tank_volume = 0.008331625788; % (m^3)
N2O_vapor_volume(1) = 0.1 * N2O_tank_volume; % 0.1 because of the diptube
N2O_liquid_volume(1) = 0.9 * N2O_tank_volume;
tank_area = pi * 0.06985^2; % (m^2), internal cross sectional area, same for both tanks
N2O_COM(1) = (N2O_vapor_volume(1)*N2O_tank_density_V(1) * (N2O_liquid_volume(1)/tank_area+(N2O_vapor_volume(1)/(tank_area*2))) + N2O_liquid_volume(1)*N2O_tank_density(1)*(N2O_liquid_volume(1)/tank_area)/2) / (N2O_vapor_volume(1)*N2O_tank_density_V(1) + N2O_liquid_volume(1)*N2O_tank_density(1));  
phase(1) = "liquid";
ox_out = 0;
startPSI = N2O_tank_pressure(1) / 6895;

% N2O-injector
N2O_Cd = 0.78;
N2O_inj_a = 0.000047; % m^2  % 0.0000295205 match phase change to eth-out
N2O_CdA = N2O_Cd * N2O_inj_a;
N2O_Cd_HEM = 0.78;
N2O_CdA_HEM = N2O_Cd_HEM * N2O_inj_a;
N2O_inj_P(1) = N2O_tank_pressure(1);
N2O_mdot(1) = mSPI(N2O_CdA, N2O_inj_P(1), 1, "liquid", 'nitrous') * 0.1;
N2O_ldot(1) = N2O_mdot(1) / N2O_tank_density(1) * 1000;
N2O_inj_stiffness = .20;
N2O_inj_dP(1) = N2O_inj_P(1) * N2O_inj_stiffness;

% Ethanol-tank 
ethanol_mass(1) = 1.6; % (kg)
ethanol_conc = 0.9;
n2_ullage_pressure(1) = N2O_tank_pressure(1) - 220632.233; % (Pa) 220632.233 Pa is 30 psi, piston friction losses
%n2_ullage_volume(1) = 3.9 / 1000; % (m^3) % should be 3.9
%n2_mass = n2_ullage_volume(1) * 67; % (kg), N2 density acquired from NIST table
ethanol_density = 850; % (kg/m^3)
ethanol_tank_volume(1) = 0.00234; % (m^3)
%ethanol_COM(1) = (n2_mass * (total_e_tank_V / (pi * 0.06985^2) - (n2_ullage_volume(1) / (pi * 0.06985^2)) / 2) + ethanol_mass(1) * (((total_e_tank_V - n2_ullage_volume(1)) / (pi * 0.06985^2)) / 2)) / (n2_mass + ethanol_mass(1));
ethanol_COM(1) = ((ethanol_tank_volume(1) / tank_area) / 2) + N2O_vapor_volume(1)/tank_area + N2O_liquid_volume(1)/tank_area;
den_tran = 0; % Don't change
fuel_out = 0;

pistonMass = 0.907185; % kg, 2 lb
pistonPosition(1) = 0.544; % in meters, or 21.4", 6" from top of bulkhead
tankCOM(1) = ((N2O_COM(1) * (N2O_liquid_volume(1) * N2O_tank_density(1) + N2O_vapor_volume(1) * N2O_tank_density_V(1))) + pistonPosition(1)*pistonMass + ethanol_COM(1)*ethanol_tank_volume(1)*ethanol_density)/((N2O_liquid_volume(1) * N2O_tank_density(1) + N2O_vapor_volume(1) * N2O_tank_density_V(1)) + pistonMass + ethanol_tank_volume(1)*ethanol_density);

% Ethanol-injector 
e_inj_a = 0.00003418; %m^2
e_Cd = 0.2096;
e_CdA = e_inj_a * e_Cd;
ethanol_inj_P(1) = n2_ullage_pressure(1);
ethanol_mdot(1) = mSPI(e_CdA, ethanol_inj_P(1), chamber_pressure(1), 'liquid', 'ethanol');
ethanol_ldot(1) = ethanol_mdot(1) / ethanol_density * 1000;

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
chamber_pressure(1) = 1e5; % Pa         (1.818955544220220e+05)
of_ratio(1) = N2O_mdot(1) / ethanol_mdot(1);
dry_mass = 44; % (kg)
total_mass(1) = dry_mass + N2O_mass(1) + ethanol_mass(1);
mdot_out = 0;
thrust_out = 0;

phase_change_i = 0; % Don't change
Q = 0;

%% Cluster Iteration

for i = 2:N-1

    % Update time
    t(i) = t(i-1)+dt;
    
    % Update phase and record when phase change occurs
    % phase(i) = get_N2O_phase(N2O_mass(i-1), N2O_mdot(i-1), dt, N2O_liquid_volume(i-1) + N2O_vapor_volume(i-1), ...
    %     py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i-1), 'Q', 1, 'NitrousOxide'), phase(i-1));
    if N2O_liquid_volume(i-1) == 0
        phase(i) = 'vapor';
    else
        phase(i) = 'liquid';
    end
    if strcmp(phase(i), 'vapor') && strcmp(phase(i-1),'liquid')
        phase_change_i = i;
        Q = 1;
        props_matrix = vap_props;
    end

    % Update N2O mass flow by FML model
    mdot_SPI(i) = mSPI(N2O_CdA, N2O_inj_P(i-1), chamber_pressure(i-1), phase(i), 'nitrous');
    mdot_SPC(i) = m_SPC(N2O_Cd, N2O_inj_a, N2O_inj_P(i-1), N2O_tank_pressure(i-1), chamber_pressure(i-1), phase(i));
    voidFraction = get_voidFraction(chamber_pressure(i-1), N2O_inj_P(i-1), phase(i));
    if strcmp(phase(i), 'liquid')
        mdot_HEM(i) = m_HEMc(N2O_inj_P(i-1), chamber_pressure(i-1), N2O_CdA_HEM, phase(i));
        N2O_mdot(i) = (1 - voidFraction) * mdot_SPC(i) + voidFraction * mdot_HEM(i);
    else
        mdot_HEM(i) = m_HEMc(N2O_inj_P(i-1), chamber_pressure(i-1), N2O_CdA_HEM, phase(i));
        N2O_mdot(i) = voidFraction * mdot_SPC(i) + (1 - voidFraction) * mdot_HEM(i);
    end
    
    % % Dyer model with K = 1
    % mdot_SPI(i) = mSPI(N2O_CdA, N2O_inj_P(i-1), chamber_pressure(i-1), phase(i), 'nitrous');
    % if phase(i) == 'liquid'
    %     mdot_HEM(i) = mHEM(N2O_CdA_HEM, N2O_inj_P(i-1), chamber_pressure(i-1), phase(i));
    % else
    %     mdot_HEM(i) = m_HEMc(N2O_inj_P(i-1), N2O_CdA_HEM, phase(i));
    % end
    % N2O_mdot(i) = 0.5 * mdot_SPI(i) + 0.5 * mdot_HEM(i); 
    

    
    if N2O_mdot(i) == 0 || N2O_mdot(i) < 0 || isnan(N2O_mdot(i))
        %N2O_mdot(i-1) = 0;
        %N2O_mdot(i) = 0;
        %chamber_pressure(i-1) = 0;
        break;
    end

    % Get ethanol mass flow
    ethanol_mdot(i) = mSPI(e_CdA, ethanol_inj_P(i-1), chamber_pressure(i-1), "liquid", 'ethanol');
    ethanol_ldot(i) = ethanol_mdot(i) / ethanol_density * 1000;

    % Update N2O mass and pressure
    N2O_mass(i) = N2O_mass(i-1) - dt * N2O_mdot(i);
    if N2O_mass(i) < 0
        N2O_mass(i) = 0;
        ox_out = 1;
        break;
    end

    if strcmp(phase(i), 'vapor')
        % Vapor phase: exponential decay of pressure
        N2O_tank_pressure(i) = N2O_tank_pressure(i-1) / exp(0.8 * dt);
    elseif strcmp(phase(i), 'liquid')
        % Liquid phase: proportional to mass ratio
        N2O_tank_pressure(i) = N2O_tank_pressure(1) * ((N2O_mass(i) / N2O_mass(1)) * (1 - 0.7) + 0.7);
    end

    if strcmp(phase(i), 'liquid')
        N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 0, 'NitrousOxide');
        N2O_tank_density_V(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide'); % (kg/m^3)
    end
    
    % Smooth out the density drop when N2O phase changes
    if strcmp(phase(i), 'vapor') && strcmp(phase(i-1), 'liquid')
        den_tran = 2;
    end
    if den_tran ~= 0
        N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide') * den_tran; 
        den_tran = den_tran - 1;
        N2O_tank_density_V(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide'); % (kg/m^3)
    elseif strcmp(phase(i), 'vapor')
        N2O_tank_density(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide');
        N2O_tank_density_V(i) = py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_tank_pressure(i), 'Q', 1, 'NitrousOxide'); % (kg/m^3)
    end

    N2O_ldot(i) = N2O_mdot(i) / N2O_tank_density(i) * 1000;
    
    % % Update N2O vapor volume
    if strcmp(phase(i), 'liquid')
        N2O_liquid_volume(i) = N2O_liquid_volume(i-1) - (N2O_mdot(i)/N2O_tank_density(i) + (N2O_tank_density_V(i)/N2O_tank_density(i)) * ethanol_mdot(i)/ethanol_density) * dt;
        N2O_vapor_volume(i) = N2O_vapor_volume(i-1) + (1 + N2O_tank_density_V(i)/N2O_tank_density(i)) * (N2O_mdot(i)/N2O_tank_density(i) + ethanol_mdot(i)/ethanol_density) * dt;
        for n = 1:100
            N2O_liquid_volume(i) = N2O_liquid_volume(i) - (N2O_tank_density_V(i)/N2O_tank_density(i))^n * N2O_mdot(i)/N2O_tank_density(i) * dt;
            N2O_vapor_volume(i) = N2O_vapor_volume(i) + (N2O_tank_density_V(i)/N2O_tank_density(i))^n * N2O_mdot(i)/N2O_tank_density(i) * dt;
        end
    else
        N2O_vapor_volume(i) = N2O_vapor_volume(i-1) + ethanol_mdot(i)/ethanol_density * dt;
    end
    if N2O_liquid_volume(i) < 0
        N2O_liquid_volume(i) = 0;
    end
    % 
    % % Update N2O COM (measured from the bottom of the tank)
    N2O_COM(i) = (N2O_vapor_volume(i)*N2O_tank_density_V(i) * (N2O_liquid_volume(i)/tank_area+(N2O_vapor_volume(i)/(tank_area*2))) + N2O_liquid_volume(i)*N2O_tank_density(i)*(N2O_liquid_volume(i)/tank_area)/2) / (N2O_vapor_volume(i)*N2O_tank_density_V(i) + N2O_liquid_volume(i)*N2O_tank_density(i));  

    % Update ethanol mass, volume, and pressure
    ethanol_mass(i) = ethanol_mass(i-1) - dt * ethanol_mdot(i);
    if ethanol_mass(i) < 0 || ethanol_mdot(i) == 0
        ethanol_mass(i) = 0;
        fuel_out = 1;
        break;
    end
    ethanol_tank_volume(i) = ethanol_mass(i) / ethanol_density;
    % n2_ullage_pressure(i) = n2_ullage_pressure(i-1) * n2_ullage_volume(i-1) / n2_ullage_volume(i);
    n2_ullage_pressure(i) = N2O_tank_pressure(i) - 220632.233;
    % Update ethanol tank COM (measured from the bottom of the tank)
    ethanol_COM(i) = (ethanol_tank_volume(i) / tank_area)/2 + N2O_vapor_volume(i) / tank_area + N2O_liquid_volume(i) / tank_area;
    
    pistonPosition(i) = pistonPosition(i-1) + ((N2O_liquid_volume(i)/tank_area) + (N2O_vapor_volume(i)/tank_area)) - ((N2O_liquid_volume(i-1)/tank_area) + (N2O_vapor_volume(i-1)/tank_area));
    tankCOM(i) = ((N2O_COM(i) * (N2O_liquid_volume(i) * N2O_tank_density(i) + N2O_vapor_volume(i) * N2O_tank_density_V(i))) + pistonPosition(i)*pistonMass + ethanol_COM(i)*ethanol_tank_volume(i)*ethanol_density)/((N2O_liquid_volume(i) * N2O_tank_density(i) + N2O_vapor_volume(i) * N2O_tank_density_V(i)) + pistonMass + ethanol_tank_volume(i)*ethanol_density);

        
    % Update N2O absolute viscosity, line dP, velocity, injector pressure, and injector dP
    N2O_abs_visc = lookup_property(N2O_tank_pressure(i)/1000000, 2, 12, matrix=props_matrix);
    [N2O_line_dP(i), N2O_line_v(i)] = get_pressuredrop((N2O_mdot(i)+N2O_mdot(i-1))/2, (N2O_tank_density(i)+py.CoolProp.CoolProp.PropsSI('D', 'P', N2O_inj_P(i-1), 'Q', Q, 'NitrousOxide'))/2, N2O_abs_visc/10^6, N2O_K_loss, N2O_line_length, N2O_line_id);

    % % If the sim is breaking, bound nitrous line dP conditions
    % if N2O_line_dP(i) < 10e5
    %     N2O_line_dP(i) = 10e5;
    % end
    
    % N2O line dP stabilization
    N2O_line_dP(i) = (N2O_line_dP(i-1) + N2O_line_dP(i)) / 2;

    N2O_inj_P(i) = N2O_tank_pressure(i) - N2O_line_dP(i);
    
    % N2O injector pressure stabilization
    N2O_inj_P(i) = (N2O_inj_P(i-1) + N2O_inj_P(i)) / 2;

    N2O_inj_dP(i) = N2O_inj_P(i) * N2O_inj_stiffness;

    % % If the sim is breaking, bound injector pressure conditions
    % if N2O_inj_P(i) < chamber_pressure(i-1)
    %     N2O_inj_P(i) = chamber_pressure(i-1) + 1e6;
    % end
    % if N2O_inj_P(i) > N2O_tank_pressure(i-1)
    %     N2O_inj_P(i) = N2O_tank_pressure(i-1) - 1e6;
    % end
    % Injector pressure stabilization
    N2O_inj_P(i) = (N2O_inj_P(i-1) + N2O_inj_P(i)) / 2; 

    % Update ethanol line dP
    ethanol_line_dP(i) = get_pressuredrop(ethanol_mdot(i), ethanol_density, ethanol_abs_visc, ethanol_K_loss, ethanol_line_length, ethanol_line_id);

    % Ethanol line dP stabilization
    ethanol_line_dP(i) = (ethanol_line_dP(i-1) + ethanol_line_dP(i)) / 2;

    % Update ethanol injector pressure
    ethanol_inj_P(i) = n2_ullage_pressure(i) - ethanol_line_dP(i);

    % Update total mass flow, OF ratio, chamber pressure, and thrust
    mdot_total(i) = N2O_mdot(i) + ethanol_mdot(i);
    if mdot_total(i) < 0.2
        mdot_out = 1;
        break;
    end
    of_ratio(i) = N2O_mdot(i) / ethanol_mdot(i);
    [chamber_pressure(i), thrust(i), choke_condition(i), chamber_temp(i)] = TransientThrustCurveAnalysis('f_e90_sar_543.mat', chamber_pressure(i-1), mdot_total(i), of_ratio(i));
    
    % % Bound if needed
    % if N2O_inj_P(i) - chamber_pressure(i) < N2O_inj_dP(i)
    %     chamber_pressure(i) = N2O_inj_P(i) - N2O_inj_dP(i);
    % end
        
    % Grow chamber pressure slowly at start
    if i < 3
        chamber_pressure(i) = chamber_pressure(i) * i / 3;
    % else
    %     if chamber_pressure(i) > chamber_pressure(i-1)
    %         chamber_pressure(i) = chamber_pressure(i-1);
    %     end
    end
    

    % Thrust stabilization
    thrust(i) = (thrust(i-1) + thrust(i)) / 2; 

    % Fix until new CEA data is uploaded
    % if thrust(i) < 0
    %     thrust_out = 1;
    %     break;
    % end
    
    % Chamber pressure stabilization
    chamber_pressure(i) = (chamber_pressure(i-1) + chamber_pressure(i)) / 2;
    
    % Calculate TWR
    total_mass(i) = dry_mass + N2O_mass(i) + ethanol_mass(i);
    TWR(i) = thrust(i) / (total_mass(i) * 9.8); % assume g is constant
    
    % If OF ratio is too low, combustion will be bad, so end sim
    if i > 10
        if of_ratio(i) < 0.12
            ox_out = 1;
            break;
        end
    end

    % Update impulse and specific impulse
    impulse(i) = impulse(i-1) + thrust(i) * dt;
    ISP(i) = thrust(i) / (mdot_total(i) * 9.81);
    
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
graphTitle = ['$\textnormal{Thrust Curve for DC } (', num2str(startPSI), '\textnormal{PSI}/', num2str(temp), '^\circ{F})$'];
newFigure(1, final_t, max(thrust)+500, gridOn=1, xaxis="Time (s)", yaxis='Thrust (N)', title=graphTitle, int=0.25, titleLat=1);
plot(t(1:t_end), thrust(1:t_end), 'LineWidth', 2, color='r');

% Mass Curves
graphTitle = ['$\textnormal{Mass of Nitrous and Ethanol } (', num2str(startPSI), '\textnormal{PSI}/', num2str(temp), '^\circ{F})$'];
newFigure(2, final_t, N2O_mass(1)+0.5, gridOn=1, xaxis="Time (s)", yaxis='Mass (kg)', title=graphTitle,int=0.25, titleLat=1);
plot(t(1:t_end), N2O_mass(1:t_end), 'LineWidth', 2, color='g');
plot(t(1:t_end), ethanol_mass(1:t_end), 'LineWidth', 2, color='r');
legend('Nitrous', 'Ethanol', 'FontSize', 12);

% Pressure Curves
graphTitle = ['$\textnormal{Pressure Curves } (', num2str(startPSI), '\textnormal{PSI}/', num2str(temp), '^\circ{F})$'];
newFigure(3, final_t, N2O_tank_pressure(1)+100000, gridOn=1, xaxis="Time (s)", yaxis='Pressure (Pa)', title=graphTitle,int=0.25, y_min=0, titleLat=1);
plot(t(1:t_end-1), N2O_tank_pressure(1:t_end-1), 'LineWidth', 2, color='g');
plot(t(1:t_end-1), n2_ullage_pressure(1:t_end-1), 'LineWidth', 2, color='r');
plot(t(1:t_end-1), chamber_pressure(1:t_end-1), 'LineWidth', 2, color='b');
%plot(t(1:t_end-1), N2O_inj_P(1:t_end-1), 'LineWidth', 2, color='c');
legend('Nitrous Tank', 'Ethanol Tank', 'Chamber', 'FontSize', 12);

% Pressure Drop Through Lines
graphTitle = ['$\textnormal{Pressure Drop through Lines } (', num2str(startPSI), '\textnormal{PSI}/', num2str(temp), '^\circ{F})$'];
newFigure(4, final_t, max(N2O_line_dP) + 100000, gridOn=1, xaxis="Time (s)", yaxis='Pressure (Pa)', title=graphTitle,int=0.25, y_min=0, titleLat=1);
plot(t(1:t_end-1), N2O_line_dP(1:t_end-1), 'LineWidth', 2, color='g');
plot(t(1:t_end-1), ethanol_line_dP(1:t_end-1), 'LineWidth', 2, color='r');
legend('Nitrous Line', 'Ethanol Line', 'FontSize', 12);

%% Make output file

thrust_lbf = thrust / 4.448;

headings = {"Time", "Thrust (N)", "Thrust (lbf)", "N2O Mass Flow Rate (kg/s)", "N2O Mass (kg)", "Ethanol Mass Flow Rate (kg/s)", "Ethanol Mass (kg)", "TWR", "OFR", 'N2O Pressure (psi)', 'Ethanol Pressure (psi)', 'Chamber Pressure (psi)', 'Nitrous COM (m)', 'Ethanol COM (m)', 'Tank COM (m)', 'Nitrous Phase', 'Impulse (N s)', 'Specific Impulse (s)', "N2O Volumetric Flow Rate (l/s)", "Ethanol Volumetric Flow Rate (l/s)", "Choke Condition", "Ethanol Concentration", "N2O Inj Area (m^2)", "Ethanol Inj Area (m^2)", "HEM Cd", "SPC Cd", "Ethanol Cd", "Temp (F)"};
writecell(headings, 'outputs.csv');

data = [t', thrust', thrust_lbf', N2O_mdot', N2O_mass', ethanol_mdot', ethanol_mass', TWR', of_ratio', N2O_tank_pressure'/6892, n2_ullage_pressure'/6892, chamber_pressure'/6892, N2O_COM', ethanol_COM', tankCOM', phase', impulse', ISP', N2O_ldot', ethanol_ldot', choke_condition'];
data = data(1:t_end, :);

scalarValues = [ethanol_conc, N2O_inj_a, e_inj_a, N2O_Cd_HEM, N2O_Cd, e_Cd, temp];
nScalars = numel(scalarValues);
scalarCols = NaN(t_end, nScalars);
scalarCols(1, :) = scalarValues;

data = [data, scalarCols];

writematrix(data, 'outputs.csv', 'WriteMode', 'append');


%% Functions

function phase = get_N2O_phase(m_prev, mdot_prev, dt, V_total_Ox, rho_Ox, prev_phase)
    m_remaining = m_prev - mdot_prev * dt;
    m_vapor_equiv = V_total_Ox * rho_Ox;

    if m_remaining < m_vapor_equiv
        phase = 'vapor';
    elseif strcmp(prev_phase, 'vapor')
        phase = 'vapor';
    else
        phase = 'liquid';
    end
end

function voidFraction = get_voidFraction(chamber_pressure, P_inj_inlet, phase)
    
    Q = 0;
    if phase == "vapor"
        Q = 1;
    end
    rho_downstream_l = py.CoolProp.CoolProp.PropsSI('D', 'P', chamber_pressure, 'Q', Q, "NitrousOxide");
    rho_downstream_v = py.CoolProp.CoolProp.PropsSI('D', 'P', chamber_pressure, 'Q', 1, "NitrousOxide");

    slip_velocity = (rho_downstream_l/rho_downstream_v)^(1/3);
    entropy_inlet = py.CoolProp.CoolProp.PropsSI('S', 'P', P_inj_inlet, 'Q', Q, 'NitrousOxide');
    entropy_outlet_l = py.CoolProp.CoolProp.PropsSI('S', 'P', chamber_pressure, 'Q', Q, 'NitrousOxide');
    entropy_outlet_v = py.CoolProp.CoolProp.PropsSI('S', 'P', chamber_pressure, 'Q', 1, 'NitrousOxide');
    
    % Quality Calculation
    % s_tank = s_inj_outlet (assumption of isentropic flow)
    % s_inj_outlet = s_inj_out_liq*(1-x) + s_inj_out_vap*x
    % s_inj_outlet = s_inj_out_liq + (s_inj_out_vap-s_inj_out_liq)*x
    % (s_inj_outlet - s_inj_out_liq) / (s_inj_out_vap-s_inj_out_liq) = 
    x_inj_out = (entropy_inlet - entropy_outlet_l) / (entropy_outlet_v-entropy_outlet_l);

    if x_inj_out < 0
        x_inj_out = 1;
    end

    voidFraction = 1/(1+(1-x_inj_out) / x_inj_out * slip_velocity * (rho_downstream_v / rho_downstream_l));

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

function m_dot = m_HEMc(N2O_inj_P, chamber_pressure, CdA, phase)
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
    criticalPressure = P_chamber_range(find(HEMmdots == max(HEMmdots)));
    if chamber_pressure < criticalPressure
        m_dot = max(HEMmdots);
    else
        m_dot = mHEM(CdA, N2O_inj_P, chamber_pressure, phase);
    end
    
    if imag(m_dot) > 0
        m_dot = real(m_dot);
    end

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

function m_dot = m_SPC(Cd_i_SPC,A_inj_N2O,P_inj_inlet, N2O_tank_pressure, P_chamber, phase)
    % Cd_i_SPC = 0.9;
    % A_inj_N2O = 0.0001535;
    % P_inj_inlet = 5e6;    
    % P_chamber = 4.137e6;
    if P_inj_inlet < 0 || abs(P_inj_inlet) < 1e-10
        m_dot = 0;
        return;
    end
    tankQual = 0;
    if strcmp(phase, "vapor")
        tankQual = 1;
    end
    H = py.CoolProp.CoolProp.PropsSI("H", "P", N2O_tank_pressure, "Q", tankQual, "NitrousOxide");
    Q = py.CoolProp.CoolProp.PropsSI("Q", "P", P_inj_inlet, "H", H, "NitrousOxide");
    if Q == -1
        Q = 1;
    end
    cp = py.CoolProp.CoolProp.PropsSI("CPMASS", "P", P_inj_inlet, "Q", Q, "NitrousOxide");
    cv = py.CoolProp.CoolProp.PropsSI("CVMASS", "P", P_inj_inlet, "Q", Q, "NitrousOxide");
    %entropy = py.CoolProp.CoolProp.PropsSI("S", "P", P_inj_inlet, "Q", 0, "NitrousOxide");
    gammaN2O = cp/cv;
   

    dP_across_inj = P_inj_inlet-P_chamber;
    %FML model paper https://www.mdpi.com/2226-4310/9/12/828#FD7-aerospace-09-00828
    %Rstar is specific gas constant for nitrous oxide. Rstar = Runiversal / Molar mass
    %Rstar = 8.314462618 / 0.044013 = 188.9092454
    % R = 8.314462618;
    % Rstar = 188.9092454; %J / kg / K
    T_inlet = py.CoolProp.CoolProp.PropsSI('T', 'P', P_inj_inlet, 'Q', Q, "NitrousOxide");
    rho_inj_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', Q, "NitrousOxide");
    %dZdTforcpressure = P_inj_inlet / Rstar * (dVdtforcpressure / T_inlet - 1 / (rho_inj_inlet*))
    %dVdTforcpressure = py.CoolProp.CoolProp.PropsSI('d(V)/d(T)|P', "P|liquid", P_inj_inlet, "Q", 0.0001, "NitrousOxide");
    h = 2;
    if phase == "liquid"
        dZdTforcrho = (py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet, 'D', rho_inj_inlet, 'NitrousOxide') - py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet-h, 'D', rho_inj_inlet, 'NitrousOxide'))/h;
        dZdTforcpressure = (py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet-h/2, 'P', P_inj_inlet, 'NitrousOxide') - py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet-3*h/2, 'P', P_inj_inlet, 'NitrousOxide'))/h;
        
        Z_compfac = py.CoolProp.CoolProp.PropsSI('Z', 'P', P_inj_inlet, 'D', rho_inj_inlet, "NitrousOxide");
    else
        dZdTforcrho = (py.CoolProp.CoolProp.PropsSI('Z', 'T|gas', T_inlet, 'D', rho_inj_inlet, 'NitrousOxide') - py.CoolProp.CoolProp.PropsSI('Z', 'T|gas', T_inlet-h, 'D', rho_inj_inlet, 'NitrousOxide'))/h;
        dZdTforcpressure = (py.CoolProp.CoolProp.PropsSI('Z', 'T|gas', T_inlet-h/2, 'P', P_inj_inlet, 'NitrousOxide') - py.CoolProp.CoolProp.PropsSI('Z', 'T|gas', T_inlet-3*h/2, 'P', P_inj_inlet, 'NitrousOxide'))/h;
        
        Z_compfac = py.CoolProp.CoolProp.PropsSI('Z', 'P|gas', P_inj_inlet, 'D', rho_inj_inlet, "NitrousOxide");
    end

    %Z_compfac

    % Z_compfac = P_inj_inlet / (rho_inj_inlet*R*T_inlet);

    %compressibiliy exponent n
    n = gammaN2O*(Z_compfac + T_inlet*dZdTforcrho) / (Z_compfac + T_inlet*dZdTforcpressure);

    %Y_compfac for compressible liq/real gases, eq 7
    Y_compfac = sqrt(  P_inj_inlet/(2*dP_across_inj)  *  (2*n/(n-1))  *  (1-dP_across_inj/P_inj_inlet)^(2/n)  *  (1-(1-dP_across_inj/P_inj_inlet)^((n-1)/n))  );

    %mdot_SPC, eq 5
    m_dot = Cd_i_SPC * Y_compfac * A_inj_N2O * sqrt(2 * rho_inj_inlet * (dP_across_inj));

    if imag(m_dot) > 0
        m_dot = real(m_dot);
    end
    
end

function [P_c_new,F_new,chokeValue, T_c_new] = TransientThrustCurveAnalysis(calibration_data,P_c_sim,m_dot,of_sim,P_0,A_e,A_t)
    arguments (Input)
        calibration_data {mustBeText}
        P_c_sim (1,1) {mustBeReal, mustBePositive} = 3.8 * 10^6 %temp
        m_dot (1,1) {mustBeReal, mustBePositive} = 1.27 % temporary
        of_sim (1,1) {mustBeReal, mustBePositive} = 4 % temp
        P_0 (1,1) {mustBeReal, mustBePositive} = 101325 % optional
        A_e (1,1) {mustBeReal, mustBePositive} = 30.90316 * (1/100)^2 % optional
        A_t (1,1) {mustBeReal, mustBePositive} = 0.0005691190424048 % optional
    end

    load(calibration_data);

    of = data.of;
    P_c = data.P_c;
    c_star = data.c_star;
    M_e = data.M_e;
    a_e = data.a_e;
    P_e = data.P_e;
    P_t = data.P_t;
    gamma_e = data.gamma_e;
    gamma_t = data.gamma_t;
    T_c = data.T_c;
    
    % instantaneous
     if of_sim < of(1)
        of_index = 1;
        %fprintf('warning! of is less than data range!')
    elseif of_sim > of(end)
        of_index = size(of, 2);
        %fprintf('warning! of is higher than data range!')
     else
        of_index = interp1( of(1,1:end), 1:numel(of(1,1:end)), round( of_sim, 1) );
    end
    
    if P_c_sim < data.P_c(1)
        P_c_index = 1;
        %fprintf('warning! pressure is less than data range!')
    elseif P_c_sim > P_c(end)
        P_c_index = size(P_c);
        %fprintf('warning! pressure is higher than data range!')
    else
        P_c_index = interp1( P_c(1:end,1).', 1:numel(P_c(1:end,1)), round( P_c_sim, 1) );
    end
    
    c_star_new = interp2(c_star, of_index, P_c_index, 'linear');
    c_star_adjustment_factor = 0.9;
    P_c_new = (c_star_new*c_star_adjustment_factor) * m_dot / A_t;
    
    M_e_new = interp2(M_e, of_index, P_c_index, 'linear' );
    a_e_new = interp2(a_e, of_index, P_c_index, 'linear' );
    P_e_new = interp2(P_e, of_index, P_c_index, 'linear' );
    P_t_new = interp2(P_t, of_index, P_c_index, 'linear' );
    gamma_e_new = interp2(gamma_e, of_index, P_c_index,'linear');
    gamma_t_new = interp2(gamma_t, of_index, P_c_index,'linear');
    T_c_new = interp2(T_c, of_index ,P_c_index, 'linear');
    
    v_e_new = M_e_new.*a_e_new;
    F_new = m_dot.*v_e_new + (P_e_new - P_0)*A_e;

    P_crit = P_c_new*(2 / (gamma_t_new + 1))^( gamma_t_new/(gamma_t_new - 1 ) );
    if P_t_new > (P_crit + 10000)
        %fprintf('flow is not choked :(')
        chokeValue = 'Not choked';
    else
        chokeValue = 'Choked';
    end
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