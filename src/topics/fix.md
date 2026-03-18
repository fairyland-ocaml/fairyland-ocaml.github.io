# Fix

(In math, a trivial example for `f` is `f x = x`. The result of `fix f` is `0` so that `0 = f 0 = 0`.)

I am asked once why to understand the fixed point computation of the abstract interpretation from the equation `fix f = f (fix f)`? I have thought about it and this is my explanation.

A simple example for `f` is `fun self -> fun n -> if n = 0 then 0 else n + self (n - 1)`. One answer for `fix f` can be like `fun n -> if n = 0 then 0 else n + self (n - 1)` where `self` points to itself. How can `self` points to itself is related to the concrete language. In untyped language calculus, `Y f` can be `fix f`. In OCaml, we can define `f` with `let rec f = ...`.

We can type these terms:
- `f : (int -> int) -> (int -> int)`
- `fix : (int -> int) -> (int -> int) -> (int -> int)`
- `fix f : int -> int`
- `f (fix f) : int -> int`

We can name the above `f` as `mk_sum`. `mk_sum` is obviously not the (denotational) answer `sum`, which has type `int -> int`. We have `sum = fix mk_sum = mk_sum (fix mk_sum) = mk_sum sum`.

Now consider the abstract interpretation case. The answer `aeval : aenv -> set_of_aval` is a fixed-point for `mk_aeval : (aenv -> set_of_aval) -> (aenv -> set_of_aval)`.

Now we have `aeval = fix mk_aeval = mk_aeval (fix mk_aeval)`. However, since `mk_aeval` is not an encoding of _a recursive function_, but an encoding of _a system of monotone equations_. The syntax looks similar but the meaning differs e.g. handling self-loop. We have to solve it in other methods instead using a `Y mk_aeval` here.