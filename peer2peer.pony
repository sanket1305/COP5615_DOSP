actor Main
  let _env: Env
  var _pending_actors: U128 = 0
  new create(env: Env) =>
    _env = env
    try
      let n = _env.args(1)?.usize()?.u128()
      let k = _env.args(2)?.usize()?.u128()
      let num_actors: U128 = (n/(2*k)) + 1 // Divide the task among actors
      let chunk_size: U128 = (n+k)/num_actors
      _pending_actors = num_actors
      var start : U128 = 1
      var finish : U128 = start + chunk_size
      var i: U128 = 1
      while(i <= num_actors) do
        // let start: U128 = if i == 1 then 1 else ((i-1) * chunk_size) - (k+1) end
        // let finish: U128 = if i == (num_actors - 1) then n+k else (start+chunk_size) end
        Luca(this, start, finish, k, env)
        start = finish + (2 - k)
        finish = (start + chunk_size + k)
        i = (i + 1)
    end
    else
      _env.out.print("Please enter valid numbers")
    end
    

  be partial_sum(result: U128) =>
    // if result != 0 then 
    //   _env.out.print(result.string())
    // end
    _pending_actors = _pending_actors - 1
    if _pending_actors == 0 then
      _env.out.print("Done!!!")
    end
    // if result != 0 then
    //   _env.out.print(result.string())
    // end
    // _pending_actors = _pending_actors - 1
    // if _pending_actors == 0 then
    //   _env.out.print("No such sequence found. Please try again !!!")
    // end

actor Luca
  let _main: Main
  let _start: U128
  let _finish: U128
  let _k: U128
  let _env: Env

  new create(main: Main, start: U128, not_start: U128, k: U128, env: Env) =>
    _main = main
    _start = start
    _finish = not_start
    _k = k
    _env = env
    calculate_sum()

  fun calculate_sum() =>
    var sum: U128 = 0
    var count : U128 = 0
    var i: U128 = _start
    while (i < (_finish + 1)) do
      sum = sum + (i*i)
      i = i + 1
      count = count + 1
      if count == _k then
        var res : F64 = sum.f64().sqrt()
        let isint : Bool = ((res - res.floor()) == 0)
        if isint then
          // _main.partial_sum(i-_k)
          _env.out.print((i-_k).string())
        // else
        end
          sum = sum - ((i-_k)*(i-_k))
          count = count - 1
        // end
      end
    end
    _main.partial_sum(0)
