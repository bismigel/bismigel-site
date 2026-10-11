;;; build.el --- Export miguelarbis.dev with org-publish -*- lexical-binding: t; -*-
;;
;; Emacs-native static site: no Hugo, no other SSG. Run with:
;;   emacs --batch -l build.el
;; Org files in org/ -> HTML in public/; static/ -> copied; home = post list.

(require 'ox-publish)

(setq org-html-head-include-default-style nil
      org-html-head-include-scripts nil
      org-html-validation-link nil
      org-html-doctype "html5"
      org-html-html5-fancy t)

(defconst site-header
  (concat "<header class=\"site-header\"><div class=\"wrap\">"
          "<a class=\"site-title\" href=\"/\">Miguel Arbis</a>"
          "<nav class=\"nav\"><a href=\"/\">Posts</a></nav>"
          "</div></header>"))

(defconst site-footer
  (concat "<footer class=\"site-footer\"><div class=\"wrap\">"
          "© Miguel Arbis · published from Org with org-publish"
          "</div></footer>"))

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
         :sitemap-sort-files anti-chronologically)
        ("assets"
         :base-directory "static/"
         :publishing-directory "public/"
         :base-extension "css\\|js\\|png\\|jpe?g\\|svg\\|ico"
         :publishing-function org-publish-attachment
         :recursive t)))

(org-publish-all t)
(message "✓ site exported to public/")
