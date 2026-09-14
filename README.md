# PR0FYLER – GeneMapper Electropherogram Exporter

### Version 1.05

## Overview

PR0FYLER is a Windows batch tool designed to automate the export of electropherogram plots from Applied Biosystems GeneMapper. It streamlines workflows in forensic DNA laboratories by collecting the required login information, closing existing GeneMapper instances, locating the GeneMapper executable, processing one or more projects, and organizing the exported files.

The current version has been tested with GeneMapper ID-X 1.6 in both Client and Full installations.

---

## Key Features

- Hidden password entry through PowerShell
- Support for exporting multiple projects in a single run
- Automatic attempt to close running GeneMapper instances
- Automatic search for GeneMapper in common Applied Biosystems installation directories
- Search across connected file-system drives
- Manual fallback for specifying the full GeneMapper executable path
- Support for Windows PowerShell and manually specified PowerShell 7 installations
- Automatic detection of the Windows Desktop folder
- Automatic creation of a separate export folder for each project
- Automated execution of GeneMapper using command-line parameters
- Separate execution log for each project
- Verification that PDF files were generated
- Support for different GeneMapper executable names and installation directories

---

## Quick Guide

1. Download **PR0FYLER.bat**.
2. Make sure the correct Default Database is configured in GeneMapper.
3. Save any work currently open in GeneMapper.
4. Run **PR0FYLER.bat**.
5. Enter your GeneMapper username and password.
6. Enter one or more GeneMapper project names. Separate multiple project names with commas.
7. Wait for PR0FYLER to complete the export.
8. Find the project folders containing the exported PDF and log files on your Desktop.

---

## Workflow Summary

Before you begin, download the **PR0FYLER.bat** file and double-click it to run.


### 1. User Input
The tool requests:
- Username  
- Password
- Project name  

### 2. Automatic Search for GeneMapper
The tool searches for the GeneMapper.exe executable using:
- A fast scan of common installation directories  
- A deeper scan of all connected drives (excluding C:)
- If the GeneMapper.exe executable cannot be found automatically, the user may provide the installation path manually directly on the screen. 
- Make sure the full path, with the .exe file name in it, is typed (e.g. C:\AppliedBiosystems\GeneMapperID-X\Client\app\genemapperidx16.exe).

### 3. Export Folder Creation
A folder named after the project is created on the user’s Desktop.  
All exported electropherogram files and the execution log will be placed in this folder.

### 4. Execution
The tool runs GeneMapper using command-line arguments to automate the export process.  
All activity and potential errors are written to a log file stored inside the project folder.

---

## Output
After execution, the project folder on the Desktop contains:
- Electropherogram PDF files  
- A full execution log  

---

## Requirements
- Windows operating system  
- Applied Biosystems GeneMapper installed  
- PowerShell (included by default in Windows)

---

  ## Author
Paulo B. Chaves  
Laboratório de Biologia e DNA Forense  
Polícia Científica de Goiás, Brazil (PCI/GO)  
paulo.bchaves@goias.gov.br

---

## Purpose
PR0FYLER supports a faster, more reliable, and user-friendly method for exporting electropherograms, reducing repetitive manual tasks and minimizing errors in forensic DNA analysis workflows.

---

  ## Version history
- 1.01: Initial release (09/12/2025). 
- 1.02: Updated the command prompt title (17/12/2025).
- 1.03: Changed language to English | Added initial warnings | Improved login credentials module | Fixed user-provided executable path routine (19/08/2026).
- 1.041: Added the option to export more than one project at the same time (use commas to separate project names) | Minor additional improvements (08/09/2026).
- 1.05: PR0FYLER attempts to close GeneMapper before it starts running (11/09/2026).
