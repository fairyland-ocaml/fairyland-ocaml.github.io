# What is polymorphic compare

![Camel Compare](/img/camel-compare.png)

## The `compare` function

OCaml's polymorphic compare is easy-to-use but hard-to-reason.

In the [manual](https://v2.ocaml.org/api/Stdlib.html#1_Comparisons), polymorphic `compare` is `val (=) : 'a -> 'a -> bool` where

> `e1 = e2` tests for structural equality of `e1` and `e2`. Mutable structures (e.g. references and arrays) are equal if and only if their current contents are structurally equal, even if the two mutable objects are not the same physical object. Equality between functional values raises `Invalid_argument`. Equality between cyclic data structures may not terminate.

In the source, `Stdlib.comare` is provided as an FFI and the actual implementation is in C code of the runtime:

```ocaml
(* https://github.com/ocaml/ocaml/blob/trunk/stdlib/stdlib.ml#L72 *)
external compare : 'a -> 'a -> int = "%compare"

(* https://github.com/ocaml/ocaml/blob/trunk/runtime/compare.c#L339 *)
CAMLprim value caml_compare(value v1, value v2)
{
  intnat res = compare_val(v1, v2, 1);
  if (res < 0)
    return Val_int(LESS);
  else if (res > 0)
    return Val_int(GREATER);
  else
    return Val_int(EQUAL);
}
```

The other sibing functions are also wrapping `compare_val` e.g. `<>`(`notequal`), `<`(`lessthan`), `<=`(`lessequal`) and the implementation is easy to infer. The third argument `total` is only set to `1` for `caml_compare` (a.k.a `Stdlib.compare`) and `0` otherwise.

```c
// https://github.com/ocaml/ocaml/blob/trunk/runtime/compare.c#L88C42-L88C42
static intnat compare_val(value v1, value v2, int total)
{
  struct compare_stack stk;
  intnat res;
  stk.stack = stk.init_stack;
  stk.limit = stk.stack + COMPARE_STACK_INIT_SIZE;
  res = do_compare_val(&stk, v1, v2, total);
  compare_free_stack(&stk);
  return res;
}
```

`campare_val` prepares a stack and invokes a payload `do_compare_val` to perform the comparison. Conceptual, `do_compare_val` also performs the strucutral comparison on the low-level representations. By keeping only the tag casing part, a simplied `do_compare_val` now looks like this:

```c
static intnat do_compare_val(struct compare_stack* stk,
                             value v1, value v2, int total)
{
  struct compare_item * sp;
  tag_t t1, t2;

  sp = stk->stack;
  while (...) {
    while (...) {
      if (v1 == v2 && total) goto next_item;
      if (Is_long(v1)) {
        if (v1 == v2) goto next_item;
        if (Is_long(v2))
          return Long_val(v1) - Long_val(v2);
        switch (Tag_val(v2)) {
          case Forward_tag:
            v2 = Forward_val(v2);
            continue;
          case Custom_tag: {
            int res = compare(v1, v2);
            if (Caml_state->compare_unordered && !total) return UNORDERED;
            if (res != 0) return res;
            goto next_item;
          }
          default: /*fallthrough*/;
          }
        return LESS;                /* v1 long < v2 block */
      }
      if (Is_long(v2)) {
          // ... symmetry of the above code
        }
        return GREATER;            /* v1 block > v2 long */
      }
      t1 = Tag_val(v1);
      t2 = Tag_val(v2);
      if (t1 != t2) {
          if (t1 == Forward_tag) { v1 = Forward_val (v1); continue; }
          if (t2 == Forward_tag) { v2 = Forward_val (v2); continue; }
          if (t1 == Infix_tag) t1 = Closure_tag;
          if (t2 == Infix_tag) t2 = Closure_tag;
          if (t1 != t2)
              return (intnat)t1 - (intnat)t2;
      }
      switch(t1) {
      case Forward_tag: {
          v1 = Forward_val (v1);
          v2 = Forward_val (v2);
          continue;
      }
      case String_tag: // ... string case

      case Double_tag: // ... double case

      case Double_array_tag: // ... double array case
      
      case Abstract_tag:
      case Closure_tag:
      case Infix_tag:
      case Cont_tag: // ... invalid cases

      case Object_tag: {
        intnat oid1 = Oid_val(v1);
        intnat oid2 = Oid_val(v2);
        if (oid1 != oid2) return oid1 - oid2;
        break;
      }
      case Custom_tag: {
        int res;
        int (*compare)(value v1, value v2) = Custom_ops_val(v1)->compare;
        /* Hardening against comparisons between different types */
        if (compare != Custom_ops_val(v2)->compare) {
          return strcmp(Custom_ops_val(v1)->identifier,
                        Custom_ops_val(v2)->identifier) < 0
                 ? LESS : GREATER;
        }
        if (compare == NULL) {
          compare_free_stack(stk);
          caml_invalid_argument("compare: abstract value");
        }
        Caml_state->compare_unordered = 0;
        res = compare(v1, v2);
        if (Caml_state->compare_unordered && !total) return UNORDERED;
        if (res != 0) return res;
        break;
      }
      default: {
        mlsize_t sz1 = Wosize_val(v1);
        mlsize_t sz2 = Wosize_val(v2);
        /* Compare sizes first for speed */
        if (sz1 != sz2) return sz1 - sz2;
        if (sz1 == 0) break;
        /* Remember that we still have to compare fields 1 ... sz - 1. */
        if (sz1 > 1) {
          if (sp >= stk->limit) sp = compare_resize_stack(stk, sp);
          struct compare_item* next = sp++;
          next->v1 = v1;
          next->v2 = v2;
          next->size = Val_long(sz1);
          next->offset = Val_long(1);
        }
        /* Continue comparison with first field */
        v1 = Field(v1, 0);
        v2 = Field(v2, 0);
        continue;
      }
      }
    next_item:
      /* Pop one more item to compare, if any */
      if (sp == stk->stack) return EQUAL; /* we're done */

      struct compare_item* last = sp-1;
      v1 = Field(last->v1, Long_val(last->offset));
      v2 = Field(last->v2, Long_val(last->offset));
      last->offset += 2;/* Long_val(last->offset) += 1 */
      if (last->offset == last->size) sp--;
    }
  }
}
```

The code here is the skeleton to compare two element tag-wise. The code omitted is details of specific tag cases. The stack is to store elements to compare, getting from compound values.

Displamer (TODO): At this moment, I am not clear when elements are pushed into the stack. `Begin_roots2(root_v1, root_v2); run_pending_actions(stk, sp);` is doubty.

## `value` and `tag`

OCaml value is stored as a _value_ in memory at runtime. `value` and tag functions e.g. `Is_long`, `Tag_val` is defined in [`runtime/caml/mlvalues.h`](https://github.com/ocaml/ocaml/blob/trunk/runtime/caml/mlvalues.h). OCaml manual explains tags in Chapter 22 [Interfacing C with OCaml](https://v2.ocaml.org/manual/intfc.html#ss:c-blocks). RWO has a clear explanation in chapter 23 [Memory Representation of Values](https://dev.realworldocaml.org/runtime-memory-layout.html). Here is my recap:

Memory _value_ can be immediate integer or a pointer to some other memory. An OCaml value of primitive types e.g. `bool`, `int`, `unit` and some others encodes to an immediate integer. The rest uses a pointer to store the extra _blocks_. The last bit of a memory word is used to identify them: `1` marks immediate integers and `0` marks a pointer. OCaml enforces word-aligned memory addresses.

A block, which a pointer value points to, contains a header. The header has a tag which identifies whether to interpret the payload as opage bytes or OCaml values.

| OCaml type                            | Value/Tag          | Compare case                 | Comment                                               |
| ------------------------------------- | ------------------ | ---------------------------- | ----------------------------------------------------- |
| int                                   | immediate          | `Is_long`                    |                                                       |
| enforced lazy value                   | `Forward_tag`      | via `Forward_val`            | `runtime/obj.c`                                       |
| abstract datatype with user functions | `Custom_tag`       | via `->compare_ext`          |                                                       |
| function (closure)                    | `Infix_tag`        | via `Closure_tag`            | a special `Closure` tag (used in `asmcomp/cmmgen.ml`) |
| string                                | `String_tag`       | `case String_tag`            |                                                       |
| float                                 | `Double_tag`       | `case Double_tag`            |                                                       |
| float array                           | `Double_array_tag` | `case Double_array_tag`      |                                                       |
| abstract datatype                     | `Abstract_tag`     | invalid `abstract value`     |                                                       |
| function (closure)                    | `Closure_tag`      | invalid `functional value`   |                                                       |
| (handling effects inside callbacks)   | `Cont_tag`         | invalid `continuation value` |                                                       |
| object                                | `Object_tag`       | via `Oid_val`                |                                                       |

## To-do

Some omitted code in `compare` above is for GC interrupts. It's heavivy discussed in [ocaml/#12128](https://github.com/ocaml/ocaml/pull/12128).

Demostrating a nice example to explain why polymorphic compare is worriable will improve this post a lot.

The example is like

```ocaml
module IntSet = Set.Make(Int);;
let a = IntSet.(add 1 (singleton 0));;
let b = IntSet.(add 0 (singleton 1));;

a = b;; (* (bool = false) *)
IntSet.equal a b;; (* bool = true *)

(* ocamldumpobj or https://github.com/favonia/ocaml-objdump *)
utop # Format.printf "@[%a@]@." pp (a, ());;
variant0(
  variant0(int(0),int(0),variant0(int(0),int(1),int(0),int(1)),int(2)),
  int(0))
- : unit = ()

utop # Format.printf "@[%a@]@." pp (b, ());;
variant0(
  variant0(variant0(int(0),int(0),int(0),int(1)),int(1),int(0),int(2)),
  int(0))
- : unit = ()
```