classdef test_ifFrequency < matlab.unittest.TestCase
    %TEST_IFFREQUENCY RF -> SDR tuned frequency, and the band plan reader.

    methods (TestClassSetup)
        function addProjectToPath(tc)
            tc.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fileparts(fileparts(mfilename("fullpath")))));
        end
    end

    methods (Test)
        function bypassHighAndLowSide(tc)
            fe = frontEnd();
            fIf = rx.physics.ifFrequency(fe, plan());
            % bypass: RF; 5500-6250 LO 8750 high side; 10750-12000 LO 9000 low side
            tc.verifyEqual(fIf, [5450; 3250; 2500; 1750; 3000]);
        end

        function sharedEdgeUsesBandLabel(tc)
            % 6250 MHz ends one band and starts the next; the label decides.
            fe.f_MHz = [6250; 6250];
            fe.path  = ["downconverter"; "downconverter"];
            fe.band  = ["5500-6250 MHz"; "6250-9000 MHz"];
            p = plan();
            p(end+1, :) = {6250, 4500, 9000, 1750, 10750, 0};
            fIf = rx.physics.ifFrequency(fe, p);
            tc.verifyEqual(fIf, [2500; 4500]);
        end

        function unknownBandErrors(tc)
            fe = frontEnd();
            fe.band(2:3) = "5000-6000 MHz";
            tc.verifyError(@() rx.physics.ifFrequency(fe, plan()), "rx:physics:ifFrequency:band");
        end

        function ifMismatchWarnsAndUsesLo(tc)
            % 12000-13250 MHz with LO 9500 but IFs written for LO 9000.
            fe.f_MHz = [12000; 13250];
            fe.path  = ["downconverter"; "downconverter"];
            fe.band  = ["12000-13250 MHz"; "12000-13250 MHz"];
            p = array2table([12000 3000 13250 4250 9500 1], VariableNames= ...
                ["rfStart_MHz" "ifStart_MHz" "rfStop_MHz" "ifStop_MHz" "lo_MHz" "filter"]);
            fIf = tc.verifyWarning(@() rx.physics.ifFrequency(fe, p), "rx:physics:ifFrequency:range");
            tc.verifyEqual(fIf, [2500; 3750]);
        end

        function readsTuningSpecsFormat(tc)
            folder = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture).Folder;
            file = fullfile(folder, "specs.txt");
            writelines(["Start (IF) [MHz], Stop (IF) [MHz], Lo [MHz], Filter;"
                        "5500 (3250), 6250 (2500), 8750, 3;"
                        "10750 (1750), 12000 (3000), 9000, 1;"], file);
            tc.verifyEqual(rx.io.readBandPlan(file), plan());
        end
    end
end

function fe = frontEnd()
    fe.f_MHz = [5450; 5500; 6250; 10750; 12000];
    fe.path  = ["bypass"; "downconverter"; "downconverter"; "downconverter"; "downconverter"];
    fe.band  = ["1000-6000 MHz"; "5500-6250 MHz"; "5500-6250 MHz"; "10750-12000 MHz"; "10750-12000 MHz"];
end

function p = plan()
    p = array2table([5500 3250 6250 2500 8750 3; 10750 1750 12000 3000 9000 1], VariableNames= ...
        ["rfStart_MHz" "ifStart_MHz" "rfStop_MHz" "ifStop_MHz" "lo_MHz" "filter"]);
end
