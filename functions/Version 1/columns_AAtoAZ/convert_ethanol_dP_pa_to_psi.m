%% Converts Ethanol injector pressure drop from Pa to psi
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_psi = convert_ethanol_dP_pa_to_psi(dP_Pa)
%
% Input:
%   dP_Pa - pressure drop (Pa)
%
% Output:
%   dP_psi - pressure drop (psi)

function dP_psi = convert_ethanol_dP_pa_to_psi(dP_Pa)
    dP_psi = dP_Pa / 6894.76;
end
