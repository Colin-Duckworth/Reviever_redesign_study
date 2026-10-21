function out = referToRf(sdr, fe, plan)
%REFERTORF SDR block -> the SDR's NF at each front-end RF point.
%   out = rx.physics.referToRf(sdr, fe, plan) looks up the SDR noise figure
%   at the frequency the SDR is tuned to for each RF point of the front end
%   (the RF in bypass, the IF in downconverter mode, see ifFrequency) and
%   returns it as a block on the front end's RF grid, ready to cascade.

    out = rx.physics.onGrid(sdr, rx.physics.ifFrequency(fe, plan));
    out.f_MHz = fe.f_MHz;
end
