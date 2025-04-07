# ai-project-rules
AI（特にコーディングエージェント）を組み合わせたプロジェクトのルールについてまとめる。

## Project Rules
AIに、どのように動作して欲しいかや、覚えて欲しいことを伝える。
Rulesには無駄なことを書かずに情報を絞りコンテキストをシンプルに保つこと。

### Policy
- チーム開発を想定し、ルール管理に [Rules Bank](https://docs.cline.bot/improving-your-prompting-skills/prompting#using-a-rules-bank) パターンを利用する
    - 非アクティブなルールを格納する `rules-bank/` ディレクトリ内にリポジトリ構造と同じになるようルールを分割して配置する
- AIサービスのコンテキストに合わせたファイルをスクリプトで作成・結合する
    - `rules-bank/` に定義した共通ルールを、各自の `.clinerules/` に配置するイメージ
- AIサービスが読み取るルールファイルはgit管理から除外する
