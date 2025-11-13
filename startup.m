function startup()
    env = pyenv;

    if env.Status == "NotLoaded"
        fprintf('Python not loaded. MATLAB will use system default.\n');
    else
        fprintf('Python: %s\n', env.Executable);
    end

    % Check if CoolProp is available
    try
        py.importlib.import_module('CoolProp');
    catch
        warning('CoolProp not found in Python environment.');
        fprintf(['To install it, run in a terminal or MATLAB Command Window:\n' ...
                 '    system("python -m pip install --user CoolProp")\n']);
    end

    % Quick test
    try
        T = py.CoolProp.CoolProp.PropsSI('T','P',101325,'Q',0,'Water');
        fprintf('CoolProp test OK — Water boiling point: %.2f K\n', double(T));
    catch ME
        warning('CoolProp test failed: %s', ME.message);
    end
end