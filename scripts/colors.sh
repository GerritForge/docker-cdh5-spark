#!/usr/bin/env bash

function red { echo $2 -e "\e[1;31m$1\e[0m"; }
function cyan { echo $2 -e "\e[1;36m$1\e[0m"; }
function green { echo $2 -e "\e[1;32m$1\e[0m"; }
function purple { echo $2 -e "\e[1;35m$1\e[0m"; }
function blue { echo $2 -e "\e[1;34m$1\e[0m"; }
function yellow { echo $2 -e "\e[1;33m$1\e[0m"; }