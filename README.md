# Femas HR Daily Check-in/Check-out Automation

Automated daily check-in and check-out scripts for Femas Cloud attendance system.

## Features

- Automatic daily check-in and check-out to Femas Cloud
- Check-in at 8:50 AM, Check-out at 7:00 PM
- Skips weekends automatically
- Configurable random delay to avoid detection
- Logs all activities
- 3-step process: clock listing → revision save → attendance status verification

## Setup

1. **Configure credentials**

   Create a `.env` file from the example:
   ```bash
   # Copy the example file
   cp .env.example .env

   # Edit .env and fill in your credentials
   # FEMAS_USER="your_username"
   # FEMAS_PASS="your_password"
   ```

   **Security Note:**
   - The `.env` file is excluded from git via `.gitignore`
   - Never commit your `.env` file to version control
   - Keep `.env.example` for reference (without real credentials)

2. **Set file permissions (Linux/Mac only)**

   ```bash
   chmod 700 femas_checkin.sh
   chmod 700 femas_checkout.sh
   ```

3. **Schedule automation**

   ### For Linux/Mac (crontab):

   ```bash
   crontab -e
   ```

   Add these lines:
   ```
   # Check-in at 8:50 AM
   50 8 * * * /path/to/femas_checkin.sh >> /tmp/femas_checkin.log 2>&1

   # Check-out at 7:00 PM
   0 19 * * * /path/to/femas_checkout.sh >> /tmp/femas_checkout.log 2>&1
   ```

   ### For Windows (Task Scheduler):

   **Using PowerShell (Quick setup):**
   ```powershell
   # Run PowerShell as Administrator, then run:

   # Check-in task (8:50 AM)
   $action = New-ScheduledTaskAction -Execute "C:\Users\user\Documents\github\repo-main\femas-hr\checkin.bat"
   $trigger = New-ScheduledTaskTrigger -Daily -At 8:50AM
   Register-ScheduledTask -TaskName "Femas Check-in" -Action $action -Trigger $trigger

   # Check-out task (7:00 PM)
   $action = New-ScheduledTaskAction -Execute "C:\Users\user\Documents\github\repo-main\femas-hr\checkout.bat"
   $trigger = New-ScheduledTaskTrigger -Daily -At 7:00PM
   Register-ScheduledTask -TaskName "Femas Check-out" -Action $action -Trigger $trigger
   ```

   **View scheduled tasks:**
   ```powershell
   Get-ScheduledTask | Where-Object {$_.TaskName -like "*Femas*"}
   ```

## Logs

**Linux/Mac:**
```bash
tail -f /tmp/femas_checkin.log
tail -f /tmp/femas_checkout.log
```

**Windows:**
```powershell
# Log files are in your TEMP folder
Get-Content $env:TEMP\femas_checkin.log -Tail 20 -Wait
Get-Content $env:TEMP\femas_checkout.log -Tail 20 -Wait
```

Or open them in Notepad:
```
%TEMP%\femas_checkin.log
%TEMP%\femas_checkout.log
```

## Schedule

- **Check-in**: 8:50 AM (Monday - Friday)
- **Check-out**: 7:00 PM (Monday - Friday)
- Weekends are automatically skipped

## How it Works

Both scripts follow the same 3-step process:

1. Checks if today is a weekend (skips if Saturday/Sunday)
2. Optional random delay (0-20 minutes, currently disabled)
3. Logs in to Femas Cloud
4. **Step 1**: POST to `Users/clock_listing` with clock data (clock_type: S for check-in, E for check-out)
5. **Step 2**: POST to `revision_save` with pk parameter
6. **Step 3**: GET to `att_status_listing` for verification
7. Logs out and cleans up cookies
