T = readtable('data/thrust_inputs.xlsx', 'Sheet', 'Sheet1');
paramName = "Initial N2O Liquid Mass (kg)";
value = T.VALUE(strcmp(T.PARAMETER, paramName));