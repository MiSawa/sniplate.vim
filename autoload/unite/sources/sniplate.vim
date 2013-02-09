"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  10 Feb 2013.
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

function! sniplate#get_unite_sniplate_candidate(snipname, ...) "{{{
  let context = get(a:000, 0, {})
  if a:0 > 1
    let sniplate = a:2
  else
    let sniplate = sniplate#enumerate_sniplates()[a:snipname]
  endif
  let res = {}

  let res.word             = a:snipname . ' ' .sniplate.class.string()
  let res.kind             = s:source.default_kind
  let res.abbr             =
        \ s:make_abbr(a:snipname, sniplate.class.string(), sniplate.abbr)
  let res.action__path     = sniplate.path
  let res.action__line     = sniplate.line_number
  let res.action__text     = join(sniplate.lines, "\n")
  let res.source__sniplate = sniplate
  let res.source__bang     = get(context, 'source__bang', 0)
  return res
endfunction "}}}

let s:source = {
      \   'name'           : 'sniplate',
      \   'description'    : 'candidates from sniplate list',
      \   'default_kind'   : 'sniplate',
      \   'default_action' : 'insert',
      \   'hooks'          : {},
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  let a:context.source__bang =
        \ index(a:args, '!') >= 0
  let classes = filter(copy(a:args), 'v:val != "!"')
  if empty(classes)
    let a:context.source__sniplates =
          \ sniplate#enumerate_sniplates()
  else
    let a:context.source__sniplates =
          \ sniplate#enumerate_sniplates_has_any_classes(classes)
  endif
  call sniplate#remove_invisible(a:context.source__sniplates)
endfunction "}}}

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate]')
  let sniplates = a:context.source__sniplates
  let res = []
  for [snipname, sniplate] in items(sniplates)
    call add(res, sniplate#get_unite_sniplate_candidate(
          \ snipname, a:context, sniplate))
  endfor
  call sniplate#util#sort_by(res, '-a:1.source__sniplate.priority')
  return res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  let res = sniplate#enumerate_classes()
  call add(res, '!')
  call filter(res, 'index(a:args[:-2], v:val) == -1')
  return res
endfunction "}}}

function! unite#sources#sniplate#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
