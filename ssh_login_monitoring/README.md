# SSH Login Monitoring with Zabbix

This project provides a solution for logging and monitoring SSH login activities using a bash script and Zabbix. It captures details of new SSH sessions and sends them to a Zabbix server for monitoring and analysis.

## Overview

The project consists of:
- A bash script (`ssh_logger.sh`) that logs SSH login details.
- A PAM configuration to trigger the script on new SSH sessions.
- A Zabbix agent configuration to monitor the log file and send data to a Zabbix server.

## Components

### 1. SSH Logger Script
The script `/usr/local/bin/ssh_logger.sh` logs details of SSH sessions, including:
- Username
- Source IP address
- Timestamp
- Hostname
- Service name
- TTY

**Script Location**: `/usr/local/bin/ssh_logger.sh`

### 2. PAM Configuration
The script is integrated with the system's PAM configuration to execute on new SSH sessions.

**Configuration**:
Add the following line to the appropriate PAM configuration file (e.g., `/etc/pam.d/sshd`):
```
session required pam_exec.so /usr/local/bin/ssh_logger.sh
```

This ensures the script runs whenever a new SSH session is opened.

### 3. Zabbix Agent Configuration
The Zabbix agent monitors the log file and sends SSH login events to the Zabbix server.

**Zabbix Item Configuration**:
- **Type**: Zabbix Agent (Active)
- **Key**: `log[/var/log/zabbix-ssh-logins.log,"User: ",,,skip]`
- **Log File**: `/var/log/zabbix-ssh-logins.log`

The `skip` parameter ensures that only new log entries are processed, avoiding duplicate data.

**Zabbix Agent Configuration File**:
To allow the Zabbix agent to monitor the log file, add the following parameter to `/etc/zabbix/zabbix_agent2.conf`:
```
AllowKey=log[*]
```

This enables the agent to process log items with the specified key pattern.

## How It Works
1. When a user logs in via SSH, the PAM module triggers the `ssh_logger.sh` script.
2. The script appends login details (username, IP, timestamp, etc.) to `/var/log/zabbix-ssh-logins.log`.
3. The Zabbix agent actively monitors the log file and sends new entries to the Zabbix server for storage and analysis.

## Prerequisites
- A Linux system with PAM and SSH configured.
- Zabbix agent (version 2 or later) installed and configured to communicate with a Zabbix server.
- Write permissions for the Zabbix agent to access `/var/log/zabbix-ssh-logins.log`.
- Execute permissions for `/usr/local/bin/ssh_logger.sh`.

## Installation
1. **Create the Script**:
   - Save the script content to `/usr/local/bin/ssh_logger.sh`.
   - Make it executable:
     ```bash
     chmod +x /usr/local/bin/ssh_logger.sh
     ```

2. **Configure PAM**:
   - Add the PAM configuration line to `/etc/pam.d/sshd` or the relevant PAM file.

3. **Set Up Log File**:
   - Ensure the log file `/var/log/zabbix-ssh-logins.log` exists and is writable by the Zabbix agent:
     ```bash
     touch /var/log/zabbix-ssh-logins.log
     chown zabbix:zabbix /var/log/zabbix-ssh-logins.log
     chmod 640 /var/log/zabbix-ssh-logins.log
     ```

4. **Configure Zabbix Agent**:
   - Add the `AllowKey=log[*]` parameter to `/etc/zabbix/zabbix_agent2.conf`.
   - Restart the Zabbix agent to apply changes:
     ```bash
     systemctl restart zabbix-agent2
     ```

5. **Add Zabbix Item**:
   Follow these steps to configure the Zabbix item for monitoring SSH logins:
   - **Access the Zabbix Frontend**:
     - Log in to the Zabbix web interface (e.g., `http://your-zabbix-server/zabbix`).
   - **Navigate to Item Configuration**:
     - Go to **Configuration** > **Hosts** (or **Templates** if using a template).
     - Select the host where the Zabbix agent is installed.
     - Click on **Items**, then click **Create item**.
   - **Configure Item Details**:
     - **Name**: Enter a descriptive name, e.g., `SSH Login Events`.
     - **Type**: Select **Zabbix agent (active)** to enable the agent to push data to the server.
     - **Key**: Use:
       ```
       log[/var/log/zabbix-ssh-logins.log,"User: ",,,skip]
       ```
       - `log[]`: Specifies log file monitoring.
       - `/var/log/zabbix-ssh-logins.log`: Path to the log file.
       - `"User: "`: Matches lines starting with "User: " to filter relevant entries.
       - `,,,`: Optional parameters (encoding, max lines, mode) left as defaults.
       - `skip`: Processes only new log entries, skipping previously read lines.
     - **Type of information**: Select **Log**.
     - **Update interval**: Set to `60s` for frequent checks without overloading the system.
     - **History storage period**: Set to a suitable duration, e.g., `30d` (30 days).
     - **Applications** (optional): Assign to a group like `SSH Monitoring`.
     - **Enabled**: Ensure the item is enabled.
   - **Save the Item**:
     - Click **Add** to save the configuration.
   - **Test the Item**:
     - Initiate an SSH login to the monitored server.
     - Check **Monitoring** > **Latest data** in the Zabbix frontend to verify that log entries (e.g., `User: <username> | IP: <ip> | Time: <timestamp> | ...`) appear for the item.

## Usage
- Once configured, the system automatically logs all new SSH sessions to `/var/log/zabbix-ssh-logins.log`.
- The Zabbix server receives and stores these logs for monitoring, alerting, or reporting purposes.

## Notes
- **Active Mode**: Ensure the Zabbix agent is configured for active checks by setting `ServerActive` in `/etc/zabbix/zabbix_agent2.conf` to the Zabbix server’s IP or hostname.
- **Log File Permissions**: Verify that the Zabbix agent can read `/var/log/zabbix-ssh-logins.log`:
  ```bash
  ls -l /var/log/zabbix-ssh-logins.log
  ```
  The file should be owned by `zabbix:zabbix` with permissions like `640`.
- **Log Rotation**: Configure log rotation for `/var/log/zabbix-ssh-logins.log` to manage disk space, e.g., using `logrotate`:
  ```bash
  /var/log/zabbix-ssh-logins.log {
      daily
      rotate 7
      compress
      missingok
      notifempty
      create 640 zabbix zabbix
  }
  ```
- **Troubleshooting**:
  - Check Zabbix agent logs (`/var/log/zabbix/zabbix_agent2.log`) for errors if no data appears.
  - Verify that `ssh_logger.sh` is writing to the log file.
  - Ensure the PAM configuration in `/etc/pam.d/sshd` is correctly set up.
- **Enhancements**:
  - Add triggers in Zabbix for alerts on specific conditions (e.g., multiple logins from the same IP).
  - Use Zabbix dashboards to visualize SSH login activity.
  - Create a Zabbix template to apply this configuration to multiple hosts.
