%% Calculates Ethanol mass (kg)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   m_fu = get_ethanol_mass(m_prev, mdot_prev, dt)
%
% Inputs:
%   m_prev    - previous ethanol mass (kg)
%   mdot_prev - previous ethanol mass flow (kg/s)
%   dt        - timestep (s)
%
% Output:
%   m_fu - current ethanol mass (kg)

function m_fu = get_ethanol_mass(m_prev, mdot_prev, dt)
    m_fu = m_prev - mdot_prev * dt;
end
