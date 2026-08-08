(load-plugin "core:stdlib")
(load-plugin "core:pickers")
(load-plugin "core:vim-keybind")
(declare-plugin "core:plum")
(declare-plugin "core:lsp")
(declare-plugin "core:git-diff")
(declare-plugin "core:steel-server")

(define-command! "move-down-select-word"
  "Move down one visual line, then select the nearest word on that line."
  (lambda (count extend)
    (call! "move-down" count extend)
    (call! "select-word-nearest-on-line" 1 extend)))

(define-command! "move-up-select-word"
  "Move up one visual line, then select the nearest word on that line."
  (lambda (count extend)
    (call! "move-up" count extend)
    (call! "select-word-nearest-on-line" 1 extend)))

(bind-key! 'normal "space space" "lsp-goto-definition")
(bind-key! 'normal "space m" "picker-git-modified")
(bind-key! 'normal "space b" "picker-buffers")
(bind-key! 'normal "space f" "picker-files")
(bind-key! 'normal "space d" "lsp-hover")
(bind-key! 'normal "\\" "goto-alternate-file")
(bind-keys! 'normal
            ("j" "move-down-select-word")
            ("k" "move-up-select-word")
            ("down" "move-down-select-word")
            ("up" "move-up-select-word"))

(set-option! "whitespace-space" "trailing")
(set-option! "whitespace-tab" "all")
(set-option! "tab-style" "soft")
(set-option! "tab-width" "2")
(set-option! "lsp.inlay-hints" "true")
