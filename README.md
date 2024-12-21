# COP5615 - Distributed Operating System Principles

Welcome to the repository for **COP5635 - Distributed Operating Systems Principles (DOSP)** coursework. This repository contains implementations of three projects, each exploring different aspects of distributed systems using the **actor model** in the **Pony programming language**.

---

## Table of Contents
- [Overview](#overview)
- [Projects](#projects)
  - [Project 1: Lucas Square](#project-1-lucas-square)
  - [Project 2: Gossip Protocol](#project-2-gossip-protocol)
  - [Project 3: Chord Protocol](#project-3-chord-protocol)
- [Installation](#installation)
- [Usage](#usage)
- [Technologies Used](#technologies-used)
- [Collborators](#collaborators)

---

## Overview

This repository demonstrates the application of distributed system principles using the actor model in Pony. The projects focus on concurrency, fault tolerance, and scalability through the implementation of:
1. Mathematical computation using multiple actors.
2. Gossip-based communication protocols across various network topologies.
3. A distributed hash table (DHT) implementation using the Chord protocol.

Each project is designed to showcase the power of decentralized systems and efficient message-passing mechanisms in distributed environments.

---

## Projects

### Project 1: Lucas Square Pyramid
**Objective:** Implement a program to compute the Lucas square for a given \( n \) using multiple actors to achieve concurrency.

- **What is Lucas Square?**
  The Lucas square is derived from the Lucas sequence, where only specific terms are perfect squares. This project computes these values efficiently using Pony's actor model.

- **Key Features:**
  - Concurrent computation using multiple actors.
  - Efficient message passing between actors for task distribution.

---

### Project 2: Gossip Protocol
**Objective:** Implement gossip-based communication and the Push-Sum algorithm across multiple network topologies using Pony's actor model.

- **What is Gossip Protocol?**
  Gossip protocols are decentralized algorithms for information dissemination in distributed systems. This project simulates message spreading and data aggregation across various topologies.

- **Implemented Topologies:**
  - **Linear Topology:** Nodes communicate only with their immediate neighbors.
  - **Full Network Topology:** Every node communicates with all other nodes.
  - **3D Grid Topology:** Nodes are arranged in a 3D grid and communicate with six neighbors.
  - **Imperfect 3D Grid Topology:** Similar to a 3D grid but with additional random connections to improve propagation speed.

- **Key Features:**
  - Simulation of gossip-based message spreading.
  - Implementation of the Push-Sum algorithm for distributed averaging.

---

### Project 3: Chord Protocol
**Objective:** Implement the Chord protocol for efficient key lookup in a distributed hash table (DHT) using Pony's actor model.

- **What is Chord?**
  Chord is a scalable DHT protocol that maps keys to nodes in a circular identifier space, enabling efficient key lookups with \( O(\log N) \) complexity.

- **Key Features:**
  - Consistent hashing for key-to-node mapping.
  - Efficient routing using finger tables.
  - Dynamic handling of node joins and departures with stabilization protocols.

---

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/COP5635-dosp.git
   cd COP5635-dosp
   ```

3. Install Pony:
Follow the installation guide on the [Pony website](https://www.ponylang.io/).

4. Build and run individual projects:
   ```
   ponyc <project-directory>
   ./<project-executable>
   ```

---

## Usage

### Running Each Project

#### Project 1: Lucas Square
    cd Project1-LucasSquare
    ponyc .
    ./lucas_square <n>
Replace `<n>` with the desired input to compute the Lucas square.

#### Project 2: Gossip Protocol
    cd Project2-GossipProtocol
    ponyc .
    ./gossip_protocol <topology> <num_nodes> <algorithm>
Parameters:
- `<topology>`: Choose from `linear`, `full`, `3d_grid`, or `imperfect_3d_grid`.
- `<num_nodes>`: Number of nodes in the network.
- `<algorithm>`: Specify `gossip` or `pushsum`.

#### Project 3: Chord Protocol
    cd Project3-ChordProtocol
    ponyc .
    ./chord_protocol <num_nodes> <num_keys>
Parameters:
- `<num_nodes>`: Number of nodes in the Chord ring.
- `<num_keys>`: Number of keys to be mapped in the DHT.

---

## Technologies Used

- **Pony Programming Language**:
  - Actor-model based concurrency.
  - High performance and memory safety without garbage collection pauses.
  
For more information on Pony, visit [Pony's official documentation](https://www.ponylang.io/).

---

## Collaborators:
- Sanket Deshmukh (sanket.deshmukh@ufl.edu)
- Sravani Garapati (sravanigarapati@ufl.edu)

---
