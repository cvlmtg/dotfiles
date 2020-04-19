; --------------------------------------------------------------------------
; PACKAGES -----------------------------------------------------------------
; --------------------------------------------------------------------------

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(setq list-of-packages
 '(
   evil evil-leader evil-surround evil-matchit evil-args
  ))

(defun check-and-install-packages ()
  (interactive)
  (package-refresh-contents)
  (dolist (package list-of-packages)
    (when (not (package-installed-p package))
      (package-install package))))

; http://stackoverflow.com/a/14838150
(defun package-list-unaccounted-packages ()
  "Like 'package-list-packages', but shows only the packages that
  are installed and are not in 'list-of-packages'.  Useful for
  cleaning out unwanted packages."
  (interactive)
  (package-show-package-list
    (remove-if-not (lambda (x) (and (not (memq x list-of-packages))
                                    (not (package-built-in-p x))
                                    (package-installed-p x)))
                   (mapcar 'car package-archive-contents))))

(when (not package-archive-contents)
  (check-and-install-packages))

; --------------------------------------------------------------------------
; APPEARANCE ---------------------------------------------------------------
; --------------------------------------------------------------------------

(set-default-font "JetBrains Mono")
(load-theme 'wombat t)

; nascondiamo un po' di roba. alcune impostazioni sono condizionali
; perchè emacs senza gui non definisce alcuni simboli (che non hanno
; senso sotto console)
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (tool-bar-mode -1))
(menu-bar-mode -1)

; evidenziamo le parentesi
(setq show-paren-delay 0)
(show-paren-mode 1)

; mostra il numero della colonna nella riga di stato
(column-number-mode 1)

; mostra i numeri di riga nel buffer. cambiamo anche il
; formato se no sotto console sono appiccicati al testo
(when (version<= "26.0.50" emacs-version)
  (setq-default display-line-numbers 'relative
      display-line-numbers-current-absolute t))

; evidenziamo la riga corrente disattivando l'underline
(global-hl-line-mode 1)
(set-face-underline-p 'hl-line nil)

; --------------------------------------------------------------------------
; MISC SETTINGS ------------------------------------------------------------
; --------------------------------------------------------------------------

(setq make-backup-files nil)
(electric-pair-mode 1)

; reduce startup noise
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

; indent with two spaces, don't use tab
(setq standard-indent 2)
(setq-default indent-tabs-mode nil)

;; Enable mouse support
(unless window-system
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

; --------------------------------------------------------------------------
; EVIL! --------------------------------------------------------------------
; --------------------------------------------------------------------------

(require 'evil)
(evil-mode 1)
(global-evil-leader-mode)
(global-evil-surround-mode)

; customizziamo i nostri tasti
(define-key evil-normal-state-map "Y" 'copy-to-end-of-line)

(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "f" 'helm-projectile-find-file
  "F" 'helm-projectile-ag
  "g" 'magit)
