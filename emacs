; --------------------------------------------------------------------------
; PACKAGES -----------------------------------------------------------------
; --------------------------------------------------------------------------

(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))

(setq list-of-packages
      '(evil evil-surround evil-matchit evil-args
             php-mode autopair linum-relative
             ergoemacs-mode))

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

(set-default-font "Droid Sans Mono-9")
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
(show-paren-mode 1)

; mostra il numero della colonna nella riga di stato
(column-number-mode 1)

; mostra i numeri di riga nel buffer. cambiamo anche il
; formato se no sotto console sono appiccicati al testo
(setq-default linum-relative-format " %3s ")
(setq-default linum-format " %d ")
; mostra numeri di riga relativi
(require 'linum-relative)
(global-linum-mode 1)

; evidenziamo la riga corrente disattivando l'underline
(global-hl-line-mode 1)
(set-face-underline-p 'hl-line nil)

; --------------------------------------------------------------------------
; MISC SETTINGS ------------------------------------------------------------
; --------------------------------------------------------------------------

(setq make-backup-files nil)

; --------------------------------------------------------------------------
; ERGOEMACS ----------------------------------------------------------------
; --------------------------------------------------------------------------

(setq ergoemacs-theme nil)
(setq ergoemacs-keyboard-layout "it")
(require 'ergoemacs-mode)
(ergoemacs-mode 1)

; --------------------------------------------------------------------------
; EVIL! --------------------------------------------------------------------
; --------------------------------------------------------------------------

(require 'evil)
(evil-mode 1)

(defun copy-to-end-of-line ()
  (interactive)
  (evil-yank (point) (point-at-eol)))

; customizziamo i nostri tasti
(define-key evil-normal-state-map "Y" 'copy-to-end-of-line)

(define-key evil-normal-state-map (kbd "C-w <up>") 'evil-window-up)
(define-key evil-normal-state-map (kbd "C-w <down>") 'evil-window-down)
(define-key evil-normal-state-map (kbd "C-w <left>") 'evil-window-left)
(define-key evil-normal-state-map (kbd "C-w <right>") 'evil-window-right)
