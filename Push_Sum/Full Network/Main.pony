use "collections"
use "random"
use "time"

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
    
    fun abs(x: F64): F64 =>
        if x < 0 then -x else x end
    
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
                let diff = abs(ratio - new_ratio)
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
        