(require 'package)
1(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(setq gc-cons-threshold 100000000)
(setq inhibit-startup-message t)

(defalias 'yes-or-no-p 'y-or-n-p)

(defconst demo-packages
  '(ac-c-headers
    ac-math
    anzu
    auto-complete
    buffer-move
    clean-aindent-mode
    comment-dwim-2
    company-irony
    company-irony-c-headers
    company
    company-auctex
    dtrt-indent
    duplicate-thing
    flycheck-irony
    flycheck
    flymake-cppcheck
    flymake-easy
    function-args
    ggtags
    github-browse-file
    helm-gtags
    helm-projectile
    helm-swoop
    helm
    helm-core
    async
    iedit
    irony
    latex-extra
    auctex
    latex-math-preview
    latex-preview-pane
    latex-pretty-symbols
    magit
    markdown-mode
    math-symbol-lists
    multiple-cursors
    pdf-tools
    let-alist
    popup
    projectile
    pkg-info
    epl
    dash
    seq
    swiper
    ivy
    tablist
    undo-tree
    volatile-highlights
    ws-butler
    yasnippet
    zygospore))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package demo-packages)
    (unless (package-installed-p package)
      (package-install package))))

(install-packages)

;; this variables must be set before load helm-gtags
;; you can change to any prefix key of your choice
(setq helm-gtags-prefix-key "\C-cg")

(add-to-list 'load-path "~/.emacs.d/custom")



(require 'setup-helm)
(require 'setup-helm-gtags)
;; (require 'setup-ggtags)
(require 'setup-cedet)
;;(require 'setup-editing)

(setq-default c-basic-offset 4)
(setq-default tab-width 4)

(add-hook 'sh-mode-hook (lambda ()
                          (setq tab-width 4)))

(defun fix-c-indent-offset-according-to-syntax-context (key val)
  ;; remove the old element
  (setq c-offsets-alist (delq (assoc key c-offsets-alist) c-offsets-alist))
  ;; new value
  (add-to-list 'c-offsets-alist '(key . val)))

(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              ;; indent
              (fix-c-indent-offset-according-to-syntax-context 'substatement-open 0))
            ))
(windmove-default-keybindings)




;; hs-minor-mode for folding source code
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;; Available C style:
;; “gnu”: The default style for GNU projects
;; “k&r”: What Kernighan and Ritchie, the authors of C used in their book
;; “bsd”: What BSD developers use, aka “Allman style” after Eric Allman.
;; “whitesmith”: Popularized by the examples that came with Whitesmiths C, an early commercial C compiler.
;; “stroustrup”: What Stroustrup, the author of C++ used in his book
;; “ellemtel”: Popular C++ coding standards as defined by “Programming in C++, Rules and Recommendations,” Erik Nyquist and Mats Henricson, Ellemtel
;; “linux”: What the Linux developers use for kernel development
;; “python”: What Python developers use for extension modules
;; “java”: The default style for java-mode (see below)
;; “user”: When you want to define your own style
(defun my-c-mode-hook ()
  (setq c-basic-offset 4
        c-indent-level 4
        c-default-style "bsd"))
(add-hook 'c-mode-common-hook 'my-c-mode-hook)
(global-set-key (kbd "RET") 'newline-and-indent)  ; automatically indent when press RET

;; activate whitespace-mode to view all whitespace characters
(global-set-key (kbd "C-c w") 'whitespace-mode)

;; show unncessary whitespace that can mess up your diff
(add-hook 'prog-mode-hook (lambda () (interactive) (setq show-trailing-whitespace 1)))

;; use space to indent by default
(setq-default indent-tabs-mode nil)

;; set appearance of a tab that is represented by 2 spaces


;; Compilation
(global-set-key (kbd "<f5>") (lambda ()
                               (interactive)
                               (setq-local compilation-read-command nil)
                               (call-interactively 'compile)))

;; setup GDB
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )

;; Package: clean-aindent-mode
(require 'clean-aindent-mode)
(add-hook 'prog-mode-hook 'clean-aindent-mode)


;; Package: ws-butler
(require 'ws-butler)
(add-hook 'prog-mode-hook 'ws-butler-mode)

;; Package: yasnippet
(require 'yasnippet)
(yas-global-mode 1)




;; Package: projectile
(require 'projectile)
(add-hook 'c++-mode-hook 'projectile-global-mode)
(add-hook 'c-mode-hook 'projectile-global-mode)
(define-key c++-mode-map (kbd "C-c h k") 'projectile-find-file)
(setq projectile-enable-caching t)

(require 'helm-projectile)
(add-hook 'c++-mode-hook 'helm-projectile-on)
(add-hook 'c-mode-hook 'helm-projectile-on)
(setq projectile-completion-system 'helm)
;; (setq projectile-indexing-method 'alien)


;; company
(require 'company)
(add-hook 'c++-mode-hook 'global-company-mode)
(add-hook 'c-mode-hook 'global-company-mode)
(delete 'company-semantic company-backends)
(define-key c-mode-map  [C-tab] 'company-complete)
(define-key c++-mode-map  [C-tab] 'company-complete)
;; (define-key c-mode-map  [(control tab)] 'company-complete)
;; (define-key c++-mode-map  [(control tab)] 'company-complete)

;; company-c-headers
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's asynchronous function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)

;; company-irony
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
(global-set-key (kbd "M-RET") 'company-complete)

(global-set-key (kbd "M-S-<mouse-1>") 'mc/add-cursor-on-click)


(require 'flycheck)
(global-flycheck-mode 1)

(require 'buffer-move)
(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

;; matching parentheses
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Package zygospore
(global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(TeX-engine (quote default))
 '(TeX-save-query nil)
 '(c-basic-offset 4)
 '(flycheck-c/c++-gcc-executable nil)
 '(flycheck-gcc-definitions
   (quote
    ("WITH_EIGEN=true" "WITH_CGAL=true" "WITH_GMP=true" "WITH_ITK=true")))
 '(flycheck-gcc-include-path
   (quote
    ("/usr/include/eigen3/" "/usr/include/qt4/" "/usr/include/boost" "/usr/include/qt4/Qt" "/usr/include/qt4/Qt3Support" "/usr/include/qt4/QtCore" "/usr/include/qt4/QtDBus" "/usr/include/qt4/QtDeclarative" "/usr/include/qt4/QtDesigner" "/usr/include/qt4/QtGui" "/usr/include/qt4/QtHelp" "/usr/include/qt4/QtNetwork" "/usr/include/qt4/QtOpenGL" "/usr/include/qt4/QtScript" "/usr/include/qt4/QtScriptTools" "/usr/include/qt4/QtSql" "/usr/include/qt4/QtSvg" "/usr/include/qt4/QtTest" "/usr/include/qt4/QtUiTools" "/usr/include/qt4/QtWebKit" "/usr/include/qt4/QtXml" "/usr/include/qt4/QtXmlPatterns" "/home/fgrelard/MyDGtalContrib/src/" "/usr/local/include/ITK-4.10/")))
 '(flycheck-gcc-language-standard "c++11")
 '(flycheck-gcc-openmp t)
 '(irony-cdb-compilation-databases
   (quote
    (irony-cdb-clang-complete irony-cdb-libclang irony-cdb-json)))
 '(lpr-command "gtklp")
 '(package-selected-packages
   (quote
    (latex-pretty-symbols auctex-lua auto-complete-auctex company-auctex magithub magit zygospore yasnippet ws-butler volatile-highlights undo-tree pdf-tools multiple-cursors markdown-mode latex-preview-pane latex-math-preview latex-extra iedit helm-swoop helm-projectile helm-gtags github-browse-file ggtags function-args flymake-cppcheck flycheck-irony duplicate-thing dtrt-indent company-irony-c-headers company-irony comment-dwim-2 clean-aindent-mode buffer-move anzu ac-math ac-c-headers)))
 '(pdf-latex-command "pdflatex")
 '(projectile-globally-ignored-directories
   (quote
    (".idea" ".eunit" ".git" ".hg" ".fslckout" ".bzr" "_darcs" ".tox" ".svn" ".stack-work" "build/" "CMakeFiles/")))
 '(projectile-globally-ignored-files (quote ("TAGS")))
 '(ps-lpr-command "gtklp"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-preprocessor-face ((t (:inherit font-lock-builtin-face)))))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ih\\'" . c++-mode))

(eval-after-load "tex"
  '(progn
     (setcdr (assq 'output-pdf TeX-view-program-selection) '("PDF Tools"))
     (add-to-list 'TeX-command-list '("Make" "make" TeX-run-compile nil t))))


(defun my-tex-compile ()
  (interactive)
  (save-buffer)
  (TeX-command "Make" 'TeX-master-file))


(eval-after-load 'latex
  '(define-key LaTeX-mode-map (kbd "<f1>") 'my-tex-compile))

(eval-after-load 'plain-tex
  '(define-key plain-TeX-mode-map (kbd "<f1>") 'my-tex-compile))

(pdf-tools-install)
(load "pdf-tools")
;; If you want synctex support, this should be sufficient assuming
;; you are using LaTeX-mode
(add-hook 'TeX-mode-hook 'TeX-source-correlate-mode)
(add-hook 'TeX-after-TeX-LaTeX-command-finished-hook
           #'TeX-view)
(set-face-attribute 'default nil :height 110)

(require 'auto-complete)
(add-to-list 'ac-modes 'latex-mode) ; beware of using 'LaTeX-mode instead
(require 'ac-math) ; package should be installed first
(defun my-ac-latex-mode () ; add ac-sources for latex
   (setq ac-sources
         (append '(ac-source-math-unicode
           ac-source-math-latex
           ac-source-latex-commands)
                 ac-sources)))
(add-hook 'LaTeX-mode-hook 'my-ac-latex-mode)
(setq ac-math-unicode-in-math-p t)
(ac-flyspell-workaround) ; fixes a known bug of delay due to flyspell (if it is there)
(add-to-list 'ac-modes 'org-mode) ; auto-complete for org-mode (optional)
(require 'auto-complete-config) ; should be after add-to-list 'ac-modes and hooks
(ac-config-default)
(setq ac-auto-start nil)            ; if t starts ac at startup automatically
(setq ac-auto-show-menu t)
(add-hook 'LaTeX-mode-hook 'global-company-mode)
(add-hook 'LaTeX-mode-hook 'company-auctex)
(add-hook 'LaTeX-mode-hook 'company-auctex-init)
(add-hook 'LaTeX-mode-hook 'global-auto-complete-mode)
(add-hook 'TeX-mode-hook 'global-company-mode)
(add-hook 'LaTeX-mode-hook 'reftex-mode)
(require 'latex-pretty-symbols)
(setq reftex-ref-macro-prompt nil)
