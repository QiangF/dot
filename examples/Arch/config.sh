#!/usr/bin/bash

dconf load /apps/guake/ < ~/.dotfiles/home/config/guake/guake.dconf

# vmware opengl support
dot_add "$HOME/.vmware/preferences" "mks.gl.allowBlacklistedDrivers = TRUE"
