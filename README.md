## How It Works

### 1. Bootstrapping (`setup_project.sh`)

Running the script prompts for a project name and creates the full directory structure shown above (`{name}` is substituted into `attendance_tracker_{name}/`). It then asks whether to update the default attendance thresholds (Warning: 75%, Failure: 50%); if yes, it reads the new values, validates they're numeric, and uses `sed` to edit `config.json` in place. Finally, it runs a health check confirming `python3` is installed and that the directory structure is intact.

Run it with:
```bash
chmod +x setup_project.sh
./setup_project.sh
```

### 2. Attendance Logic (`attendance_checker.py`)

The Python script:
- Loads thresholds from `Helpers/config.json`
- Loads student records from `Helpers/assets.csv` (columns: `student_id`, `student_name`, `total_classes`, `classes_attended`)
- Calculates each student's attendance percentage
- Classifies each student as `OK`, `WARNING`, or `FAIL` based on the configured thresholds
- Appends a timestamped summary report to `reports/reports.log`

Run it with:
```bash
python3 attendance_checker.py
```

### 3. Signal Handling (The Trap)

`setup_project.sh` traps `SIGINT` (Ctrl+C). If the user interrupts the script mid-execution:
1. The current state of the project directory is archived into `attendance_tracker_{name}_archive.tar.gz`
2. The original, incomplete project directory is deleted to keep the workspace clean
3. The script exits gracefully with a confirmation message

This was tested by running the script and pressing Ctrl+C partway through setup, then confirming the archive was created and the incomplete folder was removed.

### 4. Environment Validation

Before finishing, the script performs a health check:
- Verifies `python3` is installed by running `python3 --version`
- Prints a success message if found, or a warning if missing
- Confirms the expected directory structure exists

## Requirements

- Bash
- Python 3

## Usage Summary

1. Run `./setup_project.sh` and provide a project name
2. Optionally update thresholds when prompted
3. `cd` into the generated `attendance_tracker_{name}/` directory
4. Run `python3 attendance_checker.py` to generate an attendance report
5. Check `reports/reports.log` for results

## Notes

- Interrupting the bootstrap script (Ctrl+C) safely archives and removes any partially created project directory
- Thresholds can be re-edited directly in `Helpers/config.json` at any time without rerunning the full setup
