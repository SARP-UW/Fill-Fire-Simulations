import numpy as np
import pandas as pd
# import matplotlib.pyplot as plt
import CoolProp as cp
from scipy.interpolate import interp1d
# from scipy.signal import butter, filtfilt, savgol_filter

'''
This code processes pressure transducer and load cell data to obtain information about the system
'''

def get_K_fitting(fitting_type, Re, D):
    # Use Darby 3K method to find minor losses due to fittings
    match fitting_type:
        case "elbow_90_threaded_standard":
            K_1 = 800
            K_i = 0.14
            K_d = 4.0
        case "elbow_90_threaded_longradius":
            K_1 = 800
            K_i = 0.071
            K_d = 4.2
        case "elbow_45_threaded_standard":
            K_1 = 500
            K_i = 0.071
            K_d = 4.2
        case "t_run_through_threaded":
            K_1 = 500
            K_i = 0.274
            K_d = 4.0
        case "t_elbow_threaded":
            K_1 = 200
            K_i = 0.091
            K_d = 4.0
        case "cross_run_threaded":
            # approximate as two tee's
            return 2 * get_K_fitting("t_run_through_threaded", Re, D)
        case "ball_valve":
            K_1 = 300
            K_i = 0.017
            K_d = 3.5
        case "none":
            return 0
        case _:
            if isinstance(fitting_type, str):
                if fitting_type.startswith("contraction"):
                    s = fitting_type.split("_")
                    beta = float(s[2])/float(s[1])

                    K = (1 - (beta**2))**2
                    return K
                
                elif fitting_type.startswith("expansion"):
                    s = fitting_type.split("_")
                    beta = float(s[2])/float(s[1])

                    K = 0.5 * (1 - (beta**2))**2
                    return K

                elif fitting_type.startswith("Cv"):
                    s = fitting_type.split("=")
                    Cv = float(s[1])
                    D_mm = D * 1000          # convert metres → inches first

                    K = 0.002148 * D_mm**4 / Cv**2
                    return K
                else:
                    raise ValueError(f"Unknown fitting type: {fitting_type}")

    D_in = D * 39.37 # K values given in inches
    K = (K_1 / Re) + K_i * (1 + K_d / D_in**(0.3))
    return K

def get_friction_factor(D, epsilon, Re):
    d = D * 1000 # m -> mm

    if Re < 2100:
        # laminar region
        return 64 / Re
    elif Re > 4000:
        # Calculate f with Serghide explicit approximation
        A = -2 * np.log10( (epsilon / (3.7 * d)) + (12 / Re) )
        B = -2 * np.log10( (epsilon / (3.7 * d)) + ((2.51 * A) / Re) )
        C = -2 * np.log10( (epsilon / (3.7 * d)) + ((2.51 * B) / Re) )
        return (A - ( ((B - A)**2) / (C - (2 * B) + A)))**(-2)
    elif 2100 < Re < 4000:
        # interpolate
        f_lam = 64 / Re

        A = -2 * np.log10( (epsilon / (3.7 * d)) + (12 / Re) )
        B = -2 * np.log10( (epsilon / (3.7 * d)) + ((2.51 * A) / Re) )
        C = -2 * np.log10( (epsilon / (3.7 * d)) + ((2.51 * B) / Re) )
        f_turb = (A - ( ((B - A)**2) / (C - (2 * B) + A)))**(-2)
        
        return (f_lam + (Re - 2100) * (f_turb - f_lam) / (4000 - 2100))
    else:
        print(f"Re = {Re}")
        raise ValueError("Invalid Reynolds Number")

def get_dP(v, rho, mu, D, L, epsilon, fittings):
    """Pressure drop for a single pipe segment at inlet velocity v."""
    Re = rho * D * v / mu
    f = get_friction_factor(D, epsilon, Re)
 
    K_total = 0
    for fitting in fittings:
        K_total += get_K_fitting(fitting, Re, D)
 
    dP = (rho * v**2) / 2 * ((f * L / D) + K_total)
    return dP, v, f
 
def get_dP_total(v1, rho, mu, segments):
    """
    Total pressure drop across all pipe segments in series, given the inlet
    velocity v1 in the first segment.
 
    Continuity relates velocities between segments:
        v_n = v1 * (A1 / A_n)
 
    Each segment is a dict with keys:
        D        : inner diameter (m)
        L        : length (m)
        epsilon  : roughness (mm)
        fittings : list of fitting type strings
 
    Returns the summed dP and the friction factor of the first segment.
    """
    A1 = (np.pi / 4) * segments[0]["D"]**2 # m2
 
    dP_total = 0
    f_seg1 = None
 
    for n, seg in enumerate(segments):
        A_n = (np.pi / 4) * seg["D"]**2
        v_n = v1 * (A1 / A_n)  # momentum conservation with areas of each segment
 
        dP_n, _, f_n = get_dP(v_n, rho, mu, seg["D"], seg["L"],
                               seg["epsilon"], seg["fittings"])
        dP_total += dP_n
 
        if n == 0:
            f_seg1 = f_n  # return friction factor of the first (reference) segment
 
    return dP_total, f_seg1

def solve_velocity(dP_measured, rho, mu, segments, v_low, v_high, tolerance, max_iterations):
    """
    Use a measured dP to find the line velocity. 
    Guesses velocities, calculated a guess for dP, and adjusts until convergence on measured dP.
 
    Uses bisection: bracket the answer between v_low and v_high, then repeatedly
    halve the interval until the predicted dP is within `tolerance` Pa of the
    measured value.
    """
 
    # Evaluate dP at both ends of the bracket
    dP_low, _ = get_dP_total(v_low,  rho, mu, segments)
    dP_high, _ = get_dP_total(v_high, rho, mu, segments)
 
    # Sanity check: the measured dP must sit between the two bracket values
    if dP_measured < dP_low:
        raise ValueError(
            f"dP_measured ({dP_measured:.1f} Pa) is below dP at v_low={v_low} m/s "
        )
    if dP_measured > dP_high:
        raise ValueError(
            f"dP_measured ({dP_measured:.1f} Pa) is above dP at v_high={v_high} m/s "
        )
 
    # --- Bisection loop ---
    for iteration in range(max_iterations):
 
        v_mid = (v_low + v_high) / 2.0 # midpoint velocity
        dP_mid, f_mid = get_dP_total(v_mid, rho, mu, segments)
 
        error = dP_measured - dP_mid # positive -> need more velocity
 
        # check for convergence
        if abs(error) < tolerance:
            return v_mid, f_mid
 
        # adjust search range
        if error > 0:
            v_low = v_mid   # predicted dP too low -> need higher velocity
        else:
            v_high = v_mid  # predicted dP too high -> need lower velocity
 
    # If does not converge converging, warn but return best estimate
    print(f" Warning: bisection did not converge within {max_iterations} iterations. ")
    print(f"Final error = {error:.2f} Pa")
    return v_mid, f_mid

def get_mu_n2o_sat_liquid(P_Pa):
    """Return saturated liquid viscosity (Pa*s) of N2O at pressure P_Pa."""
    T_sat = float(sat_T_from_P(P_Pa))
    return float(sat_mu_from_T(T_sat))
'''
Parameters
'''
# Injector Parameters
A_inj_ox = 0.000047 # m2
A_inj_fu = 0.00003418 # m2

# Fluid Parameters
rho_H20_l = 1000 # kg/m^3 (for cold flows)
T_amb = 293 # Kelvin
fluid_ox = "NitrousOxide"
fluid_fu = "Ethanol"

# Physical parameters
epsilon_steel = 0.038 # absolute roughness of stainless steel tubing (mm)
epsilon_ptfe = 0.003 # absolute roughness of PTFE hose liner (mm)

# Line properties
ox_segments = [
    {"D": 0.402 / 39.37, "L": 36 / 39.37, "epsilon": epsilon_steel, "fittings": ["t_run_through_threaded", "Cv=9.7", "contraction_0.402_0.375"]},
    {"D": 0.375 / 39.37, "L": 12 / 39.37, "epsilon": epsilon_ptfe, "fittings": ["expansion_0.375_0.402"]}
]
 
fu_segments = [
    {"D": 0.277 / 39.37,  "L": 27.00 / 39.37,  "epsilon": epsilon_steel,
     "fittings": ["Cv=9.7", "expansion_0.277_0.375"]},
    {"D": 0.375 / 39.37, "L": 12.00/ 39.37, "epsilon": epsilon_ptfe,
    "fittings": ["contraction_0.375_0.277"]},
    {"D": 0.277 / 39.37, "L": 5 / 39.37, "epsilon": epsilon_steel, "fittings": ["none"]},
]

# Data Setup
RAW_DATA_FILENAME = "cold flow data 4-26-26.csv"
PROCESSED_DATA_FILENAME = "Processed Cold Flow Data 4-26-26.csv"

# Average mass flows
MDOT_OX_AVG = 0.46 # kg/s
MDOT_FU_AVG = 0.34 # kg/s

# Solver settings
START_ROW = 128
END_ROW = 354
TOLERANCE = 0.5    # convergence threshold (Pa)
MAX_ITER = 200 # maximum iterations for velocity solver
V_LOW = 0.001  # lower velocity bracket for velocity solver(m/s)
V_HIGH = 100.0  # upper velocity bracket for velocity solver (m/s)
COMPUTE_DYER = 0
COMPUTE_HEM = 1
CALCULATE_MDOT = 0
N_SWEEP = 20 # number of downstream pressures to sweep for critical HEM model

# Conversion factors
PSI_TO_PA = 6894.76
LBF_TO_KG = 0.453592


'''
Set up data frame
'''
# Load Nitrous Oxide Saturation Properties Table
properties = pd.read_csv(
    'nitrousoxide_sat_properties.txt',
    sep='\t',
    na_values=['undefined']  # treat 'undefined' as NaN
)
properties.columns = properties.columns.str.strip()
properties = properties.dropna(subset=['Temperature (K)', 'Viscosity (l, Pa*s)']).reset_index(drop=True)

# Interpolator 1: saturation pressure (Pa) → saturation temperature (K)
_sat_P_MPa = properties['Pressure (MPa)'].values
_sat_T_K   = properties['Temperature (K)'].values
_sat_mu_l  = properties['Viscosity (l, Pa*s)'].values

sat_T_from_P  = interp1d(_sat_P_MPa * 1e6,  _sat_T_K,  kind='linear', bounds_error=False, fill_value='extrapolate')
sat_mu_from_T = interp1d(_sat_T_K, _sat_mu_l, kind='linear', bounds_error=False, fill_value='extrapolate')

# Load CSV
df = pd.read_csv(RAW_DATA_FILENAME)
df = df.iloc[START_ROW:END_ROW].reset_index(drop=True)

# Convert psig to psia
PTs = ["OT-PT5 (psi)", "FT-PT6 (psi)", "OV-PT7 (psi)", "FV-PT8 (psi)", "OM-PT9 (psi)", "FM-PT10 (psi)", "CC-PT11 (psi)"]
for pt in PTs:
    df[pt] = df[pt] + 14.7

# Convert pressures from PSI to Pa before computing dP
df["dP Ox (Pa)"] = (df["OV-PT7 (psi)"] - df["OM-PT9 (psi)"])  * PSI_TO_PA
df["dP Fu (Pa)"] = (df["FV-PT8 (psi)"] - df["FM-PT10 (psi)"]) * PSI_TO_PA

# Change sign of mass flow
df["Tank Mass Flow (kg/s)"] = df["Tank Mass Flow (kg/s)"] * -1
 
# Output columns, filled in row by row below
outputs = ["v ox dP (m/s)", "f ox", "mdot ox dP (kg/s)", "v ox LC (m/s)", "mdot ox LC (kg/s)", "v ox avg (m/s)", 
           "mdot ox avg (kg/s)", "v fu dP (m/s)", "f fu dP", "mdot fu dP (kg/s)", "v fu avg (m/s)", 
           "mdot fu avg (kg/s)", "CdA ox dP SPI (m^2)", "Cd ox dP SPI", "CdA ox dP HEMC (m^2)", "Cd ox dP HEMC", 
           "CdA ox LC SPI (m^2)", "Cd ox LC SPI", "CdA ox LC HEMC (m^2)", "Cd ox LC HEMC", "CdA ox avg SPI (m^2)", 
           "Cd ox avg SPI", "CdA ox avg HEMC (m^2)", "Cd ox avg HEMC", "CdA fu dP (m^2)", "Cd fu dP", "CdA fu avg (m^2)",
           "Cd fu avg"]
for output in outputs:
    df[output] = np.nan

# initialize HEMC storage dictionary
massflux_HEMC = {}

'''
Row-by-row iterative solve
'''
for idx, row in df.iterrows():
    '''
    Ox Side
    '''
    # Try using dP method to validate LC measurements
    dP_ox_measured = row["dP Ox (Pa)"]
 
    # Fluid properties at the upstream pressure (saturated liquid conditions)
    P_ox_upstream = row["OV-PT7 (psi)"] * PSI_TO_PA
    rho_ox = cp.CoolProp.PropsSI('D', 'P', P_ox_upstream, 'Q', 0, fluid_ox)
    if fluid_ox == "NitrousOxide":
        # Coolprop doesn't work for nitrous oxide viscosity for some reason
        mu_ox = get_mu_n2o_sat_liquid(P_ox_upstream)
    else:
        mu_ox = cp.CoolProp.PropsSI("V", "P", P_ox_upstream, "Q", 0, fluid_ox)

    D_ox = ox_segments[0]["D"]
    A_ox = np.pi / 4 * D_ox**2

    # dP method
    if dP_ox_measured >= 0:
    # skip rows with no meaningful pressure drop
        try:
            v_ox, f_ox = solve_velocity(dP_measured=dP_ox_measured, rho=rho_ox, mu=mu_ox, segments=ox_segments, v_low=V_LOW, v_high=V_HIGH, tolerance=TOLERANCE, max_iterations=MAX_ITER)
            mdot_ox = rho_ox * v_ox * A_ox  # kg/s, based on segment-1 area
    
            df.at[idx, "v ox dP (m/s)"] = v_ox
            df.at[idx, "f ox"] = f_ox
            df.at[idx, "mdot ox dP (kg/s)"] = mdot_ox
    
        except ValueError as e:
            print(f"Row {idx} ox solver error: {e}")



    # Load Cell method
    if CALCULATE_MDOT == 1:
        if idx == df.index[0] or idx == df.index[-1]:
            # Can't compute derivative on first row — skip LC method
            pass
        else:
            next_row = df.loc[df.index[df.index.get_loc(idx) + 1]]
            prev_row = df.loc[df.index[df.index.get_loc(idx) - 1]]
            dt = next_row["Time (s)"] - prev_row["Time (s)"]
            dm = prev_row["Tank LC (kgf)"] - next_row["Tank LC (kgf)"]
            if dm > 0:
                mdot_ox_LC = dm / dt
                df.at[idx, "mdot ox LC (kg/s)"] = mdot_ox_LC

                # Calculate line velocity using first segment
                v_ox_LC = mdot_ox_LC / rho_ox / A_ox
                df.at[idx, "v ox LC (m/s)"] = v_ox_LC
            else:
                pass
    else:
        # use filtered data already in csv
        mdot_ox_LC = df.at[idx, "Tank Mass Flow (kg/s)"]
        v_ox_LC = mdot_ox_LC / rho_ox / A_ox

        df.at[idx, "mdot ox LC (kg/s)"] = mdot_ox_LC
        df.at[idx, "v ox LC (m/s)"] = v_ox_LC

    # Average Method
    df.at[idx, "mdot ox avg (kg/s)"] = MDOT_OX_AVG
    df.at[idx, "v ox avg (m/s)"] = MDOT_OX_AVG / rho_ox / A_ox
 
    ''' 
    Fuel side
    '''
    dP_fu_measured = row["dP Fu (Pa)"]

    D_fu = fu_segments[0]["D"]
    A_fu = np.pi / 4 * (D_fu**2)
 
    P_fu_upstream = row["FV-PT8 (psi)"] * PSI_TO_PA
    rho_fu = cp.CoolProp.PropsSI('D', 'P', P_fu_upstream, 'T', T_amb, fluid_fu)
    mu_fu  = cp.CoolProp.PropsSI('V', 'P', P_fu_upstream, 'T', T_amb, fluid_fu)
 
    # dP method
    if dP_fu_measured >= 0:
        try:
            v_fu, f_fu = solve_velocity(dP_fu_measured, rho_fu, mu_fu, fu_segments, v_low=V_LOW, v_high=V_HIGH, tolerance=TOLERANCE, max_iterations=MAX_ITER)
            
            mdot_fu = rho_fu * v_fu * A_fu  # kg/s, based on segment-1 area
    
            df.at[idx, "v fu dP (m/s)"] = v_fu
            df.at[idx, "f fu dP"] = f_fu
            df.at[idx, "mdot fu dP (kg/s)"] = mdot_fu
    
        except ValueError as e:
            print(f"Row {idx} fuel solver error: {e}")

    # Average method
    df.at[idx, "mdot fu avg (kg/s)"] = MDOT_FU_AVG
    df.at[idx, "v fu avg (m/s)"] = MDOT_FU_AVG / rho_fu / A_fu

'''
Calculate CdA for each row
'''

for idx, row in df.iterrows():
 
    '''
    Ox Side
    '''
    if CALCULATE_MDOT == 1:
        mdot_ox_LC = row["mdot ox LC (kg/s)"]
    else:
        mdot_ox_LC = row["Tank Mass Flow (kg/s)"]
    
    mdot_ox_dP = row["mdot ox dP (kg/s)"]

    # Injector face pressures (Pa)
    P_ox_inj = row["OM-PT9 (psi)"]  * PSI_TO_PA  # ox manifold pressure
    P_fu_inj = row["FM-PT10 (psi)"] * PSI_TO_PA  # fuel manifold pressure
    P_cc = row["CC-PT11 (psi)"] * PSI_TO_PA  # combustion chamber pressure, downstream of injector
 
    # Pressure drop across injector
    dP_inj_ox = P_ox_inj - P_cc
    dP_inj_fu = P_fu_inj - P_cc
 
    if dP_inj_ox <= 0 or dP_inj_fu <= 0:
        continue  # skip rows where injector dP is not positive

    # SPI Model for Ox 
    rho_ox_1 = cp.CoolProp.PropsSI('D', 'P', P_ox_inj, 'Q', 0, fluid_ox) # upstream density

    CdA_ox_dP_SPI = mdot_ox_dP / np.sqrt(2 * rho_ox_1 * dP_inj_ox)
    Cd_ox_dP_SPI = CdA_ox_dP_SPI / A_inj_ox
    
    CdA_ox_LC_SPI = mdot_ox_LC / np.sqrt(2 * rho_ox_1 * dP_inj_ox)
    Cd_ox_LC_SPI = CdA_ox_LC_SPI / A_inj_ox
    
    CdA_ox_avg_SPI = MDOT_OX_AVG / np.sqrt(2 * rho_ox_1 * dP_inj_ox)
    Cd_ox_avg_SPI = CdA_ox_avg_SPI / A_inj_ox

    df.at[idx, "CdA ox dP SPI (m^2)"] = CdA_ox_dP_SPI
    df.at[idx, "Cd ox dP SPI"] = Cd_ox_dP_SPI
    df.at[idx, "CdA ox LC SPI (m^2)"] = CdA_ox_LC_SPI
    df.at[idx, "Cd ox LC SPI"] = Cd_ox_LC_SPI
    df.at[idx, "CdA ox avg SPI (m^2)"] = CdA_ox_avg_SPI
    df.at[idx, "Cd ox avg SPI"] = Cd_ox_avg_SPI

    # Attempt implementing HEMC model
    if (COMPUTE_HEM == 1) or (COMPUTE_DYER == 1):
        # Clear previous HEMC results
        massflux_HEMC.clear()
        
        # Use tank conditions to get injector state (assume throttling process)
        P_tank = row["OT-PT5 (psi)"] * PSI_TO_PA
        h_ox_tank = cp.CoolProp.PropsSI('H', 'P', P_tank, 'Q', 0, fluid_ox)

        h_ox_1 = h_ox_tank
        try:
            s_ox_1 = cp.CoolProp.PropsSI('S', 'P', P_ox_inj, 'H', h_ox_1, fluid_ox)
        except ValueError:
            print(f"Error when determining upstream ox enthalpy in row {idx} at P: {P_ox_inj}")
            continue

        # Assume isentropic expansion
        downstream_pressures = np.linspace(P_cc * 0.5, P_ox_inj, N_SWEEP)
        for pressure in downstream_pressures:
            try:
                h_ox_2 = cp.CoolProp.PropsSI('H', 'P', pressure, 'S', s_ox_1, fluid_ox)
                rho_ox_2 = cp.CoolProp.PropsSI('D', 'P', pressure, 'S', s_ox_1, fluid_ox)
                # print(f"successful sweep in row {idx} at pressure: {pressure / PSI_TO_PA} psi")
            except ValueError:
                continue

            massflux_HEMC[pressure] = rho_ox_2 * np.sqrt(2 * (h_ox_1 - h_ox_2))

        # Identify maximum flux -- critical flow
        criticalflux_HEMC = max(massflux_HEMC.values())
        CdA_ox_dP_HEMC = mdot_ox_dP / criticalflux_HEMC
        Cd_ox_dP_HEMC = CdA_ox_dP_HEMC / A_inj_ox

        CdA_ox_LC_HEMC = mdot_ox_LC / criticalflux_HEMC
        Cd_ox_LC_HEMC = CdA_ox_LC_HEMC / A_inj_ox

        CdA_ox_avg_HEMC = MDOT_OX_AVG / criticalflux_HEMC
        Cd_ox_avg_HEMC = CdA_ox_avg_HEMC / A_inj_ox

        df.at[idx, "CdA ox dP HEMC (m^2)"] = CdA_ox_dP_HEMC
        df.at[idx, "Cd ox dP HEMC"] = Cd_ox_dP_HEMC
        df.at[idx, "CdA ox LC HEMC (m^2)"] = CdA_ox_LC_HEMC
        df.at[idx, "Cd ox LC HEMC"] = Cd_ox_LC_HEMC
        df.at[idx, "CdA ox avg HEMC (m^2)"] = CdA_ox_avg_HEMC
        df.at[idx, "Cd ox avg HEMC"] = Cd_ox_avg_HEMC

    '''
    Fuel Side
    '''
    mdot_fu_dP = row["mdot fu dP (kg/s)"]

    # SPI Model for fuel side
    rho_fu_inj = cp.CoolProp.PropsSI("D", "P", P_fu_inj, "T", T_amb, fluid_fu)  # water density treated as constant

    CdA_fu_dP = mdot_fu_dP / np.sqrt(2 * rho_fu_inj * dP_inj_fu)
    Cd_fu_dP = CdA_fu_dP / A_inj_fu

    CdA_fu_avg = MDOT_FU_AVG / np.sqrt(2 * rho_fu_inj * dP_inj_fu)
    Cd_fu_avg = CdA_fu_avg / A_inj_fu
 
    df.at[idx, "CdA fu dP (m^2)"] = CdA_fu_dP
    df.at[idx, "Cd fu dP"] = Cd_fu_dP
    df.at[idx, "CdA fu avg (m^2)"] = CdA_fu_avg
    df.at[idx, "Cd fu avg"] = Cd_fu_avg

    # print(idx) # debugging
 
 
'''
Save results
'''
df.to_csv(PROCESSED_DATA_FILENAME, index=False)
print(f"Done. Results saved to {PROCESSED_DATA_FILENAME}")