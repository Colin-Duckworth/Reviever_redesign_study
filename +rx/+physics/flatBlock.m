function blk = flatBlock(name, il_dB, f_MHz)
%FLATBLOCK Passive block with one loss over the whole grid.
%   blk = rx.physics.flatBlock(name, il_dB, f_MHz) is a matched passive
%   block at 290 K: NF = IL and gain = -IL at every frequency. Used for the
%   preselector, whose passband loss is extended across the band (as if the
%   right filter state is always selected).

    f_MHz = f_MHz(:);
    blk.name    = name;
    blk.f_MHz   = f_MHz;
    blk.nf_dB   = repmat(il_dB, size(f_MHz));
    blk.gain_dB = repmat(-il_dB, size(f_MHz));
end
