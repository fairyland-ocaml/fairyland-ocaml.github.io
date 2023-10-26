# What are [@@deriving compare, sexp_of, hash] for?

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_compare -->
```ocaml
type foo1 = P1 of int * string [@@deriving_inline compare]

let _ = fun (_ : foo1) -> ()

let compare_foo1 =
  (fun a__001_ b__002_ ->
     if Stdlib.( == ) a__001_ b__002_ then 0
     else
       match (a__001_, b__002_) with
       | P1 (_a__003_, _a__005_), P1 (_b__004_, _b__006_) -> (
           match compare_int _a__003_ _b__004_ with
           | 0 -> compare_string _a__005_ _b__006_
           | n -> n)
    : foo1 -> foo1 -> int)

let _ = compare_foo1

[@@@end]
```

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_sexp -->
```ocaml
type foo2 = P2 of int * string [@@deriving_inline sexp]

let _ = fun (_ : foo2) -> ()

let foo2_of_sexp =
  (let error_source__009_ = "src-ocaml/elements.ml.foo2" in
   function
   | Sexplib0.Sexp.List
       (Sexplib0.Sexp.Atom (("p2" | "P2") as _tag__012_) :: sexp_args__013_) as
     _sexp__011_ -> (
       match sexp_args__013_ with
       | [ arg0__014_; arg1__015_ ] ->
           let res0__016_ = int_of_sexp arg0__014_
           and res1__017_ = string_of_sexp arg1__015_ in
           P2 (res0__016_, res1__017_)
       | _ ->
           Sexplib0.Sexp_conv_error.stag_incorrect_n_args error_source__009_
             _tag__012_ _sexp__011_)
   | Sexplib0.Sexp.Atom ("p2" | "P2") as sexp__010_ ->
       Sexplib0.Sexp_conv_error.stag_takes_args error_source__009_ sexp__010_
   | Sexplib0.Sexp.List (Sexplib0.Sexp.List _ :: _) as sexp__008_ ->
       Sexplib0.Sexp_conv_error.nested_list_invalid_sum error_source__009_
         sexp__008_
   | Sexplib0.Sexp.List [] as sexp__008_ ->
       Sexplib0.Sexp_conv_error.empty_list_invalid_sum error_source__009_
         sexp__008_
   | sexp__008_ ->
       Sexplib0.Sexp_conv_error.unexpected_stag error_source__009_ sexp__008_
    : Sexplib0.Sexp.t -> foo2)

let _ = foo2_of_sexp

let sexp_of_foo2 =
  (fun (P2 (arg0__018_, arg1__019_)) ->
     let res0__020_ = sexp_of_int arg0__018_
     and res1__021_ = sexp_of_string arg1__019_ in
     Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "P2"; res0__020_; res1__021_ ]
    : foo2 -> Sexplib0.Sexp.t)

let _ = sexp_of_foo2

[@@@end]
```

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_equal -->
```ocaml
type foo3 = P3 of int * string [@@deriving_inline equal]

let _ = fun (_ : foo3) -> ()
let equal_foo3 =
  (fun a__022_ ->
     fun b__023_ ->
       if Stdlib.(==) a__022_ b__023_
       then true
       else
         (match (a__022_, b__023_) with
          | (P3 (_a__024_, _a__026_), P3 (_b__025_, _b__027_)) ->
              Stdlib.(&&) (equal_int _a__024_ _b__025_)
                (equal_string _a__026_ _b__027_)) : foo3 -> foo3 -> bool)
let _ = equal_foo3
[@@@end]
```

<!-- $MDX file=../../src-ocaml/elements.ml,part=pair_inline_hash -->
```ocaml
type foo4 = P4 of int * string [@@deriving_inline hash]

let _ = fun (_ : foo4) -> ()
let (hash_fold_foo4 :
  Ppx_hash_lib.Std.Hash.state -> foo4 -> Ppx_hash_lib.Std.Hash.state) =
  (fun hsv ->
     fun arg ->
       match arg with
       | P4 (_a0, _a1) ->
           let hsv = hsv in
           let hsv = let hsv = hsv in hash_fold_int hsv _a0 in
           hash_fold_string hsv _a1 : Ppx_hash_lib.Std.Hash.state ->
                                        foo4 -> Ppx_hash_lib.Std.Hash.state)
let _ = hash_fold_foo4
let (hash_foo4 : foo4 -> Ppx_hash_lib.Std.Hash.hash_value) =
  let func arg =
    Ppx_hash_lib.Std.Hash.get_hash_value
      (let hsv = Ppx_hash_lib.Std.Hash.create () in hash_fold_foo4 hsv arg) in
  fun x -> func x
let _ = hash_foo4

[@@@end]
```
