function printPassband(pb, name)
%PRINTPASSBAND Passband edges and losses, and the preselector model they give.
%   rx.report.printPassband(pb, name) prints the result of
%   rx.physics.passbandIl for the S-parameter set called name.

    fprintf("\nPreselector passband: %s\n", name);
    fprintf("  Passband (within %g dB of minimum): %.0f-%.0f MHz\n", ...
            pb.drop_dB, pb.fLow_MHz, pb.fHigh_MHz);
    fprintf("  Minimum IL:  %.2f dB at %.0f MHz\n", pb.ilMin_dB, pb.fIlMin_MHz);
    fprintf("  Average IL:  %.2f dB\n", pb.ilAvg_dB);
    fprintf("  Model: NF = %.2f dB, gain = %.2f dB at every frequency\n", ...
            pb.ilAvg_dB, -pb.ilAvg_dB);
end
