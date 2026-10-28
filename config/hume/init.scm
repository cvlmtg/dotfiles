(load-plugin! "core:stdlib")
(load-plugin! "core:pickers")
(load-plugin! "core:buffer-words")
(load-plugin! "core:vim-keybind")
(load-plugin! "cvlmtg/grep.hume")
(load-plugin! "core:plum")
(load-plugin! "core:lsp" #:config (hash 'inlay-hints #t))
(load-plugin! "core:lsp-install")
(load-plugin! "core:undotree")
(load-plugin! "core:git-diff")
(load-plugin! "core:steel-server")

; ---------------------------------------------------------------------

(configure-statusline!
  '("Position" "steel:git-branch" "FilePath" "Language" "ReadOnly" "DirtyIndicator")
  '()
  '("MacroRecording" "Pipe" "SearchMatches" "Diagnostics" "KittyProtocol" "Separator" "Mode"))

(set-option! "whitespace-space" "trailing")
(set-option! "whitespace-tab" "all")
(set-option! "indent-style" "soft")
(set-option! "indent-width" 2)
(set-option! "gutter-signs" "always:2")

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
(define (cased-letter? c)
  (not (char=? (char-upcase c) (char-downcase c))))

(define (letter-before-cursor? pane)
  (let ([head (call! "stdlib/cursor-char-offset" (buffer-selections pane))])
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
  (let ([a (selection-anchor sel)]
        [h (selection-head sel)])
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
        (pane-focus-prev bid))))

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
              (lambda (result)
                (let ([code (hash-ref result 'exit)])
                  (cond [(equal? code 0) (call! "git-diff/show-inline-diff" pane "HEAD^")]
                        [(equal? code 1) (call! "git-diff/show-inline-diff" pane "HEAD")]
                        [else (log! 'warning (string-append "git diff failed: "
                                                            (trim (hash-ref result 'stderr))))])))
              #:cwd (parent-name path)))))))

(bind-key! 'normal "space d" "toggle-inline-diff-auto")

; MARKDOWN ------------------------------------------------------------

(define (heading-prefix-length line)
  (let* ((n (string-length line))
         (skip (lambda (i c)
                 (let loop ((i i))
                   (if (and (< i n) (char=? (string-ref line i) c))
                       (loop (+ i 1))
                       i)))))
    (skip (skip 0 #\#) #\space)))

(define (anchor-lines pane)
  (let loop ((sels (buffer-selections pane)) (lines '()))
    (if (null? sels)
        (reverse lines)
        (let ((line (char-offset->line pane (selection-anchor (car sels)))))
          (loop (cdr sels)
                (if (and (pair? lines) (= line (car lines)))
                    lines
                    (cons line lines)))))))

(define-command! "markdown-heading"
  "Turn the line of each selection's anchor into a Markdown heading. The count sets the level."
  (lambda (pane count)
    (let ((prefix (string-append (make-string (min 6 (max 1 count)) #\#) " ")))
      (edit-text! pane
        (filter (lambda (edit) edit)
          (map (lambda (line)
                 (let ((text (car (buffer-lines pane #:range (hash 'start-line line 'end-line (+ line 1))))))
                   (and (> (string-length text) 0)
                        (let ((start (line->char-offset pane line)))
                          (hash 'start-char start
                                'end-char (+ start (heading-prefix-length text))
                                'text prefix)))))
               (anchor-lines pane)))))))

(bind-key! 'normal "G H" "markdown-heading" #:keymap "markdown-keys")

(register-hook! 'on-language-set
  (lambda (pane lang)
    (if (equal? lang "markdown")
        (attach-keymap! pane "markdown-keys")
        (detach-keymap! pane "markdown-keys"))))
