# Chord Protocol Implementation Using Actor Model in Pony

This repository contains an implementation of the **Chord Protocol** using the **actor model** in the **Pony programming language**. The implementation demonstrates how distributed hash tables (DHTs) can be efficiently managed in a decentralized system, leveraging Pony's actor-based concurrency model for scalability and fault tolerance.

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
  - [Actors in the System](#actors-in-the-system)
  - [Chord Operations](#chord-operations)
- [Installation](#installation)
- [Usage](#usage)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

The **Chord Protocol** is a scalable and efficient distributed hash table (DHT) protocol that maps keys to nodes in a decentralized network. It ensures \( O(\log N) \) time complexity for lookups and supports dynamic node joins and departures with minimal disruption.

This implementation uses the **actor model** in Pony, where each node in the Chord ring is represented as an independent actor. The actor model enables efficient message passing, fault isolation, and concurrency, making it ideal for distributed systems.

---

## Features

- **Decentralized Key Lookup:** Efficiently locate keys in a distributed network using consistent hashing.
- **Dynamic Node Management:** Handles node joins and departures dynamically with stabilization protocols.
- **Fault Tolerance:** Ensures resilience against node failures through replication and routing adjustments.
- **Efficient Routing:** Implements finger tables for logarithmic time complexity during lookups.
- **Actor-Based Concurrency:** Leverages Pony's lightweight actors for parallelism and scalability.

---

## How It Works

### Actors in the System

1. **Peer Actor:**
   - Represents a node in the Chord network.
   - Manages its own state, including its identifier, successor, predecessor, and finger table.
   - Handles key lookup requests, stabilization, and finger table updates.

2. **Simulator Actor:**
   - Simulates the Chord network by adding nodes one at a time.
   - Triggers stabilization processes and monitors lookup requests.
   - Collects statistics on performance metrics like lookup latency and message overhead.

### Chord Operations

1. **Node Join:**
   - A new node is added to the network by finding its successor using a lookup operation.
   - The new node sets its successor and predecessor accordingly.
   - Stabilization is triggered to update neighboring nodes' pointers.

2. **Lookup:**
   - A key lookup request is forwarded across the ring using finger tables until it reaches the responsible node (successor of the key).
   - This ensures \( O(\log N) \) hops for lookups.

3. **Stabilization:**
   - Periodically adjusts successors and predecessors to maintain a consistent ring structure.
   - Updates finger tables to optimize routing.

4. **Failure Handling:**
   - Nodes replicate keys to their successors to ensure data availability in case of failures.
   - Routing adjusts dynamically to bypass failed nodes.

---

## Installation

1. Clone this repository:
    ```
    git clone https://github.com/yourusername/chord-protocol.git
    cd chord-protocol
    text
    ```

2. Install Pony:
Follow the installation guide on the [Pony website](https://www.ponylang.io/).

3. Build the project:
    ```
    ponyc .
    ```

---

## Usage

Run the Chord protocol simulation with customizable parameters:
```
./chord_protocol <num_nodes> <num_keys>
```

### Parameters:
- `<num_nodes>`: Number of nodes to create in the Chord ring.
- `<num_keys>`: Number of keys to distribute across the nodes.

### Example:
```./chord_protocol 10 100```
text
This command creates a Chord ring with 10 nodes and distributes 100 keys among them.

---

## Technologies Used

- **Pony Programming Language:**
  - Actor-model-based concurrency.
  - High performance with memory safety guarantees.
  - No garbage collection pauses due to independent actor heaps.

For more information on Pony, visit [Pony's official documentation](https://www.ponylang.io/).

---
