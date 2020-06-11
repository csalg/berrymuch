#!/usr/bin/env bash

set -x

# This code Copyright 2012 Todd Mortimer <todd.mortimer@gmail.com>
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.


set -e
source ../../lib.sh
TASK=fetch

DISTVER="710_release"

package_init "$@"

if [ "$TASK" == "fetch" ]
then
  cd "$EXECDIR"
  # fetch
  echo "Fetching binutils sources if not already present"
pwd
  ls -d $WORKDIR/tools 2>/dev/null 2>&1 || \
{
  mkdir -p $WORKROOT/$DISTVER || exit 1
  cd $WORKDIR || exit 1
  git init || exit 1 
  git config core.sparseCheckout true  || exit 1
  mkdir -p "tools/binutils/branches/710_release/" || exit 1
  echo "tools/binutils/branches/710_release/" >> .git/info/sparse-checkout || exit 1
  git remote add -f origin https://github.com/extrowerk/core-dev-tools.git || exit 1
  git pull origin master || exit 1
}

  TASK=build
fi

# Target have to be --target=arm-unknown-nto-qnx8.0.0eabi
CONFIGURE_CMD=" find . -name \"config.cache\" -exec rm -rf {} \;;
		   ./tools/binutils/branches/710_release/configure
                   --host=$PBHOSTARCH
                   --build=$PBBUILDARCH
                   --target=$PBTARGETARCH
                   --with-sysroot=$QNX_TARGET
                   --prefix=$PREFIX
                   --exec-prefix=$PREFIX
                   --libdir=$PREFIX/lib
                   --libexecdir=$PREFIX/lib
                   --with-local-prefix=$PREFIX
				   --enable-gold
                   CC=$PBTARGETARCH-gcc
                   LDFLAGS='-Wl,-s '
                   AUTOMAKE=: AUTOCONF=: AUTOHEADER=: AUTORECONF=: ACLOCAL=:
		   ac_cv_func_ftello64=no;
		   ac_cv_func_fseeko64=no;
		   ac_cv_func_fopen64=no;
		   CFLAGS=\"$CFLAGS -Wno-shadow -Wno-format -Wno-sign-compare\";
		   LIBS=\"$LIBS -liconv\";
		   LDFLAGS=\"$LDFLAGS -liconv\";
                   "
package_build
package_install

# Do not read further ,this is just the gcc build.sh,  the following part is yet to be done.

cd "$DESTDIR/$PREFIX/bin"
# escape pkgsrc jail
ln -sf ./gcc ./gcc.pkgsrc

# these are broken
rm -rf $DESTDIR/$PREFIX/$TARGETNAME/qnx6/usr/include
cp $EXECDIR/ldd $DESTDIR/$PREFIX/bin/
  
package_bundle

# and pack up the system headers, etc
cd "$BBTOOLS"
zip -r -u -y "$ZIPFILE" $TARGETNAME/qnx6/armle-v7/lib $TARGETNAME/qnx6/usr/include --exclude \*qt4\* || true
zip -r -u -y "$ZIPFILE" $TARGETNAME/qnx6/armle-v7/usr/lib --exclude \*qt4\* || true


