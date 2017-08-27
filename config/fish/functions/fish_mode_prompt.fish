function fish_mode_prompt --description 'Displays the current mode'
    # Do nothing if not in vi mode
    if test $__fish_active_key_bindings = 'fish_vi_key_bindings'
        switch $fish_bind_mode
            case default
                set_color --bold brred
                echo 'N'
            case insert
                set_color --bold green
                echo 'I'
            case visual
                set_color --bold magenta
                echo 'V'
        end
        set_color normal
    end
end
