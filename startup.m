function startup()
% STARTUP  Sets up Python and CoolProp for this MATLAB project.
% This script is portable: it works across Windows, macOS, and Linux.
% If CoolProp is not installed, it gives users exact instructions to fix it.

fprintf('\n=== MATLAB + CoolProp Setup ===\n');

% --- Step 1: Detect and initialize Python environment ---
env = pyenv;
if env.Status == "Loaded"
    fprintf('Python is already loaded: %s (v%s)\n', env.Executable, env.Version);
else
    fprintf('Python is not yet loaded. MATLAB will use the default system Python.\n');
    try
        % Let MATLAB find a Python automatically
        pyenv('Version', '');
        env = pyenv;
        fprintf('Detected Python: %s (v%s)\n', env.Executable, env.Version);
    catch ME
        warning('MATLAB could not automatically find Python.\n%s', ME.message);
        fprintf(['\nTo install Python:\n',...
                 '  • Windows: Download from https://www.python.org/downloads/\n',...
                 '  • macOS: Use "brew install python3" or download from python.org\n',...
                 '  • Linux: Use your package manager, e.g. "sudo apt install python3"\n']);
        return
    end
end

% --- Step 2: Check if CoolProp is installed ---
hasCoolProp = false;
try
    py.importlib.import_module('CoolProp');
    hasCoolProp = true;
catch
    hasCoolProp = false;
end

% --- Step 3: If missing, guide user through installation ---
if ~hasCoolProp
    fprintf('\n⚠️  CoolProp not found in your Python environment.\n');
    fprintf('Follow these steps to install it:\n\n');

    if ispc
        fprintf('1.  Open Command Prompt (Windows key → "cmd")\n');
        fprintf('2️. Run this command:\n');
        fprintf('      python -m pip install --user -U CoolProp\n');
        fprintf('3️.  Restart MATLAB and rerun "startup"\n');
    elseif ismac
        fprintf('1️. Open Terminal (Cmd + Space → "Terminal")\n');
        fprintf('2️.  Run this command:\n');
        fprintf('      python3 -m pip install --user -U CoolProp\n');
        fprintf('3️.  Restart MATLAB and rerun "startup"\n');
    else
        fprintf('1️.  Open a terminal\n');
        fprintf('2️. Run this command:\n');
        fprintf('      python3 -m pip install --user -U CoolProp\n');
        fprintf('3️. Restart MATLAB and rerun "startup"\n');
    end

    fprintf('\nIf pip is missing, install it first with:\n');
    fprintf('  python -m ensurepip --upgrade\n\n');
    return
end

% --- Step 4: Test CoolProp functionality ---
try
    T = py.CoolProp.CoolProp.PropsSI('T', 'P', 101325, 'Q', 0, 'Water');
    fprintf('\n CoolProp is working correctly.\n');
    fprintf('   Water boiling point at 1 atm: %.2f K\n', double(T));
catch ME
    warning('\nCoolProp import succeeded, but test call failed:\n%s', ME.message);
    fprintf('You might need to reinstall CoolProp or restart MATLAB.\n');
    return
end

fprintf('\n Setup complete. You can now run your MATLAB project.\n');
end
