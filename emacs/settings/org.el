;;; org.el --- Description -*- lexical-binding: t; -*-

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package org-superstar)

(add-hook 'org-mode-hook (lambda ()
			   (setq bidi-paragraph-direction 'nil);; support Right To Left languages
			   (org-superstar-mode 1)))

;; Replace list hyphen with dot
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                          (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
