"=============================================================================
" FILE:           candidate_factory.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! s:make_abbr(name, class, abbr) "{{{
  let col_len = winwidth(0)
  let name_len = col_len/4
  let class_len = col_len/4
  if a:class ==# string([])
    let name_len += class_len
    let class_len = 0
  endif
  let abbr_len = col_len - name_len - class_len
  let abbr_len += abbr_len

  let res = printf(
        \ printf('%%-%d.%ds %%-%d.%ds %%s',
        \   name_len, name_len, class_len, class_len),
        \ a:name, a:class, a:abbr)
  return sniplate#util#cutoff_string(res, col_len - 8, '..')
endfunction "}}}

function! sniplate#candidate_factory#get_separetor_candidate(str, ...) "{{{
  let offset = get(a:000, 0, winwidth(0)/4)
  let fillch = string(get(a:000, 1, '-'))
  let res = {}
  let res.word = ''
  let res.abbr = join(map(range(offset), fillch), '')
  let res.abbr = res.abbr . a:str
  let res.abbr = res.abbr . join(map(range(winwidth(0)), fillch), '')
  let res.abbr = sniplate#util#cutoff_string(res.abbr, winwidth(0) - 8)
  let res.is_dummy = 1
  return res
endfunction "}}}

function! sniplate#candidate_factory#get_sniplate_candidate(arg, ...) "{{{
  let context = get(a:000, 0, {})
  if has_key(a:arg, 'sniplate')
    let sniplate = a:arg.sniplate
    let snipname = a:arg.sniplate.name
  else
    let snipname = a:arg.name
    let ft = []
    if has_key(a:arg, 'filetype')
      let ft = [a:arg.filetype]
    endif
    let sniplate =
          \ call('sniplate#enumerate_sniplates', ft)[snipname]
  endif
  let res = {}

  let res.word             = snipname . ' ' .sniplate.class.string()
  let res.kind             = 'sniplate'
  let res.abbr             =
        \ s:make_abbr(snipname, sniplate.class.string(), sniplate.abbr)
  let res.action__path     = sniplate.path
  let res.action__line     = sniplate.line_number
  let res.action__text     = join(sniplate.lines, "\n")
  let res.source__sniplate = sniplate
  let res.source__bang     = get(a:arg, 'bang', 0)
  let res.default_action   = 'insert'
  return res
endfunction "}}}

function! sniplate#candidate_factory#get_file_line_candidate(path, line) "{{{
  let res = {}
  let res.word         = a:path
  let res.kind         = 'jump_list'
  let res.abbr         = 'line ' . string(a:line) . ' in ' . a:path
  let res.action__path = a:path
  let res.action__line = a:line
  return res
endfunction "}}}

function! sniplate#candidate_factory#get_class_candidate(class, ...) "{{{
  let res = {}
  let res.word = a:class
  let res.kind = 'sniplate/class'
  let res.abbr = a:class
  if a:0
    let res.source__filetype = a:1
  endif
  return res
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
