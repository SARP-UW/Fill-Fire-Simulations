%% Calculates impulse (N·s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   J = get_impulse(Thst, dt)
%
% Inputs:
%   Thst - thrust (N)
%   dt   - timestep (s)
%
% Outputs:
%   J - impulse (N·s)

function J = get_impulse(Thst, dt)
    J = Thst * dt;
end
