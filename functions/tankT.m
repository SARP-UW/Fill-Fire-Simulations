function tT = tankT(qT, dt, cp_alum, mass_tank)
% Takes the net heat into the tank and timestep and returns the difference in 
% temperature for the timestep.

    % Constants
    % cp_alum - specific heat of aluminum
    % mass_tank - mass of the tank in kg
    
    % Find delta T:
    tT = dt * qT / (mass_tank * cp_alum);
end