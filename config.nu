use ctx-completions/

$env.config.menus ++= [
    {
        name: ctx_completions_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: description
            columns: 1
            col_width: 20
            col_padding: 2
            selection_rows: 20
            description_rows: 20
        }
        style: {}
        source: { |buffer, position|
            ctx-completions build-context $buffer $position
            | ctx-completions dispatch
        }
    }
]

$env.config.keybindings ++= [
    {
        name: ctx_completions
        modifier: alt
        keycode: char_i
        mode: [emacs, vi_insert]
        event: {
            until: [
                { send: menu name: ctx_completions_menu }
                { send: menunext }
                { edit: complete }
            ]
        }
    }
]

