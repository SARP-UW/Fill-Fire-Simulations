%% Determines N2O phase ('vapor' or 'liquid')
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   phase = get_N2O_phase(m_prev, mdot_prev, dt, V_total_Ox, rho_Ox, prev_phase)
%
% Description:
%   Checks if remaining nitrous mass < equivalent vapor mass.
%
% Inputs:
%   m_prev     - previous N2O mass (kg)
%   mdot_prev  - previous N2O mass flow (kg/s)
%   dt         - timestep (s)
%   V_total_Ox - total N2O volume (L)
%   rho_Ox     - vapor-phase density (kg/m^3)
%   prev_phase - phase from previous timestep ('vapor' or 'liquid')
%
% Output:
%   phase - 'vapor' or 'liquid'

function phase = get_N2O_phase(m_prev, mdot_prev, dt, V_total_Ox, rho_Ox, prev_phase)
    m_remaining = m_prev - mdot_prev * dt;
    m_vapor_equiv = (V_total_Ox / 1000) * rho_Ox; % L → m^3

    if m_remaining < m_vapor_equiv
        phase = 'vapor';
    elseif strcmpi(prev_phase, 'vapor')
        phase = 'vapor';
    else
        phase = 'liquid';
    end
end
