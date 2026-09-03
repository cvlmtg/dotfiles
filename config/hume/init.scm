(load-plugin "core:stdlib")
(load-plugin "core:pickers")
(load-plugin "core:vim-keybind")
(load-plugin "cvlmtg/grep.hume")
(declare-plugin "core:plum")
(declare-plugin "core:lsp")
(declare-plugin "core:git-diff")
(declare-plugin "core:steel-server")

; ---------------------------------------------------------------------

(bind-key! 'normal "space space" "lsp-goto-definition")
(bind-key! 'normal "space m" "picker-git-modified")
(bind-key! 'normal "space b" "picker-buffers")
(bind-key! 'normal "space f" "picker-files")
(bind-key! 'normal "space a" "picker-grep")
(bind-key! 'normal "space k" "lsp-hover")
(bind-key! 'normal "\\" "goto-alternate-buffer")

(define-command! "copy-buffer-path"
  "Copy the current buffer's absolute path to the clipboard register (c)."
  (lambda ()
    (let ([path (buffer-path (current-buffer))])
      (when path ; check for unsaved buffers
        (write-register! "c" (list path))))))

(bind-key! 'normal "space p" "copy-buffer-path")

(define (line-has-text? line)
  (not (equal? (trim line) "")))

(define (selection-lines bid sel)
  (let ([a (call! "stdlib/selection-anchor" sel)]
        [h (call! "stdlib/selection-head" sel)])
    (buffer-lines bid
                  #:start (- (char-index->line (min a h)) 1)
                  #:end (char-index->line (max a h)))))

; `indent`/`unindent` act on whole lines but skip blank ones (empty or
; whitespace-only), so a linewise selection covering nothing but blank lines
; leaves the buffer untouched — gating on linewise alone makes the key dead
; there instead of falling through to the pane focus.
(define (indent-would-edit? bid)
  (and (selections-linewise? bid)
       (let ([sels (current-selections)])
         (and sels
              (call! "stdlib/find"
                     line-has-text?
                     (apply append
                            (map (lambda (sel) (selection-lines bid sel))
                                 sels)))))))

(define-command! "indent-or-focus-pane"
  "Indent when every selection is linewise with text, otherwise focus the next pane."
  (lambda ()
    (if (indent-would-edit? (current-buffer))
        (call! "indent")
        (call! "pane-focus-next"))))

(define-command! "unindent-or-focus-pane"
  "Unindent when every selection is linewise with text, otherwise focus the next pane."
  (lambda ()
    (if (indent-would-edit? (current-buffer))
        (call! "unindent")
        (call! "pane-focus-next"))))

; Without the kitty protocol, Tab and Ctrl-i are the same byte (0x09), so
; rebinding "tab" here also removes jump-forward from the keyboard entirely.
(bind-key! 'normal "tab" "indent-or-focus-pane")
(bind-key! 'normal "shift-tab" "unindent-or-focus-pane")

; ---------------------------------------------------------------------

(set-option! "whitespace-space" "trailing")
(set-option! "whitespace-tab" "all")
(set-option! "tab-style" "soft")
(set-option! "tab-width" "2")
(set-option! "lsp.inlay-hints" "true")
(set-option! "signcolumn" "always:2")

(configure-statusline!
  '("Position" "steel:git-branch" "FilePath" "Language" "ReadOnly" "DirtyIndicator")
  '()
  '("MacroRecording" "SearchMatches" "Diagnostics" "KittyProtocol" "Separator" "Mode"))
