# NOTE: this can be sourced, such as from your .bash_profile, on macOS, or on the command line
# NOTE: if executed directly, the export lines won't be set after the script exits
#
# Certain Java based tools, such as Maven, use the "JAVA_HOME" env var to determine which verison of java to use
# for internal operations. By default, Maven will use the java that was used to invoke the executable, which
# can be different than the java first in your path, or the java version you want to use to compile things.
#
# This script defines shell aliases for swapping the version of java referenced in JAVA_HOME.


# unset aliases and vars managed by this script

unset JAVA_8_HOME
unalias use_java8 >/dev/null 2>/dev/null

unset JAVA_11_HOME
unalias use_java11 >/dev/null 2>/dev/null

unset JAVA_13_HOME
unalias use_java13 >/dev/null 2>/dev/null

unset JAVA_14_HOME
unalias use_java14 >/dev/null 2>/dev/null


# detect currently installed Java verisons


# Java 8 is the pre-module LTS version

JAVA_8_HOME=$(/usr/libexec/java_home -F -v1.8 2> /dev/null)
[[ -n $JAVA_8_HOME ]] && {
  echo "Found Java 8 at $JAVA_8_HOME"
  export JAVA_8_HOME
  alias use_java8='export JAVA_HOME=$JAVA_8_HOME'
}


# Java 11 is the LTS version with module support

JAVA_11_HOME=$(/usr/libexec/java_home -F  -v11 2> /dev/null)
[[ -n $JAVA_11_HOME ]] && {
  echo "Found Java 11 at $JAVA_11_HOME"
  export JAVA_11_HOME
  alias use_java11='export JAVA_HOME=$JAVA_11_HOME'
}


# Newer versions (next LTS is tentatively Java 17)

JAVA_13_HOME=$(/usr/libexec/java_home -F  -v13 2> /dev/null)
[[ -n $JAVA_13_HOME ]] && {
  echo "Found Java 13 at $JAVA_13_HOME"
  export JAVA_13_HOME
  alias use_java13='export JAVA_HOME=$JAVA_13_HOME'
}

JAVA_14_HOME=$(/usr/libexec/java_home -F  -v14 2> /dev/null)
[[ -n $JAVA_14_HOME ]] && {
  echo "Found Java 14 at $JAVA_14_HOME"
  export JAVA_13_HOME
  alias use_java14='export JAVA_HOME=$JAVA_14_HOME'
}
