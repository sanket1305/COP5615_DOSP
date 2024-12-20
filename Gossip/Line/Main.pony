use "collections"
use "random"
use "time"

actor Node3D
    let env: Env
    let id: U64
    var x: F64
    var y: F64
    var z: F64
    var neighbors: Array[Node3D tag] = Array[Node3D tag]
    var message: (String | None) = None
    let _rng: Random
    var msg_cnt: USize = 0
    var algorithm : String

    var s : F64
    var w : F64
    var cnt : U64

    new create(env': Env, id': U64, algo: String, x': F64, y': F64, z': F64) =>
        env = env'
        id = id'
        x = x'
        y = y'
        z = z'
        algorithm = algo
        s = id.f64()
        w = 1
        cnt = 0
        _rng = Rand(Time.nanos())

    be add_neighbor(neighbor: Node3D tag) =>
        neighbors.push(neighbor)
    
    be receive(msg: String) =>
        msg_cnt = msg_cnt + 1
        match message
        | None =>
            message = msg
            env.out.print(id.string() + " received 1st time: " + msg)
        else
            env.out.print(id.string() + " received " + msg_cnt.string() + " time: " + msg)
        end

        if msg_cnt < 10 then
            gossip()
        end

    be gossip() =>
        match message
        | let msg: String =>
            if neighbors.size() > 0 then
                let index = _rng.int(neighbors.size().u64()).usize()
                // var neighbor
                try
                    let neighbor = neighbors(index)?
                    match algorithm
                    | "gossip" =>
                        neighbor.receive(msg + " " + id.string())
                    | "pushsum" =>
                        // env.out.print("The algo is: " + algorithm)
                        neighbor.receive_pushSum(msg, s/2, w/2)
                    end    
                else
                    env.out.print("No neightbors")
                end
            end

            // for neighbor in neighbors.values() do
            //     neighbor.receive(msg)
            // end
        else
            None
        end
    be receive_pushSum(rumour: String, s': F64, w': F64) =>
        match message
        | None =>
            message = rumour
            msg_cnt = 1
            gossip()
        | let r: String =>
            if r == rumour then
                let ratio = s/w
                // env.out.print(id.string() + " Received the message from Push 0: " + rumour + " convergence ratio: " + ratio.string())
                s = s + s'
                w = w + w'
                let new_ratio = s/w
                let diff = (ratio - new_ratio).abs()
                // env.out.print("this is count................" + cnt.string())
                if cnt<3 then
                    // env.out.print("this is count................ debug 1" + cnt.string())
                    gossip()
                end
                if (diff <= 0.0000000001) and (cnt < 3) then
                    // env.out.print("this is count................ debug 2" + cnt.string())
                    cnt = cnt + 1
                else
                    // env.out.print("this is count................ debug 3" + cnt.string())
                    cnt = 0
                end
            end
        end

    be print_info() =>
        env.out.print("Node " + id.string() + " at (" + x.string() + ", " + y.string() + ", " + z.string() + ") with " + neighbors.size().string() + " neighbors")

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


    be set_neighbors(neighbors: Array[Node tag] val) =>
        _neighbors = Array[Node tag]
        for neighbor in neighbors.values() do
            _neighbors.push(neighbor)
        end

    be receive_gossip(rumour: String) =>
        match _rumour
        | None =>
            _rumour = rumour
            _rumour_count = 1
            spread_gossip()
        | let r: String =>
            if r == rumour then
                _env.out.print(_id + " Received the message from gossip: " + rumour)
                _rumour_count = _rumour_count + 1
                if _rumour_count < _n then
                    spread_gossip()
                end
            end
        end

    be spread_gossip() =>
        match _rumour
        | let r: String =>
            if _neighbors.size() > 0 then
                let target_index = _rand.int(_neighbors.size().u64()).usize()
                try
                    let target = _neighbors(target_index)?
                    match algorithm
                    | "gossip" =>
                        target.receive_gossip(r)
                    | "pushsum" =>
                        target.receive_pushSum(r, s/2, w/2)
                    end
                end
            end
        end
    
    // fun abs(x: F64): F64 =>
    //     if x < 0 then -x else x end
    
    be receive_pushSum(rumour: String, s': F64, w': F64) =>
        match _rumour
        | None =>
            _rumour = rumour
            _rumour_count = 1
            spread_gossip()
        | let r: String =>
            if r == rumour then
                // _env.out.print(_id + " Received the message from Push: " + rumour)
                let ratio = s/w
                s = s + s'
                w = w + w'
                let new_ratio = s/w
                let diff = (ratio - new_ratio).abs()
                if cnt<3 then
                    spread_gossip()
                end
                if (diff <= 0.0000000001) and (cnt < 3) then
                    cnt = cnt + 1
                else
                    cnt = 0
                end
            end
        end


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
                _nodes(initial_node)?.receive_gossip(rumour)
            end
        | "pushsum" =>
            try
                _nodes(initial_node)?.receive_pushSum(rumour, 0, 1)
            end
        end

actor Network3D
    let env: Env
    let nodes: Map[U64, Node3D tag] = Map[U64, Node3D tag]
    let _rng: Random
    var rand_neighbor_id: U64
    var n : U64
    let topo : String
    let algo : String

    new create(env': Env, n': U64, topo' : String, algo': String) =>
        env = env'
        n = n'
        topo = topo'
        algo = algo'
        _rng = Rand(Time.nanos())
        rand_neighbor_id = 0
        create_mesh()

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
            
        end

    // Print node information
    for node in nodes.values() do
        node.print_info()
    end

    // start gossip from te first node
    match algo
    | "gossip" =>
        try
            nodes(0)?.receive("Let's do gossip !!!")
        end
    | "pushsum" =>
        try
            nodes(0)?.receive_pushSum("Let's do pushsum gossip !!!", 0, 1)
        end
    end
    // try
    //     nodes(0)?.receive("Let's do gossip !!!")
    // end

actor Main
    new create(env: Env) =>
        let start = Time.nanos()
        try
            let n = env.args(1)?.usize()?
            
            let topo = env.args(2)?
            let algo = env.args(3)?
            if (topo == "imp3D") or (topo == "3D") then
                let n3 = n.f64().pow(1.0/3.0).u64()
                let network3d= Network3D(env, n3, topo, algo)
            else
                if n < 2 then
                    env.out.print("Enter a number greater than 2")

                end
                let network = Network(n, topo, algo, env)
                network.setup_topology()
                network.call_algo(0, "Hello, Pony!")
            end
        end
        let theEnd = Time.nanos()
        env.out.print((theEnd-start).string())
        