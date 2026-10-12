;;; build.el --- Export miguelarbis.dev with org-publish -*- lexical-binding: t; -*-
;;
;; Emacs-native static site: no Hugo, no other SSG. Run with:
;;   emacs --batch -l build.el
;; Org files in org/ -> HTML in public/; static/ -> copied; home = intro + posts.

(require 'ox-publish)

(setq org-html-head-include-default-style nil
      org-html-head-include-scripts nil
      org-html-validation-link nil
      org-html-doctype "html5"
      org-html-html5-fancy t)

;; Header/footer live in separate HTML files (easier to edit than elisp strings).
(defconst site-dir
  (file-name-directory (or load-file-name buffer-file-name)))

(defun read-partial (name)
  "Return the trimmed contents of the HTML partial NAME next to build.el."
  (with-temp-buffer
    (insert-file-contents (expand-file-name name site-dir))
    (string-trim (buffer-string))))

(defconst site-header (read-partial "preamble.html"))
(defconst site-footer (read-partial "postamble.html"))

(defun my-sitemap (title list)
  "Homepage: a short bio plus the list of posts."
  (concat
   "#+TITLE: " title "\n\n"
   "Hi, I'm Miguel: an aspiring brackish-water prawn farmer based in Toronto.\n"
   "Most of my day job lives in private company repos, so this space is where my\n"
   "personal experiments and tinkering end up.\n\n"
   "I run a small homelab — NixOS, Kubernetes, and more machines than I strictly\n"
   "need — and write about the design, the migrations, and the mistakes here. The\n"
   "site is written in Emacs and published straight from Org.\n\n"
   "* Writing\n"
   (org-list-to-org list)
   "\n"))

(setq org-publish-project-alist
      `(("site"
         :base-directory "org/"
         :base-extension "org"
         :publishing-directory "public/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :section-numbers nil
         :with-toc nil
         :html-head "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><link rel=\"stylesheet\" href=\"/style.css\">"
         :html-preamble ,site-header
         :html-postamble ,site-footer
         :auto-sitemap t
         :sitemap-title ""
         :sitemap-filename "index.org"
         :sitemap-sort-files anti-chronologically
         :sitemap-function my-sitemap
         :exclude "\\(?:index\\.org\\|drafts/.*\\.org\\)")
        ("assets"
         :base-directory "static/"
         :publishing-directory "public/"
         :base-extension "css\\|js\\|png\\|jpe?g\\|svg\\|ico"
         :publishing-function org-publish-attachment
         :recursive t)))

(org-publish-all t)
(message "✓ site exported to public/")

;; (rebuild trigger)
