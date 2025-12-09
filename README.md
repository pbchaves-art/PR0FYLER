# PR0FYLER – GeneMapper Electropherogram Exporter
### Version 1.01

## Overview
PR0FYLER is an automated tool designed to streamline the export of electropherogram plots from Applied Biosystems GeneMapper. It simplifies the workflow used in forensic DNA laboratories by collecting user credentials, locating the GeneMapper executable, running the export process, and organizing the generated files.

---

## Key Features
- Secure input for username and password  
- Automatic detection of GeneMapper installation  
- Smart search across system drives  
- Manual fallback option for specifying the installation directory  
- Automatic creation of a project-based export folder on the Desktop  
- Automated execution of GeneMapper with command-line parameters  
- Log file generation for audit and troubleshooting  
- Compatible with multiple GeneMapper versions and directory structures  

---

## Workflow Summary

### 1. User Input
The tool requests:
- Username  
- Password
- Project name  

### 2. Automatic Search for GeneMapper
The tool searches for the GeneMapper executable using:
- A fast scan of common installation directories  
- A deeper scan of all connected drives (excluding C:)  

If the executable cannot be found automatically, the user may provide the installation path manually.

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
- Paulo B. Chaves
- Laboratório de Biologia e DNA Forense
- Polícia Científica de Goiás, Brazil (PCI/GO)

---

## Purpose
PR0FYLER supports a faster, more reliable, and user-friendly method for exporting electropherograms, reducing repetitive manual tasks and minimizing errors in forensic DNA analysis workflows.

