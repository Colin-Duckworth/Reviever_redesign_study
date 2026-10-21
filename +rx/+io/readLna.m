function lna = readLna(file)
%READLNA LNA datasheet table -> block.
%   lna = rx.io.readLna(file) reads a datasheet CSV (lines starting with #
%   are comments; columns freq_MHz, gain_dB, nf_dB, p1dB_out_dBm, oip3_dBm)
%   into a block, plus the large-signal columns:
%
%       name          model, from the file name up to the first "_"
%                     (ZX60-06183LN+_datasheet.csv -> "ZX60-06183LN+")
%       f_MHz, nf_dB, gain_dB
%       p1dB_out_dBm  output power at 1 dB compression
%       oip3_dBm      output third-order intercept

    t = readtable(file, Delimiter=",", CommentStyle="#", ...
                  VariableNamingRule="preserve");

    need = ["freq_MHz" "gain_dB" "nf_dB" "p1dB_out_dBm" "oip3_dBm"];
    missing = setdiff(need, string(t.Properties.VariableNames));
    if ~isempty(missing)
        error("rx:io:readLna:columns", "%s: missing column(s) %s.", ...
              file, strjoin(missing, ", "));
    end

    [~, stem] = fileparts(file);
    lna.name         = extractBefore(string(stem) + "_", "_");
    lna.f_MHz        = t.freq_MHz;
    lna.nf_dB        = t.nf_dB;
    lna.gain_dB      = t.gain_dB;
    lna.p1dB_out_dBm = t.p1dB_out_dBm;
    lna.oip3_dBm     = t.oip3_dBm;
end
