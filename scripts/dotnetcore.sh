if hash dotnet 2>/dev/null; then 
    export PATH="$PATH:~/.dotnet/tools" 
    export DOTNET_ROOT=$(dirname $(realpath $(which dotnet))) 
fi 