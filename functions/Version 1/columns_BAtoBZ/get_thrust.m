%% Calculates corrected thrust (N)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   Thst = get_thrust(RThst, Thst_prev, D1, D2, dFdt, dt)
%
% Inputs:
%   RThst     - raw thrust (N)
%   Thst_prev - previous timestep thrust (N)
%   D1        - D1 correction factor
%   D2        - D2 correction factor
%   dFdt      - rate of thrust change (N/s)
%   dt        - timestep (s)
%
% Outputs:
%   Thst - corrected thrust (N)

function Thst = get_thrust(RThst, Thst_prev, D1, D2, dFdt, dt)
    if dFdt > D2
        Thst = (D2 * dt + Thst_prev) * D1;
    else
        Thst = RThst * D1;
    end
end
