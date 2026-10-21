function sp = readS2p(file)
%READS2P Touchstone v1 two-port file -> S-parameter struct.
%   sp = rx.io.readS2p(file) returns
%
%       f_MHz              frequency, column
%       S11, S21, S12, S22 complex, columns
%       z0                 reference impedance (ohm)
%
%   Handles the option line "# <unit> S <RI|MA|DB> R <z0>" with units
%   HZ/KHZ/MHZ/GHZ, and the Touchstone defaults (GHZ S MA R 50) for any
%   field it leaves out. Comments (!) are ignored; data may wrap over lines.

    lines = readlines(file);

    % Option line: the first line starting with #.
    unit = "GHZ"; format = "MA"; sp.z0 = 50;
    iOpt = find(startsWith(strtrim(lines), "#"), 1);
    if ~isempty(iOpt)
        tok = upper(split(strtrim(extractAfter(strtrim(lines(iOpt)), "#"))));
        tok = tok(tok ~= "");
        for k = 1:numel(tok)
            switch tok(k)
                case {'HZ', 'KHZ', 'MHZ', 'GHZ'}, unit = tok(k);
                case {'RI', 'MA', 'DB'},          format = tok(k);
                case 'S'                          % the only parameter type supported
                case 'R',                         sp.z0 = str2double(tok(k+1));
                case {'Y', 'Z', 'H', 'G'}
                    error("rx:io:readS2p:param", "%s: only S-parameters are supported.", file);
            end
        end
    end

    % Data: everything that is not a comment or the option line.
    data = lines;
    data(startsWith(strtrim(data), "#")) = "";
    hasComment = contains(data, "!");
    data(hasComment) = extractBefore(data(hasComment), "!");
    v = sscanf(char(join(data, " ")), "%f");
    if isempty(v) || mod(numel(v), 9) ~= 0
        error("rx:io:readS2p:data", ...
              "%s: expected 9 numbers per frequency point, got %d numbers.", file, numel(v));
    end
    d = reshape(v, 9, []).';

    toHz = struct("HZ", 1, "KHZ", 1e3, "MHZ", 1e6, "GHZ", 1e9);   % exact, so MHz values stay exact
    sp.f_MHz = d(:, 1) * toHz.(unit) / 1e6;

    toComplex = @(a, b) pair(a, b, format);
    sp.S11 = toComplex(d(:, 2), d(:, 3));
    sp.S21 = toComplex(d(:, 4), d(:, 5));
    sp.S12 = toComplex(d(:, 6), d(:, 7));
    sp.S22 = toComplex(d(:, 8), d(:, 9));
end

function s = pair(a, b, format)
    switch format
        case "RI", s = a + 1i*b;
        case "MA", s = a .* exp(1i*deg2rad(b));
        case "DB", s = 10.^(a/20) .* exp(1i*deg2rad(b));
    end
end
