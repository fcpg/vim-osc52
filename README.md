Vim-osc52
==========
OSC 52 is a terminal sequence used to copy printed text into clipboard.
It is useful in some environments, or when SSH'ing into some server and you
need to copy back output from there into your local clipboard.

Your terminal must support OSC 52, of course (e.g. mintty does).

Tmux is supported.

Installation
-------------
Use your favorite method:
*  [Pathogen][1] - git clone https://github.com/fcpg/vim-osc52 ~/.vim/bundle/vim-osc52
*  [NeoBundle][2] - NeoBundle 'fcpg/vim-osc52'
*  [Vundle][3] - Plugin 'fcpg/vim-osc52'
*  manual - copy all of the files into your ~/.vim directory

Usage
------
Copy to system clipboard:
  `vmap <C-c> y:Oscyank<cr>`
  `xmap <F7> y:Oscyank<cr>`

Acknowledgments
----------------
Code from Chromium, tweaked for personal use.

License
--------
Check original code on Chromium.

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/Shougo/neobundle.vim
[3]: https://github.com/gmarik/vundle
