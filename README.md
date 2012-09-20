# A Clone of Project Babel 3 in Meteor
这是一份对 Project Babel 3 的克隆，用 Meteor 写成。

Demo：https://dnspod-bbs.meteor.com

## Project Babel 3 是什么？

[PB3](http://www.v2ex.com/go/babel) 是一套非常简洁的社区软件，作者 @livid 为了运营一个叫做 [V2EX](http://www.v2ex.com) 的社区而开源了它。

准确的说，截至到2012年9月20日，只有 PB1（PHP）和 PB2（GAE）分享了源码，据说使用 Tornado 写成，可以部署在本地服务器上的PB3还没有开源，无法部署自己的版本。

## Why clone?

这份克隆源于我自己的需求，我们团队内部需要一套讨论软件，用来分享、讨论、沉淀，我非常喜欢 V2EX 的简洁，并感觉这就是我们需要的，于是我克隆了它。

## Features

- 与 V2EX 一致的「主题」、「回复」功能
- 无帐号系统，只能用 DNSPod 帐号登录
- 同一主题可以属于多个节点
- 单页应用，所有操作都无刷新，数据变化实时展现在所有浏览器上

## Tech Specs

- [Meteor](http://www.meteor.com)：非常新颖的一站式Web框架，Meteor-BBS 主要 （[讨论1](http://www.v2ex.com/t/33961)，[讨论2](http://www.v2ex.com/t/48084)）
- [Backbone.js](http://documentcloud.github.com/backbone/)：前端 MVC 框架，便于前端实现复杂的js单页应用（类似Gmail）
- [CoffeeScript](http://coffeescript.org)：一个语言，可以编译为js，语法简洁，隐藏了js中的难以驾驭的部分


## How to start

1. 安装 Meteor（目前基于 0.4.0，因为 Meteor 变化很快，新版本不一定支持）

1. git clone

   ~~~
   $ git clone https://github.com/chuangbo/meteor-bbs.git
   $ cd meteor-bbs
   ~~~

3. run

   ~~~
   $ meteor
   ~~~


## Thank Project Babel

这份代码完全没有作为产品的计划，开源仅仅只是为了分享、学习 Meteor，别无他意。
