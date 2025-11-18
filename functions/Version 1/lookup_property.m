function property = lookup_property(file, base_val, base_col, search_col)
    % Lookup function that finds the corresponding property in a certain
    % column based on a known value, search column, and result column.

    % The file must be organized into column categories and rows for
    % different values. See "liquid_properties.xlsx" for an example.

    % Matrix Setup
    t = readmatrix(sprintf("%s.xlsx", file));
    t_size = size(t);
    index = 0;
    
    % Find row of interest
    prev = t(1,base_col);
    for i = 2:t_size(1)
        if abs(t(i, base_col) - base_val) < 1e-10
            index = i;
            out = 1;
            break;
        elseif abs(prev - base_val) < abs(t(i, base_col) - base_val)
            index = i-1;
            out = 1;
            break;
        end
        prev = t(i, base_col);
    end     
    
    if index == 0
        error("Likely error in function inputs.");
    end
    
    % Get value from cell of interest
    property = t(index, search_col);

end