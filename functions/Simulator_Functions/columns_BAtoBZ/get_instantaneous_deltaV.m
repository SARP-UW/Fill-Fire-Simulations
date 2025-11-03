%% Calculates instantaneous delta-v (m/s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   deltaV_inst = get_instantaneous_deltaV(Thst, t_next, t, m_Ox, m_fu)
%
% Inputs:
%   Thst  - thrust (N)
%   t_next - next time (s)
%   t      - current time (s)
%   m_Ox   - oxidizer mass (kg)
%   m_fu   - fuel mass (kg)
%
% Outputs:
%   deltaV_inst - instantaneous delta-v (m/s)

function deltaV_inst = get_instantaneous_deltaV(Thst, t_next, t, m_Ox, m_fu)
    deltaV_inst = Thst / ((t_next - t) * (44 + m_Ox + m_fu));
end
