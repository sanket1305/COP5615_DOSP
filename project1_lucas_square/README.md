# Lucas Square Pyramid Implementation Using Actor Model in Pony

This repository contains an implementation of the **Lucas Square Pyramid problem** using the **actor model** in the **Pony programming language**. The project demonstrates how to compute the total number of spheres in a square pyramid and determine whether it forms a perfect square, leveraging concurrency through multiple actors.

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
  - [Lucas Square Pyramid Problem](#lucas-square-pyramid-problem)
  - [Actors in the System](#actors-in-the-system)
  - [Concurrency and Parallelism](#concurrency-and-parallelism)
- [Installation](#installation)
- [Usage](#usage)
- [Technologies Used](#technologies-used)

---

## Overview

The **Lucas Square Pyramid problem** is a classical mathematical challenge that involves determining when the total number of spheres in a square pyramid is also a perfect square. The total number of spheres in a pyramid with \( n \) layers is given by:

![image](https://github.com/user-attachments/assets/523836c2-3cd4-4ef1-aeac-ecce8e9f4106)


This project implements the solution using Pony's **actor model**, where multiple actors collaborate to compute \( P_n \) concurrently for a given \( n \), ensuring efficient task distribution and message passing.

---

## Features

- **Concurrent Computation:** Uses multiple actors to distribute and compute partial sums for \( P_n \).
- **Perfect Square Check:** Verifies if the computed value of \( P_n \) is a perfect square.
- **Scalable Design:** Handles large values of \( n \) by dividing computations across actors.
- **Actor-Based Concurrency:** Leverages Pony's actor model for parallelism and fault isolation.

---

## How It Works

### Lucas Square Pyramid Problem

The goal is to compute \( P_n \), the total number of spheres in a square pyramid with \( n \) layers, and determine whether it forms a perfect square. The two known solutions to this problem are:
1. For \( n = 1 \), \( P_1 = 1 = 1^2 \) (a perfect square).
2. For \( n = 24 \), \( P_24 = 4900 = 70^2 \) (a perfect square).

This project generalizes the computation for any given \( n \).

### Actors in the System

1. **Master Actor:**
   - Coordinates the computation by dividing the task into smaller parts.
   - Aggregates results from worker actors.
   - Checks if the final result is a perfect square.

2. **Worker Actors:**
   - Compute partial sums for ranges of layers.
   - Send results back to the master actor asynchronously.

### Concurrency and Parallelism

The implementation achieves concurrency by:
1. Dividing the computation into chunks.
2. Assigning each chunk to a separate worker actor.
3. Aggregating results from all workers in the master actor.

This approach ensures efficient utilization of system resources, especially for large values of \( n \).

---

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/sanket1305/COP5615_DOSP.git
   cd COP5615_DOSP/project1_lucas_square
   ```

2. Install Pony:
Follow the installation guide on the [Pony website](https://www.ponylang.io/).

3. Build the project:
   ```
   ponyc .
   ```

---

## Usage

Run the Lucas Square Pyramid computation with customizable parameters:
```
./lucas_square_pyramid <n>
```

### Parameters:
- `<n>`: The number of layers in the pyramid.

### Example:
```./lucas_square_pyramid 24```

This command computes \( P_{24} = 4900 \) and checks if it is a perfect square.

### Output:
The program prints:
1. The computed value of \( P_n \).
2. Whether or not it is a perfect square.

---

## Technologies Used

- **Pony Programming Language:**
  - Actor-model-based concurrency.
  - High performance with memory safety guarantees.
  - No garbage collection pauses due to independent actor heaps.

For more information on Pony, visit [Pony's official documentation](https://www.ponylang.io/).

---
