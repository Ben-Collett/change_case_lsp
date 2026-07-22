# change case lsp
A proof of concept lsp that provides a code action that allows you to convert the text under your cursor between camel, pascal, and snake case. You can also convert the text to be space separated.  


## Demo

![avif demo video](demo_video/demo.avif)
The animated image demonstrates using change case LSP with neovim to change between all supported casing types.

When converting from spaced case back to cammel the text had to be selected otherwise it would have only tried to change the casing of the word "this" and would have done nothing.

## Limitations

You can convert to space separated text though there is not much ability to convert from it, unless you highlight the text in visual mode or with your cursor before you trigger the code action. 

The code has only been tested on linux with neovim, and there aren't any unit tests, though I have fixed every bug I ran into.

## Installation
You need the dart programming language to compile the project.
After you do that, clone the repo, cd into the project, then into bin, and run `dart compile exe change_case_lsp.dart` or simply run `make` if you have that installed.

Then you need to set it up to work with your lsp client, probably a text editor.
For neovim you will probably want to add a code snippet like this to run in your init.lua

```lua
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  callback = function(args)
    if vim.fn.filereadable(args.file) == 1 then
      --@diagnostic disable-next-line: missing-fields
      vim.lsp.start({
        name = "change_case_lsp",
        cmd = { "<FULL_PATH_TO_EXECUTABLE>" },
        root_dir = vim.fs.dirname(args.file),
      })
    end
  end,
})

```

The path to the executable should be the full path to the compiled LSP. Note for linux users: make sure you don't use ~ for your home directory in the path, neovim doesn't like that. You need to use /home/\<name\>. I don't know why.  

Having said that vscode and windows/macos users, you are on your own I have no idea how those ecosystems work.

## TCP
To launch the lsp to handle tcp connections run `bin/change_case_lsp --tcp <portnumber>` and then in your editor connect to what ever port you set.

In neovim the code to do that looks like this where portnumber is the portnumber you set the tcp server at as an int for example port 5050 is usually available: 
```lua
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  callback = function(args)
    if vim.fn.filereadable(args.file) == 1 then
      -- @diagnostic disable-next-line: missing-fields
      vim.lsp.start({
        name = "change_case_lsp",
        cmd = vim.lsp.rpc.connect("127.0.0.1", portnumber),
        root_dir = vim.fs.dirname(args.file),
      })
    end
  end,
})
```


## License
This project is licensed under [The Unlicense](LICENSE).
