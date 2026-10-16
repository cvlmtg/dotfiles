(load-plugin! "core:stdlib")
(load-plugin! "core:pickers")
(load-plugin! "core:buffer-words")
(load-plugin! "core:vim-keybind")
(load-plugin! "cvlmtg/grep.hume")
(load-plugin! "core:plum")
(load-plugin! "core:lsp" #:config (hash "inlay-hints" #t))
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
(set-option! "signcolumn" "always:2")

; ---------------------------------------------------------------------

(bind-key! 'normal "space space" "lsp/goto-definition")
(bind-key! 'normal "space m" "pickers/git-modified")
(bind-key! 'normal "space b" "pickers/buffers")
(bind-key! 'normal "space f" "pickers/files")
(bind-key! 'normal "space g" "grep/picker")
(bind-key! 'normal "space k" "lsp/hover")
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

(define-typed-command! "trim-trailing"
  "Remove trailing spaces and tabs."
  (lambda (pane)
    (when (selections-charwise? pane)
      (select-all pane))
    (when (sift-within pane "(?m)[ \t]+$")
      (delete-selection pane)
      (keep-primary-selection pane))))

; LSP -----------------------------------------------------------------

(for-each
  (lambda (lang)
    (set-language-servers! lang
      '("typescript-language-server" "vscode-eslint-language-server")))
  '("javascript" "jsx" "typescript" "tsx"))

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
         (let* ([line (char-offset->line pane head)]
                [col  (- head (line->char-offset pane line))])
           (and (> col 0)
                (cased-letter?
                  (string-ref (car (buffer-lines pane
                                                 #:range (hash 'start-line line 'end-line (+ line 1))))
                              (- col 1))))))))

(define-command! "tab-or-complete"
  "Complete after a letter, otherwise insert a tab."
  (lambda (pane)
    (if (letter-before-cursor? pane)
        (completion-trigger pane)
        (insert-key! pane "tab"))))

(bind-key! 'insert "tab" "tab-or-complete")

(define (line-has-text? line)
  (not (equal? (trim line) "")))

(define (selection-lines bid sel)
  (let ([a (call! "stdlib/selection-anchor" sel)]
        [h (call! "stdlib/selection-head" sel)])
    (buffer-lines bid
                  #:range (hash 'start-line (char-offset->line bid (min a h))
                                'end-line (+ (char-offset->line bid (max a h)) 1)))))

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
        (indent bid)
        (pane-focus-next bid))))

(define-command! "unindent-or-focus-pane"
  "Unindent when every selection is linewise with text, otherwise focus the next pane."
  (lambda (bid)
    (if (indent-would-edit? bid)
        (unindent bid)
        (pane-focus-next bid))))

; Without the kitty protocol, Tab and Ctrl-i are the same byte (0x09), so
; rebinding "tab" here also removes jump-forward from the keyboard entirely.
(bind-key! 'normal "tab" "indent-or-focus-pane")
(bind-key! 'normal "shift-tab" "unindent-or-focus-pane")

; GIT DIFF ------------------------------------------------------------

; Off when inline diff is on, pointing the gutter signs back at HEAD first (the
; ref is shared with the signs; show-inline-diff sets it, the toggle then turns
; inline off). Otherwise on against HEAD when the tree is dirty
; (`git diff --quiet` exits 1), HEAD^ when it is clean (exits 0).
(define-command! "toggle-inline-diff-auto"
  "Toggle inline git diff: against HEAD when the tree is dirty, HEAD^ when clean."
  (lambda (pane)
    (if (call! "git-diff/inline-diff?" pane)
        (begin
          (call! "git-diff/show-inline-diff" pane "HEAD")
          (call! "git-diff/toggle-inline-diff" pane))
        (let ([path (buffer-path pane)])
          (when path
            (spawn-async! "git" '("diff" "--quiet" "HEAD")
              (lambda (stdout stderr code)
                (cond [(= code 0) (call! "git-diff/show-inline-diff" pane "HEAD^")]
                      [(= code 1) (call! "git-diff/show-inline-diff" pane "HEAD")]
                      [else (log! 'warn (string-append "git diff failed: " (trim stderr)))]))
              #:cwd (parent-name path)))))))

(bind-key! 'normal "space d" "toggle-inline-diff-auto")
