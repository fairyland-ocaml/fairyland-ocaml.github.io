# Monad: Motivation, Friends, and Examples (in OCaml)

Family resemblance (German: Familienähnlichkeit)

# Informal

## Examples

> A list is a monad

> Optional is a monad

> state monad

> A monad is just a monoid in the category of endofunctors, what's the problem?
> (You should be able to understand this after the talk)

## Not-the-Topic

The concept of **monad** is heavily related to Category Theory. We will not cover those.

Philip Wadler's seminal papers _Monads for functional programming_ ([1990b])

[Group-like Structures](group-like-structures.png)

We will not use (F-)algebra perspective to reason types.

We will not concern terminaing or not.

For the lab's sake, it's an OCaml-orietned talk. Speicifically, we will use

1. OCaml universal (explicitly polymorphic) type varaible `type 'a t = ...`.

2. OCaml module systems: module signatures, module implementation, module functors.

3. I will refer OCaml library [preface](https://github.com/xvw/preface) a lot. It's an OCaml port for many abstraction used in Haskell.

## Fixed point for free

```ocaml
(* recursive function with fixed point for functions *)
let rec sum x = 
  if x = 0 then 0 else x + sum (x-1)

(* recursive function without fixed point *)
let rec mk_sum this x = 
  if x = 0 then 0 else x + this (x-1)

let sum = Y mk_sum

(* recursive types with fixed point for types *)
type 'a list = Nil | Cons of 'a * 'a list

(* recursive types without fixed point *)
type 'a list = μ t . Nil | Cons of 'a * t

(* step-wise type definition *)
(* data ListF A X = NilF | ConsF A X *)
type ('a, 'x) listF = NilF | ConsF of 'a * 'x
NilF : ('a, 'b) listF
ConsF (0, NilF) : (int, ('a, 'b) listF) listF
ConsF (0, ConsF (0, NilF)) : (int, (int, ('a, 'b) listF) listF) listF
ConsF (0, ConsF ("a", NilF)) : (int, (string, ('a, 'b) listF) listF) listF

(* [] *)
Nil : 'a list

(* [0] *)
Cons(0, Nil) : int list

(* [ 0; 1 ] *)
Cons(0, Cons(1, Nil)) : int list

(* [ 0; "a" ] *)
Cons(0, Cons("a", Nil)) (* type error *)

(* [ [] ] *)
Cons(Nil, Nil) : ('a list) list

(* [ [ [] ] ] *)
Cons(Cons(Nil, Nil), Nil) : (('a list) list) list
```

## Specs

![Typeclasspedia](https://wiki.haskell.org/wikiupload/d/df/Typeclassopedia-diagram.png)

Typeclasspedia on Haskell wiki

![Specs](https://ocaml-preface.github.io/images/specs.svg)

Typeclasspedia on OCaml preface

## What for?

**Monads and friends** are some artifacts (or _a priori constructs_) of certain types.

Those types of interest have expected good static properties in type-check.

Therefore, the values in those types have expected good dynamic properties or invariants.

## Aside: Invariants

```ocaml
module type Int_set = sig
  type t

  val empty : t
  val add : int -> t -> t
  val remove : int -> t -> t
end

module My_set : Int_set = struct ... end

(* invariant 1 *)

My_set.(empty |> add e) 
My_set.(empty |> add e |> add e)

(* invariant 2 *)

My_set.(empty) 
My_set.(empty |> add e |> remove e)
```

The invariants for data structures usually concern implementation integrity.

## Type structures

Type ingridients (valid type expresions)

```ocaml
type t = int
type 'a t = Tag of 'a
type ('a, 'b) t = Foo of 'a | Bar of 'b
type int_str_pair = int * string
type ('a, 'b, 'c) three_tuple = 'a * 'b * 'c

type int_dumper = int -> ()
type 'a dumper = 'a -> ()
type 'a fmt = formatter -> 'a -> ()
```

*Monads and friends* form a taxonomy for these type ingridients.

## Core ideas for monads and friends

1. *Monads and friends* are for composing computations (functions).

2. Each signature of *monads and friends* has `type 'a t` and miscellaneous types for operations (functions).
Note `t` in the `'a t` is what the implementation concretely defines. `'a` in the `'a t` is the universal type's requirement

3. The implementation of *monads and friends* should have dynamic properties or invariants. OCaml type system may not help to check them.

4. Each *monads and friends* may have multiple minimal definitions: they are inter-definable.

## Core ideas for monads and friends (shortly)

1. composing computations
2. define `'a t` and others
3. invariants
4. inter-definable minimal definitions

(the last slide/paragraph for introducing monads)

## Composibility

![Killing 3000](killing-3000.png)

*Monads and friends* composes things under their types.

What does **compose** here mean? (I hope it's the correct english word)

1. It can compose individual things into a composed thing.

2. When _applying_ dynamically (running), it makes no difference either to apply individual things one-by-one or apply the composed thing.

3. *Monads and friends* allow different dynamic flexibility: does the type require a concrete thing or an abstract thing that can be decided at runtime?

## A Correspondence between deep and shallow compose

```ocaml
let deep_compose2 (op1 : 'a t) (op2 : 'b t) : ('b t) t = 
let deep_compose3 (op1 : 'a t) (op2 : 'b t) (op3 : 'c t) : (('c t) t) t = 

let shallow_compose2 (op1 : 'a t) (op2 : 'b t) : ('a ,'b) t = ...
let shallow_compose3 (op1 : 'a t) (op2 : 'b t) (op3 : 'b t) : ('a ,'b, 'c) t = ...

(* Usually a naive-implemented *_compose3 can be derived from *_compose2 *)
let deep_compose3' (op1 : 'a t) (op2 : 'b t) (op3 : 'c t) : (('c t) t) t = 
  deep_compose2 (deep_compose2 (op1, op2), op3)

let shallow_compose3'  (op1 : 'a t) (op2 : 'b t) (op3 : 'c t) : (('a, 'b), 'c) t = 
  shallow_compose2 (shallow_compose2 (op1, op2), op3)

let shallow_compose3'' (op1 : 'a t) (op2 : 'b t) (op3 : 'c t) : ('a, ('b, 'c)) t = 
  shallow_compose2 (op1, shallow_compose2 (op2, op3))

let apply_deep (ops : 'a t) = ...
let apply_shallow (ops : 'a t) = ...
```

## Functor, Applicative, Monad

What is the natual (maximal) signature a type can have?
What is the natual result an implementation can have?

Of a software design, what role/signature do we assign to a type?

```ocaml
module type Functor = sig
  type 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
end

module type Applicative = sig
  type 'a t
  val pure : 'a -> 'a t
  val apply : ('a -> 'b) t -> 'a t -> 'b t
end

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

type direction = Up | Down | Left | Right

module Steps = struct
  type 'a t = direction * 'a

  let map f (this_d, next) = (this_d, f next)
end

module FunctorSteps : Functor with type 'a t = direction * 'a 
  = Steps

let up : unit Steps.t = Up, ();;

let up_right : (unit Steps.t) Steps.t = Up, (Right, ());;

let up_right_up : ((unit Steps.t) Steps.t) Steps.t = Up, (Right, (Up, ()));;
```

## Metrics

Motivation
Static Semantics
Dynamic Semantics
Typing Constraints
Compostionality!

## Compose Cequential Operations

pure function

```ocaml
module Almost_function : Applicative with type 'a t = 'a = struct
  type 'a t = 'a
  let pure f = f
  let apply f a = f a
end

let i2s = Almost_function.pure int_to_string;;
let s2i = Almost_function.pure string_to_int;;
Almost_function.(pure 3 |> apply i2s |> apply s2i);;

```

## Monad

`Monad` is to compose sequential effectful operations dynamically. In its module signature:
- `t` in `'a t` represents the sequential side effect
- `'a` in `'a t` is the universal result type placeholder
- The type of `bind : 'a t -> ('a -> 'b t) -> 'b t` specify one composing method, when given an effectful operation `'a t` and an result handler that handling the result part of the previous operation and given a effectful result.

In its implementation, if the `'a t` and `bind` has a correct implementation, all the monadic rules should hold.

## Monad Examples

Examples of sequential effectful: 
- operations that can raise exceptions
- operations that can read from the screen
- operations that is nondeterministic

## Typeclasspedia 

It's not a rigorous taxonomy, but an empirical classification for common typeclasses (module signatures and default implementations)