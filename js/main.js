document.addEventListener('DOMContentLoaded', function() {
    var markdownContent = document.querySelector('.generated-page .markdown-content');
    if (markdownContent) {
        function handleScroll() {
            var scrollY = window.scrollY || window.pageYOffset;
            if (scrollY > window.innerHeight * 0.2) {
                markdownContent.classList.add('faded-in');
            } else {
                markdownContent.classList.remove('faded-in');
            }
        }
        window.addEventListener('scroll', handleScroll);
        handleScroll(); // Initial check
    }

    // Footnote popup logic
    function createFootnotePopup() {
        // Remove any existing popup
        const existing = document.querySelector('.footnote-popup');
        if (existing) existing.remove();
    }

    function showFootnotePopup(ref, content) {
        createFootnotePopup();
        const popup = document.createElement('div');
        popup.className = 'footnote-popup';
        popup.innerHTML = content;
        document.body.appendChild(popup);
        // Position above the reference
        const rect = ref.getBoundingClientRect();
        const scrollY = window.scrollY || window.pageYOffset;
        const scrollX = window.scrollX || window.pageXOffset;
        popup.style.left = (rect.left + scrollX + rect.width/2 - popup.offsetWidth/2) + 'px';
        popup.style.top = (rect.top + scrollY - popup.offsetHeight - 8) + 'px';
        // Adjust after adding to DOM for correct width/height
        setTimeout(() => {
            popup.style.left = (rect.left + scrollX + rect.width/2 - popup.offsetWidth/2) + 'px';
            popup.style.top = (rect.top + scrollY - popup.offsetHeight - 8) + 'px';
        }, 0);
    }

    document.querySelectorAll('.footnote-ref').forEach(function(ref) {
        ref.addEventListener('mouseenter', function(e) {
            const href = ref.getAttribute('href');
            if (!href || !href.startsWith('#fn')) return;
            const footnote = document.querySelector(href);
            if (footnote) {
                // Get the footnote content, stripping the backlink
                let clone = footnote.cloneNode(true);
                // Remove backlink
                clone.querySelectorAll('.footnote-back').forEach(el => el.remove());
                showFootnotePopup(ref, clone.innerHTML);
            }
        });
        ref.addEventListener('mouseleave', function() {
            createFootnotePopup();
        });
    });

    // TOC highlight logic
    var tocLinks = document.querySelectorAll('.toc-sidebar a[href^="#"]');
    var headingAnchors = Array.from(tocLinks).map(function(link) {
        var id = link.getAttribute('href').slice(1);
        return document.getElementById(id) || document.querySelector('[id="' + id + '"]');
    });

    function highlightCurrentTOC() {
        var scrollPosition = window.scrollY || window.pageYOffset;
        var offset = 80; // Offset for header, adjust as needed
        var currentIndex = -1;
        for (var i = 0; i < headingAnchors.length; i++) {
            var anchor = headingAnchors[i];
            if (anchor) {
                var top = anchor.getBoundingClientRect().top + window.scrollY - offset;
                if (scrollPosition >= top) {
                    currentIndex = i;
                }
            }
        }
        tocLinks.forEach(function(link, idx) {
            if (idx === currentIndex) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }
    if (tocLinks.length > 0) {
        window.addEventListener('scroll', highlightCurrentTOC);
        highlightCurrentTOC(); // Initial check
    }
}); 