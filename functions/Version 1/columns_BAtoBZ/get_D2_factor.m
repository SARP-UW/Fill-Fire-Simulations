%% Calculates D2 correction factor
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   D2 = get_D2_factor(dt, row)
%
% Inputs:
%   dt  - timestep (s)
%   row - current row index
%
% Outputs:
%   D2 - correction factor (dimensionless)

function D2 = get_D2_factor(dt, row)
    if row >= 3 && row <= 16
        D2 = 1.5e6 * dt;
    else
        D2 = 1;
    end
end
