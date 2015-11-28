(set-face-attribute 'default nil :height 200)
(setq-default indent-tabs-mode nil)

;; fix the PATH variable
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "$SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(defvar lisp-packages
  '(clojure-mode
    cider
    paredit
    nlinum
    fill-column-indicator))

(dolist (p lisp-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "/usr/local/bin/ccl64")

(autoload 'enable-paredit-mode "paredit" 
  "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'clojure-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook (lambda () (slime-mode t)))

(defun scheme-add-keywords (face-name keyword-rules)
  (let* ((keyword-list (mapcar #'(lambda (x)
				   (symbol-name (cdr x)))
			       keyword-rules))
	 (keyword-regexp (concat "(\\("
				 (regexp-opt keyword-list)
				 "\\)[ \n]")))
    (font-lock-add-keywords 'scheme-mode
			    `((,keyword-regexp 1 ',face-name))))
  (mapc #'(lambda (x)
	    (put (cdr x)
		 'scheme-indent-function
		 (car x)))
	keyword-rules))

(scheme-add-keywords
 'font-lock-keyword-face
 '((1 . when)
   (1 . unless)
   (1 . actor)
   (1 . match)
   (1 . error)))

(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")
(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
	(save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

(defun clojure-setup ()
  (local-set-key (kbd "RET") 'electrify-return-if-match)
  (local-set-key (kbd "C-c e") 'cider-eval-buffer))
(defun lisp-setup ()
  (local-set-key (kbd "RET") 'electrify-return-if-match))
(add-hook 'clojure-mode-hook #'clojure-setup)
(add-hook 'lisp-mode-hook #'lisp-setup)

;(defun racket-setup ()
;  (local-set-key (kbd "RET") 'electrify-return-if-match)
;  (local-set-key (kbd "C-c e") 'geiser-eval-buffer))
;(add-hook 'scheme-mode-hook #'racket-setup)
;(setq geiser-active-implementations '(racket))
(require 'clojure-mode)

(define-clojure-indent
  (defroutes 'defun)
  (GET 2)
  (POST 2)
  (PUT 2)
  (DELETE 2)
  (HEAD 2)
  (ANY 2)
  (context 2))

(setq show-paren-delay 0)
(show-paren-mode 1)
(require 'ido)
(ido-mode t)
(require 'nlinum)
(fringe-mode -1)
(global-linum-mode t)
(setq linum-format " %04d ")
(require 'fill-column-indicator)
(define-globalized-minor-mode global-fci-mode fci-mode
  (lambda () 
    (fci-mode 1)
    (setq fci-rule-column 80)))

(global-fci-mode 1)

(defun plist-to-alist (the-plist)
  (defun get-tuple-from-plist (the-plist)
    (when the-plist
      (cons (car the-plist) (cadr the-plist))))

  (let ((alist '()))
    (while the-plist
      (add-to-list 'alist (get-tuple-from-plist the-plist))
      (setq the-plist (cddr the-plist)))
  alist))

(setq ring-bell-function 'ignore)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-frame-parameter nil 'fullscreen 'fullboth)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (deeper-blue)))
 '(fci-rule-color "#383838")
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map (quote ((20 . "#BC8383") (40 . "#CC9393") (60 . "#DFAF8F") (80 . "#D0BF8F") (100 . "#E0CF9F") (120 . "#F0DFAF") (140 . "#5F7F5F") (160 . "#7F9F7F") (180 . "#8FB28F") (200 . "#9FC59F") (220 . "#AFD8AF") (240 . "#BFEBBF") (260 . "#93E0E3") (280 . "#6CA0A3") (300 . "#7CB8BB") (320 . "#8CD0D3") (340 . "#94BFF3") (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(linum ((t (:inherit (shadow default) :foreground "MediumPurple4")))))
