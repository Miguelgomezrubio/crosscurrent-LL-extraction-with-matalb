# cross-current-ll-extraction

MATLAB tools for equilibrium stage calculation in cross-current liquid–liquid extraction systems.

---

## Overview

This repository contains a set of MATLAB functions for modeling a cross-current liquid–liquid (LL) extraction process involving partially miscible solvents. Given experimental equilibrium data and a desired raffinate composition, the model computes:

- The required number of equilibrium stages  
- Raffinate, extract, and mixing stream compositions at each stage  
- Mass flow rates associated with each stream  

A graphical tool is provided to visualize the operating lines, equilibrium curves, and stage construction.

A schematic of the extraction process is included to clarify the stage definitions and nomenclature.

---

## Key Features

- Cross-current LL extraction modeling  
- Equilibrium stage calculation  
- Tie-line correlations from experimental data  
- Graphical visualization of stage construction  
- Clear nomenclature and process schematic  
- MATLAB implementation with no toolboxes required  

---

## Repository Structure

```
/src
    LL_stages_function.m
    plot_graph_function.m
    main.m

/docs
    process_schematic.png
    README.md
```

---

## How to Use

1. Place your equilibrium data and feed specifications in `main.m`.
2. Run:

```matlab
main
```

3. The script will:
- Compute equilibrium stages
- Output stream compositions
- Display the graphical operating diagram

---

## Example Output Variables

- `Number_of_equilibrium_stages`  
- `R` (raffinate compositions by stage)  
- `E` (extract compositions by stage)  
- `M` (mixing points)  
- `R_massFlow`, `E_massFlow` (flow rates per stage)  

---

## Applications

Suitable for:

- LL extraction modeling and design  
- Chemical/process engineering coursework  
- Research involving phase equilibrium data  
- Educational demonstrations  

---

## Requirements

- MATLAB R201x or newer  
- No additional toolboxes required  

---

## Input Data

The user must provide:

- Raffinate equilibrium curve (xS–xD)  
- Extract equilibrium curve (yS–yD)  
- Polynomial degree for tie-line correlation  
- Feed compositions and flow rates  
- Target raffinate composition  

---

## Output Data

The tool provides:

- Number of equilibrium stages  
- Stream compositions (solute and solvent mass fractions)  
- Stream flow rates per stage  
- Graphical representation of the operating diagram  

---

## License

MIT License

---

## Citation

Please cite this repository if used for academic or research purposes.

---

## Author

Miguel Gomez
