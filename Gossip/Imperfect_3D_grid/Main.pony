use "collections"
use "random"
use "time"

actor Node
    // Common vars
    let _id: String
    var _neighbors: Array[Node tag] = Array[Node tag]
    var _rumour: (String | None)
    let rand: Rand = Rand
    // Gossip specific vars
    var _rumour_count: U64
    // 3D vars
    var x: F64
    var y: F64
    var z: F64
    // Pushsum specific vars
    var s : F64
    var w : F64
    var cnt : U64

    var algorithm : String
    let _env : Env
    
    new create(id: String, algo: String, env : Env) => 
        _id = id
        _rumour = None
        _rumour_count = 0
        algorithm = algo
        try
            s = id.f64()?
        else
            s = 0.0 
        end
        w = 1
        cnt = 0
        _env = env
    
    new create3D(id: String, algo: String, x': F64, y': F64, z': F64, env : Env) =>
        _id = id
        _rumour = None
        _rumour_count = 0
        x = x'
        y = y'
        z = z'
        algorithm = algo
        try
            s = id.f64()?
        else
            s = 0.0 
        end
        w = 1
        cnt = 0
        _env = env

    be add_neighbor(neighbor: Node tag) =>
        _neighbors.push(neighbor)
    
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
                if _rumour_count < 10 then
                    spread_gossip()
                end
            end
        end

    be spread_gossip() =>
        match _rumour
        | let r: String =>
            if _neighbors.size() > 0 then
                let target_index = rand.int(_neighbors.size().u64()).usize()
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
                _env.out.print(_id + " Received the message from Push: " + rumour)
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
    
    let nodes3D: Map[U64, Node tag] = Map[U64, Node tag]
    var rand_neighbor_id: U64
    let rand: Random

    let _env : Env

    new create(size: USize, topo: String, algo : String, env : Env) =>
        _algo = algo
        _topo = topo
        rand = Rand(Time.nanos())
        rand_neighbor_id = 0
        _env = env

        let nodes = recover Array[Node tag](size) end
        _size = size

        if (_topo == "3D") or (_topo == "imp3D") then
            create_mesh()
            for (id, node) in nodes3D.pairs() do
                nodes.push(node)
            end
        else
            
            for i in Range(0, size) do
                nodes.push(Node.create(i.string(), _algo, _env))
            end
            
        end
        _nodes = consume nodes
        
    
    be create_mesh() =>
        // Create a 3x3x3 mesh of nodes
        for i in Range(0, 3) do
            for j in Range(0, 3) do
                for k in Range(0, 3) do
                    let id = (i * 9) + (j * 3) + k
                    let node = Node.create3D(id.string(), _algo, i.f64(), j.f64(), k.f64(), _env)
                    nodes3D(id.u64()) = node
                end
            end
        end
    
    fun topology_3D() =>
        // Connect neighboring nodes
        for (id, node) in nodes3D.pairs() do
            let i = (id / 9).u64()
            let j = ((id % 9) / 3).u64()
            let k = (id % 3).u64()

            let neighbors = [
                (i.i64()-1, j.i64(), k.i64()); (i.i64()+1, j.i64(), k.i64()); (i.i64(), j.i64()-1, k.i64()); (i.i64(), j.i64()+1, k.i64()); (i.i64(), j.i64(), k.i64()-1); (i.i64(), j.i64(), k.i64()+1)
            ]

            for (ni, nj, nk) in neighbors.values() do
                if (ni >= 0) and (ni < 3) and (nj >= 0) and (nj < 3) and (nk >= 0) and (nk < 3) then
                    let neighbor_id = (ni.u64() * 9) + (nj.u64() * 3) + nk.u64()
                    try
                        node.add_neighbor(nodes3D(neighbor_id)?)
                    end
                end
            end
            if _topo == "imp3D" then
                while true do
                    _env.out.print(rand_neighbor_id.string() + " " + id.string())
                    Time.seconds()
                    rand_neighbor_id = rand.int(26)
                    let ni = (rand_neighbor_id / 9).u64()
                    let nj = ((rand_neighbor_id % 9) / 3).u64()
                    let nk = (rand_neighbor_id % 3).u64()

                    if rand_neighbor_id != id then
                        let diff: U64 = (ni - i).abs() + (nj - j).abs() + (nk - k).abs()
                        if diff > 1 then
                            try 
                                node.add_neighbor(nodes3D(rand_neighbor_id)?)
                            end
                            break
                        end
                    end 
                end
            end
            
        end    
    
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
        | "3D" | "imp3D" =>
            topology_3D()
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

actor Main
    new create(env: Env) =>
        let start = Time.nanos()
        try
            let n = env.args(1)?.usize()?
            let topo = env.args(2)?
            let algo = env.args(3)?
            if n < 2 then
                env.out.print("Enter a number greater than 2")

            end
            let network = Network(n, topo, algo, env)
            network.setup_topology()
            network.call_algo(0, "Hello, Pony!")
        end
        let theEnd = Time.nanos()
        env.out.print((theEnd-start).string())
        




        

