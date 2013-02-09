"=============================================================================
" FILE:           util.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  10 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! sniplate#util#sort_by_cmp(ls, expr) "{{{
  exec      "function! s:COMPARE_FUNC_FOR_SORT(...)\n"
        \ . "  return eval(".string(a:expr).")\n"
        \ . "endfunction\n"
  let res = sort(a:ls, 's:COMPARE_FUNC_FOR_SORT')
  delfunction s:COMPARE_FUNC_FOR_SORT
  return res
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
  let to_s = get(a:000, 0, 'string(v:val)')
  let used = {}
  let lhs_s = map(copy(a:lhs), to_s)
  let rhs_s = map(copy(a:rhs), to_s)

  for i in range(len(a:lhs))
    let used[lhs_s[i]] = 1
  endfor
  for i in range(len(a:rhs))
    if !has_key(used, rhs_s[i])
      let used[rhs_s[i]] = 1
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
  let res = index([0, 1, 2], a:var)
  let max = get(a:000, 0, 2)
  if res == -1 && type(a:var) == type('string')
    let res = get({'0': 0, '1': 1, '2':2}, a:var,
          \ index(['false', 'true', 'auto'], tolower(a:var)))
  endif
  if res != -1 && res <= max
    return res
  endif
  echoerr 'ERROR in sniplate.vim: ' . a:error_message
  return -1
endfunction "}}}

function! sniplate#util#input_variable(var, ...) "{{{
  if a:0
    return call('input', a:000)
  else
    return input('input value of ' . a:var . ' :')
  endif
endfunction "}}}

function! sniplate#util#remove_multibyte_garbage(str)  "{{{
  return substitute(strtrans(a:str), '^\V\(<\x\x>\)\+\|\(<\x\x>\)\+\$', '', 'g')
endfunction "}}}

function! sniplate#util#cutoff_string(str, length, ...) "{{{
  let ry = get(a:000, 0, '')
  let raw = ""
  for i in range(len(a:str))
    let raw = raw . a:str[i]
    let crr = sniplate#util#remove_multibyte_garbage(raw)
    if strwidth(crr) > a:length + len(ry)
      if i == 0
        return ""
      else
        let res = sniplate#util#remove_multibyte_garbage(raw[:-2])
        if strwidth(res . ry) >= strwidth(a:str)
          return a:str
        else
          return res . ry
        endif
      endif
    endif
  endfor
  return a:str
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
