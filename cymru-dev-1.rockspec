package = "cymru"
version = "dev-1"
source = {
   url = "https://github.com/mischief/cymru-uv.git"
}
description = {
   summary = "Team Cymru IP ASN mapping bindings over luv",
   homepage = "https://github.com/mischief/cymru-uv.git",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      cymru = "init.lua"
   }
}
