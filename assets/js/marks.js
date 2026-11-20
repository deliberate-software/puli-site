// Phone menu: the hamburger opens and closes the header links.
(function () {
  "use strict";
  // The header slims down and casts a shadow once the page scrolls under it.
  var header = document.querySelector(".site-header");
  if (header) {
    var stuck = function () { header.classList.toggle("is-stuck", window.scrollY > 8); };
    window.addEventListener("scroll", stuck, { passive: true });
    stuck();
  }
  var nav = document.querySelector(".nav");
  var toggle = document.querySelector(".nav__toggle");
  if (!nav || !toggle) return;

  function setOpen(open) {
    nav.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
    toggle.setAttribute("aria-label", open ? "Close menu" : "Menu");
  }

  toggle.addEventListener("click", function () {
    setOpen(!nav.classList.contains("is-open"));
  });
  nav.querySelectorAll(".nav__links a").forEach(function (link) {
    link.addEventListener("click", function () { setOpen(false); });
  });
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && nav.classList.contains("is-open")) {
      setOpen(false);
      toggle.focus();
    }
  });
})();

// Screenshots: clicking one shows it enlarged, letterboxed. Click again or press Escape to close.
// Guide shots are links to their image (without dialog support, the link just opens it). Home page shots are images
// marked data-full (and data-full-dark), naming the full-size file to show, so the page itself can load a smaller copy
// and the big one loads only when asked for. Those images take keyboard focus, and Return or Space opens them too.
(function () {
  "use strict";
  var links = document.querySelectorAll(".shot a");
  var shots = document.querySelectorAll("img[data-full]");
  if ((!links.length && !shots.length) || typeof HTMLDialogElement !== "function") return;

  var view = document.createElement("dialog");
  view.className = "shot-view";
  view.setAttribute("aria-label", "Screenshot");
  var big = document.createElement("img");
  view.appendChild(big);
  document.body.appendChild(view);
  view.addEventListener("click", function () { view.close(); });
  var dark = window.matchMedia("(prefers-color-scheme: dark)");

  function open(img, src) {
    big.src = src;
    big.alt = img.alt;
    // As big as the window really is (its width and height attributes), but never past the screen, less 24px a side.
    var w = +img.getAttribute("width") || 1200, h = +img.getAttribute("height") || 780;
    var scale = Math.min(1, (window.innerWidth - 48) / w, (window.innerHeight - 48) / h);
    big.style.width = Math.round(w * scale) + "px";
    big.style.height = Math.round(h * scale) + "px";
    big.style.borderRadius = getComputedStyle(img).borderRadius;   // percentages, so they fit any size
    view.showModal();
  }

  links.forEach(function (link) {
    link.addEventListener("click", function (event) {
      var img = link.querySelector("img");
      event.preventDefault();
      open(img, img.currentSrc || img.src);   // the light or dark shot, whichever the page is showing
    });
  });

  shots.forEach(function (img) {
    img.classList.add("is-zoomable");
    img.tabIndex = 0;
    img.setAttribute("role", "button");
    img.setAttribute("aria-label", "Enlarge: " + img.alt);
    function show() { open(img, (dark.matches && img.dataset.fullDark) || img.dataset.full); }
    img.addEventListener("click", show);
    img.addEventListener("keydown", function (event) {
      if (event.key === "Enter" || event.key === " ") { event.preventDefault(); show(); }
    });
  });
})();
