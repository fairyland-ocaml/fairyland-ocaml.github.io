all:
	mdbook serve --open

mdx:
	dune runtest && dune promote

dev-submodule:
	git submodule add https://github.com/rust-lang/mdBook.git