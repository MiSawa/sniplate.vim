"=============================================================================
" FILE:           scc.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! s:scc_visit(g, v, scc, st, inS, low, num, t) "{{{
  let a:t[0] = a:t[0] + 1
  let v = a:v
  let a:low[v] = a:t[0]
  let a:num[v] = a:t[0]
  call add(a:st, v)
  let a:inS[v] = 1
  for w in a:g[v]
    if a:num[w] == 0
      call s:scc_visit(a:g, w, a:scc, a:st, a:inS, a:low, a:num, a:t)
      let a:low[v] = min([a:low[v], a:low[w]])
    elseif a:inS[w] == 1
      let a:low[v] = min([a:low[v], a:num[w]])
    endif
  endfor
  if a:low[v] == a:num[v]
    call add(a:scc, [])
    while 1
      let w = a:st[-1]
      call remove(a:st, -1)
      let a:inS[w] = 0
      call add(a:scc[-1], w)
      if v == w
        break
      endif
    endwhile
  endif
endfunction "}}}

function! s:scc(g) "{{{
  let n = len(a:g)
  let num = map(range(n), '0')
  let low = map(range(n), '0')
  let inS = map(range(n), '0')
  let st = []
  let t = [0]
  let scc = []
  for u in range(n)
    if num[u] == 0
      call s:scc_visit(a:g, u, scc, st, inS, low, num, t)
    endif
  endfor
  return reverse(scc)
endfunction "}}}

function! sniplate#util#scc#run(vs) "{{{
  let n = len(a:vs)
  let g = map(range(n), '[]')
  let ed = sniplate#util#encdec#new()
  for [v_raw, v_arg] in items(a:vs)
    let v = ed.enc(v_raw)
    let g[v] =  map(deepcopy(v_arg), 'ed.enc(v:val)')
  endfor
  let scc = s:scc(g)
  for cc in scc
    call map(cc, 'ed.dec(v:val)')
  endfor
  return scc
endfunction "}}}

"strongly connected component and topological sort
"ex:
" unlet! a
" let a = {
"       \ '~': ['.vim', '.vimrc'],
"       \ '.vim': ['bundle'],
"       \ '.vimrc': [],
"       \ 'bundle' : [],
"       \}
" echo sniplate#util#scc#run(a)
" unlet! a

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
