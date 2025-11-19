%% Converts thrust from newtons (N) to pounds-force (lbf)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   Thst_lbf = convert_thrust_N_to_lbf(Thst_N)
%
% Description:
%   Converts the final calculated thrust value from newtons (N)
%   to pounds-force (lbf) using a fixed conversion factor.
%
% Inputs:
%   Thst_N - thrust (N)
%
% Outputs:
%   Thst_lbf - thrust (lbf)

function Thst_lbf = convert_thrust_N_to_lbf(Thst_N)
    % Conversion constant: 1 lbf = 4.448 N
    conversion_factor = 4.448;

    % Convert thrust to lbf
    Thst_lbf = Thst_N / conversion_factor;
end