classdef test_friisCascade < matlab.unittest.TestCase
    %TEST_FRIISCASCADE Cascaded NF against hand-worked textbook cases.

    methods (TestClassSetup)
        function addProjectToPath(tc)
            tc.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fileparts(fileparts(mfilename("fullpath")))));
        end
    end

    methods (Test)
        function amplifierThenReceiver(tc)
            % F = 2 + (10 - 1)/100 = 2.09
            r = rx.physics.friisCascade({blk("amp", 3.0103, 20), blk("rx", 10, NaN)});
            tc.verifyEqual(r.nf_dB, 10*log10(2.09), AbsTol=1e-3);
            tc.verifyEqual(r.gainToLast_dB, 20, AbsTol=1e-12);
        end

        function lossThenReceiver(tc)
            % 10 dB pad then 3 dB stage: F = 10 + (2 - 1)/0.1 = 20
            r = rx.physics.friisCascade({blk("pad", 10, -10), blk("rx", 3.0103, NaN)});
            tc.verifyEqual(r.nf_dB, 10*log10(20), AbsTol=1e-3);
        end

        function orderMatters(tc)
            % LNA first gives a lower NF than the pad first.
            lna = blk("lna", 2, 20); pad = blk("pad", 9, -9); rx_ = blk("rx", 15, NaN);
            a = rx.physics.friisCascade({lna, pad, rx_});
            b = rx.physics.friisCascade({pad, lna, rx_});
            tc.verifyLessThan(a.nf_dB, b.nf_dB);
        end

        function contributionsSumTo100(tc)
            r = rx.physics.friisCascade({blk("a", 2, 15), blk("b", 6, 10), blk("c", 12, NaN)});
            tc.verifyEqual(sum(r.contrib_pct, 2), 100, AbsTol=1e-9);
            tc.verifyEqual(r.stageNames, ["a" "b" "c"]);
        end

        function nanPropagates(tc)
            a = blk("a", [2; NaN], [20; 20]);
            r = rx.physics.friisCascade({a, blk("rx", [10; 10], [NaN; NaN])});
            tc.verifyFalse(isnan(r.nf_dB(1)));
            tc.verifyTrue(isnan(r.nf_dB(2)));
        end

        function gridMismatchErrors(tc)
            a = blk("a", 2, 20);
            b = blk("b", 10, NaN); b.f_MHz = 2000;
            tc.verifyError(@() rx.physics.friisCascade({a, b}), "rx:physics:friisCascade:grid");
        end

        function nameDefaultsToChain(tc)
            r = rx.physics.friisCascade({blk("a", 2, 20), blk("b", 10, NaN)});
            tc.verifyEqual(r.name, "a → b");
            r = rx.physics.friisCascade({blk("a", 2, 20), blk("b", 10, NaN)}, Id="x", Name="X");
            tc.verifyEqual([r.id r.name], ["x" "X"]);
        end
    end
end

function b = blk(name, nf_dB, gain_dB)
    b.name    = string(name);
    b.f_MHz   = 1000 * (1:numel(nf_dB)).';
    b.nf_dB   = nf_dB(:);
    b.gain_dB = gain_dB(:);
end
