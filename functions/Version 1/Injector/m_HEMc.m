%INPUTS: 
%   N2O_inj_P = Injector inlet pressure (Pa)
%   Cd_i     - discharge coefficient for HEM flow (dimensionless)
%   A_exit_i - injector exit area (m^2)
%   rho_i_out - N2O injector outlet density (kg/m^3)
%   P_tank   - N2O tank pressure (Pa) for entropy + enthalpy


function m_dot = m_HEMc(N2O_inj_P, Cd_i, A_exit_i, phase)
%% HEMcritical Calculation
% Technically, the FML equation requires HEM critical flow, so you need to
% maximize the flow rate curve given by HEM. This can be done either
% experimentally or analytically.
% N2O_inj_P = 5*10^6; %Pa
% P_tank = 6*10^6; %Pa
N = 20; %number of outlet pressure range of outlet pressures
P_chamber_range = N2O_inj_P*(linspace(0.1,1,N));
%P_chamber_range = 
% Cd_i = 0.9;
% A_exit_i = 0.0001535; %m^2

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
        %Need exit density,  exit enthalpy.

        % rho_inj_out_liq = py.CoolProp.CoolProp.PropsSI('D', 'P', P_ch_press_temp, 'Q', 1, "NitrousOxide");
        % rho_inj_out_vap = py.CoolProp.CoolProp.PropsSI('D', 'P', P_ch_press_temp, 'Q', 0, "NitrousOxide");
        % h_inj_out_liq = py.CoolProp.CoolProp.PropsSI('H', 'P', P_ch_press_temp, 'Q', 1, "NitrousOxide"); %J/kg
        % h_inj_out_vap = py.CoolProp.CoolProp.PropsSI('H', 'P', P_ch_press_temp, 'Q', 0, "NitrousOxide"); %J/kg
        % s_inj_out_liq = py.CoolProp.CoolProp.PropsSI('S', 'P', P_ch_press_temp, 'Q', 1, "NitrousOxide");%J/kg/K
        % s_inj_out_vap = py.CoolProp.CoolProp.PropsSI('S', 'P', P_ch_press_temp, 'Q', 0, "NitrousOxide");%J/kg/K

        %s_tank = s_inj_outlet (assumption of isentropic flow)
        %s_inj_outlet = s_inj_out_liq*(1-x) + s_inj_out_vap*x
        %s_inj_outlet = s_inj_out_liq + (s_inj_out_vap-s_inj_out_liq)*x
        %(s_inj_outlet - s_inj_out_liq) / (s_inj_out_vap-s_inj_out_liq) = 
        % x_inj_out = (s_tank - s_inj_out_liq) / (s_inj_out_vap-s_inj_out_liq);
        % 
        % rho_i_out = rho_inj_out_liq*(1-x_inj_out) + rho_inj_out_vap*(x_inj_out);
        % H_i_out = h_inj_out_liq*(1-x_inj_out) + h_inj_out_vap*(x_inj_out);

        H_i_out = py.CoolProp.CoolProp.PropsSI("H", "P", P_ch_press_temp, "S", s_tank, "NitrousOxide");
        rho_i_out = py.CoolProp.CoolProp.PropsSI("D", "P", P_ch_press_temp, "S", s_tank, "NitrousOxide");

        HEMmdots(j) = get_mass_flow_HEM_N2O(Cd_i, A_exit_i, rho_i_out, H_tank, H_i_out);
    end

    %plot(P_chamber_range, HEMmdots);
%Take max flow ratex
    m_dot = max(HEMmdots);
end

%end