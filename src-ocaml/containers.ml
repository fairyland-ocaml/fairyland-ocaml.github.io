open Base

let a0 = Array.create ~len:3 42

module E_c_s = struct
  module T = struct
    type t = Foo1 [@@deriving compare, sexp_of]
  end

  include T
  include Comparator.Make (T)
end

module E_c_s_h = struct
  module T = struct
    type t = Foo1 [@@deriving compare, sexp_of, hash]
  end

  include T
  include Comparator.Make (T)
end

module E_c_s_h_no_hf = struct
  module T = struct
    type t = Foo1 [@@deriving compare, sexp_of]

    let hash _ = Hashtbl.hash 42

    (* let hash_fold s _ = hash_fold_int s 42 *)
  end

  include T
  include Comparator.Make (T)
end

let _ = Hash_set.Poly.create ()

(* let _ = Hash_set.create (module E_c_s) *)
let _ = Hash_set.create (module E_c_s_h)
let _ = Hash_set.create (module E_c_s_h_no_hf)

(* let _ = Hashtbl.create (module E_c_s) *)
let _ = Hashtbl.create (module E_c_s_h)
let _ = Hashtbl.create (module E_c_s_h_no_hf)
let _ = Map.empty (module E_c_s)
let _ = Set.empty (module E_c_s)

module Set_E_c_s = struct
  module T = struct
    type t = Set.M(E_c_s).t [@@deriving_inline compare, sexp_of]

    let _ = fun (_ : t) -> ()

    let compare =
      (fun a__007_ b__008_ -> Set.compare_m__t (module E_c_s) a__007_ b__008_
        : t -> t -> int)

    let _ = compare

    let sexp_of_t =
      (fun x__009_ -> Set.sexp_of_m__t (module E_c_s) x__009_
        : t -> Sexplib0.Sexp.t)

    let _ = sexp_of_t

    [@@@end]
  end

  include T
  include Comparator.Make (T)
end

(* module Set_E_c_s_h_no_hf = struct
     module T = struct
       module R = Set.M (E_c_s_h_no_hf)

       type t = R.t [@@deriving compare, sexp_of, hash]
     end

     include T
     include Comparator.Make (T)
   end *)

module Set_E_c_s_h_no_hf = struct
  module T = struct
    type t = Set.M(E_c_s_h_no_hf).t [@@deriving compare, sexp_of]
  end

  let hash e = Hashtbl.hash e

  include T
  include Comparator.Make (T)
end

module Set_E_c_s_h = struct
  module T = struct
    type t = Set.M(E_c_s_h).t [@@deriving_inline compare, sexp_of, hash]

    let _ = fun (_ : t) -> ()

    let compare =
      (fun a__013_ b__014_ -> Set.compare_m__t (module E_c_s_h) a__013_ b__014_
        : t -> t -> int)

    let _ = compare

    let sexp_of_t =
      (fun x__015_ -> Set.sexp_of_m__t (module E_c_s_h) x__015_
        : t -> Sexplib0.Sexp.t)

    let _ = sexp_of_t

    let (hash_fold_t :
          Ppx_hash_lib.Std.Hash.state -> t -> Ppx_hash_lib.Std.Hash.state) =
     fun hsv arg -> Set.hash_fold_m__t (module E_c_s_h) hsv arg

    and (hash : t -> Ppx_hash_lib.Std.Hash.hash_value) =
      let func = Set.hash_m__t (module E_c_s_h) in
      fun x -> func x

    let _ = hash_fold_t
    and _ = hash

    [@@@end]
  end

  include T
  include Comparator.Make (T)
end

module Map_E_c_s = struct
  module T = struct
    type t = int Map.M(E_c_s).t [@@deriving compare, sexp_of]
  end

  include T
  include Comparator.Make (T)
end

(* module Map_E_c_s_h_no_hf = struct
     module T = struct
       type t = int Map.M(E_c_s_h_no_hf).t [@@deriving compare, sexp_of, hash]
     end

     include T
     include Comparator.Make (T)
   end *)

module Map_E_c_s_h = struct
  module T = struct
    type t = int Map.M(E_c_s_h).t [@@deriving_inline compare, sexp_of, hash]

    let _ = fun (_ : t) -> ()

    let compare =
      (fun a__021_ b__022_ ->
         Map.compare_m__t (module E_c_s_h) compare_int a__021_ b__022_
        : t -> t -> int)

    let _ = compare

    let sexp_of_t =
      (fun x__025_ -> Map.sexp_of_m__t (module E_c_s_h) sexp_of_int x__025_
        : t -> Sexplib0.Sexp.t)

    let _ = sexp_of_t

    let (hash_fold_t :
          Ppx_hash_lib.Std.Hash.state -> t -> Ppx_hash_lib.Std.Hash.state) =
     fun hsv arg -> Map.hash_fold_m__t (module E_c_s_h) hash_fold_int hsv arg

    let _ = hash_fold_t

    let (hash : t -> Ppx_hash_lib.Std.Hash.hash_value) =
      let func arg =
        Ppx_hash_lib.Std.Hash.get_hash_value
          (let hsv = Ppx_hash_lib.Std.Hash.create () in
           hash_fold_t hsv arg)
      in
      fun x -> func x

    let _ = hash

    [@@@end]
  end

  include T
  include Comparator.Make (T)
end

let _ = Set.empty (module Set_E_c_s)
let _ = Set.empty (module Map_E_c_s)
let _ = Hash_set.create (module Set_E_c_s_h)
let _ = Hash_set.create (module Set_E_c_s_h_no_hf)
let _ = Hash_set.create (module Map_E_c_s_h)
