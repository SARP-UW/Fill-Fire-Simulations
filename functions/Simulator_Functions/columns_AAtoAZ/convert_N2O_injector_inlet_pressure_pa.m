%% Converts N2O injector inlet pressure from psi to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_i_Ox_Pa = convert_N2O_injector_inlet_pressure_pa(P_i_Ox_psi)
%
% Input:
%   P_i_Ox_psi - injector inlet pressure (psi)
%
% Output:
%   P_i_Ox_Pa - injector inlet pressure (Pa)

function P_i_Ox_Pa = convert_N2O_injector_inlet_pressure_pa(P_i_Ox_psi)
    P_i_Ox_Pa = P_i_Ox_psi * 6894.76;
end
