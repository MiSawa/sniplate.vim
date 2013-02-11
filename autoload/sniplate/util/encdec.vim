"=============================================================================
" FILE:           encdec.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! sniplate#util#encdec#new(...)
  let res = deepcopy(s:encdec)
  return res
endfunction

let s:encdec = {
      \ '_enc': {},
      \ '_dec' : [],
      \ }

function! s:encdec.enc(str) dict "{{{
  if !has_key(self._enc, a:str)
    let self._enc[a:str] = len(self._enc)
    call add(self._dec, a:str)
  endif
  return self._enc[a:str]
endfunction "}}}

function! s:encdec.dec(num) dict "{{{
  return self._dec[a:num]
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
