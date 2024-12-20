# COP5615 Distributed Operating System Principles#
## University of Florida
### Collaborators:
Sravani Garapati (sravanigarapati@ufl.edu)
Sanket Deshmukh (sanket.deshmukh@ufl.edu)

## Master-Slave System : Lucas Square Pyramid
An interesting problem in arithmetic with deep implications for elliptic curve theory is the problem of finding perfect squares that are sums of consecutive squares. A classic example is the Pythagorean identity:
3^2 + 4^2 = 5^2
That reveals that the sum of squares of 3, 4 is itself a square. A more interesting example is Lucas‘ Square Pyramid :
1^2 + 2^2 + ... + 24^2 = 70^2
In both these examples, sums of squares of consecutive integers from the square of another integer. The goal of this project is to use Pony and the actor model to build a good solution to this problem that runs well on multi-core machines.

Task: Given n, k, find sequences of k consecutive numbers s1, s2, s3,.......sk in the range(1, n), such that s1^2 + s2^2 + s3^2 + .....+ sk^2 = S^2 where S is a Natural Number.

# Code:
This is an _Asynchronised_ Multi-Actor model that employs _Parallelism_.
The Main actor is the snippet where the actors return after they are done. Here, we initialize
> num_actors = n/(2*k) + 1.
> chunk_size _(size of Work Unit)_ = (n+k)/num_actors
We assign each chunk_size to each actor to scan for a sequence in that particular chunk. We initialize two iterators _start_ and _finish_ to determine the size of each work unit for an actor and keep track of actors that finished using __pending_actors_.
> start = finish + (2 - k)
> finish = (start + chunk_size + k)
> _pending_actors = num_actors
```
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
```
We run a _while loop_ which calls the _Luca_ function from the other Actor that has the logic that does the computation and search.
The **behaviour** _partial_sum_ of the Main Actor handles the actors that returned after they finish and updates the __pending_actors_. It returns altogether at the end of the program.
```
// behaviour to which the Luca Actor returns and in which the end result is printed
  be partial_search_res(result: U128) =>
    _pending_actors = _pending_actors - 1
    if _pending_actors == 0 then
      _env.out.print("Done!!!")
    end
```
The Actor Luca as mentioned above has the computation and search algorithm for each Actor and it's chunk_size.
```
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
```


