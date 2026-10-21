# Receiver Redesign Study

System-level comparison of receiver configurations: preselector only, LNA only, preselector + LNA, and a switchable LNA. The study weighs cascaded noise figure (sensitivity) against tolerance of strong blocking signals (selectivity) and ends in a recommended architecture. Background and motivation: [Receiver Redesign ; System-Level Approach.md](Receiver%20Redesign%20;%20System-Level%20Approach.md).

**Status:** Phases 1–3 (noise figure) implemented for the current system and the four preselector/LNA chains. Selectivity (Phase 4) not started.

## Quick start

```matlab
cs_sim                    % current system: front end → SDR
chain_comparison_sim      % preselector / LNA chains vs. the current system, one figure each
runtests('tests')         % 20 tests: Friis cascade, passband IL, Touchstone reader, IF mapping
```

Needs MATLAB R2023b or newer (`xregion`). No toolboxes.

## Signal chain

```
Antenna ─▶ [Preselector] ─▶ [LNA] ─▶ Front end ─┬─ Bypass ──────────────┬─▶ SDR
                                                └─ Downconverter (DC) ──┘
```

The bracketed blocks are optional. Each configuration below sets which blocks are present and their order.

## Applications

| Script | Chain(s) | Outputs in `processed_data/<script>/` |
|--------|----------|---------------------------------------|
| [cs_sim.m](cs_sim.m) | Front end → SDR | `cs_sim.csv`, `cs_nf.png` (system NF with the front-end and SDR NF it is built from) |
| [chain_comparison_sim.m](chain_comparison_sim.m) | `ps_cs`: preselector → CS<br>`lna_cs`: LNA → CS<br>`ps_lna_cs`: preselector → LNA → CS<br>`lna_ps_cs`: LNA → preselector → CS | `chain_comparison_sim.csv`, `preselector_passband.png`, and `<id>_nf.png` per chain (NF against the current system, plus the improvement in dB) |

CS = current system (front end → SDR). Each app also prints a per-band table: min / median / max NF, the improvement over the current system, and the stage that contributes most to the noise. The CSVs have one row per frequency point, with `<id>_nf_dB` and `<id>_gain_to_sdr_dB` per chain.

`lna_ps_cs` is in the comparison as a reference only. It has the best noise figure of the preselector chains, but with a blocker the LNA compresses before the preselector can reject it (Key Considerations 3 of the background doc).

## Modelling assumptions

- **Preselector:** the average insertion loss across the passband of the measured filter state (`000`), extended over the whole band, as if the right filter state is always selected. The passband is the contiguous region within 3 dB of the minimum loss (7375–10520 MHz). The average is taken over frequency in linear units (|S21|²). Result: **IL = 9.60 dB**, so NF = 9.60 dB and gain = −9.60 dB at every frequency.
- **SDR:** the noise figure at **gain 50**, the QuadSAT payload default. It is looked up at the frequency the SDR is tuned to: the RF in bypass, the IF (|RF − LO|) in downconverter mode.
- **Band plan:** the 12000–13250 MHz row of `downconverter_tuning_specs.txt` gives LO 9500 MHz but IFs (3000–4250 MHz) that match LO 9000. The LO is taken as correct, so the IF is 2550–3750 MHz. The code prints a warning for this band on every run.
- **LNA:** datasheet typical values. ZX60-63GLN+ below 6 GHz, ZX60-06183LN+ from 6 GHz. The LNA sits ahead of the front end, so the 6 GHz split doesn't have to line up with the front end's 5.5 GHz bypass/DC hand-over. No LNA covers 1.0–1.8 GHz, so the LNA chains have no result there (16 points).
- **Friis:** all blocks are interpolated (linearly, in dB) onto the front end's 50 MHz grid; nothing is extrapolated. The cascade is done in linear units, and dB is used only for display.

## LNA profiles

Datasheet values at +5 V, +25 °C (Mini-Circuits). The typical-performance tables are in `raw_data/*_datasheet.csv`.

**ZX60-63GLN+ (low band)**
| | |
|---|---|
| Frequency range | 1.8–6 GHz |
| Gain (typ.) | 31.5 dB at 1.8 GHz, falling to 24.5 dB at 6 GHz |
| Noise figure (typ.) | 0.9 dB at 1.8 GHz; 0.8 dB at 2.5–3.5 GHz; 1.5 dB at 6 GHz |
| Output P1dB (typ.) | +15 dBm at 1.8 GHz, falling to +10.2 dBm at 6 GHz |
| Output IP3 (typ.) | +27.8 dBm at 1.8 GHz, falling to +21.7 dBm at 6 GHz |
| Max input power | +10 dBm continuous; +29 dBm for 5 minutes max. |
| Supply | +5 V, 67 mA typ. |

**ZX60-06183LN+ (high band)**
| | |
|---|---|
| Frequency range | 6–18 GHz |
| Gain (typ.) | 21 dB at 6–8 GHz; 20 dB at 8–16 GHz; 19 dB at 16–18 GHz |
| Noise figure (typ.) | 2.2 dB at 6–12 GHz; 2.9 dB at 12–16 GHz; 3.1 dB at 16–18 GHz |
| Output P1dB (typ.) | +14 dBm at 6–8 GHz; +15 dBm at 8–18 GHz |
| Output IP3 (typ.) | +25 dBm at 6–8 GHz; +26 dBm at 8–18 GHz |
| Max input power | +17 dBm CW |
| Supply | +5 V, 110 mA typ. |

**An LNA's maximum input power is a damage limit, not a linearity limit.** The LNA compresses well below it: the input P1dB is roughly output P1dB minus gain, about −9 to −4 dBm for the ZX60-06183LN+ and −17 to −14 dBm for the ZX60-63GLN+ (from the typical-performance tables). So the maximum input power tells you whether the LNA survives a blocker, not whether it keeps working. Phase 4 checks both, and the preselector's rejection is what protects the LNA.

## Raw data

Data as received, in `raw_data/`. These files are not edited; any conditioning happens in code.

| File | Block | Contents |
|------|-------|----------|
| [Geo18_SH_Vpol_nf_gain.csv](raw_data/Geo18_SH_Vpol_nf_gain.csv) | Analog front end | NF and gain vs. frequency, 1–18 GHz in 50 MHz steps, measured with the Signal Hound by the Y-factor method. Columns: `freq_MHz`, `nf_dB`, `gain_dB`, `path` (`bypass` / `downconverter`), `band`. Bypass covers 1000–5450 MHz; the nine downconverter bands cover 5500–18000 MHz. |
| [MYPCB_000.s2p](raw_data/MYPCB_000.s2p) | Preselector PCB | Touchstone S-parameters (real/imaginary, 50 Ω) of the custom preselector PCB with filter state `000` selected, 1–18 GHz, 201 points, measured on an R&S ZNA43. |
| [Z3U_noise_figure_vs_gain_freq.csv](raw_data/Z3U_noise_figure_vs_gain_freq.csv) | SDR (Z3u) | NF vs. frequency at each receiver gain, 100–6000 MHz in 50 MHz steps. One column per gain: `NF_dB_gain_<G>dB` for G = 0, 10, …, 70, 76. Empty cells are points where the Y-factor was too small to measure the NF: every point at gains 0 and 10, about half the points at gain 20. |
| [downconverter_tuning_specs.txt](raw_data/downconverter_tuning_specs.txt) | Downconverter | Band plan: RF start and stop (with the IF at each), LO and filter for each of the nine downconverter bands. |
| [ZX60-63GLN+_datasheet.csv](raw_data/ZX60-63GLN+_datasheet.csv) | Low-band LNA | Datasheet typical performance, 1.8–6 GHz: gain, NF, output P1dB, OIP3, input/output VSWR. |
| [ZX60-06183LN+_datasheet.csv](raw_data/ZX60-06183LN+_datasheet.csv) | High-band LNA | The same, 6–18 GHz. |

Known limits of the data:
- **Negative bypass NF:** a few bypass-path points have NF slightly below 0 dB, which isn't physical (measurement scatter on a low-loss path). They are used as measured. In bypass the SDR contributes over 90% of the system noise, so the effect on the result is small.
- **Coverage:** the front-end data starts at 1 GHz, so the study band is 1–18 GHz.
- **One preselector state only:** `000` covers roughly 7.4–10.5 GHz. Selectivity across the rest of the band needs the S-parameters of the other filter states.

## Project layout

```
Reciever_redesign_study/
├── cs_sim.m                       APPLICATIONS: settings + pipeline, nothing else
├── chain_comparison_sim.m
│
├── +rx/                           SOURCE LIBRARY (MATLAB package)
│   ├── +io/                       files ↔ structs; the only layer that reads or writes files
│   │   ├── readFrontEnd.m           front-end CSV → block (+ path, band per point)
│   │   ├── readSdrNf.m              SDR NF table + one gain → block
│   │   ├── readS2p.m                Touchstone v1 two-port → S-parameters
│   │   ├── readLna.m                LNA datasheet CSV → block (+ P1dB, OIP3)
│   │   ├── readBandPlan.m           downconverter tuning specs → table
│   │   ├── writeCascadeCsv.m        cascade results → CSV (processed_data)
│   │   └── saveFigures.m            figures → .png / .pdf / .fig (processed_data)
│   │
│   ├── +physics/                  the model
│   │   ├── friisCascade.m           ordered blocks → system NF, gain to SDR, per-stage share
│   │   ├── passbandIl.m             S21 → passband edges + average IL
│   │   ├── flatBlock.m              one loss → passive block over the grid (NF = IL)
│   │   ├── onGrid.m                 block → resampled onto a grid (no extrapolation)
│   │   ├── spliceBlocks.m           low-band + high-band block → one block
│   │   ├── ifFrequency.m            RF point → frequency the SDR is tuned to
│   │   └── referToRf.m              SDR block → its NF at each front-end RF point
│   │
│   ├── +plots/                    figures only
│   │   ├── nfTraces.m               several NF traces overlaid
│   │   ├── chainVsBaseline.m        one chain vs. the current system + improvement
│   │   ├── passband.m               S21 with passband and average IL
│   │   └── private/
│   │       └── shadeModes.m           downconverter background shading
│   │
│   ├── +report/                   printed summaries only
│   │   ├── printPassband.m          passband edges, min and average IL
│   │   └── printCascadeSummary.m    per-band NF table per chain
│   │
│   └── +util/
│       ├── toDb.m                   10*log10, NaN for x <= 0
│       └── fromDb.m                 10^(x/10)
│
├── tests/                         matlab.unittest tests: runtests('tests')
│
├── raw_data/                      data as received (see Raw data)
└── processed_data/                app outputs, one folder per app, NOT tracked in git
```

Every block (front end, SDR, preselector, LNA) is a struct with the same fields, `name`, `f_MHz`, `nf_dB` and `gain_dB`, all on one frequency grid. A chain is an ordered cell array of blocks passed to `rx.physics.friisCascade`, so adding or reordering a chain is a one-line change in the app.

## Configurations

| ID | Chain                                          | Purpose                                     | Status |
|----|------------------------------------------------|---------------------------------------------|--------|
| C0 | Front end → SDR                                | Baseline: the product as it stands           | `cs_sim`, `cs` |
| C1 | Preselector → front end → SDR                  | Selectivity with no gain to offset the filter loss | `ps_cs` |
| C2 | LNA → front end → SDR                          | Best sensitivity, no selectivity             | `lna_cs` |
| C3 | Preselector → LNA → front end → SDR            | Main candidate: filter protects the LNA, LNA offsets later stages | `ps_lna_cs` |
| C4 | LNA → preselector → front end → SDR            | Reference only; expected to fail with a blocker | `lna_ps_cs` |
| C5 | LNA inside the DC branch only                  | Gain only where the noise figure is worst    | not yet |
| C6 | Preselector → switchable LNA (LNA / bypass)    | Expected practical answer; the two states are C3 and C1 | not yet (its states are C3 and C1) |

## Plan

### Phase 1: Data conditioning (done)
- Read every block's data from `raw_data/` into one block format, on the front end's grid.
- Map each RF point in DC mode to its IF with the band plan before looking up the SDR NF.

### Phase 2: Cascaded noise figure model (done)
- Friis cascade over frequency for an arbitrary ordered list of blocks:
  $F_{sys} = F_1 + \frac{F_2 - 1}{G_1} + \frac{F_3 - 1}{G_1 G_2} + \dots$
- SDR gain fixed at 50 (payload default).

### Phase 3: Sensitivity comparison (C0–C4 done)
- $NF_{sys}(f)$ and per-stage noise share for each chain, per band.
- Still to do: C5 (LNA in the DC branch only) and C6 (switchable LNA).

### Phase 4: Selectivity / blocker analysis
- Define blocker scenarios: frequency offsets and power levels representative of the operating environment.
- For each configuration, find the blocker level at which the first stage compresses (input-referred), accounting for preselector rejection at the blocker frequency.
- Separately, find the blocker level that would exceed each LNA's maximum input power (damage), with and without the preselector in front.
- Use this to confirm or reject the C4 argument and to set the LNA's large-signal requirements.

### Phase 5: Trade-off and recommendation
- Put sensitivity (NF) and selectivity (blocker tolerance) for every configuration side by side, per mode and per band.
- Recommend an architecture, with the conditions under which each state of a switchable LNA should be used.
- Write the specification for any new hardware (LNA gain, NF, P1dB; preselector loss target).

### Phase 6: Hardware validation (later)
- Re-evaluate the preselector PCB against the simulated requirements; respin if needed.
- Measure the cascaded NF of the chosen configuration with the Y-factor method and compare it with the Phase 3 predictions.

## Open questions
- Which blocker scenarios (frequencies, power levels) are representative?
- Is large-signal data available for the front end and the SDR, or do we use datasheet values?
- Is an LNA needed for 1.0–1.8 GHz, where neither LNA is specified?
- Do we have, or can we measure, the preselector S-parameters for the other filter states?
