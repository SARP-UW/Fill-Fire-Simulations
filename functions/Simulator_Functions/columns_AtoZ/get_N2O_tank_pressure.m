%% Calculates N2O tank pressure (psia) based on phase and timestep
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_T_Ox = get_N2O_tank_pressure(phase, P_prev, dt, P_init, m_prev, m_init)
%
% Inputs:
%   phase  - 'vapor' or 'liquid'
%   P_prev - N2O tank pressure from previous timestep (psia)
%   dt     - timestep (s)
%   P_init - initial N2O tank pressure (psia)
%   m_prev - N2O mass from previous timestep (kg)
%   m_init - initial N2O mass (kg)
%
% Output:
%   P_T_Ox - updated N2O tank pressure (psia)

function P_T_Ox = get_N2O_tank_pressure(phase, P_prev, dt, P_init, m_prev, m_init)
    if strcmpi(phase, 'vapor')
        % Vapor phase: exponential decay of pressure
        P_T_Ox = P_prev / exp(0.8 * dt);
    elseif strcmpi(phase, 'liquid')
        % Liquid phase: proportional to mass ratio
        P_T_Ox = P_init * ((m_prev / m_init) * (1 - 0.7) + 0.7);
    else
        error('Invalid phase: must be ''vapor'' or ''liquid''.');
    end
end
