function q_n = nitrousQ(n_temp, t_temp, h_n, int_surf)
% Assign to nitrous q vector
    % h_n - nitrous heat transfer coefficient
    % int_surf - internal surface area of tank in m^2
    q_n = h_n * int_surf * (t_temp - n_temp);
end