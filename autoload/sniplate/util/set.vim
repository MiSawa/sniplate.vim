"=============================================================================
" FILE:           set.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! sniplate#util#set#new(...) "{{{
  let res = deepcopy(s:emptyset)
  if a:0
    call res.add_items(a:items)
  endif
  return res
endfunction "}}}

let s:emptyset = {}

let s:emptyset.raw_items = {}

function! s:emptyset.items() dict "{{{
  return keys(self.raw_items)
endfunction "}}}

function! s:emptyset.empty() dict "{{{
  return empty(self.raw_items)
endfunction "}}}

function! s:emptyset.add(item) dict "{{{
  let self.raw_items[a:item] = 1
  return self
endfunction "}}}

function! s:emptyset.remove(item) dict "{{{
  call remove(self.raw_items, a:item)
  return self
endfunction "}}}

function! s:emptyset.has(item) dict "{{{
  return has_key(self.raw_items, a:item)
endfunction "}}}

function! s:emptyset.has_all(items) dict "{{{
  for item in a:items
    if !self.has(item)
      return 0
    endif
  endfor
  return 1
endfunction "}}}

function! s:emptyset.has_any(items) dict "{{{
  for item in a:items
    if self.has(item)
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:emptyset.union(other) dict "{{{
  call extend(self.raw_items, a:other.raw_items)
  return self
endfunction "}}}

function! s:emptyset.intersection(other) dict "{{{
  for item in self.items()
    if !a:other.has(item)
      call self.remove(item)
    endif
  endfor
  return self
endfunction "}}}

function! s:emptyset.add_items(items) dict "{{{
  for item in a:items
    call self.add(item)
  endfor
  return self
endfunction "}}}

function! s:emptyset.remove_items(items) dict "{{{
  for item in a:items
    call self.remove(item)
  endfor
  return self
endfunction "}}}

function! s:emptyset.string() "{{{
  return string(self.items())
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
