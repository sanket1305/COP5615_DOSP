use "collections"
use "random"

actor Node
    let _id: String
    var _neighbors: Array[Node tag]
    var _rumour: (String | None)
    var _rumour_count: U64
    let _rand: Rand
    let _env : Env
    var _n : U64

    new create(id: String, n: U64, env : Env) =>
        _id = id
        _neighbors = Array[Node tag]
        _rumour = None
        _rumour_count = 0
        _rand = Rand
        _n = n
        _env = env

    be set_neighbors(neighbors: Array[Node tag] val) =>
        _neighbors = Array[Node tag]
        for neighbor in neighbors.values() do
            _neighbors.push(neighbor)
        end

    be receive_rumour(rumour: String) =>
        match _rumour
        | None =>
            _rumour = rumour
            _rumour_count = 1
            spread_rumour()
        | let r: String =>
            if r == rumour then
                _env.out.print(_id + " Received the message: " + rumour)
                _rumour_count = _rumour_count + 1
                if _rumour_count < _n then
                    spread_rumour()
                end
            end
        end

    be spread_rumour() =>
        match _rumour
        | let r: String =>
            if _neighbors.size() > 0 then
                let target_index = _rand.int(_neighbors.size().u64()).usize()
                try
                    let target = _neighbors(target_index)?
                    target.receive_rumour(r)
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
            nodes.push(Node(i.string(), 10, env))
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

    be start_gossip(initial_node: USize, rumour: String) =>
        try
            _nodes(initial_node)?.receive_rumour(rumour)
        end

actor Main
    new create(env: Env) =>
        let network1 = Network(20, "full", "gossip", env)
        network1.setup_topology()
        network1.start_gossip(0, "Hello, Pony!")
