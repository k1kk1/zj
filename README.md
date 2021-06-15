# zj

コマンドラインからZoomミーティングへ参加するシェルスクリプト

## Install
```
$ cd ~/your/path
$ git clone https://github.com/kikki-git/zj.git
```
どこからでも使えるようにするには、以下のコードを`~/.zshrc`または`~/.bashrc`に追加してください。
```
alias zj='~/your/path/zj.sh'
```

## Requirements
- fzf
- jq
- bash
- Linux or Mac or Windows Subsystem for Linux

## Usage
```
$ chmod 744 zj.sh
$ ./zj.sh
```
aliasを設定した場合
```
$ zj
```

## Note

本ソフトウェアを利用して、ミーティングに遅れたなどの責任は負えません。
使用に関しては自己責任でお願いいたします。

## Author
- Mizuki Mukai
