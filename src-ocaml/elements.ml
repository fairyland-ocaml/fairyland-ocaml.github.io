open Core

let x = 1
(* $MDX part-begin=pair_inline *)

type my_pair = P of int * int [@@deriving_inline compare, sexp_of, hash]

let _ = fun (_ : my_pair) -> ()

let compare_my_pair =
  (fun a__001_ ->
     fun b__002_ ->
       if Stdlib.(==) a__001_ b__002_
       then 0
       else
         (match (a__001_, b__002_) with
          | (P (_a__003_, _a__005_), P (_b__004_, _b__006_)) ->
              (match compare_int _a__003_ _b__004_ with
               | 0 -> compare_int _a__005_ _b__006_
               | n -> n)) : my_pair -> my_pair -> int)
let _ = compare_my_pair

let sexp_of_my_pair =
  (fun (P (arg0__007_, arg1__008_)) ->
     let res0__009_ = sexp_of_int arg0__007_
     and res1__010_ = sexp_of_int arg1__008_ in
     Sexplib0.Sexp.List [Sexplib0.Sexp.Atom "P"; res0__009_; res1__010_] :
  my_pair -> Sexplib0.Sexp.t)
let _ = sexp_of_my_pair

let (hash_fold_my_pair :
  Ppx_hash_lib.Std.Hash.state -> my_pair -> Ppx_hash_lib.Std.Hash.state) =
  (fun hsv ->
     fun arg ->
       match arg with
       | P (_a0, _a1) ->
           let hsv = hsv in
           let hsv = let hsv = hsv in hash_fold_int hsv _a0 in
           hash_fold_int hsv _a1 : Ppx_hash_lib.Std.Hash.state ->
                                     my_pair -> Ppx_hash_lib.Std.Hash.state)

let _ = hash_fold_my_pair

let (hash_my_pair : my_pair -> Ppx_hash_lib.Std.Hash.hash_value) =
  let func arg =
    Ppx_hash_lib.Std.Hash.get_hash_value
      (let hsv = Ppx_hash_lib.Std.Hash.create () in
       hash_fold_my_pair hsv arg)
  in
  fun x -> func x

let _ = hash_my_pair

[@@@end]

(* $MDX part-end *)
