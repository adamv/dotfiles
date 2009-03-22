## Back up delicious.com links
# Ref: http://rentzsch.com/notes/backingUpDelicious
read -p "Usename: " myusername
read -s -p "Password: " mypassword
printf '\nBacking up delicious bookmarks for user: %s\n' $myusername
mkdir -p ~/Documents/backups
curl --user $myusername:$mypassword -o ~/Documents/backups/$myusername-delicious.xml -O 'https://api.del.icio.us/v1/posts/all'
