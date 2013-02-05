"=============================================================================
" FILE:           util.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  4 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! sniplate#util#sort_by_cmp(ls, expr) "{{{
  exec      "function! s:COMPARE_FUNC_FOR_SORT(...)\n"
        \ . "  return eval(".string(a:expr).")\n"
        \ . "endfunction\n"
  let l:res = sort(a:ls, 's:COMPARE_FUNC_FOR_SORT')
  delfunction s:COMPARE_FUNC_FOR_SORT
  return l:res
endfunction "}}}

function! sniplate#util#sort_by(ls, expr) "{{{
  exec      "function! s:UNARY_FUNC_FOR_SORT(...)\n"
        \ . "  return eval(".string(a:expr).")\n"
        \ . "endfunction\n"
  call sniplate#util#sort_by_cmp(a:ls,
        \ '(s:UNARY_FUNC_FOR_SORT(a:1) > s:UNARY_FUNC_FOR_SORT(a:2)) - (s:UNARY_FUNC_FOR_SORT(a:1) < s:UNARY_FUNC_FOR_SORT(a:2))')
  delfunction s:UNARY_FUNC_FOR_SORT
  return a:ls
endfunction "}}}

function! sniplate#util#is_empty_buffer() "{{{
  return line('$') == 1 && strlen(getline(1)) == 0
endfunction "}}}

function! sniplate#util#is_already_insert(sniplate) "{{{
  return a:sniplate.pattern != '' && search(a:sniplate.pattern, 'nw') != 0
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
