PR0FYLER – GeneMapper Electropherogram Exporter
Version 1.01
Overview

PR0FYLER is an automated tool designed to streamline the export of electropherogram plots from Applied Biosystems GeneMapper. It simplifies the workflow used in forensic DNA laboratories by collecting user credentials, locating the GeneMapper executable, running the export process, and organizing the generated files.

This tool was developed for the Laboratory of Biology and Forensic DNA – Goiás State Forensic Police (PCI/GO).

Key Features

Secure input for username and password

Automatic detection of GeneMapper installation

Smart search across system drives

Option for manual path selection in case automatic detection fails

Automatic creation of an export folder based on the project name

Direct execution of GeneMapper with export parameters

Log file generation for audit and troubleshooting

Compatible with multiple GeneMapper versions and directories

Workflow Summary
1. User Input

The tool asks for the username, password (securely), and project name.
All fields must be provided before proceeding.

2. Automatic Search for GeneMapper

The tool attempts to locate the GeneMapper executable using a two-step approach:

A quick check in common default installation paths

A full drive scan across all connected disks (excluding C:)

If GeneMapper cannot be located automatically, the user may provide the installation folder manually.

3. Validation

The discovered or manually provided path is analyzed to ensure that GeneMapper is present and ready to run.
If the file cannot be validated, the tool stops and displays an error message.

4. Export Folder Creation

A dedicated folder with the project’s name is created on the user’s desktop.
All exported electropherogram files and logs will be saved inside this folder.

5. Execution

The tool runs GeneMapper using command-line parameters to automate the project export.
All activity is recorded in a log file stored inside the project’s export folder.

6. Completion

When processing is finished, the tool informs:

The location of the exported files

The location of the log file

The user is prompted before closing.

Output

After execution, the user will find:

Electropherogram PDF files

Execution log

inside a folder named after the project, located on the desktop.

Requirements

Windows environment

Applied Biosystems GeneMapper installed

PowerShell available (default in Windows)

Purpose

PR0FYLER ensures a faster, more reliable, and user-friendly method for exporting electropherograms, avoiding repetitive manual operations and reducing errors in forensic DNA workflows.
