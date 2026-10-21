function writeCascadeCsv(file, fe, results)
%WRITECASCADECSV Cascade results -> CSV (processed_data).
%   rx.io.writeCascadeCsv(file, fe, results) writes one row per frequency
%   point of the front end fe, with columns
%
%       freq_MHz, path, band,
%       <id>_nf_dB, <id>_gain_to_sdr_dB   for each result, in order
%
%   results is a struct array from rx.physics.friisCascade, all on the
%   front end's grid. The folder is created if needed.

    t = table(fe.f_MHz, fe.path, fe.band, VariableNames=["freq_MHz" "path" "band"]);
    for r = results(:).'
        if ~isequal(r.f_MHz, fe.f_MHz)
            error("rx:io:writeCascadeCsv:grid", ...
                  "Result ""%s"" is not on the front end's frequency grid.", r.id);
        end
        t.(char(r.id + "_nf_dB"))          = r.nf_dB;
        t.(char(r.id + "_gain_to_sdr_dB")) = r.gainToLast_dB;
    end

    folder = fileparts(file);
    if folder ~= "" && ~isfolder(folder)
        mkdir(folder);
    end
    writetable(t, file);
    fprintf("Wrote %s\n", file);
end
