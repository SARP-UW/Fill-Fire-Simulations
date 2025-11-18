%% Calculates D1 correction factor
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   D1 = get_D1_factor(RThst_prev, RThst_prev2)
%
% Inputs:
%   RThst_prev  - raw thrust at previous timestep (N)
%   RThst_prev2 - raw thrust two timesteps prior (N)
%
% Outputs:
%   D1 - correction factor (dimensionless)

function D1 = get_D1_factor(RThst_prev, RThst_prev2)
    if RThst_prev < RThst_prev2
        D1 = RThst_prev / RThst_prev2;
    else
        D1 = 1;
    end
end
