function q_n = nitrousQ(n_temp, t_temp)
% Assign to nitrous q vector
    h_n = 100; % Guess
    int_surf = 0.258399483; % internal surface area of tank in m^2
    q_n = h_n * int_surf * (t_temp - n_temp);
end