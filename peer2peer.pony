actor Main
  let _env: Env
  var n : U128 = 100
  let k : U64 = 24
  var _final_sum: U128 = 0
  var _pending_actors: U64 = 0
  var flag : U32 = 0

  new create(env: Env) =>
    _env = env
    let num_actors: U64 = 4 // Divide the task among 8 actors
    n = n+k.u128()
    let chunk_size: U128 = (n/num_actors.u128())
    _pending_actors = num_actors

    var i: U64 = 1
    while(i <= num_actors) do
      let start: U128 = if i == 1 then 1 else (i.u128() * chunk_size) - (k.u128() + 1) end
      let finish: U128 = if i == (num_actors - 1) then n else (i.u128() + 1) * chunk_size end
      SquareSumActor(this, start, finish, k, _env)
      i = (i + 1)
    end
  
  be partial_search_res(result: U128) =>
    if result != 0 then
      flag = 1
      _env.out.print(result.string())
      return
    end
    _pending_actors = _pending_actors - 1
    if (_pending_actors == 0) and (flag != 1) then
      _env.out.print("No such sequence found. Fuck off")
    end

actor SquareSumActor
  let _main: Main
  let _start: U128
  let _finish: U128
  let _k: U64
  
  new create(main: Main, start: U128, not_start: U128, k: U64, env: Env) =>
    _main = main
    _start = start
    _finish = not_start
    _k = k
    lucas_square_sum(env)

  fun lucas_square_sum(env: Env) =>
    var sum: U128 = 0
    var count : U64 = 0
    var i: U128 = _start
    let kvar = _k.u128()
    while (i < (_finish + 1)) do
      sum = sum + (i*i)
      i = i + 1
      count = count + 1
      if count == _k then
        // env.out.print(sum.string())
        var root : F64 = sum.f64().sqrt()
        let truncated_root: U128 = root.trunc().u128()  // Truncate and convert to U128
        if truncated_root.f64() == root then
          _main.partial_search_res(i-kvar)
        else
          sum = sum - ((i-kvar)*(i-kvar))
          count = count - 1
        end
      end
    end
    _main.partial_search_res(0)
