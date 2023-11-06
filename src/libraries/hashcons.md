# Understanding `Hashcons`

## Motivation

_Aside_. Data, value, object, component in this post means the same thing but from different perspectives.

_Folklore_. Hash-consing, as the name may suggest, is a hash value cons-ed (appended) after the immutable data (hash key). The immediate benefit is to reuse the hash value for the unchanged data. When used in recursive datatypes, the hash value of a data can be computed from the new payload part and the recursive part whose hash value is already cons-ed.

_One-step further_. It's obvious hash-consing is straightforward for immutable data. However, with immutable data, more aggresive designs can be made. Hash-consing libraries in real-world usually coincide with [Flyweight pattern](https://en.wikipedia.org/wiki/Flyweight_pattern). They have the same targets:

1. Encapsulate the object creation so that any distinct object is created just once.
2. Generate and save a **unique id** to identify distinct objects.
3. Save the hash value in the objects and choose a hash function that is aware of the saved hash values for its recursive components.

## Some Concept (or Implementation) Details

_Hash functions_. With a unique id cons-ed, the datatype can provide a new `equal` function and a new `hash` function based on this id. In whole scenarios, three `hash` functions can be used.

1. Global `hash`. Language provide e.g. `Hashtbl.hash`. It's used internally for convenience.
2. Data's `hash`. The hash function for your hash-consed data provided by users.
3. Hash-consing library `hash`. The hash function for your hash-consed data provided by the library.

The existence and difference between **2** and **3** is not so clear depending on the library design. However, the ultimate target is to provide a better **2** with or without **3** than the old structural `hash`.

_Weak references_. Hash-consing library needs to provide an internal store to save the unique objects. This storage can be a *weak* array or a *weak* hash table. The internal storage should be *weak* because it should not prevent the garbage collection if any elements are not used outside.

_Hash collision_. Hash collision and hash resize is handled during the process to generate the unique id with the internal storage. The data's `equal` and data's `hash` function will be used. Data's `hash` collision outside of the internal storage is not concerned here.

_Structural equality_. A natural consequence of unique objects and ids is the structural equality check between two values can be replaced by physical equality. Refresh: structural equality checks whether two values per-component of their structures. Physical equality checks whether two values are at the same memory address. If all the objects is created inside the hash consing library, strutural equality can be replaced by phisical equality. `=` in OCaml approximates a structural equality check. `==` in OCaml is phisical equality check.

## Reading library code

Now we are ready to look closely into two OCaml libraries `backtracking/ocaml-hashcons` (`hashcons` on opam) and `fpottier/fix` with `Fix.HashCons` (`fix` on opam).

### `backtracking/ocaml-hashcons`

The repo is [backtracking/ocaml-hashcons](https://github.com/backtracking/ocaml-hashcons).

[`hashcons.mli`](https://github.com/backtracking/ocaml-hashcons/blob/master/hashcons.mli) defines the type:

```ocaml
type +'a hash_consed = private {
  hkey: int;
  tag : int;
  node: 'a;
}
```

It's a bit subtle since `hkey` is computed _value_ from the user-provided `H.hash` on the data before adding to the internal store. `tag` is the unique id which is either old from a previous object or new if added. `node` is the data before hash-consed.

The following code snippets are from [`test.ml`](https://github.com/backtracking/ocaml-hashcons/blob/master/test.ml) :

```ocaml
open Hashcons

(* a quick demo of Hashcons using lambda-terms *)

type node =
  | Var of string
  | App of term * term
  | Lam of string * term
and term = node hash_consed

(* the key here is to make a O(1) equal and hash functions, making use of the fact that sub-terms are already hash-consed and thus we can 
   1. use == on sub-terms to implement equal
   2. use .tag from sub-terms to implement hash 
   *)
module X = struct
  type t = node
  let equal t1 t2 = match t1, t2 with
    | Var s1, Var s2 -> s1 = s2
    | App (t11, t12), App (t21, t22) -> t11 == t21 && t12 == t22
    | Lam (s1, t1), Lam (s2, t2) -> s1 = s2 && t1 == t2
    | _ -> false
  let hash = function
    | Var s -> Hashtbl.hash s
    | App (t1, t2) -> t1.tag * 19 + t2.tag
    | Lam (s, t) -> Hashtbl.hash s * 19 + t.tag
end
module H = Make(X)

let ht = H.create 17
let var s = H.hashcons ht (Var s)
let app t1 t2 = H.hashcons ht (App (t1,t2))
let lam s t = H.hashcons ht (Lam (s,t))

let x = var "x"
let delta = lam "x" (app x x)
let omega = app delta delta

let () = assert (var "x" == x)
let () = assert (app x x == app x x)
```

`X.hash` is the data's `hash`. Global `hash` is used both in `X.hash` inside of [`H.hashcons`](https://github.com/backtracking/ocaml-hashcons/blob/872594154dd263334a8f79822f99f1065832d383/hashcons.ml#L110). `X.equal` uses physical equality for objects. `X.hash` also uses the unique ids for components. The last two `assert`s check the objects created at different application shares the same memory addresses.

Module `Hashcons` also provides `Hset` and `Hmap`. They're external containers which is aware of your hash-consed data. Don't confuse them with the internal storage, which is also a hash-based container.


### `fpottier/fix`

The repo is [fpottier/fix](https://gitlab.inria.fr/fpottier/fix).

`Fix.HashCons`([ml](https://gitlab.inria.fr/fpottier/fix/-/blob/master/src/HashCons.ml),[mli](https://gitlab.inria.fr/fpottier/fix/-/blob/master/src/HashCons.mli)) looks very lightweighted because the internal storage is achieved by another module `Fix.MEMOIZER`. 

```ocaml
type 'data cell =
  { id: int; data: 'data }
```

`id` is the unique id while `data` is your datatype to hash-cons. The another difference worth mentioning is with `backtracking/ocaml-hashcons` the user is in change of the objects pool getting from `H.create` while with `Fix.HashCons` the pool is shared. It's explained in [HashCons.ml](https://gitlab.inria.fr/fpottier/fix/-/blob/master/src/HashCons.ml?ref_type=heads#L19).

```ocaml
(* M : MEMOIZER *)
let make =
    M.memoize (fun data -> { id = gensym(); data })
```

`MEMOIZER` is a module relying on the user-provide `Map.S` which contains `find` and `add`. No data's `hash` is required, but making `MEMOIZER` requires a `HashedType`. The result module of `HashCons.Make` provides a `hash` which relies on the unique id.

The demo code [demos/hco
HashConsDemo.ml](https://gitlab.inria.fr/fpottier/fix/-/blob/master/demos/hco/HashConsDemo.ml) is challenging to read if one is not aware of these `hash` functions in use.

```ocaml
open Fix

module MySkeleton = struct
  type 'a t =
    | Leaf
    | Node of int * 'a * 'a

  let equal equal sk1 sk2 =
    match sk1, sk2 with
    | Leaf, Leaf ->
        true
    | Node (x1, l1, r1), Node (x2, l2, r2) ->
        x1 = x2 && equal l1 l2 && equal r1 r2
    | Node _, Leaf
    | Leaf, Node _ ->
        false

  let hash hash sk =
    match sk with
    | Leaf ->
        0
    | Node (x, l, r) ->
        x + hash l + hash r
end

type tree =
  skeleton HashCons.cell

and skeleton =
  S of tree MySkeleton.t [@@unboxed]

module M =
  HashCons.ForHashedTypeWeak(struct
    type t = skeleton
    let equal (S sk1) (S sk2) =
      MySkeleton.equal HashCons.equal sk1 sk2
    let hash (S sk) =
      MySkeleton.hash HashCons.hash sk
  end)

let leaf () : tree =
  M.make (S MySkeleton.Leaf)

let node x l r : tree =
  M.make (S (MySkeleton.Node (x, l, r)))

let example() =
  node 0
    (leaf())
    (leaf())

let () =
  assert (example() == example());
  Printf.printf "Size of example tree is %d.\n" (size (example()));
  print_endline "Success."
```

`MySkeleton` provides `equal` and `hash`, which require another `equal` and `hash` as arguments respectively. The hash-consing aware `equal` and `hash` is provided in `HashCons.ForHashedTypeWeak`. The resulting code shares the same motivation as the previous demo.

## Summary and Questions (To-do)

I am short on time to polish the post and complete all my to-do now. My motivation is the fixed point computation runs very slow on several test cases, and the profiling results show it's doing too much repeated structural hashing. The post mainly shares how to understand hash-consing libraries. _If I may_, I will rename both `hash consing` or `flyweight` to `with_unique` or `with_uid`.

Besides these two OCaml libraries, I also refer to [wiki/Hashconing](https://en.wikipedia.org/wiki/Hash_consing) and papers

- Sylvain Conchon and Jean-Christophe Filliâtre. Type-Safe Modular Hash-Consing. In ACM SIGPLAN Workshop on ML, Portland, Oregon, September 2006.
- Implementing and reasoning about hash-consed data structures in Coq

How to bring hash-consing to `Core` is my immediate problem.

Furthermore, as string intern is widely used for many languages, why is hash-consing not the default implementation inside OCaml compilers?

The functions on the raw types need to be reimplemented with the hash cons-ed type with just tedious fmap. Is it another case for the _Expression Problem_ or _Open Recursion_?

I am also interested in the implementation of [camlp5/pa_ppx_hashcons](https://github.com/camlp5/pa_ppx_hashcons) and [coq-core/Hashcons](https://coq.inria.fr/doc/master/api/coq-core/Hashcons/index.html).