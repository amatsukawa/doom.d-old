;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Akihiro Matsukawa"
      user-mail-address "akihiro.matsukawa@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; =============
;;     emacs 
;; =============

(add-to-list 'default-frame-alist '(height . 80))
(add-to-list 'default-frame-alist '(width . 200))

(setq confirm-kill-emacs nil
      confirm-kill-processes nil
      select-enable-primary t)


;; =============
;;      org 
;; =============


(setq org-ellipsis " ▾ "
      org-hide-emphasis-markers t
      org-return-follows-link t
      org-catch-invisible-edits 'smart
      org-image-actual-width nil
      org-preview-latex-image-directory "/tmp/ltximg/"
      org-export-with-sub-superscripts nil)

(map! :after org
      :map org-mode-map
      :localleader
      :prefix ("z" . "my-org")
      "t" #'org-show-todo-tree)



;; == gdt ==
(setq org-log-done 'time
      org-log-into-drawer t)

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))

(setq org-refile-use-outline-path 'file
      org-refile-allow-creating-parent-nodes 'confirm
      org-outline-path-complete-in-steps nil)

(setq org-agenda-files `(,(expand-file-name "gtd.org" org-directory)))

(after! org-capture ; after is needed here.
  (setq org-capture-templates
        `(("t" "TODO" entry (file+headline ,(expand-file-name "gtd.org" org-directory) "Inbox")
           "* TODO %^{Description}\n:LOGBOOK:\n- Added %U\n:END:\n%?")
          ("r" "Reminder" entry (file+headline ,(expand-file-name "gtd.org" org-directory) "Reminders")
                "* TODO %^{Description}\nSCHEDULED: %^T"))))


;; == org-download ==
(use-package! org-download
  :commands
  org-download-dnd
  org-download-yank
  org-download-screenshot
  org-download-dnd-base64
  :init
  (pushnew! dnd-protocol-alist
            '("^\\(?:https?\\|ftp\\|file\\|nfs\\):" . +org-dragndrop-download-dnd-fn)
            '("^data:" . org-download-dnd-base64))
  (advice-add #'org-download-enable :override #'ignore)
  :config
  ;; write images to images/<filename>/ in the path of the org file.
  (defun my-org-download-method (link)
    (let* ((filename
            (file-name-nondirectory
            (car (url-path-and-query
                  (url-generic-parse-url link)))))
          (dirname (concat "./images/" (file-name-sans-extension (buffer-name))))
          (filename-with-timestamp (format "%s%s.%s"
                                  (file-name-sans-extension filename)
                                  (format-time-string org-download-timestamp)
                                  (file-name-extension filename))))
      (unless (file-exists-p dirname)
        (make-directory dirname t))
      (expand-file-name filename-with-timestamp dirname)))
  (setq org-download-method 'my-org-download-method)
  (setq org-download-screenshot-method
        (cond (IS-MAC "screencapture -i %s")
              (IS-LINUX
               (cond ((executable-find "maim")  "maim -s %s")
                     ((executable-find "scrot") "scrot -s %s")))))
  (if (memq window-system '(mac ns))
      (setq org-download-screenshot-method "screencapture -i %s")
    (setq org-download-screenshot-method "maim -s %s"))
  (setq org-download-image-org-width 600
        org-download-image-html-width 600
        org-download-image-latex-width 15))


;; == org-pomodoro ==
(setq org-pomodoro-keep-killed-time t
      org-pomodoro-play-sounds nil)


;; == org-journal ==
(after! org-journal
  (setq org-journal-file-type 'weekly
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-date-format "%A, %d %B %Y"))


;; == org-roam ==
;; see org-roam branch
