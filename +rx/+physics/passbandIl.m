function pb = passbandIl(sp, drop_dB)
%PASSBANDIL S21 -> passband edges and average insertion loss.
%   pb = rx.physics.passbandIl(sp, drop_dB) finds the point of minimum
%   insertion loss and extends the passband either side, over contiguous
%   points, while the loss stays within drop_dB of that minimum (default
%   3 dB). The average is taken over frequency in linear units (|S21|^2),
%   then converted to dB. Returns
%
%       fLow_MHz, fHigh_MHz   first and last measured point in the passband
%       ilMin_dB, fIlMin_MHz  minimum loss and where it occurs
%       ilAvg_dB              average loss across the passband
%       drop_dB               the threshold used
%       inBand                logical, per point of sp

    arguments
        sp struct
        drop_dB (1,1) double {mustBePositive} = 3
    end

    p  = abs(sp.S21).^2;
    il = -rx.util.toDb(p);
    [ilMin, k] = min(il);

    within = il <= ilMin + drop_dB;
    lo = find(~within(1:k), 1, "last") + 1;
    if isempty(lo), lo = 1; end
    hi = k - 2 + find(~within(k:end), 1, "first");
    if isempty(hi), hi = numel(il); end

    f = sp.f_MHz(lo:hi);
    if numel(f) > 1
        pAvg = trapz(f, p(lo:hi)) / (f(end) - f(1));
    else
        pAvg = p(lo);
    end

    pb.fLow_MHz   = f(1);
    pb.fHigh_MHz  = f(end);
    pb.ilMin_dB   = ilMin;
    pb.fIlMin_MHz = sp.f_MHz(k);
    pb.ilAvg_dB   = -rx.util.toDb(pAvg);
    pb.drop_dB    = drop_dB;
    pb.inBand     = false(size(il));
    pb.inBand(lo:hi) = true;
end
