# Map, Set and Hashtables

What are exact functions required for distinct data containers?


Afterr all, what collections are in `Base` and `Core`?

 | Base                        | Core | Stdlib                   | kind      | requiring                | comment                                                                        |
 | --------------------------- | ---- | ------------------------ | --------- | ------------------------ | ------------------------------------------------------------------------------ |
 | `Applicative`               |      | /                        | functor   |                          |                                                                                |
 | `Array`                     |      | `Array`                  | std       |                          |                                                                                |
 | `Avltree`                   |      | /                        | low-level |                          |                                                                                |
 | `Backtrace`                 |      | `Printexc.raw_backtrace` | system    |                          |                                                                                |
 | `Binary_search`             |      | /                        | interface |                          |                                                                                |
 | `Binary_searchable`         |      | /                        | functor   |                          |                                                                                |
 | `Blit`                      |      | /                        | std       |                          | bit-block transfer                                                             |
 | `Bool`                      |      | `Bool`                   | std       |                          |                                                                                |
 | `Buffer`                    |      | `Buffer`                 | std       |                          |                                                                                |
 | `Bytes`                     |      | `Bytes`                  | std       |                          |                                                                                |
 | `Char`                      |      | `Char`                   | std       |                          |                                                                                |
 | `Comparable`                |      | /                        | functor   |                          |                                                                                |
 | `Comparator`                |      | /                        | functor   |                          |                                                                                |
 | `Comparisons`               |      | /                        | interface |                          |                                                                                |
 | `Container`                 |      | /                        | functor   |                          |                                                                                |
 | `Either`                    |      | `Either`                 | std       |                          |                                                                                |
 | `Equal`                     |      | /                        | interface |                          |                                                                                |
 | `Error`                     |      | /                        | std       |                          |                                                                                |
 | `Exn`                       |      | `exn`                    | std       |                          |                                                                                |
 | `Export`                    |      | /                        | wrap      |                          | undoc                                                                          |
 | `Field`                     |      | /                        | std       |                          |                                                                                |
 | `Float`                     |      | `Float`                  | std       |                          |                                                                                |
 | `Floatable`                 |      | /                        | interface |                          |                                                                                |
 | `Fn`                        |      | /                        | std       |                          |                                                                                |
 | `Formatter`                 |      | `Formatter`              | std       |                          |                                                                                |
 | `Hash`                      |      | /                        | std       |                          | hash primitives                                                                |
 | `Hash_set`                  |      | /                        | container | `compare, sexp_of, hash` |                                                                                |
 | `Hashable`                  |      | /                        | interface |                          | module trait                                                                   |
 | `Hasher`                    |      | /                        | interface |                          | just `t` and `hash_fold_t`                                                     |
 | `Hashtbl`                   |      | `Hashtbl`                | container | `compare, sexp_of, hash` |                                                                                |
 | `Identifiable`              |      | /                        | functor   |                          |                                                                                |
 | `Indexed_container`         |      | /                        | interface |                          |                                                                                |
 | `Info`                      |      | /                        | std       |                          |                                                                                |
 | `Int`                       |      | `Int`                    | std       |                          |                                                                                |
 | `Int32`                     |      | `Int32`                  | std       |                          |                                                                                |
 | `Int63`                     |      | /                        | std       |                          |                                                                                |
 | `Int64`                     |      | `Int64`                  | std       |                          |                                                                                |
 | `Int_conversions`           |      | /                        | std       |                          |                                                                                |
 | `Intable`                   |      | /                        | interface |                          |                                                                                |
 | `Int_math`                  |      | /                        | functor   |                          |                                                                                |
 | `Invariant`                 |      | /                        | interface |                          |                                                                                |
 | `Lazy`                      |      | `Lazy`                   | std       |                          |                                                                                |
 | `Linked_queue`              |      | `Queue `                 | container |                          |                                                                                |
 | `List`                      |      | `List`                   | container |                          |                                                                                |
 | `Map`                       |      | `Map`                    | std       | `compare, sexp_of`       | balanced binary tree over a totally-ordered domain                             |
 | `Maybe_bound`               |      | /                        | std       |                          |                                                                                |
 | `Monad`                     |      | /                        | functor   |                          |                                                                                |
 | `Nativeint`                 |      | /                        | std       |                          |                                                                                |
 | `Nothing`                   |      | /                        | std       |                          |                                                                                |
 | `Option`                    |      | `Option`                 | std       |                          |                                                                                |
 | `Option_array`              |      | /                        | std       |                          |                                                                                |
 | `Or_error`                  |      | /                        | std       |                          | a specialization of the `Result` type                                          |
 | `Ordered_collection_common` |      | /                        | trait     |                          |                                                                                |
 | `Ordering`                  |      | /                        | std       |                          |                                                                                |
 | `Poly`                      |      | `Stdlib`                 | std       |                          |                                                                                |
 | `Pretty_printer`            |      | /                        | std       |                          | for use in toplevels                                                           |
 | `Printf`                    |      | `Printf`                 | std       |                          |                                                                                |
 | `Queue`                     |      | `Queue`                  | std       |                          | A queue implemented with an array                                              |
 | `Random`                    |      | `Random`                 | std       |                          |                                                                                |
 | `Ref`                       |      | `'a ref`                 | std       |                          |                                                                                |
 | `Result`                    |      | `Result`                 | std       |                          |                                                                                |
 | `Sequence`                  |      | `Seq`                    | std       |                          |                                                                                |
 | `Set`                       |      | `Set`                    | std       |                          | Sets based on `Comparator.S`                                                   |
 | `Sexp`                      |      | /                        | std       |                          |                                                                                |
 | `Sexpable`                  |      | /                        | functor   |                          |                                                                                |
 | `Sign`                      |      | /                        | std       |                          |                                                                                |
 | `Sign_or_nan`               |      | /                        | std       |                          |                                                                                |
 | `Source_code_position`      |      | /                        | std       |                          |                                                                                |
 | `Stack`                     |      | `Stack`                  | std       |                          |                                                                                |
 | `Staged`                    |      | /                        | std       |                          |                                                                                |
 | `String`                    |      | `String`                 | std       |                          |                                                                                |
 | `Stringable`                |      | /                        | interface |                          |                                                                                |
 | `Sys`                       |      | `Sys`                    | std       |                          |                                                                                |
 | `T`                         |      | /                        | interface |                          |                                                                                |
 | `Type_equal`                |      | /                        | std       |                          | to represent type equalities that the type checker otherwise would not know    |
 | `Uniform_array`             |      | /                        | std       |                          | guaranteed that the representation array is not tagged with `Double_array_tag` |
 | `Unit`                      |      | `unit`                   | std       |                          |                                                                                |
 | `Uchar`                     |      | /                        | std       |                          |                                                                                |
 | `Variant`                   |      | /                        | std       |                          | used in `[@@deriving variants]`                                                |
 | `With_return`               |      | /                        | std       |                          |                                                                                |
 | `Word_size`                 |      | /                        | std       |                          |                                                                                |
 | ``                          |      | /                        | std       |                          |                                                                                |

