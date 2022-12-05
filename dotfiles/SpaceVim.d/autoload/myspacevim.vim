function! myspacevim#before() abort
endfunction

function! myspacevim#after() abort
    let g:neoformat_python_myblack = {
        \ 'exe': 'black',
        \ 'args': ['--target-version=py36', '--line-length=79', '--skip-string-normalization', '--quiet', '-'],
        \ 'stdin': 1,
        \ }

    let g:neoformat_enabled_python = ['myblack']
    let g:neoformat_try_myblack = 1

    " Enable basic formatting when a filetype is not found.
    " Enable alignment
    let g:neoformat_basic_format_align = 1
    " Enable tab to spaces conversion
    let g:neoformat_basic_format_retab = 1
    " Enable trimmming of trailing whitespace
    let g:neoformat_basic_format_trim = 1

    " Have Neoformat only msg when there is an error
    " let g:neoformat_only_msg_on_error = 1
endfunction
