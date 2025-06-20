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
}); 