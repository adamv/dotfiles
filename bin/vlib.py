#!/usr/bin/env python
import sys
import os
import optparse


def main():
    v = os.environ.get('VIRTUAL_ENV')
    if not v:
        print "No virtual environment active."
        sys.exit(101)

    parser = optparse.OptionParser(version="0.1", usage="vlib.py SOURCE_DIR")

    options, args = parser.parse_args()
    if len(args) < 1:
        print "No sources specified."
        sys.exit(102)
        
    source = os.path.abspath(args[0])
    ignore, source_name = os.path.split(source)

    py_version = 'python%s.%s' % (sys.version_info[0], sys.version_info[1])
    vlib = os.path.join(v, 'lib', py_version, 'site-packages')
    
    target = os.path.join(vlib, source_name)
    
    print "Source package is:", source
    print "Target folder will be:", target
    print
    
    if not os.path.exists(source):
        print "Source does not exist."
        sys.exit(103)
    
    if os.path.exists(target):
        print "Target already exists."
        sys.exit(104)
    
    os.symlink(source, target)


if __name__ == '__main__':
    main()
