
export PUREBASIC_HOME="/Users/fred/svn/v5.70/Build/purebasic_x64"

export PB_PROCESSOR=X64
export PB_COCOA=1
export PB_OSXHOST=10.1

echo "Setting up purebasic basic environment $PB_PROCESSOR..."

export PB_LIBRARIES="$PWD/Libraries"
export PB_BUILDTARGET="$PWD/Build/x64"

export PATH="$PUREBASIC_HOME/compilers:$PUREBASIC_HOME/sdk/pureunit:/sw/bin:$PATH"

# For OGRE
export DYLD_LIBRARY_PATH=$PUREBASIC_HOME/compilers:$DYLD_LIBRARY_PATH

mkdir -p Build/x64

. $PB_LIBRARIES/EnvironmentVariables.bash OSX

