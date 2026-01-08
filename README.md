# BCL → FASTQ One-Step Demultiplexing Pipeline

This repository provides a **single-command, reproducible pipeline** to demultiplex Illumina BCL data into FASTQ files using **BCL Convert (Docker)**.

The pipeline:
- Cleans the Illumina SampleSheet (removes `NoLaneSplitting`)
- Generates a run-specific config file
- Runs BCL Convert via Docker
- Produces timestamped logs
- Is callable via a **single shell command: `Demultiplex`**

---

## Features

- One-command execution
- Sudo-safe, production-grade logging
- Explicit failure on bad input
- No fragile bash tricks
- Works from inside the run directory
- Minimal assumptions, no magic

---

## Requirements

- Linux
- Bash ≥ 4
- Docker
- `sudo` access
- Illumina run directory containing BCL files
- Illumina SampleSheet CSV
- Docker container - zymoresearch/bcl-convert


---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/amanpruthi15/One-Step-Demulitplex.git
cd One-Step-Demupltiplex
```
### 2. Make scripts executable
```bash
chmod +x demultiplexing_bcl_to_fastq.sh
chmod +x docker-bcl-convert.sh
```
### 3. Add Demultiplex Command (bashrc Setup)

To enable a single-word command, add the following function to your ~/.bashrc.

Add this block at the bottom:
```bash
Demultiplex() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: Demultiplex <SampleSheet.csv>"
        return 1
    fi

    local SAMPLESHEET=$(realpath "$1")
    local WORKDIR="$PWD"
    local SCRIPT="/home/norwalk1/software/apruthi/demulltiplexing_bcl_to_fastq.sh"

    if [ ! -f "${SAMPLESHEET}" ]; then
        echo "ERROR: SampleSheet not found: ${SAMPLESHEET}"
        return 1
    fi

    if [ ! -x "${SCRIPT}" ]; then
        echo "ERROR: Script not executable: ${SCRIPT}"
        return 1
    fi

    sudo bash "${SCRIPT}" "${WORKDIR}" "${SAMPLESHEET}"
}

export -f Demultiplex
```

Reload your shell:
```bash
source ~/.bashrc
```
---

## Usage

### Step 1: Move into the Illumina run directory
```bash
cd /path/to/illumina/run_directory
```

### Step 2: Run demultiplexing
```bash
Demultiplex SampleSheet.csv
```
---

## Outputs

#### The pipeline generates:

- YYYY-MM-DD_{RunName}_SampleSheet_Demux.csv
- YYYY-MM-DD_{RunName}.config
- FASTQ output directory: output/
- Log file: YYYY-MM-DD_demux.log
