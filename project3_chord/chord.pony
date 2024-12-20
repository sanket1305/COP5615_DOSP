use "collections"
use "random"
use "time"

actor ChordRing
  var num_nodes: USize
  var num_reqs: F64
  var tot_hop_cnt: F64 = 0

  // we need this, as num_reqs will be used as decr counter,
  // as soon as the request has been processed.
  var init_num_req: USize

  // arrays to keep track of nodes and sorted nodes
  var nodes: Array[USize]
  var sorted_nodes: Array[USize]

  // mapping of nodes with their respective ids
  var network_state: Map[USize, CNode]
  var env: Env

  new create(env': Env, num_nodes': USize, num_reqs': F64) =>
    network_state = Map[USize, CNode]
    sorted_nodes = Array[USize]
    nodes = Array[USize]
    num_nodes = num_nodes'
    num_reqs = num_reqs'
    init_num_req = num_reqs.usize()
    env = env'

    // calculate vale of m, by taking log
    let m = (num_nodes.f64().log2()).ceil()
    
    // initiate node creation
    env.out.print("Generating " + num_nodes.string() + " Nodes...")
    generate_nodes(num_nodes, m.usize())

    // generate finger tables
    generate_finger_table(m.usize())

    // notify all nodes
    env.out.print("Initiating " + num_reqs.string() + " search requests...")
    notify_all(num_reqs, m.usize())
  
  fun ref generate_nodes(count: USize, m: USize)=>
    var cnt: U32 = 1
    let rand = Rand
    while cnt <= count.u32() do

      // ensure that randomized id is within given node_count
      let node_id = ((rand.usize())%(count.usize()))
      let chord_node = CNode(env, node_id, m, this)

      env.out.print("Adding node with id " + node_id.string() + " into network...")
      network_state.insert(node_id,chord_node)
      nodes.push(node_id)
      sorted_nodes.push(node_id)
      cnt = cnt+1
    end

  be lookup_node(next_node: USize, lookup_key: USize, hops: F64, reference_network: ChordRing )=>
    try network_state(next_node)?.lookup(lookup_key, hops+1, reference_network)? end
      
  be final_fun_call(node_id: USize, k: USize, hops: F64) =>
    // as this is final call, one request has been completed, 
    // so decr counter and count hops
    num_reqs = num_reqs-1
    tot_hop_cnt = tot_hop_cnt + hops

    if num_reqs < 0 then
        let hop_cnt_avg = tot_hop_cnt.f64()/ (num_nodes).f64()
        env.out.print("The avg hop count at Node " + node_id.string() + " for key " + k.string() + " is = " + hop_cnt_avg.string())
    end
  
  fun notify_all(req_cnt: F64, m: USize)=>
    // we create "numReqs" keys and then send same requests to all nodes in the network
    try 
      let rand = Rand
      for i in Range(0, req_cnt.usize()) do
        env.out.print("Performing request number " + i.string())
        let index = ((rand.usize()) % (nodes.size()))
        let k = nodes(index)?
       
        // for each node, perform same key lookup operation
        for node_id in nodes.values() do
          try 
            network_state(node_id)?.lookup(k,0, this)? 
          end     
        end
      end
    end
  
  fun ref generate_finger_table(m:USize val)=>
    let nodes_dup: Array[USize] = nodes.clone()

    for node_id in nodes.values() do
      var base: F64 = 2
      var cnt: F64 = 0
      var f: USize = 0
      while cnt<m.f64() do
        // calculate next successor id to map into finger table
        let next_succ_id = (node_id + (((base.pow(cnt)).usize()) % ((base.pow(m.f64())).usize())))
      
        try
          var s = sorted_nodes.size()
          for i in Range(0, s) do
            for j in Range(0, s -i -1) do
              if sorted_nodes(j+1)? < sorted_nodes(j)? then
                let tmp = sorted_nodes(j+1)?
                sorted_nodes(j+1)? = sorted_nodes(j)?
                sorted_nodes(j)? = tmp
              end
            end
          end
        end
      
        for curr_id in sorted_nodes.values() do
          if curr_id >= next_succ_id then
            f = 1
            try 
              network_state(node_id)?.update_finger_table(cnt.usize(),curr_id)? 
            end
            break
          end
        end

        if f != 1 then
          try 
            network_state(node_id)?.update_finger_table(cnt.usize(),sorted_nodes(0)?) ? 
          end    
        end

        cnt = cnt+1
      end
    end

actor CNode
  var env: Env
  let m: USize
  let node_id: USize
  var succ_node: USize
  var finger_table: Map[USize, USize]
  let ring_network: ChordRing
  
  new create(env': Env, id': USize, m': USize, ring_network': ChordRing)=>
    node_id = id'
    m = m'
    ring_network = ring_network'
    finger_table = Map[USize, USize]
    succ_node = 0
    env = env'
  
  // find closest preceding node
  fun closest_preceding_node(k: USize): USize=>
    var f: USize = 0
    
    for i in (finger_table.values()) do
      if i < k then
        f = 1
        return i
      end
    end

    if f != 1 then
      return succ_node  
    end

    f = 2
  
  // update finger table
  be update_finger_table(i: USize, closestNode: USize)=>
    finger_table.insert(i, closestNode)
  
  fun search_key(k: USize): Bool =>
    if node_id < succ_node then
      (node_id < k) and (k <= succ_node)
    else
      (node_id < k) or (k <= succ_node)
    end
  
  be lookup(k: USize, hops:F64, reference_network: ChordRing)=>
    if search_key(k) then
      ring_network.final_fun_call(node_id, k, hops)
    else
      let next_node = closest_preceding_node(k)
      reference_network.lookup_node(next_node, k,hops+1, reference_network)
    end

actor Main
  var num_nodes: USize = 64
  var num_reqs: F64 = 4
  
  new create(env: Env) =>
    try 
      num_nodes = env.args(1)?.usize()?
      num_reqs = env.args(2)?.f64()? 
    end

    // create chord ring network
    ChordRing(env, num_nodes, num_reqs)