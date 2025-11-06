%% Determines engine status (Burning, OX-OUT, or FUEL-OUT)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   status = get_engine_status(m_Ox, m_fu)
%
% Inputs:
%   m_Ox - oxidizer mass (kg)
%   m_fu - fuel mass (kg)
%
% Outputs:
%   status - engine status (string)

function status = get_engine_status(m_Ox, m_fu)
    if isnan(m_Ox) && isnan(m_fu)
        if m_Ox < 0
            status = 'OX-OUT';
        else
            status = 'FUEL-OUT';
        end
    else
        status = 'Burning';
    end
end
