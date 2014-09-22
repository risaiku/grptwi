grptwi
======

## 概要
このスクリプトを使うと、特定のメールアドレスへメールを送ることによりTwitterへツイートできるようになります。
また、ひとつのTwitterアカウントに対して複数の人がツイートすることを可能にします。  
企業やサークルなど、複数人数が所属する組織の公式アカウントで使用することを想定して作成しました。

## 機能
* メール送信によるTwitterへの投稿、投稿したツイートの削除
* 投稿通知メール、削除通知メールの送信
* 投稿可能の送信元メールアドレスを限定
* 投稿者以外への通知メールの送信先の設定

## 使い方
#### Twitterへのツイート
メール本文につぶやきたい内容を入力して、投稿用メールアカウントへ送信

#### ツイートの削除
ツイート後に送られてくる投稿通知メールを「引用返信」する

##環境構築
### 前提事項
* postfixにてメールサーバを運用している（他のMTAで動作するかは未検証）
* rubyが動作する

### 設定
1. grptwi.rb と grptwi.yml を任意の同一フォルダに格納する
1. [ 投稿用メールアカウント ] を作成する
1. /etc/aliasesに次のように指定する

  ```sh
  # Tweet
  [ 投稿用メールアカウント ]: "| /[grptwi.rb格納ディレクトリ]/grptwi.rb"
  ```
1. newaliases コマンドを実行
1. grptwi.rb に実行権限の付与
1. grptwi.yml を設定

  | ハッシュキー | 設定値 | 設定する値の型 |
  | --- | --- | --- |
  | ok\_addrs | 投稿を許可するメールアドレス | 文字列のリスト |
  | notice\_addrs | 通知メール送信先メールアドレス | 文字列のリスト |
  | from\_addr | 投稿用メールアドレス | 文字列 |
  | api\_key | あなたのTwitterアカウントで取得したAPI KEY | 文字列 |
  | api\_secret | あなたのTwitterアカウントで取得したAPI SECRET | 文字列 |
  | access\_token | あなたのTwitterアカウントで取得したACCESS TOKEN | 文字列 |
  | access\_token\_secret | あなたのTwitterアカウントで取得したACCESS TOKEN SECRET | 文字列 |

## ライセンス等
MIT License  
Copyright 2014, risaiku  
http://risaiku.net  
https://github.com/risaiku/grptwi

