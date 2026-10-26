# Personal Dotfiles

This script does not install any system packages. It can tell you if you are missing some that are required but that is all it does.

### Requirements

For this script to work you need [stow](https://www.gnu.org/software/stow/). For installing fonts, you need [curl](https://curl.se/docs/manpage.html). Any other requirements will be in the form of missing command errors when running the script.

### Installation

> NOTE: dotsctl is a bash script, make sure to chmod it or just run it manually.
> - `chmod +x dotsctl` then `./dotsctl`
> - `bash dotsctl`

Run `./dotsctl --help` for more information.

If you want to skip caring about anything and ball out hoping it works, just run `./dotsctl stow` to symlink all my configurations into your `~/.config` folder. If you decide you care a bit more, you can run `./dotsctl -v -n stow` to run get verbosity and run stow under `--simulate` mode.