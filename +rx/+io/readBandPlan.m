function plan = readBandPlan(file)
%READBANDPLAN Downconverter tuning specs -> table, one row per band.
%   plan = rx.io.readBandPlan(file) reads lines of the form
%
%       5500 (3250), 6250 (2500), 8750, 3;
%       RF start (IF at start), RF stop (IF at stop), LO, filter
%
%   into a table with variables rfStart_MHz, ifStart_MHz, rfStop_MHz,
%   ifStop_MHz, lo_MHz, filter. Lines without digits (the header) are
%   skipped; any other line must hold exactly six numbers.

    lines = strtrim(readlines(file));
    rows = zeros(0, 6);
    for k = 1:numel(lines)
        nums = str2double(regexp(lines(k), "-?\d+(\.\d+)?", "match"));
        if isempty(nums)
            continue
        end
        if numel(nums) ~= 6
            error("rx:io:readBandPlan:line", ...
                  "%s, line %d: expected 6 numbers, got %d: ""%s"".", ...
                  file, k, numel(nums), lines(k));
        end
        rows(end+1, :) = nums; %#ok<AGROW>
    end

    plan = array2table(rows, VariableNames= ...
        ["rfStart_MHz" "ifStart_MHz" "rfStop_MHz" "ifStop_MHz" "lo_MHz" "filter"]);
end
