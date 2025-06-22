

picture doesn't work. 
the prince's toc interruption. 

rename headings, ie FIRST h1 as title ok, so next headings
can use h1, h2 h3...

reconvert source files. but commit first just in case. 


'settings' files, ie files that aren't new posts to be added, but rather timeless enduring settings that apply to
these posts, should be added directly to the public folder, and not included in the build process. the build process
should only apply to content that you ADD to your website over time. redundant to re-convert the same default settings
to html every time. Examples of such default settings pages are:
- landing page, it is customized and 'timeless'. so directly as html in public folder.
- css formatting


configure build.sh in a way that organizes the converted source files in the public folder in the same way as the source folder.
so for example when converting source/articles/equalityofopportunity.md, the converted file should be placed in public/articles/equalityofopportunity.html . 


also configure to delete the original source files once converted to html, and to KEEP ALL converted html files even
after the source files are deleted. This way, every build only builds the new content, and doesn't need to re-convert old
content. 


but how do i serve this website online, when packages like pandoc and python are being used?

tested. this workflow keeps old htmls when generating new ones. ie i don't have to keep the source files for EVERY desired html file, 
and reconvert everytime. i can just delete old source files, and add new source files and convert only these to html, adding to the
existing stock of htmls. 