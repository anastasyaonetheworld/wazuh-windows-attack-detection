# Detection notes and limitations

These rules are transcribed from the original Wazuh 4.9.2 laboratory report as a **reproducibility starting point**, not a production-grade detection pack.

- **100010 / T1564.001:** observed file creation/changes under `C:\Users\Public`. The rule does not explicitly constrain the `Hidden` attribute. Therefore the MITRE mapping describes the lab scenario, not uniquely proven intent from any single file event.
- **100020 / T1547.001:** checks changes to Run-like registry keys. Registry FIM event fields may be exposed as `syscheck.path` (depending on decoder/version); the report's `file` condition should be checked with real `alerts.json` samples and adjusted before relying on it.
- **100030 / T1547.001:** watches a user's Startup directory with FIM. The assigned LogCollector/Sysmon approach was not implemented in the described environment.
- The `Startup` sample path contains a **placeholder account name**; the lab report used a specific Windows user directory.
- The rules use `<if_sid>554,550</if_sid>` and `<if_group>syscheck</if_group>` as in the report. Verify actual parent rule IDs and parsed fields in your local Wazuh version.
- Real-time monitoring of registry changes is not implied by setting `<frequency>60</frequency>`; allow time for the scheduled scan.

## Improvement ideas

1. Match the exact structure of `syscheck.path`, `syscheck.event`, and registry fields from your own alert samples.
2. Distinguish a *hidden file attribute* from merely writing a file into `Public`.
3. Implement optional Sysmon Event IDs and compare FIM vs LogCollector fidelity.
4. Add anonymized screenshots showing the rule ID, agent name and MITRE mapping, after reviewing them for private IPs, usernames, and secrets.
