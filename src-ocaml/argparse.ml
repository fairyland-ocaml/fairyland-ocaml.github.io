open Cmdliner

let top_t =
  let ai = Arg.info [] in
  let str_lst : int list Term.t = Arg.(value & pos_all int [] ai) in
  let extra_int : int Term.t = Arg.(value & pos 1 int 0 ai) in
  let handle_all : (int list -> int -> unit) Term.t =
    Term.const @@ fun _str_list _extra_int -> ()
  in
  Term.(handle_all $ str_lst $ extra_int)

let c =
  let i = Cmd.info "" in
  Cmd.v i top_t
;;

Cmd.eval_value ~argv:[| "a"; "2" |] c
