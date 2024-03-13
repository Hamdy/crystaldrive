# crystaldrive

A file manager server that utilizes [Crystalstore](https://github.com/Hamdy/crystalstore) library to store files on top of the [Threefold bcdb](https://github.com/threefoldtech/bcdb) store.

Crystaldrive uses [Filebrowser](https://filebrowser.org/) as a frontend

<p align="center">
  <img src="https://raw.githubusercontent.com/filebrowser/logo/master/banner.png" width="550"/>
</p>

![Preview](https://user-images.githubusercontent.com/5447088/50716739-ebd26700-107a-11e9-9817-14230c53efd2.gif)


## Build ui

`./build-ui.sh`

## Run
```
shards install
crystal  run src/crystaldrive.cr
```

