actor Main
  let _env: Env
  let n : U64 = 40
  let k : U64 = 24
  var _final_sum: U64 = 0
  var _pending_actors: U64 = 0

  new create(env: Env) =>
    _env = env
    let num_actors: U64 = 1  // Divide the task among 10 actors
    let chunk_size: U64 = n/num_actors
    _pending_actors = num_actors

    var i: U64 = 0
    while(i < num_actors) do
      let start: U64 = if i == 1 then 0 else (i * chunk_size) - (k + 1) end
      let finish: U64 = if i == (num_actors - 1) then n else (i + 1) * chunk_size end
      Luca(this, start, finish, k, env)
      i = (i + 1)
    end

  be partial_sum(result: U64) =>
    // _final_sum = _final_sum + result * res
    if result != 0 then
      _env.out.print(result.string())
    end
    _pending_actors = _pending_actors - 1
    if _pending_actors == 0 then
      _env.out.print("No such sequence found. Try again !!!")
    end

actor Luca
  let _main: Main
  let _start: U64
  let _finish: U64
  let _k: U64
  let _env: Env

  new create(main: Main, start: U64, not_start: U64, k: U64, env: Env) =>
    _main = main
    _start = start
    _finish = not_start
    _k = k
    _env = env
    calculate_sum()

  fun calculate_sum() =>
    var sum: U64 = 0
    var count : U64 = 0
    var i: U64 = _start
    _env.out.print("calculate_sum: start " + _start.string() + "end " + _finish.string())
    while (i < (_finish + 1)) do
      _env.out.print("inside while " + i.string())
      sum = sum + (i*i)
      i = i + 1
      count = count + 1
      if count == _k then
        var res : F64 = sum.f64().sqrt()
        let isint : Bool = ((res - res.floor()) != 0)
        _env.out.print("count == k ")
        if isint then
          _main.partial_sum(i-_k)
        else
          sum = sum - ((i-_k)*(i-_k))
          count = count - 1
        end
      end
    end
    _main.partial_sum(0)
