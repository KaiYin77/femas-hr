# FemAs HR Daily Check-in Automation

Automated daily check-in script for FemAs Cloud attendance system.

## Features

- Automatic daily check-in to FemAs Cloud
- Skips weekends automatically
- Configurable random delay to avoid detection
- Logs all activities

## Setup

1. **Configure credentials**

   Edit `femas_daily.sh` and update your credentials:
   ```bash
   FEMAS_USER="your_username"
   FEMAS_PASS="your_password"
   ```

2. **Set file permissions**

   ```bash
   chmod 700 femas_daily.sh
   ```

3. **Add to crontab**

   Open crontab editor:
   ```bash
   crontab -e
   ```

   Add this line to run daily at 8:50 AM:
   ```
   50 8 * * * /path/to/femas_daily.sh >> /tmp/femas.log 2>&1
   ```

   Replace `/path/to/` with the actual absolute path to the script.

## Logs

Check the log file to verify the script is running:
```bash
tail -f /tmp/femas.log
```

## How it Works

1. Checks if today is a weekend (skips if Saturday/Sunday)
2. Optional random delay (0-20 minutes, currently disabled)
3. Logs in to FemAs Cloud
4. Performs check-in
5. Logs completion status
