actor Main
  let _env: Env
  let n : U64 = 1000
  let k : U64 = 5
  var _final_sum: U64 = 0
  var _pending_actors: U64 = 0

  new create(env: Env) =>
    _env = env
    // let n: U64 = 10_000_000_000_000_000_000_000_000  // N = 10^10
    let num_actors: U64 = 8  // Divide the task among 10 actors
    let chunk_size: U64 = n/num_actors
    _pending_actors = num_actors

    var i: U64 = 0
    while(i < num_actors) do
      let start: U64 = if i == 1 then 0 else (i * chunk_size) - (k + 1) end
      let finish: U64 = if i == (num_actors - 1) then n else (i + 1) * chunk_size end
      SumActor(this, start, finish)
      i = (i + 1)
    end

  be partial_sum(result: U64) =>
    // _final_sum = _final_sum + result * res
    if result != 0 then
      _env.out.print(result.string())
    end
    _pending_actors = _pending_actors - 1
    if _pending_actors == 0 then
      _env.out.print("No such sequence found. Fuck off")
    end

actor SumActor
  let _main: Main
  let _start: U64
  let _finish: U64
  let _k: U64

  new create(main: Main, start: U64, not_start: U64) =>
    _main = main
    _start = start
    _finish = not_start
    _k = _main.k
    calculate_sum()

  fun calculate_sum() =>
    var sum: U64 = 0
    var count : U64 = 0
    var i: U64 = _start
    while (i < (_finish + 1)) do
      sum = sum + (i*i)
      i = i + 1
      count = count + 1
      if count == _k then
        var res : (U64 | F64) = sum.f64().sqrt()
        let isint : Bool = match res
          | U64 => true
          | F64 => false
        end
        if isint then
          _main.partial_sum(i-_k)
        else
          sum = sum - ((i-_k)*(i-_k))
          count = count - 1
        end
      end
    end
    _main.partial_sum(0)
