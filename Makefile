all:
	mdbook serve --open

dev-submodule:
	git submodule add https://github.com/rust-lang/mdBook.git