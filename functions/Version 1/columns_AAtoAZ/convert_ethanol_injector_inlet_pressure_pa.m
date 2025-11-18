%% Converts Ethanol injector inlet pressure from psi to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_i_fu_Pa = convert_ethanol_injector_inlet_pressure_pa(P_i_fu_psi)
%
% Input:
%   P_i_fu_psi - injector inlet pressure (psi)
%
% Output:
%   P_i_fu_Pa - injector inlet pressure (Pa)

function P_i_fu_Pa = convert_ethanol_injector_inlet_pressure_pa(P_i_fu_psi)
    P_i_fu_Pa = P_i_fu_psi * 6894.76;
end
