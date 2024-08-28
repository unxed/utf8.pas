#!/bin/bash
rm -rf *.o
rm -rf *.so
rm -rf *.ppu
find . -maxdepth 1 -type f ! -name "*.*" -exec rm {} +
