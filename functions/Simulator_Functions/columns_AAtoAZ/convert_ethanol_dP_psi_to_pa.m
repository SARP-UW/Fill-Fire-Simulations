%% Converts Ethanol total pressure drop from psi to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Pa = convert_ethanol_dP_psi_to_pa(dP_psi)
%
% Input:
%   dP_psi - ethanol pressure drop (psi)
%
% Output:
%   dP_Pa - ethanol pressure drop (Pa)

function dP_Pa = convert_ethanol_dP_psi_to_pa(dP_psi)
    dP_Pa = dP_psi * 6894.76;
end
