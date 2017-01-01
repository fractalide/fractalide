# HOWTO

## Intended Audience

People interesting in programming Fractalide applications.

## Purpose

To provide a real world example on how to program Fractalide applications.

## Prerequisites

The reader should have read these documents in this order.

1. [Nodes](./nodes/README.md)
2. [Edges](./edges/README.md)
3. [Fractals](./fractals/README.md)
4. [Services](./services/README.md)

## Steps

### Fractalide installation

#### Virtualbox guest installation

* Complete the [Installing Virtualbox Guest](http://nixos.org/nixos/manual/index.html#sec-instaling-virtualbox-guest) section of the NixOS Manual.

#### Building the `Fractalide Virtual Machine (FVM)``

Once logged into your virtualbox guest issue these commands:

* `$ git clone https://github.com/fractalide/fractalide.git`
* `$ cd fractalide`
* `$ nix-build`

(the hash will probably be different)

Let us inspect the content of the output folder.

```
$ readlink result
/nix/store/ymfqavzrgmj3q3aljgwvh769fq9dszp2-fvm
```
```
$ tree result
result
└── bin
    └── fvm
```

#### Peek under the hood

* `$ nix-build --argstr node test_nand`

This replaces the `result` symlink with a new symlink pointing to generated file.
```
$ readlink result
/nix/store/zld4d7zc80wh38qhn00jqgc6lybd2cdi-test_nand
```
Let's investigate the contents of this file:
```
$ cat /nix/store/zld4d7zc80wh38qhn00jqgc6lybd2cdi-test_nand
/nix/store/ymfqavzrgmj3q3aljgwvh769fq9dszp2-fvm/bin/fvm /nix/store/jk5ibldrvi6cai5aj1j00p8rgi3zw4l7-test_nand
```
Notice that we're passing the path of the actual `test_nand` `subgraph` into the `fvm`, which was previously built.

What does the contents of the actual `/nix/store/jk5ibldrvi6cai5aj1j00p8rgi3zw4l7-test_nand` file look like?
```
$ cat /nix/store/jk5ibldrvi6cai5aj1j00p8rgi3zw4l7-test_nand/lib/lib.subgraph
'/nix/store/ynm9ipggdvxhzi5l2kkz9cgiqgvq2g87-prim_bool:(bool=true)' -> a nand(/nix/store/y919fp98qw33w0cs2wn5wzwgwpwgbchs-maths_boolean_nand) output -> input io_print(/nix/store/4fnk9dmky6jni4f4sbrzl1xsj50m3mb0-maths_boolean_print)
'/nix/store/ynm9ipggdvxhzi5l2kkz9cgiqgvq2g87-prim_bool:(bool=true)' -> b nand()
```

The `--argstr node xxx` are arguments passed into the `nix-build` executable. Specifically

```
$ man nix-build
...
       --argstr name value
           This option is like --arg, only the value is not a Nix expression but a string. So instead
           of --arg system \"i686-linux\" (the outer quotes are to keep the shell happy) you can say
           --argstr system i686-linux.
...
```

The name `node` refers to the top level `graph` to be executed by the `fvm`.
Whatever that graph is `nix` compiles each of the `agents` and inserts their paths into `subgraphs`.

#### A Todo backend

We will design an http server, that will host "todo" element. It will give the following features : GET, POST, PATCH/PUT, DELETE. The different "todos" will be saved in a `sqlite` database. The client will use `json` to deal with the "todos".

A todo had the following fields :
* id : a unique integer id, that is used to retrieve, delete and patch the todos.
* title : a string that represents the goal of the todo, the text to display.
* completed : a boolean that remember if the todo is comple
just use the latest version depending on whatever nasty semver string
is passed to youted or not.
* order : a positive integer that is used if the user want to display the todo in a certain order.

The http server will respond to request like :
* GET
The request will look like `GET http://localhost:8000/todos/1`. With the http method "GET", and a numeric ID given, the server will respond the corresponding todo in the database, otherwise it will respond a 404 page.
* POST
The request will look like `POST http://localhost:8000/todos`. The content of the request must be a `json` that correspond to a "todo". The `id` field is ignored. ex : `{ "title": "Create a todo http server", "order": 1 }`
* PATCH or PUT
The request will look like `PUT http://localhost:8000/todos/1`. The content of the request is the fields to update. ex : `{ "completed": true }`
* Delete
The request will be `DELETE http://localhost:8000/todos/1`. This will delete the todo with the `id` 1.

#### The big picture

![the big picture](./doc/images/global_http.png)

The main `agent` here is `http`. It will receive all the http requests, and dispatch them around four other `agents`, one for each feature. Each of these four `agents` will in fact be an other `subgraph`, to process the request and provide the response. Before we will look in them, we will look how work the `http` `agent`.

##### The `HTTP agent`

The `http agent` is a tiny http server. It receives http requests, asks for responses, then replies to the user.

![The `http agent`](./doc/images/request_response.png)

The `http agent` had one array output port by [HTTP method](https://docs.rs/tiny_http/0.5.5/tiny_http/enum.Method.html), and the "selection" is a [rust Regex](https://doc.rust-lang.org/regex/regex/index.html).

For example, `http() GET[^/news/?$]` will match the request with method GET and url `http://.../news` or `http://../news/`.

On the output port, it send an IP with the contract `request`. For here, we will just use the fields `id`, `url`, `content`. The `id` is the unique id for the request. It must be provided in the response corresponding to this request. The `url` is the url given by the user. The `content` is the content of the request, the data given by the user.

The `http agent` want an IP with the contract `response`. A `response` had a `id`, which correspond to the `request id`. It had a `status_code`, which is the response code of the request. By default, it's 200 (OK). The `content` is the data that are send back to the user.

The `http agent` must be started with an IIP of type `address`. It specify on which address and port the server must listen :

![http listen](./doc/images/connect.png)

##### The `GET subgraph`

![get](./doc/images/get.png)

An request will follow the following path :
* get into the `subgraph` by the virtual port `request`
* Go into the first `agent` `get_id`. This `agent` have two output ports : `req_id` and `id`. The `req_id` is the id of the http request, given by the `http_agent`. The `id` is retrieved by the url (ie: http://.../todos/2 will send the number '2').
* The `id` from the url will go in the `sql_get` `agent`, that retrieve from a database the IP corresponding to the `id`.
* If the `id` exist, the IP is send to `build_json` that send the json of the todo.
* If the `id` doesn't exist in the database, an IP is send on the error port.
* The `build_request` will receive one IP in one of his two input ports (error or playload). If there is an error, it will send a 404 response, or otherwise, it will send a 200 repsonse with the json as data.
* This new response go now in `add_req_id`, which retrieve the `req_id` from the request, and set it in the new `response`.
* The response can go out of the `subgraph`.

Now we can connect the `http` `agent` to the `get` `subgraph`, to retrieve all the `GET` http request.

![http_get](./doc/images/http_get.png)

##### The `POST subgraph`

![post](./doc/images/post.png)

A request will go through :

* In the `subgraph` by the virtual port `request`
* Go in `get_todo`. This `agent` send `req_id` and the content, which is a `json todo` in a new contract `todo`.
* The `json todo` is cloned in two `agents`
* On go in `sql_insert`, that send out the `id` of the todo in the database. This id is send in `build_json`.
* The `build_json` receive the database id and the todo, and merge them together in a `json` format
* This allows to build a response, with the json as content
* `add_req_id` then add the `req_id` in the reponse
* The response is sended out

The post `subgraph` is connect to the `http` output port :

    http() POST[/todos/?$] -> request post()

##### The `DELETE subgraph`

![delete](./doc/images/delete.png)

This `subgraph` is easier than the two before, so it is mainly self-explaining!

* The `req_id` and the `id` are get in `get_id`.
* The `id` is send to `sql_delete`, which give back the id to `build_response`.
* `build_response` simply fill the http response with the id
* `add_req_id` add the http `id`

The delete `subgraph` is connect to the `http` output port :

    http() DELETE[/todos/.+] -> request post()

##### The `PATCH subgraph`

![path](./doc/images/patch.png)

The patch `subgraph` is a little more complicated, because of the `synch` `agent`. Let first see what happend without it :

![patch_without_sync](./doc/images/patch_without_sync.png)

The "idea" of the stream is :
* Get the new "todos" values in the request
* In parrallel, get the old value of the todo (look in the database)
* Then, send the old and the new values to a "merge" `agent`, that build the result todo

The problem with this simple flow is when the "old" todo doesn't exist, when the "old" todo is not in the database. In this case, the "old" edge (from `get_todo` to `merge`) and the "error" edge (from `sql_get` to `build_response`) are completly concurent. There will be a problem in the case of the "error" case. If the "todo" is not found in the database, `sql_get` will send an error. But `get_todo` will already have sended the "new" todo IP. The current http response will be correct, but at the next one, there will be 2 IPs in the `old` input port, with the first one that is wrong.
A solution is to add a `synch` `agent`. This `agent` receive the IP "old", "new" and "error". If it receive "error", it send it to `build_respone` and discard the "old". If it receive "new", it forwards "new" and "old" to `merge`. So all IPs are well taken in account.

To simplify a little the graph, we ommit to speak about a connection : from `sql_get` to `patch_sql`. An IP is send from the former with the todo `id`, which need to be updated. But all the logic, with synch, is exactly the same. The complete figure is :

![patch_final](./doc/images/patch_final.png)

## Extension

Further reading in depth topics are:

* [The Rust Book](https://doc.rust-lang.org/stable/book/)
* [Flow-Based Programming Book](https://www.amazon.com/Flow-Based-Programming-2nd-Application-Development/dp/1451542321)
* [The Nix Manual](http://nixos.org/nix/manual/)
* [The NixOS Manual](http://nixos.org/nixos/manual/)
* [The Hydra Manual](http://nixos.org/hydra/manual/)
* [The Nixops Manual](http://nixos.org/nixops/manual/)
* [The Cap'n Proto Schema Language](https://capnproto.org/language.html)
