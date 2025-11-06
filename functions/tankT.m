function tT = tankT(qT, dt)
% Takes the net heat into the tank and timestep and returns the difference in 
% temperature for the timestep.

    % Constants
    cp_alum = 896; % specific heat of aluminum
    mass_tank = 9.07; % mass of the tank in kg
    
    % Find delta T:
    tT = dt * qT / (mass_tank * cp_alum);
end