actor Main
  let _env: Env
  var _pending_actors: U128 = 0
  new create(env: Env) =>
    _env = env
    try
      // input n, k from the console
      let n = _env.args(1)?.usize()?.u128()
      let k = _env.args(2)?.usize()?.u128()
      // Divide the task among actors and assign the work unit size
      let num_actors: U128 = (n/(2*k)) + 1 
      let chunk_size: U128 = (n+k)/num_actors
      // updates the actor count
      _pending_actors = num_actors
      // pointers to the chunks for each actor
      var start : U128 = 1
      var finish : U128 = start + chunk_size
      var i: U128 = 1
      // loops through the implementation for each actor using Luca 
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
    
  // behaviour to which the Luca Actor returns and in which the end result is printed
  be partial_search_res(result: U128) =>
    _pending_actors = _pending_actors - 1
    if _pending_actors == 0 then
      _env.out.print("Done!!!")
    end

// Actor that does all the computation
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
    luca_square_seq()
  // function for logic implementation for sequence search in a chunk
  fun luca_square_seq() =>
    var sum: U128 = 0
    var count : U128 = 0
    var i: U128 = _start
    // loop for finding sequence in a chunk
    while (i < (_finish + 1)) do
      sum = sum + (i*i)
      i = i + 1
      count = count + 1
      if count == _k then
        var res : F64 = sum.f64().sqrt()
        let isint : Bool = ((res - res.floor()) == 0)
        if isint then
          _env.out.print((i-_k).string())
        end
          sum = sum - ((i-_k)*(i-_k))
          count = count - 1
      end
    end
    // returns to the behaviour in Main
    _main.partial_search_res(0)
