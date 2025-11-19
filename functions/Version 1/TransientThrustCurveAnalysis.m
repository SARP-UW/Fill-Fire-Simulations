function [P_c_new,F_new] = TransientThrustCurveAnalysis(calibration_data,P_c_sim,m_dot,of_sim,P_0,A_e,A_t)
    arguments (Input)
        calibration_data {mustBeText}
        P_c_sim (1,1) {mustBeReal, mustBePositive} = 3.8 * 10^6 %temp
        m_dot (1,1) {mustBeReal, mustBePositive} = 1.27 % temporary
        of_sim (1,1) {mustBeReal, mustBePositive} = 4 % temp
        P_0 (1,1) {mustBeReal, mustBePositive} = 101325 % optional
        A_e (1,1) {mustBeReal, mustBePositive} = 123.899*(1/100)^2 % optional
        A_t (1,1) {mustBeReal, mustBePositive} = 5.69 * (1/100)^2 % optional
    end

    load(calibration_data)

    of = data.of;
    P_c = data.P_c;
    c_star = data.c_star;
    M_e = data.M_e;
    a_e = data.a_e;
    P_e = data.P_e;
    
    % instantaneous
     if of_sim < of(1)
        of_index = 1;
        fprintf('warning! of is less than data range!')
    elseif of_sim > of(end)
        of_index = length(of);
        fprintf('warning! of is higher than data range!')
    else
        of_index = round( interp1( of(1,1:end), 1:numel(of(1,1:end)), round( of_sim, 1) ), 0 );
    end
    
    if P_c_sim < data.P_c(1)
        P_c_index = 1;
        fprintf('warning! pressure is less than data range!')
    elseif P_c_sim > P_c(end)
        P_c_index = length(P_c);
        fprintf('warning! pressure is higher than data range!')
    else
        P_c_index = round( interp1( P_c(1:end,1).', 1:numel(P_c(1:end,1)), round( P_c_sim, 1) ) );
    end
    c_star_sim = c_star(P_c_index,of_index);
    P_c_new = c_star_sim * m_dot / A_t;
    
    M_e_sim = M_e( P_c_index, of_index );
    a_e_sim = a_e( P_c_index, of_index );
    P_e_sim = P_e( P_c_index, of_index );
    
    v_e_sim = M_e_sim.*a_e_sim;
    F_new = m_dot.*v_e_sim + (P_e_sim - P_0)*A_e;
end