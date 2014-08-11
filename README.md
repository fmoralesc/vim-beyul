# vim-beyul

Super experimental hypertext mode for vim, inspired by Ted Nelson's [Project
Xanadu](http://en.wikipedia.org/wiki/Project_Xanadu) and [this reddit
discussion](http://www.reddit.com/r/vim/comments/2d56df/ideas_for_hotlinkingreusing_a_block_of_text/).

*Xanadu is Shambhala, and a beyul is Shambhala in Earth*.

## The idea

The beyul fileformat describes how to build up a document. Vim interprets this
description to present the document (on `BufReadCmd`). On writes
(`BufWriteCmd`), the description is updated. If the description sources from
external documents, changes on those will change the document. 
