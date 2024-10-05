use "collections"

actor Node
  let env: Env
  let id: U64
  var x: F64
  var y: F64
  var z: F64
  var neighbors: Array[Node tag] = Array[Node tag]

  new create(env': Env, id': U64, x': F64, y': F64, z': F64) =>
    env = env'
    id = id'
    x = x'
    y = y'
    z = z'

  be add_neighbor(neighbor: Node tag) =>
    neighbors.push(neighbor)

  be update_position(new_x: F64, new_y: F64, new_z: F64) =>
    x = new_x
    y = new_y
    z = new_z

  be get_info(callback: {(U64, F64, F64, F64, USize)} iso) =>
    callback(id, x, y, z, neighbors.size())

  be print_info() =>
    env.out.print("Node " + id.string() + " at (" + x.string() + ", " + y.string() + ", " + z.string() + ") with " + neighbors.size().string() + " neighbors")

actor Main
  let env: Env
  let nodes: Map[U64, Node tag] = Map[U64, Node tag]

  new create(env': Env) =>
    env = env'
    create_mesh()

  be create_mesh() =>
    // Create a 3x3x3 mesh of nodes
    for i in Range(0, 3) do
      for j in Range(0, 3) do
        for k in Range(0, 3) do
          let id = (i * 9) + (j * 3) + k
          let node = Node(env, id.u64(), i.f64(), j.f64(), k.f64())
          nodes(id.u64()) = node
        end
      end
    end

    // Connect neighboring nodes
    for (id, node) in nodes.pairs() do
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
            node.add_neighbor(nodes(neighbor_id)?)
          end
        end
      end
    end

    // Print node information
    for node in nodes.values() do
      node.print_info()
    end
