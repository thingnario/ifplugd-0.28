#!/bin/bash
set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: ./build_ifplugd.sh tool_chain_path install_path!"
    echo "Example: ./build_ifplugd.sh /usr/local/arm-linux /Desktop/eric/logger/build/moxa-ia240/ifplugd"
    exit
fi

export PATH="$PATH:$1/bin"

tool_chain_path=$1
install_path=$2/../
#ARCH=`echo $1 | awk -F"/" '{print (NF>1)? $NF : $1}'`

# linux architecture 
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

# ======== ifplugd with static build ========

export ARCH=$ARCH
if [ "$ARCH" == "" ]; then
	export AR=ar
	export AS=as
	export LD=ld
	export RANLIB=ranlib
	export CC=gcc
	export NM=nm
	./configure --prefix=$2
else
	export AR=${ARCH}-ar
	export AS=${ARCH}-as
	export LD=${ARCH}-ld
	export RANLIB=${ARCH}-ranlib
	export CC=${ARCH}-gcc
	export NM=${ARCH}-nm
	PKG_CONFIG_PATH="$install_path/libdaemon/lib/pkgconfig" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --prefix=$2 --target=${ARCH} --host=${ARCH} --with-gnu-ld --disable-lynx
fi

make clean
make
make install
