# ctx-completions

This modules offers contextual completions for Nushell.

Contextual here means one keybind can be used for multiple commands and multiple types of completion.

The completions will differ based on the first command left to your cursor.

## Installation

1. Clone this repository or download the sources
2. Place the files in your Nushell configuration directory e.g. `<nu-config-dir>/scripts/ctx-completions`

## Configuration

As an expample, you can copy the content of [./config.nu](./config.nu) and add it to your own configuration e.g. at the end of your `<nu-config-dir>/config.nu` file.

The idea is to have a menu using `ctx-completions` to generate the source for the completions.
Then you need a keybinding to trigger this menu.

**WARNING :** It is very important to use `only_buffer_difference = false` for the menu options.
Otherwise, the completions might not work properly.

## Usage

This module comes with two completers :

- one to complete modules paths for `use` and `overlay use` commands (`./complete-use.nu`)
- one to complete `file` and/or `directories` paths for anything else (`./complete-path.nu`)

To use the `use/overlay use` completer

- start typing `use ` or `overlay use `
- press the keybind configured for the completions menu (e.g. `<Alt-i>` from [./config.nu](./config.nu#L28) ), then type a pattern
- or type a pattern first, then press the keybind

To use the `file/directory` completer :

- anywhere in the command line
- press the keybind configured for the completions menu, then type a pattern
- or type a pattern first, then press the keybind

## Notes

**WARNING:** This plugin is in early stage.

- The `use/overlay use` completer will only complete the first "word" after the command
- The `file/directory` completer will force directory completions if the command left to the cursor is `cd`
- The completers can be used anywhere in your commandline, not only at the beginning of it
