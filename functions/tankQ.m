function qT = tankQ(amb_temp, t_temp, qN, wind_speed, solar_zenith)
% Assign to tank q vector. Should be called after nitrousQ

    % CHANGE FOR K-BOTTLE OR IF DIMENSIONS OF TANK CHANGE
    a_surf = 0.234896304; % surface area of tank in m^2

    % Calculate
    rad_phi = 0.2*(1000*(2/pi)*sin(solar_zenith)+0.5*75+0.5*0.3*(1000*sin(solar_zenith)+75));
    h_air = 1.16 * (10.45 - wind_speed + 10 * (wind_speed^(1/2)));
    q_a = h_air * a_surf * (amb_temp - t_temp);
    q_rad = rad_phi * a_surf / 2;
       
    % Find net heat flow into/outof tank
    qT = q_a + q_rad - qN;
end