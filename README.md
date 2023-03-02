# Docker_node-red

以下のコマンドで、全てのサービスが起動する。

```sh
docker-compose up
```

- Node-REDは、ポート番号1880
- sinatraは、ポート番号4567
- sinatraの 4567 は、80 にマッピングされる

## Node-REDの起動方法

```sh
docker-compose up node-red
```

## sinatraの起動方法

```sh
docker-compose up sinatra
```

## 各環境へ入る方法

Node-REDの環境へ入るには、以下を実行する。`<service>`の部分には、`node-red`または`sinatra`を指定する。

```sh
docker-compose exec <service> bash
```

バックグランドで動かす場合は `-d` をつける。

## アクセス方法

ブラウザで `http://localhost/` にアクセスする。

## ノード作成方法

(1)githubでリポジトリを作成する。（リポジトリ名はnode-red-contrib-xxx）

(2)jsファイル、htmlファイル、jsonファイルを作成する。

以下にLEDノードの場合の例を示す。

・jsファイル
```sh
module.exports = function(RED){
function LED_Node(config){
　　node.on('input', function(){
　　　//必要変数の設定
　　});
}
RED.nodes.registerType("LED",LED_Node);
```

・htmlファイル
```sh
<script type="text/javascript">
    RED.nodes.registerType('LED', {　　
        category: 'mruby_Rboad_Nodes', //ノードのグループ名（common,fnction,network,parsers,sequence,storage,オリジナル）
        color: "#ffe3a6",
        defaults: {
           //必要変数の設定
        },
        inputs: 1,　　//ノードの入力端子
        outputs: 0,　　//ノードの出力端子
        icon: "light.svg",　　//ノードのアイコン
        label: function () {
            return this.name || "LED";　　
        },
        
        oneditprepare: function () {
        　//複数の機能を付ける場合（今回はRboad上のLEDとGPIOに接続させたLEDの場合）
        $("#node-input-LEDtype").on("change", function () {
               if (this.value === "GPIO") {
                    $("#LED-conected-Pin").show();
                    $("#LED-onBoard").hide();
        
                } else if (this.value === "onBoardLED") {
                    $("#LED-conected-Pin").hide();
                    $("#LED-onBoard").show();
                }
            }).trigger("change");
        }
   });
</script>
       
//htmlの表示コード
```
・jsonファイル

以下の項目は設定必須。

```name```,
```nodes```,
```main```,
```url```,
```homepage```

```sh
{
 "name": "node-red-contrib-xxx",
  "node-red" : {
   "nodes": {
      "LED":"LED.js"
 　　}
},
 "version":"1.0.0",
 "description":"//ノードの説明"
 "main":"LED.js"
 "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "repository": {
    "type": "git",
    "url": "//ノードが格納されているgithubのURL"
  },
  "keywords": [
    "//ノードに関係するキーワードを記載"
  ],
  "author": "",
  "license": "Apache-2.0",
  "bugs": {
    "url": "ノードが格納されているgithubのURL/issues"
  },
  "homepage": "ノードが格納されているgithubのURL"
}
```

## ノードの追加方法

(1)```Dockerfile```はリポジトリ```node-red-contrib-xxx```と同じ階層に作成する。

Dockerfileに以下の項目を追加する。

・Dockerfile
```sh
FROM nodered/node-red:latest

//リポジトリの追加
COPY node-red-contrib-xxx ./node-red-contrib-xxx
RUN npm install ./node-red-contrib-xxx

//ノードの削除（必要な場合）
RUN rm ./node_modules/@node-red/nodes/core/xxx/xxx.html
RUN rm ./node_modules/@node-red/nodes/core/xxx/xxx.js
```

(2)コマンドプロンプトにて、ディレクトリ```node-red-contrib-xxx```に移動する。

(3)```docker-compose build```でイメージを構築する。

　```docker-compose up -d```でコンテナを開始する。

## 書き込みツールの実行方法
- 「JSON書き込みエリア」にJSONを貼り付ける
- 「JSON→Byte」ボタンを押すと，JSONをバイトコードに変換する
- 「接続」ボタンを押して，接続したいシリアルデバイスを選択する
- 「書き込み」ボタンを押すと，バイトコードの書き込みおよび実行をすることができる
