;;;Commentary
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(el-get 'sync)

(require 'ido)
(ido-mode t)

(add-to-list 'load-path "~/.emacs.d/el-get/auto-complete")
(require 'auto-complete)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(require 'auto-complete-config)
(ac-config-default)
(global-auto-complete-mode t)

; pymacs
(add-to-list 'load-path "~/.emacs.d/el-get/pymacs")
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(autoload 'pymacs-autoload "pymacs")

; ropemacs
(require 'pymacs)
(pymacs-load "ropemacs" "rope-")

(add-to-list 'load-path "~/.emacs.d/el-get/fill-column-indicator")
(require 'fill-column-indicator)
(define-globalized-minor-mode
 global-fci-mode fci-mode (lambda () (fci-mode 1)))
(global-fci-mode t)

(add-hook 'python-mode-hook 'jedi:setup)
   (setq jedi:setup-keys t)                      ; optional
   (setq jedi:complete-on-dot t)                 ; optional


(add-to-list 'load-path "~/.emacs.d/el-get/python-pep8")
(require 'python-pep8)

(add-to-list 'load-path "~/.emacs.d/el-get/flycheck")
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

(global-set-key (kbd "C-x j") 'python-django-open-project)
