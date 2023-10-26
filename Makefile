all:
	mdbook build

serve:
	mdbook serve -p 8000

mdx:
	dune build src-ocaml @fmt
	dune promote src-ocaml
	dune runtest src || true
	dune promote src

dev-submodule:
	git submodule add https://github.com/rust-lang/mdBook.git
	cargo install mdbook-external-links