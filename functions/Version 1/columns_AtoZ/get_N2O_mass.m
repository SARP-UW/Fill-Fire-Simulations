%% Calculates N2O mass (kg) depending on phase
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   m_Ox = get_N2O_mass(phase, m_prev, mdot_prev, dt, rho_Ox, V_total_Ox)
%
% Inputs:
%   phase      - 'liquid' or 'vapor'
%   m_prev     - previous N2O mass (kg)
%   mdot_prev  - previous N2O mass flow (kg/s)
%   dt         - timestep (s)
%   rho_Ox     - N2O density (kg/m^3)
%   V_total_Ox - total N2O tank volume (L)
%
% Output:
%   m_Ox - current N2O mass (kg)

function m_Ox = get_N2O_mass(m_prev, mdot_prev, dt)
    m_Ox = m_prev - mdot_prev * dt;
end
