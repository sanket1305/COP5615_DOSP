use "net"
actor Main
  let _env: Env
  var n : U64 = 100
  var k : U64 = 2
  var _final_sum: U64 = 0
  var _pending_actors: U64 = 0

  new create(env: Env) =>
    _env = env
    // let input = InputHandler(env)  // Create an actor to handle input
    // _env.input.read(input)
    // _env.out.print(input)
    let num_actors: U64 = 2 // Divide the task among 8 actors
    n = n+k
    let chunk_size: U64 = (n/num_actors)
    _pending_actors = num_actors

    var i: U64 = 1
    while(i <= num_actors) do
      let start: U64 = if i == 1 then 1 else ((i * chunk_size) + (1-k)) end
      let finish: U64 = if i == (num_actors - 1) then n else (i + 1) * chunk_size end
      SquareSumActor(this, start, finish, k, _env)
      i = (i + 1)
    end
  
  be partial_search_res(fl: U8) =>
    _pending_actors = _pending_actors - 1
    if (_pending_actors == 0) and (fl != 1) then
      _env.out.print("No such sequence found. Fuck off")
    end

actor SquareSumActor
  let _main: Main
  let _start: U64
  let _finish: U64
  let _k: U64
  
  new create(main: Main, start: U64, not_start: U64, k: U64, env: Env) =>
    _main = main
    _start = start
    _finish = not_start
    _k = k
    lucas_square_sum(env)

  fun lucas_square_sum(env: Env) =>
    var sum: U64 = 0
    var count : U64 = 0
    var i: U64 = _start
    var fl: U8 = 0
    while (i < (_finish + 1)) do
      sum = sum + (i*i)
      i = i + 1
      count = count + 1
      if count == _k then
        // env.out.print(sum.string())
        var root : F64 = sum.f64().sqrt()
        let truncated_root: U64 = root.trunc().u64()  // Truncate and convert to U64
        if truncated_root.f64() == root then
          fl = 1
          env.out.print((i-_k).string())
        else
          fl = 0
          sum = sum - ((i-_k)*(i-_k))
          count = count - 1
        end
      end
    end
    _main.partial_search_res(fl)



// actor InputHandler
//   let _env: Env

//   new create(env: Env) =>
//     _env = env

//   // This behavior will be called once input is received
//   be apply(data: String iso) =>
//     _env.out.print("Hello, " + data)