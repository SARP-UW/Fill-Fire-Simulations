%% Converts velocity from m/s to ft/s
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   v_ftps = convert_velocity_mps_to_ftps(v_mps)
%
% Input:
%   v_mps - velocity (m/s)
%
% Output:
%   v_ftps - velocity (ft/s)

function v_ftps = convert_velocity_mps_to_ftps(v_mps)
    conversion_factor = 3.28084; % 1 m/s = 3.28084 ft/s
    v_ftps = v_mps * conversion_factor;
end