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

(defconst site-header
  (concat "<header class=\"site-header\"><div class=\"wrap\">"
          "<a class=\"site-title\" href=\"/\">bismigel</a>"
          "<nav class=\"nav\"><a href=\"/\">Posts</a>"
          "<a class=\"nav-icon\" href=\"https://github.com/bismigel\" aria-label=\"GitHub\" title=\"GitHub\">"
          "<svg viewBox=\"0 0 16 16\" width=\"20\" height=\"20\" aria-hidden=\"true\" fill=\"currentColor\"><path d=\"M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z\"/></svg></a>"
          "</nav></div></header>"))

(defconst site-footer
  (concat "<footer class=\"site-footer\"><div class=\"wrap\">"
          "© bismigel · published from Org with org-publish"
          "</div></footer>"))

(defun my-sitemap (title list)
  "Homepage: a short intro plus the list of posts."
  (concat
   "#+TITLE: " title "\n\n"
   "Hi — I'm Miguel. I run a small, two-machine homelab (NixOS + k3s + ArgoCD)\n"
   "and write up the design, the migrations, and the mistakes here.\n\n"
   "This whole site is written in Emacs and published straight from Org with\n"
   "=org-publish= — no static-site generator in the middle.\n\n"
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
         :exclude "index\\.org")
        ("assets"
         :base-directory "static/"
         :publishing-directory "public/"
         :base-extension "css\\|js\\|png\\|jpe?g\\|svg\\|ico"
         :publishing-function org-publish-attachment
         :recursive t)))

(org-publish-all t)
(message "✓ site exported to public/")

;; (rebuild trigger)
