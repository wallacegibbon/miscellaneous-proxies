#! /bin/bash

printf "%b\n" "${1//%/\\x}"

