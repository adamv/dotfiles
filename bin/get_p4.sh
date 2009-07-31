#/bin/bash

if [[ ! -e ~/bin/p4 ]] ; then
    curl http://www.perforce.com/perforce/downloads/download/P4macosx104uessentials.html -o ~/bin/p4
    chmod u+x ~/bin/p4
fi
