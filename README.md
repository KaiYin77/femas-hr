# Femas HR Daily Check-in/Check-out Automation

Automated daily check-in and check-out scripts for Femas Cloud attendance system.

## Features

- Automatic daily check-in and check-out to Femas Cloud
- Customizable check-in and check-out times
- Skips weekends and Taiwan national holidays automatically
- Configurable random delay to avoid detection
- Logs all activities
- 3-step process: clock listing → revision save → attendance status verification

## Quick Start (Windows)

### Installation

1. **Right-click `install.bat`** → **Run as Administrator**
2. Enter your Femas username and password
3. Set your check-in time (e.g., 08:50)
4. Set your check-out time (e.g., 19:00)
5. Done! Tasks are now registered in Task Scheduler

### Uninstallation

1. **Right-click `uninstall.bat`** → **Run as Administrator**
2. Confirm to remove scheduled tasks

## Verify Installation

**View tasks in Task Scheduler:**
- Press `Win` key → Search "Task Scheduler"
- Look for "FemasHR Check-in" and "FemasHR Check-out"

**Or use command line:**
```batch
schtasks /Query /TN "FemasHR Check-in"
schtasks /Query /TN "FemasHR Check-out"
```

## Manual Testing

Test the scripts before relying on automation:
```batch
checkin.bat   # Test check-in
checkout.bat  # Test check-out
```

## View Logs

Open in Notepad:
```
%TEMP%\femas_checkin.log
%TEMP%\femas_checkout.log
```

Or view in PowerShell:
```powershell
Get-Content $env:TEMP\femas_checkin.log -Tail 20
Get-Content $env:TEMP\femas_checkout.log -Tail 20
```

## How it Works

Both scripts follow the same 3-step process:

1. Checks if today is a weekend or Taiwan national holiday (skips if yes)
2. Optional random delay (0-20 minutes, currently disabled)
3. Logs in to Femas Cloud
4. **Step 1**: POST to `Users/clock_listing` with clock data (clock_type: S for check-in, E for check-out)
5. **Step 2**: POST to `revision_save` with pk parameter
6. **Step 3**: GET to `att_status_listing` for verification
7. Logs out and cleans up cookies

## Holiday Detection

The system automatically skips:
- **Weekends**: Saturday and Sunday
- **Taiwan National Holidays**: Spring Festival, Tomb Sweeping Day, Dragon Boat Festival, Mid-Autumn Festival, National Day, etc.

**Update holidays for new years:**
Edit `check_holiday.sh` and update the `HOLIDAYS_XXXX` arrays. Taiwan national holidays are usually announced by the government in the previous year.

## Security Note

- Credentials are stored in `.env` file (auto-created by install.bat)
- The `.env` file is excluded from git via `.gitignore`
- **Never commit your `.env` file to version control**
