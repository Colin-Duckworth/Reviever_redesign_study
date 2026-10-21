### Internship Objective

The primary internship objective, as originally stated:

> **Primary Objective:** Investigate the feasibility of adding a preselector to the current product, optionally in combination with a Low Noise Amplifier (LNA), and assess the trade-offs between noise figure and resistance to powerful blocking signals (selectivity).
> 
> - Start in simulation, investigating different scenarios such as preselector only, preselector with LNA, and LNA only. Assess and document the findings.
> - Re-evaluate the existing preselector PCB assembly and update the design based on design guidelines and/or simulated parameters. Another spin will be manufactured if required.
> - Implement a suitable method for measuring the cascaded noise figure of the system. This method should be used to experimentally validate the cascaded noise figure with a preselector and/or LNA present. A calibrated noise source will be acquired if necessary. Optionally, the cascaded noise figure measurement can be automated.

### Progress to Date

The first half of the internship focused on building the infrastructure and collecting the data needed to carry out this objective. With that foundation in place, the comparative analysis can now begin. The following data is currently available:

- **Analog front end:** $NF(f)$ and $G(f)$ across the entire operating band
- **Preselector module (custom):** $S(f)$
- **SDR (final receiver stage):** $NF(f, G)$
- **Candidate LNA:** $NF(f)$ and $G(f)$

### Key Considerations

Using this data, the possible system configurations can be compared. Before doing so, several nuances are worth noting.

**1. The front end operates in two distinct modes:**

- **Bypass mode:** The downconverter is not used. The front end provides no gain, and its NF/IL is 1.5–2 dB.
- **Downconverter (DC) mode:** A satcom downconverter is used. The NF is between 13 and 20 dB, and the gain varies from −5 to +5 dB.

This suggests that an LNA may be most practical in the DC branch alone and may not be strictly necessary in the bypass branch. However, the SDR’s 8 dB noise figure is still significant in bypass mode.

**2. Current performance:** As the product stands, it has both poor sensitivity and poor selectivity.

**3. LNA placement relative to the preselector:** In an LNA → preselector → front end configuration, the preselector loses its value. In the presence of a blocker, the LNA’s small-signal gain collapses before the preselector can reject the interferer, which renders the preselector ineffective in this arrangement.

**4. Preselector loss:** The preselector has a high intrinsic loss of 8–10 dB in the passband. This effectively sets a floor on the lowest achievable system NF.

**5. Switchable LNA:** Making the LNA switchable with a bypass path may be the most practical solution.