" Code from Chromium, tweaked for personal use.

"---------
" Options
"---------

" Max length of the OSC 52 sequence
let g:max_osc52_sequence=100000


"-----------
" Functions
"-----------

" Send a string to the terminal's clipboard using the OSC 52 sequence
function! SendViaOSC52(str)
  if match($TERM, 'screen') > -1
    let osc52 = s:get_OSC52_DCS(a:str)
  else
    let osc52 = s:get_OSC52(a:str)
  endif
  let len = strlen(osc52)
  if len < g:max_osc52_sequence
    call s:rawecho(osc52)
  else
    echo "Selection too long to send to terminal: " . len
  endif
endfun


" Base64 the entire string and wraps it in a single OSC52
function! s:get_OSC52(str)
  let b64 = s:b64encode(a:str)
  let rv = "\e]52;0;" . b64 . "\x07"
  return rv
endfun


" Base64 the entire source, wraps it in a single OSC52, and then
" breaks the result in small chunks which are each wrapped in a DCS sequence
"
" DCS imposes a small max length to DCS sequences, so it is sent in chunks
function! s:get_OSC52_DCS(str)
  " The base64 commands with no params will return a string with newlines
  " every 72 characters.
  let b64 = s:b64encode(a:str)
  " Remove the trailing newline.
  let b64 = substitute(b64, '\n*$', '', '')
  " Replace each newline with an <end-dcs><start-dcs> pair.
  let b64 = substitute(b64, '\n', "\e/\ePtmux;", "g")
  " (except end-of-dcs is "ESC \", begin is "ESC P", and I can't figure out
  "  how to express "ESC \ ESC P" in a single string.  So, the first substitute
  "  uses "ESC / ESC P", and the second one swaps out the "/".  It seems like
  "  there should be a better way.)
  let b64 = substitute(b64, '/', '\', 'g')
  " Now wrap the whole thing in <start-dcs><start-osc52>...<end-osc52><end-dcs>.
  let b64 = "\ePtmux;\e\e]52;0;" . b64 . "\x07\e\x5c"
  " echom "b64: " b64
  return b64
endfun


" Echo a string to the terminal without munging the escape sequences
function! s:rawecho(str)
  execute "silent! !echo " . shellescape(a:str)
  redraw!
endfun


" Lookup table for s:b64encode
let s:b64_table = [
      \ "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
      \ "Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f",
      \ "g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v",
      \ "w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/"]

" Encode a string of bytes in base64
function! s:b64encode(str)
  let bytes = s:str2bytes(a:str)
  let b64 = []
  for i in range(0, len(bytes) - 1, 3)
    let n = bytes[i] * 0x10000
          \ + get(bytes, i + 1, 0) * 0x100
          \ + get(bytes, i + 2, 0)
    call add(b64, s:b64_table[n / 0x40000])
    call add(b64, s:b64_table[n / 0x1000 % 0x40])
    call add(b64, s:b64_table[n / 0x40 % 0x40])
    call add(b64, s:b64_table[n % 0x40])
  endfor
  if len(bytes) % 3 == 1
    let b64[-1] = '='
    let b64[-2] = '='
  endif
  if len(bytes) % 3 == 2
    let b64[-1] = '='
  endif
  return join(b64, '')
endfun

" String to bytes
function! s:str2bytes(str)
  return map(range(len(a:str)), 'char2nr(a:str[v:val])')
endfun


