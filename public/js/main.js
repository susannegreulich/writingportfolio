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
}); 