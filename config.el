;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Joni Hiltunen"
      user-mail-address "djonih@gmail.com")

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
(setq doom-font (font-spec :family "Source Code Pro" :size 12 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)

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

(defun aborn/backward-kill-word ()
  "Customize/Smart backward-kill-word."
  (interactive)
  (let* ((cp (point))
         (backword)
         (end)
         (space-pos)
         (backword-char (if (bobp)
                            ""           ;; cursor in begin of buffer
                          (buffer-substring cp (- cp 1)))))
    (if (equal (length backword-char) (string-width backword-char))
        (progn
          (save-excursion
            (setq backword (buffer-substring (point) (progn (forward-word -1) (point)))))
          (setq ab/debug backword)
          (save-excursion
            (when (and backword          ;; when backword contains space
                       (s-contains? " " backword))
              (setq space-pos (ignore-errors (search-backward " ")))))
          (save-excursion
            (let* ((pos (ignore-errors (search-backward-regexp "\n")))
                   (substr (when pos (buffer-substring pos cp))))
              (when (or (and substr (s-blank? (s-trim substr)))
                        (s-contains? "\n" backword))
                (setq end pos))))
          (if end
              (kill-region cp end)
            (if space-pos
                (kill-region cp space-pos)
              (backward-kill-word 1))))
      (kill-region cp (- cp 1)))))         ;; word is non-english word


(global-set-key  [C-backspace] 'aborn/backward-kill-word)
;; Jump between 2 buffers
(defun switch-to-previous-buffer ()
  "Switch to previously opened buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(map! :nvi "C-." #'switch-to-previous-buffer)

;; Custom key binds
(map! :nvi :after 'swiper "C-s" #'swiper)
(map! :after 'ace-window "C-w C-w" #'ace-window)

(after! treemacs
  (map! :leader
        (:prefix "t"
         :desc "Treemacs"
         "t" #'treemacs)))

(defun sose/lsp-ui-toggle ()
  "Toggle LSP UI"
  (interactive)
  (if (get-buffer "*lsp-diagnostics*")
      (lsp-ui-flycheck-list--quit)
    (lsp-ui-flycheck-list)))

(map! :leader
      (:prefix "c"
       :desc "Show all errors"
       "X" #'sose/lsp-ui-toggle))

;; Visual line mode (word wrap)
(global-visual-line-mode t)

;; My custom stuff
(setq
 js-indent-level 2
 typescript-indent-level 2
 json-reformat:indent-width 2
 which-key-idle-delay 0.2
 which-key-idle-secondary-delay 0.05
 evil-escape-key-sequence "fd"
 kill-whole-line t
 lsp-auto-guess-root t
 scroll-margin 2
 show-trailing-whitespace t
 eldoc-idle-delay 0.1
 +ivy-project-search-engines '(rg)
 all-the-icons-scale-factor 1.1
 evil-move-cursor-back nil)

;; Fix PATH inside emacs
(after! exec-path-from-shell
  (exec-path-from-shell-initialize))

;; Python fill column is 88 with Black
(add-hook! 'python-mode-hook (set-fill-column 88))

(defun sose/cider-maybe-load ()
  (interactive)
  (let ((filename (file-name-nondirectory (buffer-file-name)))
        (extension (file-name-extension (buffer-file-name))))
    (when (and (not (string= filename "project.clj"))
               (not (string= extension "edn")))
      (cider-ns-reload))))

(add-hook! 'clojure-mode-hook
  (add-hook 'after-save-hook #'sose/cider-maybe-load nil 'local))

;; Use prettier to format Javascript and TypeScript, instead of LSP
(setq-hook! 'js2-mode-hook
  +format-with-lsp nil)

(setq-hook! 'typescript-mode-hook
  +format-with-lsp nil)
