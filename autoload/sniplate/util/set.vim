"=============================================================================
" FILE:           util.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  7 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! sniplate#util#set#emptyset()
  return deepcopy(s:emptyset)
endfunction

let s:emptyset = {}

let s:emptyset.raw_items = {}

function! s:emptyset.items() dict "{{{
  return keys(l:self.raw_items)
endfunction "}}}

function! s:emptyset.empty() dict "{{{
  return empty(l:self.raw_items)
endfunction "}}}

function! s:emptyset.add(item) dict "{{{
  let l:self.raw_items[a:item] = 1
  return l:self
endfunction "}}}

function! s:emptyset.remove(item) dict "{{{
  call remove(l:self.raw_items, a:item)
  return l:self
endfunction "}}}

function! s:emptyset.has(item) dict "{{{
  return has_key(l:self.raw_items, a:item)
endfunction "}}}

function! s:emptyset.has_all(items) dict "{{{
  for l:item in a:items
    if !l:self.has(l:item)
      return 0
    endif
  endfor
  return 1
endfunction "}}}

function! s:emptyset.has_any(items) dict "{{{
  for l:item in a:items
    if l:self.has(l:item)
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:emptyset.union(other) dict "{{{
  call extend(l:self.raw_items, a:other.raw_items)
  return l:self
endfunction "}}}

function! s:emptyset.intersection(other) dict "{{{
  for l:item in l:self.items()
    if !a:other.has(l:item)
      call l:self.remove(l:item)
    endif
  endfor
  return l:self
endfunction "}}}

function! s:emptyset.add_items(items) dict "{{{
  for l:item in a:items
    call l:self.add(l:item)
  endfor
  return l:self
endfunction "}}}

function! s:emptyset.remove_items(items) dict "{{{
  for l:item in a:items
    call l:self.remove(l:item)
  endfor
  return l:self
endfunction "}}}

function! s:emptyset.string() "{{{
  return string(self.items())
endfunction "}}}

function! sniplate#util#set#make_set(items) "{{{
  let l:res = sniplate#util#set#emptyset()
  call l:res.add_items(a:items)
  return l:res
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
