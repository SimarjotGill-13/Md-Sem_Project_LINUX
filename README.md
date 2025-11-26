# Daily User Log Archiver

## Project Overview
This project is a **Shell Script Automation Tool** that logs key system information on macOS/Linux every day, archives old logs, and keeps a record of weekly summaries.  
It is created as part of the **Mid Term Project – Linux Lab** assignment.

---

## Goal
To create a shell script that:
- Logs **system information** (user, date, running processes, disk usage)
- Rotates and archives old logs weekly
- Schedules itself to run **daily** using 'plist' instead of `cron`.
- Implements **error handling** for missing directories and files

---

## Features Implemented

### Identify User
Uses:
```bash
whoami 


# Mid-Sem-Project-LINUX
