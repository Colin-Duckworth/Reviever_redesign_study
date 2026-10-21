function out = onGrid(block, f_MHz)
%ONGRID Block -> the same block resampled onto a frequency grid.
%   out = rx.physics.onGrid(block, f_MHz) interpolates nf_dB and gain_dB
%   linearly (in dB) onto f_MHz. Points outside the block's own frequency
%   range are NaN: a block is never extrapolated. Only the common block
%   fields (name, f_MHz, nf_dB, gain_dB) are kept.

    f_MHz = f_MHz(:);
    out.name    = block.name;
    out.f_MHz   = f_MHz;
    out.nf_dB   = interp1(block.f_MHz, block.nf_dB,   f_MHz, "linear", NaN);
    out.gain_dB = interp1(block.f_MHz, block.gain_dB, f_MHz, "linear", NaN);
end
