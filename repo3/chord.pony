use "collections"
use "crypto"



interface val Callback
  fun apply(result: (String | None)): None

actor Node
  let _id: U64
  var _predecessor: (Node | None)
  var _successor: Node
  let _finger_table: Array[Node]
  let _keys: Map[U64, String]

  new create(id: U64) =>
    _id = id
    _predecessor = None
    _successor = this
    _finger_table = Array[Node].init(this, 64)
    _keys = Map[U64, String]

  be join(node: Node) =>
    node.find_successor(_id, {(successor: Node) =>
      _successor = successor
      successor.notify_predecessor(this)
    })

  be find_successor(id: U64, callback: {(Node)} iso) =>
    if (_id < id) and (id <= _successor._id) then
      callback(_successor)
    else
      let next = closest_preceding_node(id)
      next.find_successor(id, consume callback)
    end

  fun ref closest_preceding_node(id: U64): Node =>
    for i in Range(63, -1, -1) do
      let finger = _finger_table(i)?
      if (_id < finger._id) and (finger._id < id) then
        return finger
      end
    end
    this

  be notify_predecessor(node: Node) =>
    _predecessor = node

  be stabilize() =>
    _successor.get_predecessor({(pred: (Node | None)) =>
      match pred
      | let p: Node =>
        if (_id < p._id) and (p._id < _successor._id) then
          _successor = p
        end
      end
      _successor.notify_predecessor(this)
    })

  be fix_fingers() =>
    for i in Range(0, 64) do
      let next_id = (_id + (1 << i)) % (1 << 64)
      find_successor(next_id, {(node: Node) =>
        _finger_table(i)? = node
      })
    end

  be put(key: String, value: String) =>
    let hash = SHA256(key)
    let key_id = hash.u64()
    find_successor(key_id, {(node: Node) =>
      node.store(key_id, value)
    })

  be store(key_id: U64, value: String) =>
    _keys(key_id) = value
  
  
  be get(key: String, callback: Callback iso) =>
    let hash = SHA256(key)
    let key_id = hash.u64()
    find_successor(key_id, {(node: Node) =>
      node.retrieve(key_id, consume callback)
    })

  be retrieve(key_id: U64, callback: Callback iso) =>
    callback(_keys.get_or_else(key_id, None))

actor ChordNetwork
  let _nodes: Array[Node]

  new create(size: USize) =>
    _nodes = Array[Node](size)
    for i in Range(0, size) do
      let node = Node(i.u64())
      _nodes.push(node)
      if i > 0 then
        node.join(_nodes(0)?)
      end
    end

  be stabilize_network() =>
    for node in _nodes.values() do
      node.stabilize()
      node.fix_fingers()
    end

actor Main
  new create(env: Env) =>
    let network = ChordNetwork(10)
    network.stabilize_network()
    
    // Example usage
    let node = network._nodes(0)?
    node.put("key1", "value1")
    node.get("key1", object iso is Callback
      fun apply(result: (String | None)): None =>
        match result
        | let value: String =>
          env.out.print("Retrieved value: " + value)
        | None =>
          env.out.print("Key not found")
        end
      end)  // Closing 'end' for the object literal