# Windows Attack Detection with Wazuh

A small Wazuh setup for monitoring common persistence and file-hiding activity on a Windows host. It uses file integrity monitoring (FIM), custom detection rules, and MITRE ATT&CK mappings.

The project covers three cases:

- Changes to files in `C:\Users\Public`, including the creation of hidden files.
- Changes to the `Run` and `RunOnce` registry keys used for startup persistence.
- Files created or modified in a user's Startup folder.

## Environment

| Component | Setup |
| --- | --- |
| Wazuh server | Debian 12, Wazuh 4.9.2 (all-in-one) |
| Endpoint | Windows with Wazuh Agent 4.9.2 |
| Network | VirtualBox Host-Only (`192.168.56.0/24`) |
| Server IP | `192.168.56.10` |
| Agent name | `host-win` |

The IP addresses and paths below match this setup. Change them to fit your environment.

## Install the Wazuh server

On Debian 12, run:

```bash
su -
curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh
bash wazuh-install.sh -a
```

If the graphical session interferes with installation, it can be stopped with `systemctl stop gdm3` before running the installer.

Keep the generated `admin` password somewhere private. The dashboard is available at `https://192.168.56.10` once installation is complete.

Check the services:

```bash
systemctl status wazuh-manager wazuh-indexer wazuh-dashboard filebeat
```

## Install the Windows agent

Open PowerShell as Administrator:

```powershell
Invoke-WebRequest -Uri 'https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.2-1.msi' -OutFile "$env:TEMP\wazuh-agent.msi"
msiexec.exe /i "$env:TEMP\wazuh-agent.msi" /q WAZUH_MANAGER="192.168.56.10" WAZUH_AGENT_NAME="host-win"
Start-Service WazuhSvc
Get-Service WazuhSvc
```

The agent should appear as **Active** in the Wazuh dashboard.

## Configure monitoring

On Windows, open:

```text
C:\Program Files (x86)\ossec-agent\ossec.conf
```

The settings in [`configs/agent/syscheck-snippet.xml`](configs/agent/syscheck-snippet.xml) enable monitoring for `C:\Users\Public`, the registry startup keys, and the user's Startup folder.

Copy the entries **inside** the existing `<syscheck>` section in `ossec.conf`. Do not create a second `<syscheck>` section. Replace `LAB_USER` with the actual Windows username.

Restart the agent after saving the file:

```powershell
Restart-Service WazuhSvc
```

On Debian, merge [`configs/manager/local_rules.xml`](configs/manager/local_rules.xml) into:

```text
/var/ossec/etc/rules/local_rules.xml
```

Check that the rule IDs are not already in use, then restart the manager:

```bash
systemctl restart wazuh-manager
```

## Detection rules

| Rule | Monitored activity | ATT&CK technique |
| --- | --- | --- |
| `100010` | File changes in `C:\Users\Public` | [T1564.001](https://attack.mitre.org/techniques/T1564/001/) |
| `100020` | Changes to `Run` / `RunOnce` registry keys | [T1547.001](https://attack.mitre.org/techniques/T1547/001/) |
| `100030` | File changes in the Startup folder | [T1547.001](https://attack.mitre.org/techniques/T1547/001/) |

These are deliberately simple rules. In particular, `100010` matches changes in the Public directory; it does not check the Hidden attribute itself. The Startup folder is monitored through FIM, without Sysmon.

The registry rule may need adjustment depending on the fields produced by your Wazuh version. Review the alert JSON and confirm that the custom rules match before using them beyond this setup.

## Test the detections

The [`tests`](tests/) directory contains PowerShell scripts that make harmless changes on the Windows machine:

```powershell
.\tests\01-public-hidden.ps1
.\tests\02-run-key.ps1
.\tests\03-startup-file.ps1
```

Run the commands from the repository root, one at a time. The registry test needs an elevated PowerShell session. Each script prints the command needed to remove what it created.

You can inspect the resulting events in the Wazuh dashboard or read the alerts directly on Debian:

```bash
tail -f /var/ossec/logs/alerts/alerts.json | grep --line-buffered -a '100010'
grep -a -iE '100020|WazuhLabDemo' /var/ossec/logs/alerts/alerts.json | tail -10
grep -a '100030' /var/ossec/logs/alerts/alerts.json | tail -5
```

If an event doesn't match, inspect the corresponding `syscheck` fields in `alerts.json` and compare them with the rule conditions. See [detection notes](docs/detection-notes.md) for known limitations.

## Repository contents

```text
configs/
  agent/syscheck-snippet.xml
  manager/local_rules.xml
tests/
  01-public-hidden.ps1
  02-run-key.ps1
  03-startup-file.ps1
docs/
  setup.md
  detection-notes.md
```

This repository records a setup built with Wazuh 4.9.2. For a new deployment, check the current Wazuh documentation and supported versions. Keep passwords, certificates and unredacted alert logs out of Git.
