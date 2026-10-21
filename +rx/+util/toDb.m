function y = toDb(x)
%TODB Power ratio -> dB: 10*log10(x), NaN for x <= 0.
    y = 10*log10(x);
    y(x <= 0) = NaN;
end
