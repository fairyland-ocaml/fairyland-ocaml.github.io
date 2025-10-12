// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded affix "><a href="SUMMARY.html">Summary</a></li><li class="chapter-item expanded affix "><a href="preface.html">Preface</a></li><li class="chapter-item expanded affix "><a href="libraries/hashcons.html">Understanding Hashcons</a></li><li class="chapter-item expanded affix "><a href="libraries/argparse.html">Understanding Core.Command and Cmdliner</a></li><li class="chapter-item expanded affix "><a href="libraries/z3-datatype.html">Using Z3.Datatype</a></li><li class="chapter-item expanded affix "><a href="core/container-elements.html">What are [@@deriving compare, sexp_of, hash] for?</a></li><li class="chapter-item expanded affix "><a href="internals/ppxlib.html">A Glance of ppxlib</a></li><li class="chapter-item expanded affix "><a href="internals/gadt.html">Understanding gadt</a></li><li class="chapter-item expanded affix "><a href="internals/polymorphic-compare.html">What is polymorphic compare?</a></li><li class="chapter-item expanded affix "><a href="core/maps-and-hashtables.html">Understanding Data Collections in Core</a></li><li class="chapter-item expanded affix "><div>Using Hashcons</div></li><li class="chapter-item expanded affix "><div>Understanding Fix</div></li><li class="chapter-item expanded affix "><div>Using Fix</div></li><li class="chapter-item expanded affix "><div>Understanding Ocamlgraph</div></li><li class="chapter-item expanded affix "><div>Profiling</div></li><li class="chapter-item expanded affix "><div>Deriving print</div></li><li class="chapter-item expanded affix "><div>Understanding type format6</div></li><li class="chapter-item expanded affix "><div>Understanding module Format</div></li><li class="chapter-item expanded affix "><div>Understanding destructive substitution</div></li><li class="chapter-item expanded affix "><div>Fixed point</div></li><li class="chapter-item expanded affix "><div>Contravariant</div></li><li class="chapter-item expanded affix "><div>Typeclassopedia</div></li><li class="chapter-item expanded affix "><div>OCaml source reading</div></li><li class="chapter-item expanded affix "><li class="part-title">Earthbound</li><li class="chapter-item expanded affix "><div>Understanding t-string in Python 3.14</div></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0].split("?")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
