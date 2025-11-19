function [data] = TransientThrustCurveCalibration(txt)
    keywords_input = ["Pin =", 'O/F='," # Pressure \("];
    keywords_output = ["P, BAR", "T, K", "Cp, KJ/\(KG\)\(K\)", 'GAMMAs',"SON VEL,M/SEC","MACH NUMBER","CSTAR, M/SEC"];
    
    filetext = fileread(txt);
    
    inputs = cell(length(keywords_input),1); 
    for i = 1:length(keywords_input) 
        raw_lines = regexp(filetext,'(?<=' + keywords_input(i) + '\s*)\d+(\.\d+)?', 'match');
        vals = [];
        for j = 1:length(raw_lines)
            nums = str2double(regexp(raw_lines{j}, '\d+(\.\d+)?', 'match'));
            vals = [vals; nums];
        end
        inputs{i} = vals;
    end
    
    
    outputs = cell(length(keywords_output),1);
    for i = 1:length(keywords_output) 
        raw_lines = regexp(filetext,'(?<=' + keywords_output(i) + ').*?(?=\r?\n|$)', 'match');
        vals = [];
        for j = 1:length(raw_lines)
            nums = str2double(regexp(raw_lines{j}, '\d+(\.\d+)?', 'match'));
            vals = [vals; nums];
        end
        outputs{i} = vals;
    end

    % outputs is in form outputs{Pressure, Temperature, Cp, Gamma, sonic velocity, Mach Number, Cstar)
    % with the columns (chamber, throat, exit). C* has two columns but they are
    % the same, cea outputs 2 for sum reason
    % inputs is inputs{Input Pressure (into CEA), O/F ratio, nx (number of
    % pressure variables)}
    
    % unit conversion
    bar2Pa = 100000;
    nx = inputs{3}; % number of pressures per o/f ratio
    
    data.gamma_e = reshape(outputs{4}(:,3),nx,[]);
    data.Cp_e = reshape(outputs{3}(:,3)*10^3,nx,[]);
    data.R_e = reshape(data.Cp_e.*(data.gamma_e-1)./data.gamma_e,nx,[]);
    data.T_c = reshape(outputs{2}(:,1),nx,[]);
    data.P_c = reshape(outputs{1}(:,1)*bar2Pa,nx,[]);
    data.P_e = reshape(outputs{1}(:,3)*bar2Pa,nx,[]);
    data.a_e = reshape(outputs{5}(:,3),nx,[]);
    data.M_e = reshape(outputs{6}(:,3),nx,[]);
    data.c_star = reshape(outputs{7}(:,1),nx,[]);
    data.of = reshape(inputs{2},nx,[]);
end
