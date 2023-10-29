all:
	mdbook build

serve:
	mdbook serve -p 8000

mdx:
	dune build src-ocaml @fmt || true
	dune promote
	dune runtest src || true
	dune promote

dev-submodule:
	git submodule add https://github.com/rust-lang/mdBook.git
	cargo install mdbook-external-links