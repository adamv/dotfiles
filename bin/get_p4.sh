#/bin/bash

if [[ ! -e ~/bin/p4 ]] ; then
    curl http://filehost.perforce.com/perforce/r09.1/bin.macosx104u/p4 -o ~/bin/p4
    chmod u+x ~/bin/p4
fi
