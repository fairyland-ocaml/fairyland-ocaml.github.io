# deriving print

```ocaml
1 + 2;;
```

```ocaml
let rec sum x = 
  if x = 0 then 0 else x + sum (x-1)
in
sum 3
```
