# cloud_service_wordpress

## docker + wordpress + nginx + mysqlを使ったAWSでのWeb公開の流れ

## AWS初期設定
#### 1. インスタンスの起動

#### 2. EC2にsshできるように設定

#### 3. 80(http), 443(https)ポートの解放
 - EC2ダッシュボードからセキリュティグループを選択
 - インバウンドのルールを編集を選択
 - 以下のようにポートを解放する
   
![unnamed](https://user-images.githubusercontent.com/76994536/228906474-383e708d-4ed4-4090-a612-250a85e485b3.png)

#### 4. ドメイン名の登録
 - [freenom](https://www.freenom.com/ja/index.html)で無料のドメインを探す
 - checkout(チェックアウト)で購入手続きをする
 - AWSでRoute53のサービスに移動
 - ホストゾーンの作成を選択
 	- ドメイン名にfreenomで獲得したドメイン名を入力
 	- パプリックゾーンを指定
 	- ホストゾーンの作成を選択
  
![unnamed (1)](https://user-images.githubusercontent.com/76994536/228906856-4d847238-4f35-4678-b62e-345a69840bd2.png)

 - freenomのcheckout(チェックアウト)画面に戻る
 	- Use DNSのUse your own DNSのNameserver欄にとりあえず２つのRoute53のホストゾーンのレコードしたドメイン名のNSの値を入力（IP address欄は記入なし）
 	- 記入したらContinueを選択
 	- Complete Orderが完了を確認
 - freenomのServicesのMy Domainsを選択
 - 購入したドメイン名のManage Domainを選択
 - Management ToolsからNameserversを選択
 - Use custom nameservers (enter below)にて残りの２つのRoute53のホストゾーンのレコードしたドメイン名のNSの値を入力
 - Route53のホストゾーンのドメイン名に対してレコードを作成を選択
 	- レコード名：記入しない
 	- レコードタイプ：A-IPv4を選択
 	- 値：EC2サーバのパブリックIPv4アドレスを記入
  
![unnamed (2)](https://user-images.githubusercontent.com/76994536/228907005-329c432f-c738-464c-926d-3830dd349144.png)

## EC2サーバの設定

#### 1. EC2サーバにssh
#### 2. docker, docker-compose, nginx, cerbotのインストール
  - https://kacfg.com/aws-ec2-docker/
  - https://qiita.com/e-onm/items/0814b6c4db395e331df1
#### 3. サイトのhttps化のためのSSL証明書の取得（Let's encrypt）
  - 以下のディレクトリ構造になるようにroot権限で作成

![unnamed (3)](https://user-images.githubusercontent.com/76994536/228910806-93bada7e-ac76-484d-bda6-c34b5cc5b89c.png)

  - Index.htmlには好きに記載する
  - nginxの起動
  ```
  sudo service nginx start
  ```
  - SSL証明書の取得（Let's encrypt）
  ```
  sudo certbot certonly -d {取得ドメイン名}
  ```
  - nginxの停止（dockerでnginxを起動するため）
  ```
  sudo service nginx stop
  ```
  
#### 4. ssl自動更新

  - sslを更新するためのbash（rennew_ssl.sh）を用意する
  ```
  #!/bin/bash

  cd /cloud_service_production/

  certbot renew

  docker-compose down

  docker-compose up -d
  ```
  - crontabを用いて月１で自動更新するbashを起動するようにする
  ```
  0 0 1 * * /cloud_service_productionrenew_ssl.sh 2>&1 >>/cloud_service_production/renew_ssl.log
  ```





