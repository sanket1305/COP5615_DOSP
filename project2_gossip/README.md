# Gossip Protocol and Push-Sum Algorithm Implementation Using Actor Model in Pony

This repository contains an implementation of the **Gossip Protocol** and **Push-Sum Algorithm** using the **actor model** in the **Pony programming language**. The project simulates information dissemination and distributed computation across various network topologies, leveraging Pony's concurrency model for scalability and fault tolerance.

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
  - [Gossip Protocol](#gossip-protocol)
  - [Push-Sum Algorithm](#push-sum-algorithm)
  - [Topologies](#topologies)
    - [Full Network Topology](#full-network-topology)
    - [3D Grid Topology](#3d-grid-topology)
    - [Line Topology](#line-topology)
    - [Imperfect 3D Grid Topology](#imperfect-3d-grid-topology)
- [Installation](#installation)
- [Usage](#usage)
- [Technologies Used](#technologies-used)

---

## Overview

The **Gossip Protocol** is a decentralized communication mechanism inspired by the way rumors spread in social networks. It is used for information propagation and aggregate computation in distributed systems. 

The **Push-Sum Algorithm** is designed for distributed sum computation and convergence.

This project simulates these algorithms across different network topologies using Pony's actor model. Each node in the network is represented as an independent actor, enabling efficient message passing and fault isolation.

---

## Features

- **Asynchronous Gossip Protocol:** Simulates rumor spreading with termination conditions.
- **Push-Sum Algorithm:** Implements distributed sum computation with convergence detection.
- **Customizable Topologies:** Supports multiple network topologies to analyze algorithm performance.
- **Actor-Based Concurrency:** Leverages Pony's lightweight actors for parallelism and scalability.
- **Performance Metrics:** Measures convergence time for each algorithm and topology.

---

## How It Works

### Gossip Protocol

The Gossip Protocol involves spreading a rumor (or fact) through a network of nodes (actors) until all nodes have received it. Key steps include:
1. **Starting:** A node is initialized with a rumor by the main process.
2. **Spreading:** Each node randomly selects a neighbor and sends the rumor.
3. **Termination:** A node stops transmitting once it has received the rumor 10 times (or another configurable threshold).

### Push-Sum Algorithm

The Push-Sum Algorithm is used for distributed sum computation. Each node maintains two values, \( s \) (sum) and \( w \) (weight), which are updated as messages are exchanged:
1. **Initialization:** Each node starts with \( s = i \) (its identifier) and \( w = 1 \).
2. **Message Passing:** Nodes send half of their \( s \) and \( w \) values to a random neighbor while retaining the other half.
3. **Convergence Detection:** Nodes terminate when their ratio \( s/w \) stabilizes (i.e., changes by less than \( 10^{-10} \) over three consecutive rounds).

### Topologies

The network topology determines how nodes are connected and influences the speed of information dissemination:

#### Line Topology
- Actors are arranged in a line, each communicating only with its left and right neighbors.
- Slowest convergence due to limited connectivity.

#### 3D Grid Topology
- Actors form a 3D grid, communicating only with their immediate neighbors.
- Balances communication cost and convergence speed.

#### Imperfect 3D Grid Topology
- Similar to the 3D grid but with additional random connections to improve propagation speed.
- Faster than pure 3D grids while maintaining moderate communication cost.

#### Full Network Topology
- Every actor is a neighbor of all other actors.
- Fastest convergence but highest communication overhead.

---

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/sanket1305/COP5615_DOSP.git
   cd COP5615_DOSP/project2_gossip
   ```

2. Install Pony:
   Follow the installation guide on the [Pony website](https://www.ponylang.io/).

3. Build the project:
   ```
   ponyc .
   ```

---

## Usage

Run the Gossip Protocol or Push-Sum Algorithm simulation with customizable parameters:

```
./project2_gossip <num_nodes> <topology> <algorithm>
```

### Parameters:
- `<num_nodes>`: Number of nodes in the network.
- `<topology>`: Network topology (`full`, `3d`, `line`, or `imp3d`).
- `<algorithm>`: Algorithm to run (`gossip` or `pushsum`).

### Example:
```
./project2_gossip 100 full gossip
```
This command runs the Gossip Protocol on a full network topology with 100 nodes.

### Output:
The program prints the time taken to achieve convergence for the specified algorithm and topology.

---

## Technologies Used

- **Pony Programming Language:**
  - Actor-model-based concurrency.
  - High performance with memory safety guarantees.
  - No garbage collection pauses due to independent actor heaps.

For more information on Pony, visit [Pony's official documentation](https://www.ponylang.io/).

---
