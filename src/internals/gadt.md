# Understanding gadt

https://v2.ocaml.org/manual/gadts-tutorial.html

Generalized algebraic datatypes, or GADTs, extend usual sum types in two ways: 
- constraints on type parameters may change depending on the value constructor
- and some type variables may be existentially quantified.

Question2:
1. tags-to-types N-1, 1-N
2. use in a nonrecursive cases

Question3:
1. type as index
2. type with equality



```ocaml
type _ term =
  | Int : int -> int term
  | Add : (int -> int -> int) term
  | App : ('b -> 'a) term * 'b term -> 'a term

let rec eval : type a. a term -> a = function
  | Int n    -> n                 (* a = int *)
  | Add      -> (fun x y -> x+y)  (* a = int -> int -> int *)
  | App(f,x) -> (eval f) (eval x)
          (* eval called at types (b->a) and b for fresh b *)
```

`Int` makes concrete property type
`App` makes a type constraint (however, these type constraint are only used on occurance).
I cannot type-case on `App`

..which mean to align with the recursive `Z3.Expr` I will also have a recursive ml type like

```ocaml
(* instead of *)
type t = Foo of int * bool

type foo = G_foo
(* I will have *)

type _ t_ml = 
  | M_int : int -> int t_ml
  | M_bool : bool -> bool t_ml
  | M_foo : int t_ml * bool t_ml -> foo t_ml
```

```ocaml
type _ t =
  | Int : int t
  | Bool : bool t

let deep : (char t * int) option -> char = function
  | None -> 'c'
  | _ -> .
```

The term type we have defined above is an *indexed* type, where a type parameter reflects a property of the value contents.
Another use of GADTs is *singleton* types, where a GADT value represents exactly one type. 

