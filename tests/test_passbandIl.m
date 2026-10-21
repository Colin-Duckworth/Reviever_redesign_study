classdef test_passbandIl < matlab.unittest.TestCase
    %TEST_PASSBANDIL Passband edges and average IL on synthetic filters.

    methods (TestClassSetup)
        function addProjectToPath(tc)
            tc.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fileparts(fileparts(mfilename("fullpath")))));
        end
    end

    methods (Test)
        function flatPassband(tc)
            sp = filter_(1000:1000:18000, [8000 10000], -9);
            pb = rx.physics.passbandIl(sp);
            tc.verifyEqual([pb.fLow_MHz pb.fHigh_MHz], [8000 10000]);
            tc.verifyEqual(pb.ilAvg_dB, 9, AbsTol=1e-9);
            tc.verifyEqual(pb.ilMin_dB, 9, AbsTol=1e-9);
            tc.verifyEqual(nnz(pb.inBand), 3);
        end

        function averageIsLinear(tc)
            % Two points, -8 and -10 dB: average |S21|^2, not average dB.
            f = 1000:1000:18000;
            s21dB = -40 * ones(size(f));
            s21dB(f == 8000) = -8;
            s21dB(f == 9000) = -10;
            sp.f_MHz = f(:);
            sp.S21 = 10.^(s21dB(:)/20);
            pb = rx.physics.passbandIl(sp);
            tc.verifyEqual(pb.ilAvg_dB, -10*log10((10^-0.8 + 10^-1)/2), AbsTol=1e-9);
            tc.verifyEqual(pb.fIlMin_MHz, 8000);
        end

        function onlyContiguousPoints(tc)
            % A second in-threshold peak away from the main one is not in the passband.
            sp = filter_(1000:1000:18000, [8000 10000], -9);
            sp.S21(sp.f_MHz == 15000) = 10^(-10/20);
            pb = rx.physics.passbandIl(sp);
            tc.verifyEqual(pb.fHigh_MHz, 10000);
        end

        function dropSetsWidth(tc)
            f = (1000:1000:18000).';
            sp.f_MHz = f;
            sp.S21 = 10.^(-(9 + abs(f - 9000)/1000)/20);    % 1 dB more loss per GHz off 9 GHz
            pb = rx.physics.passbandIl(sp, 2.5);
            tc.verifyEqual([pb.fLow_MHz pb.fHigh_MHz], [7000 11000]);
        end
    end
end

function sp = filter_(f, band, passDb)
    f = f(:);
    s21dB = -40 * ones(size(f));
    s21dB(f >= band(1) & f <= band(2)) = passDb;
    sp.f_MHz = f;
    sp.S21 = 10.^(s21dB/20);
end
