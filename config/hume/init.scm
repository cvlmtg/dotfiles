(load-plugin! "core:stdlib")
(load-plugin! "core:pickers")
(load-plugin! "core:buffer-words")
(load-plugin! "core:vim-keybind")
(load-plugin! "cvlmtg/grep.hume")
(load-plugin! "core:plum")
(load-plugin! "core:lsp")
(load-plugin! "core:lsp-install")
(load-plugin! "core:undotree")
(load-plugin! "core:git-diff")
(load-plugin! "core:steel-server")

; ---------------------------------------------------------------------

(configure-statusline!
  '("Position" "steel:git-branch" "FilePath" "Language" "ReadOnly" "DirtyIndicator")
  '()
  '("MacroRecording" "SearchMatches" "Diagnostics" "KittyProtocol" "Separator" "Mode"))

(set-option! "whitespace-space" "trailing")
(set-option! "whitespace-tab" "all")
(set-option! "tab-style" "soft")
(set-option! "tab-width" "2")
(set-option! "lsp.inlay-hints" "true")
(set-option! "signcolumn" "always:2")

; ---------------------------------------------------------------------

(bind-key! 'normal "space space" "lsp-goto-definition")
(bind-key! 'normal "space m" "picker-git-modified")
(bind-key! 'normal "space b" "picker-buffers")
(bind-key! 'normal "space f" "picker-files")
(bind-key! 'normal "space g" "picker-grep")
(bind-key! 'normal "space k" "lsp-hover")
(bind-key! 'normal "{" "goto-prev-tab")
(bind-key! 'normal "}" "goto-next-tab")
(bind-key! 'normal "\\" "goto-alternate-buffer")

(define-command! "copy-buffer-path"
  "Copy the current buffer's absolute path to the clipboard register (c)."
  (lambda (bid)
    (let ([path (buffer-path bid)])
      (when path ; check for unsaved buffers
        (write-register! "c" (list path))))))

(bind-key! 'normal "space p" "copy-buffer-path")

; TAB -----------------------------------------------------------------

; Complete after a letter; insert a tab everywhere else (start of line,
; after whitespace/punctuation). Steel has no char-alphabetic?, so "letter"
; is tested as "has case" — covers Latin/Greek/Cyrillic, excludes digits,
; punctuation, and caseless scripts.
(define (primary-head pane)
  (let loop ([sels (or (buffer-selections pane) '())])
    (cond [(null? sels) #f]
          [(call! "stdlib/selection-primary?" (car sels))
           (call! "stdlib/selection-head" (car sels))]
          [else (loop (cdr sels))])))

(define (cased-letter? c)
  (not (char=? (char-upcase c) (char-downcase c))))

(define (letter-before-cursor? pane)
  (let ([head (primary-head pane)])
    (and head
         (let* ([line (offset->line pane head)]
                [col  (- head (line->offset pane line))])
           (and (> col 0)
                (cased-letter?
                  (string-ref (car (buffer-lines pane #:start line #:end (+ line 1)))
                              (- col 1))))))))

(define-command! "tab-or-complete"
  "Complete after a letter, otherwise insert a tab."
  (lambda (pane)
    (if (letter-before-cursor? pane)
        (call! "completion-trigger" pane)
        (insert-key! pane "tab"))))

(bind-key! 'insert "tab" "tab-or-complete")

(define (line-has-text? line)
  (not (equal? (trim line) "")))

(define (selection-lines bid sel)
  (let ([a (call! "stdlib/selection-anchor" sel)]
        [h (call! "stdlib/selection-head" sel)])
    (buffer-lines bid
                  #:start (offset->line bid (min a h))
                  #:end (+ (offset->line bid (max a h)) 1))))

; `indent`/`unindent` act on whole lines but skip blank ones (empty or
; whitespace-only), so a linewise selection covering nothing but blank lines
; leaves the buffer untouched — gating on linewise alone makes the key dead
; there instead of falling through to the pane focus.
(define (indent-would-edit? bid)
  (and (selections-linewise? bid)
       (let ([sels (buffer-selections bid)])
         (and sels
              (call! "stdlib/find"
                     line-has-text?
                     (apply append
                            (map (lambda (sel) (selection-lines bid sel))
                                 sels)))))))

(define-command! "indent-or-focus-pane"
  "Indent when every selection is linewise with text, otherwise focus the next pane."
  (lambda (bid)
    (if (indent-would-edit? bid)
        (call! "indent" bid)
        (call! "pane-focus-next" bid))))

(define-command! "unindent-or-focus-pane"
  "Unindent when every selection is linewise with text, otherwise focus the next pane."
  (lambda (bid)
    (if (indent-would-edit? bid)
        (call! "unindent" bid)
        (call! "pane-focus-next" bid))))

; Without the kitty protocol, Tab and Ctrl-i are the same byte (0x09), so
; rebinding "tab" here also removes jump-forward from the keyboard entirely.
(bind-key! 'normal "tab" "indent-or-focus-pane")
(bind-key! 'normal "shift-tab" "unindent-or-focus-pane")
