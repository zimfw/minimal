minimal
=======

A minimal fork of [subnixr's minimal] prompt theme.

<img width="706" src="https://zimfw.github.io/images/prompts/minimal@2.png">

What does it show?
------------------

Left prompt:
  * The hostname only if current session is through a SSH connection.
  * The current activated python virtualenv.
  * An indicator displaying the following information:
    * User privilege: `#` when root, MNML_USER_CHAR otherwise.
    * Last command success: indicator's color is set to MNML_OK_COLOR when the
      last command was successful, MNML_ERR_COLOR otherwise.
    * Background jobs: MNML_BGJOB_MODE is applied to the indicator if at least
      one job is in background.
  * An indicator displaying the current keymap: MNML_INSERT_CHAR when in main or
    vi insert mode, MNML_NORMAL_CHAR when in vi command mode.

Right prompt:
  * The last 2 components of the current working directory.
  * The current git branch, when inside a git repo. Color is set to
    MNML_OK_COLOR if the branch is clean, MNML_ERR_COLOR if the branch is dirty.

Magic enter
-----------

A fork of the magic enter feature from [subnixr's minimal] is available
separately in Zim's [magic-enter] module.

Settings
--------

This theme can be customized with the following environment variables. If a
variable is not defined, the respective default value is used.

| Variable         | Description                                 | Default value |
| ---------------- | ------------------------------------------- | ------------- |
| MNML_OK_COLOR    | Color for successful things                 | `green`       |
| MNML_ERR_COLOR   | Color for failures                          | `red`         |
| MNML_BGJOB_MODE  | Mode applied when there are background jobs | `4`           |
| MNML_USER_CHAR   | Character used for unprivileged users       | `λ`           |
| MNML_INSERT_CHAR | Character used for main or vi insert mode   | `›`           |
| MNML_NORMAL_CHAR | Character used for vi command mode          | `·`           |

Advanced settings
-----------------

You can customize how the current working directory is shown with the
[prompt-pwd module settings].

These advanced settings must be overridden after the theme is initialized.

Requirements
------------

Requires Zim's [prompt-pwd] module to show the current working directory, and
[git-info] to show git information.

[subnixr's minimal]: https://github.com/subnixr/minimal
[magic-enter]: https://github.com/zimfw/magic-enter
[prompt-pwd module settings]: https://github.com/zimfw/prompt-pwd/blob/master/README.md#settings
[prompt-pwd]: https://github.com/zimfw/prompt-pwd
[git-info]: https://github.com/zimfw/git-info
