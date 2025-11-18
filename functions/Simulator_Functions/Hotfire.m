function out = run_hotfire_from_calculations_sheet()
%RUN_HOTFIRE_FROM_CALCULATIONS_SHEET
% Drives the transient DC hotfire sim strictly in the order of the
% "Calculations" sheet columns (C → CH), while pulling constants/props
% from other sheets as needed (I_O + property tables).
%
% Workbook expected:
%   data/HOTFIRE - Transient DC Engine Sim.xlsx
% Sheets:
%   - Calculations: time vector, initials, and column-by-column pipeline
%   - I_O: geometry, injector, line data, constants
%   - N2O_Liquid_Phase_Properties, N2O_Vapor_Phase_Properties: P->props
%
% NOTE: This is the orchestration layer. All physics are delegated to
% your helper functions (already created earlier).
% ---------------------------------------------------------------------

%% 0) Paths & conversions
this_file   = mfilename('fullpath');
this_folder = fileparts(this_file);
main_folder = fileparts(this_folder);
addpath(fullfile(main_folder, 'functions'));

% Fallback conversion struct if c() not present
if exist('c','file') == 2
    cf = c();
else
    cf.ft_to_m    = 0.3048;
    cf.in_to_m    = 0.0254;
    cf.L_to_m3    = 1e-3;
    cf.ft3_to_m3  = 0.028316846592;
    cf.lb_to_kg   = 0.45359237;
    cf.lbmhr_to_kgs = 1/7936.64;
    cf.kgs_to_lbmhr = 7936.64;
    cf.psi_to_Pa  = 6894.76;
    cf.Pa_to_psi  = 1/6894.76;
    cf.N_to_lbf   = 1/4.448;
end

%% 1) Load workbook sheets
wb = fullfile(main_folder, 'data', 'HOTFIRE - Transient DC Engine Sim.xlsx');
calcT  = readtable(wb, 'Sheet', 'Calculations', 'PreserveVariableNames', true);
ioT    = readtable(wb, 'Sheet', 'I_O', 'PreserveVariableNames', true);
n2oLiq = readtable(wb, 'Sheet', 'N2O_Liquid_Phase_Properties', 'PreserveVariableNames', true);
n2oVap = readtable(wb, 'Sheet', 'N2O_Vapor_Phase_Properties',  'PreserveVariableNames', true);

% helpers to fetch by name in I_O
ival = @(name,default) pick(ioT, name, default);

%% 2) Time base (A,B)
t  = calc_col(calcT,'t_s', 0);     % seconds; or from a column named e.g. t_s
dt = calc_col(calcT,'dt_s', 1);    % constant or vector timestep
if isscalar(dt), dt = dt*ones(size(t)); end
Nt = numel(t);

%% 3) Pull global inputs from I_O
% Geometry & injector
A_throat     = ival('A_throat_m2',  1e-4);
A_exit       = ival('A_exit_m2',    2e-4);
Cd_i_N2O     = ival('Cd_N2O',       0.7);
Cd_i_fu      = ival('Cd_Ethanol',   0.7);
A_exit_i_N2O = ival('A_i_N2O_m2',   1e-6);
A_exit_i_fu  = ival('A_i_fu_m2',    1e-6);

% Line/tube
Di_Ox_in     = ival('Di_N2O_in',    0.25);
Di_fu_in     = ival('Di_fu_in',     0.25);
Di_Ox        = Di_Ox_in*cf.in_to_m;
Di_fu        = Di_fu_in*cf.in_to_m;
L_line_Ox_ft = ival('L_line_N2O_ft', 10);
L_line_fu_ft = ival('L_line_fu_ft',  10);
eps_Ox_in    = ival('eps_N2O_in',    1e-4);
eps_fu_in    = ival('eps_fu_in',     1e-4);
Cv_main      = ival('Cv_main',       1);
K_sum_Ox     = ival('K_sum_N2O',     0);
K_sum_fu     = ival('K_sum_fu',      0);
K_blend      = ival('K_blend',       1); % Column I blend

% Tanks/volumes
V_total_fu_L = ival('V_total_fu_L',  0); V_total_fu = V_total_fu_L*cf.L_to_m3;
V_total_Ox_L = ival('V_total_Ox_L',  0); V_total_Ox = V_total_Ox_L*cf.L_to_m3;

% Combustion constants (BQ–BS)
gamma_cmb = ival('gamma_cmb',       1.229);
R_cmb     = ival('R_cmb_JkgK',      281.3039456);
cstar     = ival('cstar_mps',       1600);
M_exit_120= ival('M_exit_gamma_1p20', 3.0);
M_exit_125= ival('M_exit_gamma_1p25', 2.8);

% Initials
P_T_Ox0_psi = ival('P_T_Ox0_psia', 600);
P_T_fu0_psi = ival('P_T_fu0_psia', 300);
ChTmp0      = ival('ChTmp0_K',     3000);
ChPres0_Pa  = ival('ChPres0_Pa',   1e5);
m_Ox0       = ival('m_Ox0_kg',     0);
m_fu0       = ival('m_fu0_kg',     0);
rho_fu0     = ival('rho_fu0_kgm3', 789);

%% 4) Preallocate arrays (C → CH)
P_T_Ox_psi = zeros(Nt,1);  P_T_Ox_Pa = zeros(Nt,1);
rho_Ox     = zeros(Nt,1);  rho_fu    = zeros(Nt,1);
P_T_fu_psi = zeros(Nt,1);  P_T_fu_Pa = zeros(Nt,1);

mdot_Ox      = zeros(Nt,1); mdot_Ox_lbh = zeros(Nt,1);
Q_Ox_GPM     = zeros(Nt,1); v_Ox_ms     = zeros(Nt,1); v_Ox_fts = zeros(Nt,1);
mdot_fu      = zeros(Nt,1); mdot_fu_lbh = zeros(Nt,1);
Q_fu_GPM     = zeros(Nt,1); v_fu_ms     = zeros(Nt,1); v_fu_fts = zeros(Nt,1);
mdot_sum     = zeros(Nt,1);

m_Ox = zeros(Nt,1); m_fu = zeros(Nt,1); phase_Ox = strings(Nt,1);

dPi_Ox_Pa = zeros(Nt,1); dPi_Ox_psi = zeros(Nt,1);
dP_Maj_Ox = zeros(Nt,1); dP_Min_Ox  = zeros(Nt,1); dP_Cmp_Ox = zeros(Nt,1);
dPsum_Ox_psi = zeros(Nt,1); dPsum_Ox_Pa = zeros(Nt,1);

dPi_fu_Pa = zeros(Nt,1); dPi_fu_psi = zeros(Nt,1);
dP_Maj_fu = zeros(Nt,1); dP_Min_fu  = zeros(Nt,1); dP_Cmp_fu = zeros(Nt,1);
dPsum_fu_psi = zeros(Nt,1); dPsum_fu_Pa = zeros(Nt,1);

Re_Ox = zeros(Nt,1); Re_fu = zeros(Nt,1);
f_Ox  = zeros(Nt,1); f_fu  = zeros(Nt,1);

P_i_Ox_psi = zeros(Nt,1); P_i_Ox_Pa = zeros(Nt,1);
P_i_fu_psi = zeros(Nt,1); P_i_fu_Pa = zeros(Nt,1);

ChPres_raw_Pa = zeros(Nt,1); ChPres_Pa = zeros(Nt,1);
ChTmp_K = zeros(Nt,1); ExhtTmp_K = zeros(Nt,1);
M_exit  = zeros(Nt,1); V_exit    = zeros(Nt,1);
P_ratio = zeros(Nt,1); ExhtPres_Pa = zeros(Nt,1);

RThst_N  = zeros(Nt,1); RThst_lbf = zeros(Nt,1);
dFdt     = zeros(Nt,1); D1 = ones(Nt,1); D2 = ones(Nt,1);
Thst_N   = zeros(Nt,1); Thst_lbf  = zeros(Nt,1);
J_Ns     = zeros(Nt,1); OF        = zeros(Nt,1);
status   = strings(Nt,1);

% Thermo mixes (BU…CE, CA…CH)
S_Ox = zeros(Nt,1); S_i_out_l_Ox = zeros(Nt,1); S_i_out_g_Ox = zeros(Nt,1); x_Ox = zeros(Nt,1);
rho_i_out_l_Ox = zeros(Nt,1); rho_i_out_g_Ox = zeros(Nt,1); rho_i_out_Ox = zeros(Nt,1);
H_tank_Ox = zeros(Nt,1); H_i_out_l_Ox = zeros(Nt,1); H_i_out_g_Ox = zeros(Nt,1); H_i_out_N2O = zeros(Nt,1);
mdot_N2O_SPI = zeros(Nt,1); mdot_N2O_HEM = zeros(Nt,1);
deltaV_inst = zeros(Nt,1);

%% 5) Initial conditions from Calculations (C,F,BA,AY,S,U…)
P_T_Ox_psi(1) = grab(calcT,'P_T_Ox_psia', P_T_Ox0_psi);
P_T_Ox_Pa(1)  = P_T_Ox_psi(1)*cf.psi_to_Pa;
P_T_fu_psi(1) = grab(calcT,'P_T_fu_psia', P_T_fu0_psi);
P_T_fu_Pa(1)  = P_T_fu_psi(1)*cf.psi_to_Pa;

m_Ox(1) = grab(calcT,'m_Ox_kg', m_Ox0);
m_fu(1) = grab(calcT,'m_fu_kg', m_fu0);

ChTmp_K(1)   = grab(calcT,'ChTmp_K', ChTmp0);
ChPres_Pa(1) = grab(calcT,'ChPres_Pa', ChPres0_Pa);

% Densities at t0 from tables (E, ρ_Ox; user table fields assumed)
rho_Ox(1) = table_lookup_density_N2O_fromP(P_T_Ox_psi(1), n2oLiq, n2oVap);
rho_fu(1) = grab(calcT,'rho_fu_kgm3', rho_fu0);

% Exit Mach interpolation (BC)
M_exit(1) = get_exit_mach_number(M_exit_120, M_exit_125, gamma_cmb);

%% 6) March over time, following Calculations sheet order
for k = 1:Nt-1

    %% =====================================================================
    %% LAYER 1  (A, B, T, U, V, AM, AS, AT, BA, BC, BF, BG, BH, BQ, BR, BS, CF)
    %% Base state & constants: time, dt, masses, phases, friction constants,
    %% combustion properties, D1/D2 thrust history factors.
    %% =====================================================================

    % D1 (BG) and D2 (BH) depend only on previous thrust and dt (previous rows)
    if k > 2
        D1(k) = get_D1_factor(RThst_N(k-1), RThst_N(k-2));   % BG
    else
        D1(k) = 1;                                           % BG (startup)
    end
    D2(k) = get_D2_factor(dt(k), k);                         % BH

    % t (A), dt (B), m_Ox (S), m_fu (U), Phase N2O (T), c*, gamma_cmb, etc.
    % are taken from I/O or previous step and assumed already defined:
    %   t(k), dt(k), m_Ox(k), m_fu(k), PhaseN2O(k), cstar, gamma_cmb, R_cmb, etc.

    %% =====================================================================
    %% LAYER 2–3  (C, D, E, F, G, S)
    %% Tank pressures and densities for current row (k+1)
    %% =====================================================================

    % ----- C,D: Nitrous tank pressure (psia / Pa) -----
    % Column C: P_T_Ox_psi, Column D: P_T_Ox_Pa
    P_T_Ox_psi(k+1) = P_T_Ox_psi(k);          % TODO: plug in Column C formula
    P_T_Ox_Pa(k+1)  = P_T_Ox_psi(k+1)*cf.psi_to_Pa;

    % ----- F,G: Ethanol tank pressure (psia / Pa) -----
    % Column F: P_T_fu_psi, Column G: P_T_fu_Pa
    P_T_fu_psi(k+1) = P_T_fu_psi(k);          % TODO: plug in Column F (ullage) formula
    P_T_fu_Pa(k+1)  = P_T_fu_psi(k+1)*cf.psi_to_Pa;

    % ----- E: ρ_Ox from properties tables -----
    % Column E: rho_Ox, (rho_fu is analogous to ethanol density from I/O)
    rho_Ox(k+1) = table_lookup_density_N2O_fromP( ...
                      P_T_Ox_psi(k+1), n2oLiq, n2oVap);      % E
    rho_fu(k+1) = rho_fu(k);                                % keep simple for now

    % S, U (masses) get updated later (after mdot) – see Layer 13.

    %% =====================================================================
    %% LAYER 4–6  (AK, AL, AM, AN, AA, AB, AC, Y, Z,
    %%             AH, AI, AJ, AF, AG)
    %% Line Reynolds numbers, friction factors, and line ΔP for N2O & ethanol
    %% =====================================================================

    % ----- AK,AL: Reynolds numbers (using previous-step mdot as a reference) -----
    mdotOx_ref = max(mdot_Ox(max(k,1)), 0);
    mdotFu_ref = max(mdot_fu(max(k,1)), 0);

    Re_Ox(k) = get_Re_N2O( ...
        mdotOx_ref*cf.kgs_to_lbmhr, ...
        Di_Ox_in, ...
        get_viscosity_cp(P_T_Ox_psi(k), n2oLiq, n2oVap));   % AK

    Re_fu(k) = get_Re_ethanol( ...
        mdotFu_ref*cf.kgs_to_lbmhr, ...
        Di_fu_in, ...
        get_viscosity_cp_ethanol());                        % AL

    % ----- AM,AN: Darcy friction factors -----
    f_Ox(k) = get_friction_factor_N2O(eps_Ox_in, Di_Ox_in, max(Re_Ox(k),1)); % AM
    f_fu(k) = get_friction_factor_ethanol(eps_fu_in, Di_fu_in, max(Re_fu(k),1)); % AN

    % ----- AA,AB,AC,Y,Z: N2O line ΔP maj/min/cmp and totals -----
    dP_Maj_Ox(k) = get_N2O_major_dP( ...
        f_Ox(k), L_line_Ox_ft, mdotOx_ref*cf.kgs_to_lbmhr, ...
        rho_Ox(k+1), Di_Ox_in);                             % AA

    dP_Min_Ox(k) = get_N2O_minor_dP( ...
        K_sum_Ox, mdotOx_ref*cf.kgs_to_lbmhr, ...
        rho_Ox(k+1), Di_Ox_in);                             % AB

    Q_Ox_GPM(k)  = 15850.323*(mdotOx_ref/max(rho_Ox(k+1),1e-9)); % K (used for AC)

    dP_Cmp_Ox(k) = get_N2O_component_dP( ...
        rho_Ox(k+1), Q_Ox_GPM(k), Cv_main);                 % AC

    dPsum_Ox_psi(k) = dP_Maj_Ox(k) + dP_Min_Ox(k) + dP_Cmp_Ox(k); % Y
    dPsum_Ox_Pa(k)  = dPsum_Ox_psi(k)*cf.psi_to_Pa;               % Z

    % ----- AH,AI,AJ,AF,AG: Ethanol line ΔP maj/min/cmp and totals -----
    dP_Maj_fu(k) = get_ethanol_major_dP( ...
        f_fu(k), L_line_fu_ft, mdotFu_ref*cf.kgs_to_lbmhr, ...
        rho_to_lbmft3(rho_fu(k+1)), Di_fu_in);              % AH

    dP_Min_fu(k) = get_ethanol_minor_dP( ...
        K_sum_fu, mdotFu_ref*cf.kgs_to_lbmhr, ...
        rho_to_lbmft3(rho_fu(k+1)), Di_fu_in);              % AI

    Q_fu_GPM(k)  = 15850.323*(mdotFu_ref/max(rho_fu(k+1),1e-9)); % P, reused later

    dP_Cmp_fu(k) = get_ethanol_component_dP( ...
        get_SG_ethanol(rho_fu(k+1)), Q_fu_GPM(k), Cv_main); % AJ

    dPsum_fu_psi(k) = get_ethanol_total_line_dP_psi( ...
                          dP_Maj_fu(k), dP_Min_fu(k), dP_Cmp_fu(k)); % AF
    dPsum_fu_Pa(k)  = convert_ethanol_dP_psi_to_pa(dPsum_fu_psi(k)); % AG

    %% =====================================================================
    %% LAYER 6–7  (AO, AP, AQ, AR, BU, BV, BW, BX, BY, BZ, CA, CB, CC, CD, CE)
    %% Injector inlet pressures & N2O thermo state at injector outlet
    %% =====================================================================

    % ----- AO,AP: N2O injector inlet pressure -----
    P_i_Ox_psi(k) = get_N2O_injector_inlet_pressure( ...
                        P_T_Ox_psi(k+1), dPsum_Ox_psi(k));      % AO
    P_i_Ox_Pa(k)  = convert_N2O_injector_pressure_pa( ...
                        P_i_Ox_psi(k));                         % AP

    % ----- AQ,AR: Ethanol injector inlet pressure -----
    P_i_fu_psi(k) = get_ethanol_injector_inlet_pressure( ...
                        P_T_fu_psi(k+1), dPsum_fu_psi(k));      % AQ
    P_i_fu_Pa(k)  = convert_ethanol_injector_inlet_pressure_pa( ...
                        P_i_fu_psi(k));                         % AR

    % ----- BU…BX,BY…CA,CB…CE: N2O entropy, quality, densities, enthalpies -----
    S_Ox(k)         = lookup_entropy_from_P(P_T_Ox_psi(k+1));          % BU

    % Use previous-step chamber pressure for state at injector outlet
    S_i_out_l_Ox(k) = lookup_entropy_liq_from_P( ...
                        ChPres_Pa(k)*cf.Pa_to_psi);                    % BV
    S_i_out_g_Ox(k) = lookup_entropy_vap_from_P( ...
                        ChPres_Pa(k)*cf.Pa_to_psi);                    % BW
    x_Ox(k)         = get_quality_N2O( ...
                        S_Ox(k), S_i_out_l_Ox(k), S_i_out_g_Ox(k));    % BX

    rho_i_out_l_Ox(k) = lookup_rho_liq_from_P( ...
                            ChPres_Pa(k)*cf.Pa_to_psi);                % BY
    rho_i_out_g_Ox(k) = lookup_rho_vap_from_P( ...
                            ChPres_Pa(k)*cf.Pa_to_psi);                % BZ
    rho_i_out_Ox(k)   = get_injector_outlet_density_N2O( ...
                            x_Ox(k), rho_i_out_g_Ox(k), rho_i_out_l_Ox(k)); % CA

    H_tank_Ox(k)    = lookup_tank_enthalpy_N2O(P_T_Ox_psi(k+1));      % CB
    H_i_out_l_Ox(k) = lookup_injector_liquid_enthalpy_N2O( ...
                          ChPres_Pa(k)*cf.Pa_to_psi);                 % CC
    H_i_out_g_Ox(k) = lookup_injector_vapor_enthalpy_N2O( ...
                          ChPres_Pa(k)*cf.Pa_to_psi);                 % CD
    H_i_out_N2O(k)  = get_injector_enthalpy_N2O( ...
                          x_Ox(k), H_i_out_g_Ox(k), H_i_out_l_Ox(k)); % CE

    %% =====================================================================
    %% LAYER 8–9  (W, X, AD, CH, CG)
    %% Injector ΔP and N2O mass flow models (SPI & HEM)
    %% =====================================================================

    % ----- W,X: N2O injector ΔP -----
    dPi_Ox_Pa(k)  = max(P_i_Ox_Pa(k) - ChPres_Pa(k), 0);       % W
    dPi_Ox_psi(k) = dPi_Ox_Pa(k)*cf.Pa_to_psi;                 % X

    % ----- AD: Ethanol injector ΔP (Pa) -----
    dPi_fu_Pa(k)  = max(P_i_fu_Pa(k) - ChPres_Pa(k), 0);       % AD
    % (AE = psi conversion not explicitly stored)

    % ----- CH,CG: N2O mdot_SPI and mdot_HEM -----
    mdot_N2O_SPI(k) = get_mass_flow_SPI_N2O( ...
        Cd_i_N2O, A_exit_i_N2O, rho_Ox(k+1), dPi_Ox_Pa(k));    % CH

    mdot_N2O_HEM(k) = get_mass_flow_HEM_N2O( ...
        Cd_i_N2O, A_exit_i_N2O, rho_i_out_Ox(k), ...
        H_tank_Ox(k), H_i_out_g_Ox(k));                        % CG

    %% =====================================================================
    %% LAYER 10–12  (I, J, K, L, M, N, O, P, Q, R, H)
    %% N2O & ethanol mdot, velocities, flows, and total mass flow
    %% =====================================================================

    % ----- I: blended Nitrous mass flow (kg/s) -----
    mdot_Ox(k) = (1 - 1/(1+K_blend))*mdot_N2O_SPI(k) + ...
                 (1/(1+K_blend))*mdot_N2O_HEM(k);             % I

    % ----- J,K,L,M: helper flows/velocities for N2O -----
    mdot_Ox_lbh(k) = mdot_Ox(k)*cf.kgs_to_lbmhr;               % J
    v_Ox_ms(k)     = line_velocity(mdot_Ox(k), rho_Ox(k+1), Di_Ox); % L
    v_Ox_fts(k)    = v_Ox_ms(k)/cf.ft_to_m;                    % M
    % Q_Ox_GPM(k) already defined earlier for dP_Cmp_Ox (acts as K)

    % ----- N,O,P,Q,R: Ethanol side mdot/velocities -----
    mdot_fu(k)     = get_ethanol_mdot_simple( ...
                         Cd_i_fu, A_exit_i_fu, ...
                         rho_fu(k+1), dPi_fu_Pa(k));           % N
    mdot_fu_lbh(k) = mdot_fu(k)*cf.kgs_to_lbmhr;               % O
    v_fu_ms(k)     = line_velocity(mdot_fu(k), rho_fu(k+1), Di_fu); % Q
    v_fu_fts(k)    = v_fu_ms(k)/cf.ft_to_m;                    % R
    Q_fu_GPM(k)    = 15850.323*(mdot_fu(k)/max(rho_fu(k+1),1e-9));  % P (refined)

    % ----- H: total mass flow -----
    mdot_sum(k) = mdot_Ox(k) + mdot_fu(k);                     % H

    %% =====================================================================
    %% LAYER 13  (S, U)
    %% Mass bookkeeping for next timestep
    %% =====================================================================

    m_Ox(k+1) = max(m_Ox(k) - mdot_Ox(k)*dt(k), 0);           % S
    m_fu(k+1) = max(m_fu(k) - mdot_fu(k)*dt(k), 0);           % U

    %% =====================================================================
    %% LAYER 14–15  (AV, AU, AX, AY, AZ, BA, BB, BC, BD, BE)
    %% Chamber pressures and nozzle thermodynamics
    %% =====================================================================

    % ----- AV: Raw chamber pressure (Pa) -----
    ChPres_raw_Pa(k) = get_raw_chamber_pressure_pa( ...
                           cstar, mdot_sum(k), A_throat);      % AV

    % BA: chamber temperature – here just propagated
    ChTmp_K(k+1) = ChTmp_K(k);                                % BA (can refine later)

    % BC: exit Mach number
    M_exit(k+1)  = get_exit_mach_number(M_exit_120, M_exit_125, gamma_cmb); % BC

    % BB: exit gas temperature
    ExhtTmp_K(k) = get_exit_temperature(ChTmp_K(k+1), gamma_cmb, M_exit(k+1)); % BB

    % AZ: pressure ratio P/P0
    P_ratio(k)   = get_pressure_ratio_P_over_P0(gamma_cmb, M_exit(k+1)); % AZ

    % ----- AY: corrected chamber pressure (Pa) -----
    ChPres_Pa(k+1) = get_corrected_chamber_pressure_pa( ...
                         ChPres_Pa(k), ChPres_raw_Pa(k), ...
                         D1(k), 'liquid');                     % AY
    % AX (psia) is just ChPres_Pa*Pa_to_psi when needed in lookups.

    % ----- BD,BE: exit velocity and exit pressure -----
    V_exit(k)      = get_exit_velocity(M_exit(k+1), gamma_cmb, R_cmb, ExhtTmp_K(k)); % BD
    ExhtPres_Pa(k) = get_exit_pressure(ChPres_Pa(k+1), P_ratio(k));                  % BE

    %% =====================================================================
    %% LAYER 16–18  (BI, BJ, BK, BL, BM, BN, BO, BT, BP)
    %% Thrust, its derivatives, impulse, mixture ratio, Δv, engine status
    %% =====================================================================

    % ----- BI,BJ: raw thrust (N, lbf) -----
    RThst_N(k)   = get_raw_thrust( ...
                        mdot_sum(k), V_exit(k), ...
                        ExhtPres_Pa(k), 101300, A_exit);      % BI + BF
    RThst_lbf(k) = convert_raw_thrust_N_to_lbf(RThst_N(k));   % BJ

    % ----- BK: dF/dt (instantaneous thrust slope) -----
    if k > 1
        dFdt(k) = get_thrust_rate(RThst_N(k), Thst_N(k-1), dt(k)); % BK
    else
        dFdt(k) = 0;                                               % BK
    end

    % ----- BL,BM: thrust (N, lbf) -----
    if k > 1
        Thst_N(k) = get_thrust( ...
                        RThst_N(k), Thst_N(k-1), ...
                        D1(k), D2(k), dFdt(k), dt(k));        % BL
    else
        Thst_N(k) = RThst_N(k);                               % BL
    end

    Thst_lbf(k) = convert_thrust_N_to_lbf(Thst_N(k));         % BM

    % ----- BN: impulse J (N*s) -----
    J_Ns(k) = get_impulse(Thst_N(k), dt(k));                  % BN

    % ----- BO: mixture ratio O/F -----
    OF(k) = get_mixture_ratio( ...
               max(mdot_Ox(k),1e-12), max(mdot_fu(k),1e-12)); % BO

    % ----- BT: instantaneous Δv -----
    deltaV_inst(k) = get_instantaneous_deltaV( ...
                        Thst_N(k), ...
                        t(min(k+1,Nt)), t(k), ...
                        m_Ox(k), m_fu(k));                    % BT

    % ----- BP: engine status -----
    status(k) = get_engine_status(m_Ox(k+1), m_fu(k+1));      % BP

end


%% 7) Pack outputs (names match sheet concepts)
out.t = t; out.dt = dt;
out.P_T_Ox_psi = P_T_Ox_psi; out.P_T_Ox_Pa = P_T_Ox_Pa;
out.P_T_fu_psi = P_T_fu_psi; out.P_T_fu_Pa = P_T_fu_Pa;
out.rho_Ox = rho_Ox; out.rho_fu = rho_fu;
out.m_Ox = m_Ox; out.m_fu = m_fu; out.phase_Ox = phase_Ox;
out.mdot_Ox = mdot_Ox; out.mdot_fu = mdot_fu; out.mdot_sum = mdot_sum;
out.v_Ox_ms = v_Ox_ms; out.v_Ox_fts = v_Ox_fts;
out.v_fu_ms = v_fu_ms; out.v_fu_fts = v_fu_fts;
out.Q_Ox_GPM = Q_Ox_GPM; out.Q_fu_GPM = Q_fu_GPM;
out.dPi_Ox_Pa = dPi_Ox_Pa; out.dPi_Ox_psi = dPi_Ox_psi;
out.dP_Maj_Ox = dP_Maj_Ox; out.dP_Min_Ox = dP_Min_Ox; out.dP_Cmp_Ox = dP_Cmp_Ox;
out.dPsum_Ox_psi = dPsum_Ox_psi; out.dPsum_Ox_Pa = dPsum_Ox_Pa;
out.dPi_fu_Pa = dPi_fu_Pa; out.dPi_fu_psi = dPi_fu_psi;
out.dP_Maj_fu = dP_Maj_fu; out.dP_Min_fu = dP_Min_fu; out.dP_Cmp_fu = dP_Cmp_fu;
out.dPsum_fu_psi = dPsum_fu_psi; out.dPsum_fu_Pa = dPsum_fu_Pa;
out.Re_Ox = Re_Ox; out.Re_fu = Re_fu; out.f_Ox = f_Ox; out.f_fu = f_fu;
out.P_i_Ox_psi = P_i_Ox_psi; out.P_i_Ox_Pa = P_i_Ox_Pa;
out.P_i_fu_psi = P_i_fu_psi; out.P_i_fu_Pa = P_i_fu_Pa;
out.ChPres_raw_Pa = ChPres_raw_Pa; out.ChPres_Pa = ChPres_Pa;
out.ChTmp_K = ChTmp_K; out.ExhtTmp_K = ExhtTmp_K;
out.M_exit = M_exit; out.V_exit = V_exit; out.P_ratio = P_ratio; out.ExhtPres_Pa = ExhtPres_Pa;
out.RThst_N = RThst_N; out.RThst_lbf = RThst_lbf;
out.dFdt = dFdt; out.D1 = D1; out.D2 = D2;
out.Thst_N = Thst_N; out.Thst_lbf = Thst_lbf; out.J_Ns = J_Ns;
out.OF = OF; out.status = status;
out.S_Ox = S_Ox; out.S_i_out_l_Ox = S_i_out_l_Ox; out.S_i_out_g_Ox = S_i_out_g_Ox; out.x_Ox = x_Ox;
out.rho_i_out_l_Ox = rho_i_out_l_Ox; out.rho_i_out_g_Ox = rho_i_out_g_Ox; out.rho_i_out_Ox = rho_i_out_Ox;
out.H_tank_Ox = H_tank_Ox; out.H_i_out_l_Ox = H_i_out_l_Ox; out.H_i_out_g_Ox = H_i_out_g_Ox; out.H_i_out_N2O = H_i_out_N2O;
out.mdot_N2O_SPI = mdot_N2O_SPI; out.mdot_N2O_HEM = mdot_N2O_HEM;
out.deltaV_inst = deltaV_inst;

end

% ====================== LOCAL HELPERS ======================

function v = calc_col(T, name, default)
    if ismember(name, T.Properties.VariableNames)
        v = T.(name);
    else
        v = default;
    end
end

function v = grab(T, name, default)
    if ismember(name, T.Properties.VariableNames)
        v = T.(name); v = v(1);
    else
        v = default;
    end
end

function v = pick(ioT, param, default)
    v = default;
    if ismember('PARAMETER', ioT.Properties.VariableNames) && ismember('VALUE', ioT.Properties.VariableNames)
        idx = strcmp(ioT.PARAMETER, param);
        if any(idx), v = ioT.VALUE(find(idx,1,'first')); end
    end
end

function rho = table_lookup_density_N2O_fromP(P_psia, liqT, vapT)
% Example: prefer liquid table near high P, else vapor. Replace with your rule.
    rhoL = nearest_from_table(liqT, 'Pressure_psia', P_psia, 'Density_kg_m3');
    rhoG = nearest_from_table(vapT, 'Pressure_psia', P_psia, 'Density_kg_m3');
    rho  = max(rhoL, rhoG); % conservative; swap with your phase logic
end

function mu_cP = get_viscosity_cp(P_psia, liqT, vapT)
% Example fetch (centipoise). Replace field names if different.
    muL = nearest_from_table(liqT, 'Pressure_psia', P_psia, 'Viscosity_cP');
    muG = nearest_from_table(vapT, 'Pressure_psia', P_psia, 'Viscosity_cP');
    mu_cP = min(muL, muG);
end

function mu_cP = get_viscosity_cp_ethanol()
% Placeholder constant; wire to your ethanol table if available.
    mu_cP = 1.2;
end

function val = nearest_from_table(T, keyCol, key, outCol)
    if ~ismember(keyCol, T.Properties.VariableNames) || ~ismember(outCol,T.Properties.VariableNames)
        error('Missing columns %s or %s in table.', keyCol, outCol);
    end
    [~,ix] = min(abs(T.(keyCol) - key));
    val = T.(outCol)(ix);
end

function v = line_velocity(mdot, rho, Di_m)
    A = pi*(Di_m/2)^2;
    v = mdot/(rho*max(A,1e-12));
end

function rho_lbmft3 = rho_to_lbmft3(rho_kgm3)
    rho_lbmft3 = rho_kgm3 * 0.06242796; % 1 kg/m^3 = 0.06242796 lbm/ft^3
end

function sg = get_SG_ethanol(rho_fu_kgm3)
    sg = rho_fu_kgm3/1000; % vs water 1000 kg/m^3
end

function mdot_fu = get_ethanol_mdot_simple(Cd, A_exit_i, rho_fu, dP_Pa)
    mdot_fu = Cd * A_exit_i * sqrt(2*rho_fu*max(dP_Pa,0));
end
