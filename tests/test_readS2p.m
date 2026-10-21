classdef test_readS2p < matlab.unittest.TestCase
    %TEST_READS2P Touchstone parsing: formats, units, comments, wrapped data.

    methods (TestClassSetup)
        function addProjectToPath(tc)
            tc.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fileparts(fileparts(mfilename("fullpath")))));
        end
    end

    methods (Test)
        function realImaginaryHz(tc)
            file = tc.write([
                "! comment line"
                "# HZ S RI R 50"
                "1e9  0.1 0.2  0.3 -0.4  0.5 0.6  0.7 0.8   ! trailing comment"
                "2e9  0 0  1 0  0 0  0 0"]);
            sp = rx.io.readS2p(file);
            tc.verifyEqual(sp.f_MHz, [1000; 2000]);
            tc.verifyEqual(sp.S21, [0.3 - 0.4i; 1], AbsTol=1e-12);
            tc.verifyEqual(sp.S22(1), 0.7 + 0.8i, AbsTol=1e-12);
            tc.verifyEqual(sp.z0, 50);
        end

        function dbAngleGhzWrapped(tc)
            file = tc.write([
                "# GHZ S DB R 75"
                "9.5  -20 0  -9 90"
                "     -30 0  -25 180"]);
            sp = rx.io.readS2p(file);
            tc.verifyEqual(sp.f_MHz, 9500);
            tc.verifyEqual(abs(sp.S21), 10^(-9/20), AbsTol=1e-12);
            tc.verifyEqual(angle(sp.S21), pi/2, AbsTol=1e-12);
            tc.verifyEqual(sp.z0, 75);
        end

        function defaultsAreGhzMa(tc)
            file = tc.write("1  0.5 0  0.25 180  0 0  0 0");
            sp = rx.io.readS2p(file);
            tc.verifyEqual(sp.f_MHz, 1000);
            tc.verifyEqual(abs(sp.S21), 0.25, AbsTol=1e-12);
            tc.verifyEqual(real(sp.S21), -0.25, AbsTol=1e-12);
        end

        function badCountErrors(tc)
            file = tc.write(["# HZ S RI R 50"; "1e9 0.1 0.2 0.3"]);
            tc.verifyError(@() rx.io.readS2p(file), "rx:io:readS2p:data");
        end
    end

    methods
        function file = write(tc, lines)
            folder = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture).Folder;
            file = fullfile(folder, "t.s2p");
            writelines(lines, file);
        end
    end
end
