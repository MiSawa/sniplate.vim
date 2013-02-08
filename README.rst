============
sniplate.vim
============

これは何?
---------
sniplateは, ファイルの編集中に, コード断片を読み込む為のプラグインである.

既存のプラグインに比べ, 関数程度の大きさのコードを扱いやすく, 依存関係の処理, 多重読み込みの防止等の機能がある.


インストール
------------
プラグイン管理プラグインを使っている場合は,

::

  NeoBundle 'MiSawa/sniplate.vim'

等とし, ``:NeoBundleInstall`` する. そうでない場合は, ``~/.vim/`` 又は ``$HOME/vimfiles/`` 等に, ダウンロードしたファイルを展開する.


使い方
------
詳しくは, ``help sniplate`` を参照.

例として, C++で関数 ``sum`` と ``average`` をスニペット化する場合,

::

  //BEGIN SNIPLATE sum
  //{{pattern: int sum(vector<int> in)}}
  //{{class: statistics}}
  int sum(vector<int> in) {
    int res = 0;
    for(int i = 0; i < in.size(); ++i)
      res += in[i];
    return res;
  }
  //END SNIPLATE

  //BEGIN SNIPLATE average
  //{{pattern: double average(vector<int> in)}}
  //{{require: sum}}
  //{{class: statistics}}
  double average(vector<int> in) {
    return (double)sum(in) / in.size();
  }
  //END SNIPLATE

等とする.
ここで, ``:SniplateLoad average`` を行うと, バッファに ``int sum(vector<int> in)`` とマッチする部分が無い場合, ``sum`` も一緒に挿入される.

また, ``unite.vim`` のソースもあり, 例えば ``:Unite sniplate:statistics`` とすると, ``{{class: statistics}}`` の記述があるスニペットを表示し, 選択/挿入出来る.

他に, ``cursor``, ``eval``,  ``exec`` 等, 様々なキーワードの埋め込みが可能である.

