# Gossip and Push-Sum Algorithms
Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Pony. Since actors in Pony are fully asynchronous, the particular type of Gossip implemented is the so called Asynchronous Gossip.

Gossip Algorithm for information propagation The Gossip algorithm involves the following:
• Starting: A participant(actor) it told/sent a roumor(fact) by the main process
• Step: Each actor selects a random neighbor and tells it the rumor
• Termination: Each actor keeps track of rumors and how many times it has heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, you can select other values).

2. Push-Sum algorithm for sum computation
• State: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1
• Starting: Ask one of the actors to start from the main process.
• Receive: Messages sent and received are pairs of the form (s, w). Upon receive, an actor should add received pair to its own corresponding values. Upon receive, each actor selects a random neighbor and sends it a message.
• Send: When sending a message to another actor, half of s and w is kept by the sending actor and half is placed in the message.
• Sum estimate: At any given moment of time, the sum estimate is s_w  where s and w are the current values of an actor.
• Termination: If an actors ratio s_w did not change more than 10−10 in 3 consecutive rounds the actor terminates. WARNING: the values s and w independently never converge, only the ratio does.

## Topologies
Topologies The actual network topology plays a critical role in the dissemination speed of Gossip protocols. As part of this project you have to experiment with various topologies. The topology determines who is considered a neighboor in the above algorithms.
• Full Network Every actor is a neighbor of all other actors. That is, every actor can talk directly to any other actor.
• 3D Grid: Actors form a 3D grid. The actors can only talk to the grid neighbors.
• Line: Actors are arranged in a line. Each actor has only 2 neighbors (one left and one right, unless you are the first or last actor).
• Imperfect 3D Grid: Grid arrangement but one random other neighbor is selected from the list of all actors (4+1 neighbors).
2 Requirements
### Input:
The input provided (as command line to your project2) will be of the form:
project2 numNodes topology algorithm
Where numNodes is the number of actors involved (for 2D based topologies you can round up until you get a square), topology is one of full, 3D, line,
imp3D, algorithm is one of gossip, push-sum

### Output:
Print the amount of time it took to achieve convergence of the algorithm. Please measure the time using
## The Code
We set up Topologies for each kind of network and initialize one of the Nodes inside the Network or Network 3D actors, for {line, Full} and {3D, imperfect 3D} respectively.
The Network Actors set up the neighbors for each node and call the "receive" functions to start the gossip

## Node
The actual Structure of a Node in the Network and it's fields:
```
actor Node
    let _id: String
    var _neighbors: Array[Node tag]
    var _rumour: (String | None)
    var _rumour_count: U64
    let _rand: Rand
    var _n : U64
    var s : F64
    var w : F64
    var cnt : U64
    var algorithm : String
    let _env : Env
    

    new create(id: String, n: U64, algo: String, env : Env) => 
        _id = id
        _neighbors = Array[Node tag]
        _rumour = None
        _rumour_count = 0
        _rand = Rand
        _n = n
        algorithm = algo
        try
            s = id.f64()?
        else
            s = 0.0 
        end
        w = 1
        cnt = 0
        _env = env
```
## Linear Topology
```
fun linear_topology() =>
    for i in Range(0, _size) do
        let neighbors = recover val
            let arr = Array[Node tag]
            if i>0 then
                try
                    arr.push(_nodes(i-1)?)
                end
            end
            if i<(_size-1) then
                try
                    arr.push(_nodes(i+1)?)
                end
            end
            arr
        end
        try
            _nodes(i)?.set_neighbors(neighbors)
        end
    end
```
## Full Topology
```
fun full_topology() =>
    for node in _nodes.values() do
        let neighbors = recover val
            let arr = Array[Node tag]
            for neighbor in _nodes.values() do
                if neighbor isnt node then
                    arr.push(neighbor)
                end
            end
            arr
        end
        node.set_neighbors(neighbors)
    end
```
## 3D Topology
```
be create_mesh() =>
    // Create a 3x3x3 mesh of nodes
    var n2 = n*n
    for i in Range(0, n.usize()) do
        for j in Range(0, n.usize()) do
            for k in Range(0, n.usize()) do
                let id = (i * n2.usize()) + (j * n.usize()) + k
                let node = Node3D(env, id.u64(), algo, i.f64(), j.f64(), k.f64())
                nodes(id.u64()) = node
            end
        end
    end
    
    // Connect neighboring nodes
    for (id, node) in nodes.pairs() do
        let i = (id / n2).u64()
        let j = ((id % n2) / n).u64()
        let k = (id % n).u64()
    
        let neighbors = [
            (i.i64()-1, j.i64(), k.i64()); (i.i64()+1, j.i64(), k.i64()); (i.i64(), j.i64()-1, k.i64()); (i.i64(), j.i64()+1, k.i64()); (i.i64(), j.i64(), k.i64()-1); (i.i64(), j.i64(), k.i64()+1)
        ]
    
        for (ni, nj, nk) in neighbors.values() do
            if (ni >= 0) and (ni < n.i64()) and (nj >= 0) and (nj < n.i64()) and (nk >= 0) and (nk < n.i64()) then
                let neighbor_id = (ni.u64() * n2) + (nj.u64() * n) + nk.u64()
                try
                    node.add_neighbor(nodes(neighbor_id)?)
                end
            end
        end
    end
```
## Imperfect 3D Topology
```
 if topo == "imp3D" then
    while true do
        // env.out.print(rand_neighbor_id.string() + " " + id.string())
        Time.seconds()
        rand_neighbor_id = _rng.int(n*n*n)
        let ni = (rand_neighbor_id / n2).u64()
        let nj = ((rand_neighbor_id % n2) / n).u64()
        let nk = (rand_neighbor_id % n).u64()

        if rand_neighbor_id != id then
            let diff: U64 = (ni - i).abs() + (nj - j).abs() + (nk - k).abs()
            if diff > 1 then
        // end
        // if (ni != (i+1)) and (ni != i) and (ni != (i-1)) and (nj != (j+1)) and (nj != j) and (nj != (j-1)) and (nk != (k+1)) and (nk != k) and (nk != (k-1)) then
                try 
                    node.add_neighbor(nodes(rand_neighbor_id)?)
                end
                break
            end
        end 
    end
end
```

## Network
The Network Actor
• Initializes the Nodes, based on the input number
• Sets the Topologies
• Makes the Initial Call for the 0th Node to receive and boot the network
```
actor Network
    let _nodes: Array[Node tag] val
    var _algo : String
    var _topo : String
    var _size : USize

    new create(size: USize, topo: String, algo : String, env : Env) =>
        _algo = algo
        _topo = topo
        let nodes = recover Array[Node tag](size) end
        _size = size
        for i in Range(0, size) do
            nodes.push(Node(i.string(), 10, _algo, env))
        end
        _nodes = consume nodes

    fun linear_topology() =>
        for i in Range(0, _size) do
            let neighbors = recover val
                let arr = Array[Node tag]
                if i>0 then
                    try
                        arr.push(_nodes(i-1)?)
                    end
                end
                if i<(_size-1) then
                    try
                        arr.push(_nodes(i+1)?)
                    end
                end
                arr
            end
            try
                _nodes(i)?.set_neighbors(neighbors)
            end
        end
    fun full_topology() =>
        for node in _nodes.values() do
            let neighbors = recover val
                let arr = Array[Node tag]
                for neighbor in _nodes.values() do
                    if neighbor isnt node then
                        arr.push(neighbor)
                    end
                end
                arr
            end
            node.set_neighbors(neighbors)
        end
    
    be setup_topology() =>
        match _topo
        | "linear" =>
            linear_topology()
        | "full" =>
            full_topology()
        end
        
    be call_algo(initial_node: USize, rumour: String) =>
        match _algo
        | "gossip" =>
            try
                let start = Time.nanos()
                _nodes(initial_node)?.receive_gossip(rumour)
                let theEnd = Time.nanos()
                env.out.print((theEnd-start).string())
            end
        | "pushsum" =>
            try
                _nodes(initial_node)?.receive_pushSum(rumour, 0, 1)
            end
        end
```

## Main
Finally the main Runs the code.
