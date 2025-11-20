%% Calculates corrected chamber pressure (Pa) using D1 correction factor
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_chamber_corr = get_corrected_chamber_pressure_pa(P_chamber, P_chamber_raw, D1, mode)
%
% Description:
%   If mode = 'vapor', the function uses the first form:
%       P_chamber_corr = (P_chamber / 2) * D1 * 0.2
%   If mode = 'liquid', the function uses:
%       P_chamber_corr = P_chamber_raw * D1 * 0.2
%
% Inputs:
%   P_chamber      - current chamber pressure (Pa)
%   P_chamber_raw  - raw chamber pressure (Pa)
%   D1             - correction factor (dimensionless)
%   mode           - 'vapor' or 'liquid' (string)
%
% Output:
%   P_chamber_corr - corrected chamber pressure (Pa)

function P_chamber_corr = get_corrected_chamber_pressure_pa(P_chamber, P_chamber_raw, D1, mode)
    if strcmpi(mode, 'vapor')
        P_chamber_corr = (P_chamber / 2) * D1;
    elseif strcmpi(mode, 'liquid')
        P_chamber_corr = P_chamber_raw * D1 * 0.2;
    else
        error('Invalid mode: must be ''vapor'' or ''liquid''.');
    end
end
