(load-plugin "core:plum")
(load-plugin "core:stdlib")
(load-plugin "core:vim-keybind")

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
(set-option! "theme" "sand")
