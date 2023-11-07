# What are [@@deriving compare, sexp_of, hash] for?

Real World OCaml has a dedicated chapter [Maps and Hash Tables](https://dev.realworldocaml.org/maps-and-hashtables.html). It's an excellent tutorial to start with data containers in Jane Street's `core` (or `Base`), an alternative to the OCaml standard library `stdlib`. For both `core` and `stdlib`, elements need to provide required _functions_ to be put into containers. The tutorial gives examples of elements with hand-written functions and derived functions.

<!-- $MDX file=../../src-ocaml/elements.ml,part=book1 -->
```ocaml
  open Core

  module Book = struct
    module T = struct
      type t = { title : string; isbn : string }

      let compare t1 t2 =
        let cmp_title = String.compare t1.title t2.title in
        if cmp_title <> 0 then cmp_title else String.compare t1.isbn t2.isbn

      let sexp_of_t t : Sexp.t = List [ Atom t.title; Atom t.isbn ]
    end

    include T
    include Comparator.Make (T)
  end
```

<!-- $MDX file=../../src-ocaml/elements.ml,part=book2 -->
```ocaml
  open Core

  module Book = struct
    module T = struct
      type t = { title : string; isbn : string } [@@deriving compare, sexp_of]
    end

    include T
    include Comparator.Make (T)
  end
```

Let's focus in what's inside of `T`. In this post, we will figure out one question:

What are `[@@deriving compare, sexp_of, hash]` for, as the post title askes?

We will answer this question from the user-code side, and left the explanation from the library-code side for the future.

## Deriving Functions

These ppx deriver are [janestreet/ppx_compare](https://github.com/janestreet/ppx_compare) for `equal` and `compare`, [janestreet/ppx_sexp_conv](https://github.com/janestreet/ppx_sexp_conv) for `sexp_of` and `of_sexp`, and [janestreet/ppx_hash](https://github.com/janestreet/ppx_hash) for `hash` and `hash_fold`.

A quick way to inspect the deriving result is to change `[@@deriving <ppx>]` to `[@@deriving_inline <ppx>] [@@@end]` so there we can read the generated code between tags.

The idea of all these function deriver are type-based structural traversal. Don't be disturbed by the variable names in the generated code. 

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_equal -->
```ocaml
type foo1 = P1 of int * string [@@deriving_inline equal]

let _ = fun (_ : foo1) -> ()

let equal_foo1 =
  (fun a__008_ b__009_ ->
     if Stdlib.( == ) a__008_ b__009_ then true
     else
       match (a__008_, b__009_) with
       | P1 (_a__010_, _a__012_), P1 (_b__011_, _b__013_) ->
           Stdlib.( && )
             (equal_int _a__010_ _b__011_)
             (equal_string _a__012_ _b__013_)
    : foo1 -> foo1 -> bool)

let _ = equal_foo1

[@@@end]
```

`equal` is straightforward. Two values are equal if they are physically equal i.e. at the same memory address. Otherwises, they need to be equal piecewise-ly. `Core` doesn't shadow OCaml vanilla standard library `Stdlib`.

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_compare -->
```ocaml
type foo2 = P2 of int * string [@@deriving_inline compare]

let _ = fun (_ : foo2) -> ()

let compare_foo2 =
  (fun a__014_ b__015_ ->
     if Stdlib.( == ) a__014_ b__015_ then 0
     else
       match (a__014_, b__015_) with
       | P2 (_a__016_, _a__018_), P2 (_b__017_, _b__019_) -> (
           match compare_int _a__016_ _b__017_ with
           | 0 -> compare_string _a__018_ _b__019_
           | n -> n)
    : foo2 -> foo2 -> int)

let _ = compare_foo2

[@@@end]
```

`compare` is similar to `equal`. `Stdlib.compare : 'a -> 'a -> int` the polymorphic compare is not used in `Core`, however, the convertion should be observed: `compare x y` returns 0 if x is equal to y, a negative integer if x is less than y, and a positive integer if x is greater than y.

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_sexp -->
```ocaml
type foo3 = P3 of int * string [@@deriving_inline sexp]

let _ = fun (_ : foo3) -> ()

let foo3_of_sexp =
  (let error_source__022_ = "src-ocaml/elements.ml.foo3" in
   function
   | Sexplib0.Sexp.List
       (Sexplib0.Sexp.Atom (("p3" | "P3") as _tag__025_) :: sexp_args__026_) as
     _sexp__024_ -> (
       match sexp_args__026_ with
       | [ arg0__027_; arg1__028_ ] ->
           let res0__029_ = int_of_sexp arg0__027_
           and res1__030_ = string_of_sexp arg1__028_ in
           P3 (res0__029_, res1__030_)
       | _ ->
           Sexplib0.Sexp_conv_error.stag_incorrect_n_args error_source__022_
             _tag__025_ _sexp__024_)
   | Sexplib0.Sexp.Atom ("p3" | "P3") as sexp__023_ ->
       Sexplib0.Sexp_conv_error.stag_takes_args error_source__022_ sexp__023_
   | Sexplib0.Sexp.List (Sexplib0.Sexp.List _ :: _) as sexp__021_ ->
       Sexplib0.Sexp_conv_error.nested_list_invalid_sum error_source__022_
         sexp__021_
   | Sexplib0.Sexp.List [] as sexp__021_ ->
       Sexplib0.Sexp_conv_error.empty_list_invalid_sum error_source__022_
         sexp__021_
   | sexp__021_ ->
       Sexplib0.Sexp_conv_error.unexpected_stag error_source__022_ sexp__021_
    : Sexplib0.Sexp.t -> foo3)

let _ = foo3_of_sexp

let sexp_of_foo3 =
  (fun (P3 (arg0__031_, arg1__032_)) ->
     let res0__033_ = sexp_of_int arg0__031_
     and res1__034_ = sexp_of_string arg1__032_ in
     Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "P3"; res0__033_; res1__034_ ]
    : foo3 -> Sexplib0.Sexp.t)

let _ = sexp_of_foo3

[@@@end]
```

`sexp_of` and `of_sexp` are for serialization and deserialization. More details are at RWO Chapter [Data Serialization with S-Expressions](https://dev.realworldocaml.org/data-serialization.html).

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_hash -->
```ocaml
type foo4 = P4 of int * string [@@deriving_inline hash]

let _ = fun (_ : foo4) -> ()

let (hash_fold_foo4 :
      Ppx_hash_lib.Std.Hash.state -> foo4 -> Ppx_hash_lib.Std.Hash.state) =
  (fun hsv arg ->
     match arg with
     | P4 (_a0, _a1) ->
         let hsv = hsv in
         let hsv =
           let hsv = hsv in
           hash_fold_int hsv _a0
         in
         hash_fold_string hsv _a1
    : Ppx_hash_lib.Std.Hash.state -> foo4 -> Ppx_hash_lib.Std.Hash.state)

let _ = hash_fold_foo4

let (hash_foo4 : foo4 -> Ppx_hash_lib.Std.Hash.hash_value) =
  let func arg =
    Ppx_hash_lib.Std.Hash.get_hash_value
      (let hsv = Ppx_hash_lib.Std.Hash.create () in
       hash_fold_foo4 hsv arg)
  in
  fun x -> func x

let _ = hash_foo4

[@@@end]
```

Here are the most _complex_ functions. `hash_fold` is a state-passing function to perform the hashing payload. `hash` wraps `hash_fold` by providing an initial hash state via `Hash.create ()` and converting the hash result to `int` via `Hash.get_hash_value`.
It implies if we need a cutsom hash function, implementing `hash_fold` to perform hashing and providing the same wrapping `hash` here.

Further explanation can be found at doc for [Base.Hasher.S](https://v3.ocaml.org/p/base/latest/doc/Base/Hasher/module-type-S/index.html) and the [ppx_hash/design_doc](https://github.com/janestreet/ppx_hash/blob/master/doc/design.notes). In short, `hash_fold` should take care of not only the values in the structure not also the structure itself, to avoid easily hash collision.

It becomes tricky when a `Core`-container is used as an element and this element is intended to be used in a container requiring hash, e.g. putting this `Int_set_as_element` in a `Hash_set`.

<!-- $MDX file=../../src-ocaml/elements.ml,part=int_set_as_element -->
```ocaml
module Int_set_as_element = struct
  module T = struct
    type t = Set.M(Int).t [@@deriving_inline compare, sexp_of, hash]

    let _ = fun (_ : t) -> ()

    let compare =
      (fun a__035_ b__036_ -> Set.compare_m__t (module Int) a__035_ b__036_
        : t -> t -> int)

    let _ = compare

    let sexp_of_t =
      (fun x__037_ -> Set.sexp_of_m__t (module Int) x__037_
        : t -> Sexplib0.Sexp.t)

    let _ = sexp_of_t

    let (hash_fold_t :
          Ppx_hash_lib.Std.Hash.state -> t -> Ppx_hash_lib.Std.Hash.state) =
     fun hsv arg -> Set.hash_fold_m__t (module Int) hsv arg

    and (hash : t -> Ppx_hash_lib.Std.Hash.hash_value) =
      let func = Set.hash_m__t (module Int) in
      fun x -> func x

    let _ = hash_fold_t
    and _ = hash

    [@@@end]
  end

  include T
  include Comparator.Make (T)
end

let _ = Set.empty (module Int_set_as_element)
let _ = Hash_set.create (module Int_set_as_element)
```

Both `Set.hash_m__t` and `Set.hash_fold_m__t` requires a first-class module implementing `Hasher.S` (which requires `hash_fold_t`). In this example, the module is `Int`. `Int` is a build-in module containing `hash` and `hash_fold`. If this is `Your_data` rather than `Int`, the generated code above for `Set.M(Your_data).t` will have `Set.hash_m__t (module Your_data)` and `Set.hash_fold_m__t (module Your_data)`. Therefore, `Your_data` have to provide `hash` and `hash_fold` functions.

This can explain why `Base.Hash_set.Key` contains `hash` and no `hash_fold`, but `ppx_hash` still derives both `hash` and `hash_fold`.

p.s. I don't claim this design is good.
