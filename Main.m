main_folder = fileparts(mfilename('fullpath'));
addpath(fullfile(main_folder, 'functions'));

%T = readtable('data/thrust_inputs.xlsx', 'Sheet', 'Sheet1');
%paramName = "Initial N2O Liquid Mass (kg)";
%value = T.VALUE(strcmp(T.PARAMETER, paramName));

% This is Emerson's comment.    

result = state_density(20, 356.80597, 227.9);
disp(result)