/**
 * Custom javascript for bibtex interactions
 */

function clicked_bib(element) {
    // Find the bibtex child
    let bibtex = null;
    for (let i = 0; i < element.children.length; i++) {
        if (element.children[i].tagName.toUpperCase() === 'PRE') {
            bibtex = element.children[i];
        }
    }

    // Don't do anything if the child was not found
    if (!bibtex) return;

    // If the child was found, then toggle its display
    if (getComputedStyle(bibtex).display === 'none') {
        bibtex.style.display = 'block';
    } else {
        bibtex.style.display = 'none';
    }
}
