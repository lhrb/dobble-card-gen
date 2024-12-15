# Dobble Card Generator  

Do you know the children's game *"Spot It"* (or *Dobble* in German)?  
In this game, there are 57 cards, each with 8 symbols, and the magic is:  
**Every card shares exactly one symbol with every other card.**  

This fascinated me, and I decided to figure out how to generate a set of cards like this. It felt like a perfect problem for Prolog, but as I learned, constructing such a dataset isn't as simple as I initially thought.  

In the process of solving this, I:  
- Learned how to properly construct a **finite projective plane** (the mathematical basis behind the card relationships).  
- Sharpened my Prolog skills.  
- Rediscovered some forgotten knowledge of modular arithmetic and linear algebra.  

## What This Program Does  

This program generates a **finite projective plane** of order `P`. The output is a dataset that satisfies the *Spot It* card rules. Specifically:  
1. **Each card (or line) contains `P + 1` symbols (or points)**.  
2. **Any two cards share exactly one symbol**.  

The output is saved as a JSON file, which can be used by another program to design the actual cards.  

---

## How to Use  

1. **Install [SWI-Prolog](https://www.swi-prolog.org/):**  
   Ensure you have SWI-Prolog installed on your system.  

2. **Clone this Repository:**  
   ```bash
   git clone <your-repo-link>
   cd <your-repo-directory>
   ```

3. **Run the Program:**  
   You can generate a projective plane of order `P` (e.g., `P = 7`) and output it to a JSON file.  

   Start by running the Prolog file in SWI-Prolog:  
   ```bash
   swipl -sq dobble-gen.pl
   ```  

   Then, in the Prolog shell, generate the output by running:  
   ```prolog
   ?- output_plane(7, 'output.json').
   ```  

   This generates a JSON file named `output.json` in the same directory.  

---

## JSON Output Format  

The JSON file contains two sections:  
- `symbols`: A dictionary of points (e.g., `P0`, `P1`, ...).  
- `cards`: A dictionary of lines/cards, where each card lists the points it contains.  

Example:  
```json
{
  "symbols": {
    "P0": "",
    "P1": "",
    "P2": "",
    "P3": ""
  },
  "cards": {
    "L0": ["P0", "P1", "P2"],
    "L1": ["P0", "P3", "P2"]
  }
}
```

You can use this output with another program to generate the graphics for the cards.

---

## About the Code  

### Main Concepts  

1. **Finite Projective Plane:**  
   The program constructs a projective plane of order `P` using normalized triples and modular arithmetic. Each triple represents a point, and combinations of points generate lines (or cards).  

2. **Modular Arithmetic and Normalization:**  
   To ensure unique representations of points and lines, normalization is applied using modular inverses.  

3. **Labeling:**  
   Each point and line is assigned a human-readable label (e.g., `P0`, `L0`) for easy representation in the output file.  

4. **Output in JSON:**  
   The results are written as a structured JSON file with clear mappings between points and cards.  

---

### Example Prolog Commands  

#### Run Tests  
The program includes unit tests to verify correctness. Run the tests by executing:  
```prolog
?- run_tests.
```  

#### Generate a Plane  
Generate a projective plane of order 7 and print it in the console:  
```prolog
?- projective_plane_with_label(7, PlaneLabeled), print_plane(PlaneLabeled).
```  

#### Generate a JSON File  
Generate a projective plane of order 7 and save it as `output.json`:  
```prolog
?- output_plane(7, 'output.json').
```  

---

## Opportunities for Optimization  

While the program works, there are opportunities to improve:  
1. **Efficiency:**  
   - Replace brute-force computations (e.g., modular inverses) with optimized algorithms like the Extended Euclidean Algorithm.  
   - Reduce redundant computations when generating lines.  

2. **Flexibility:**  
   - Allow users to specify more options, such as a custom prefix for labels.  
   - Add input validation for the order `P`.  

3. **Scalability:**  
   - Handle larger projective planes by optimizing the enumeration of points and lines.  

---

## Final Thoughts  

This project started as a curiosity and became a fun learning experience. Whether you're a fan of *Spot It*, interested in Prolog, or curious about finite projective planes, I hope this project inspires you in some way.  

Let me know if you find this useful or have suggestions for improvements!  
