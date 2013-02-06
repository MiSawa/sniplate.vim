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

function! sniplate#util#marge(lhs, rhs, ...) "{{{
  let l:to_s = get(a:000, 0, 'string(v:val)')
  let l:used = {}
  let l:lhs_s = map(copy(a:lhs), l:to_s)
  let l:rhs_s = map(copy(a:rhs), l:to_s)

  for l:i in range(len(a:lhs))
    let l:used[l:lhs_s[i]] = 1
  endfor
  for l:i in range(len(a:rhs))
    if !has_key(l:used, l:rhs_s[i])
      let l:used[l:rhs_s[i]] = 1
      call add(a:lhs, a:rhs[i])
    endif
  endfor
  return a:lhs
endfunction "}}}

function! sniplate#util#is_empty_buffer() "{{{
  return line('$') == 1 && strlen(getline(1)) == 0
endfunction "}}}

function! sniplate#util#is_already_insert(sniplate) "{{{
  return a:sniplate.pattern != '' && search(a:sniplate.pattern, 'nw') != 0
endfunction "}}}

function! sniplate#util#convert_to_012(var, error_message, ...) "{{{
  " 0, '0', 'false' を 0 に, 1, '1', 'true' を 1 に, 2, '2', 'auto' を 2 にする.
  " 大文字/小文字の区別は無し. 当てはまらないならメッセージを表示し, -1 を返す.
  let l:res = index([0, 1, 2], a:var)
  let l:max = get(a:000, 0, 2)
  if l:res == -1 && type(a:var) == type('string')
    let l:res = get({'0': 0, '1': 1, '2':2}, a:var,
          \ index(['false', 'true', 'auto'], tolower(a:var)))
  endif
  if l:res != -1 && l:res <= l:max
    return l:res
  endif
  echoerr 'ERROR in sniplate.vim: ' . a:error_message
  return -1
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
