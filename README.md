#COP5615 Distributed Operating System Principles#
##University of Florida
###Collaborators:
Sravani Garapati (sravanigarapati@ufl.edu)
Sanket Deshmukh (sanket.deshmukh@ufl.edu)

##Master-Slave System : Lucas Square Pyramid
An interesting problem in arithmetic with deep implications for elliptic curve theory is the problem of finding perfect squares that are sums of consecutive squares. A classic example is the Pythagorean identity:
3^2 + 4^2 = 5^2
That reveals that the sum of squares of 3, 4 is itself a square. A more interesting example is Lucas‘ Square Pyramid :
1^2 + 2^2 + ... + 24^2 = 70^2
In both these examples, sums of squares of consecutive integers from the square of another integer. The goal of this project is to use Pony and the actor model to build a good solution to this problem that runs well on multi-core machines.

Task: Given n, k, find sequences of k consecutive numbers s1, s2, s3,.......sk in the range(1, n), such that s1^2 + s2^2 + s3^2 + .....+ sk^2 = S^2 where S is a Natural Number.

#Code:
This is an Asynchronised Multi-Actor model that employs paralellism.
The Main actor is the snippet where the actors return after their work is done. Here, we take >num_actors = n/(2*k) + 1.
```
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
        Luca(this, start, finish, k, env)
        start = finish + (2 - k)
        finish = (start + chunk_size + k)
        i = (i + 1)
    end
    else
      _env.out.print("Please enter valid numbers")
    end
    

  be partial_sum(result: U128) =>
    _pending_actors = _pending_actors - 1
    if _pending_actors == 0 then
      _env.out.print("Done!!!")
    end
```






