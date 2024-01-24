#!/usr/bin/bash

wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz
tar -xzf libsodium-1.0.18.tar.gz
cd libsodium-1.0.18; ./configure; make

