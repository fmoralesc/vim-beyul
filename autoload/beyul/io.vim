function! beyul#io#Read(path)
    exe "cd ".fnamemodify(a:path, ":h")
    let lines = readfile(a:path)
    for line in lines
        call append(line('$'), readfile(line))
    endfor
    normal dd
    let s:final_line = line('$')
endfunction

function! beyul#io#Write(path)
    " check for changes changes (is `modified` set?)
    if &modified
        " extract changes in chunks of continuous lines
        " check if new chunks split old chunks
        " for each chunk, create a file and save the data
        " rebuild the table in the .beyul file
        "
        " for now, we only save appends to the file
        " on this scheme, we should probably compress things so the collection
        " of files is protected and the "document" is self contained.
        if line('$') > s:final_line
            let new_fname = fnamemodify(a:path, ":p:r").".".localtime().".part"
            silent exe s:final_line+1.",".line('$')." w ".new_fname
            let fl = readfile(a:path)
            let fl = add(fl, new_fname)
            call writefile(fl, a:path)
            let s:final_line = line('$')
            setlocal nomodified
        endif
    endif
endfunction
