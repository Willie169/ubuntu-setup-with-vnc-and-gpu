#!/bin/bash

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export CXXFLAGS='-std=gnu++20 -O2'
export CFLAGS='-std=c17 -O2'
alias gpp11='g++ -std=gnu++11'
alias cpp11='clang++ -std=gnu++11'
alias gpp111='g++ -std=gnu++11 -O1'
alias cpp111='clang++ -std=gnu++11 -O1'
alias gpp112='g++ -std=gnu++11 -O2'
alias cpp112='clang++ -std=gnu++11 -O2'
alias gpp113='g++ -std=gnu++11 -O3'
alias cpp113='clang++ -std=gnu++11 -O3'
alias gpp14='g++ -std=gnu++14'
alias cpp14='clang++ -std=gnu++14'
alias gpp141='g++ -std=gnu++14 -O1'
alias cpp141='clang++ -std=gnu++14 -O1'
alias gpp142='g++ -std=gnu++14 -O2'
alias cpp142='clang++ -std=gnu++14 -O2'
alias gpp143='g++ -std=gnu++14 -O3'
alias cpp143='clang++ -std=gnu++14 -O3'
alias gpp17='g++ -std=gnu++17'
alias cpp17='clang++ -std=gnu++17'
alias gpp171='g++ -std=gnu++17 -O1'
alias cpp171='clang++ -std=gnu++17 -O1'
alias gpp172='g++ -std=gnu++17 -O2'
alias cpp172='clang++ -std=gnu++17 -O2'
alias gpp173='g++ -std=gnu++17 -O3'
alias cpp173='clang++ -std=gnu++17 -O3'
alias gpp20='g++ -std=gnu++20'
alias cpp20='clang++ -std=gnu++20'
alias gpp201='g++ -std=gnu++20 -O1'
alias cpp201='clang++ -std=gnu++20 -O1'
alias gpp202='g++ -std=gnu++20 -O2'
alias cpp202='clang++ -std=gnu++20 -O2'
alias gpp203='g++ -std=gnu++20 -O3'
alias cpp203='clang++ -std=gnu++20 -O3'
alias gpp23='g++ -std=gnu++23'
alias cpp23='clang++ -std=gnu++23'
alias gpp231='g++ -std=gnu++23 -O1'
alias cpp231='clang++ -std=gnu++23 -O1'
alias gpp232='g++ -std=gnu++23 -O2'
alias cpp232='clang++ -std=gnu++23 -O2'
alias gpp233='g++ -std=gnu++23 -O3'
alias cpp233='clang++ -std=gnu++23 -O3'
alias cfm='clang -f ormat'
alias cfmi='clang -f ormat -i'

gccSDL2() {
  gcc "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lm -lstdc++
}

gccSDL2bgi() {
  gcc "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi -lm -lstdc++
}

gppSDL2() {
  g++ "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gppSDL2bgi() {
  g++ "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp11SDL2() {
  g++ -std=gnu++11 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp11SDL2bgi() {
  g++ -std=gnu++11 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp111SDL2() {
  g++ -std=gnu++11 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp111SDL2bgi() {
  g++ -std=gnu++11 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp112SDL2() {
  g++ -std=gnu++11 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp112SDL2bgi() {
  g++ -std=gnu++11 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp113SDL2() {
  g++ -std=gnu++11 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp113SDL2bgi() {
  g++ -std=gnu++11 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp14SDL2() {
  g++ -std=gnu++14 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp14SDL2bgi() {
  g++ -std=gnu++14 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp141SDL2() {
  g++ -std=gnu++14 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp141SDL2bgi() {
  g++ -std=gnu++14 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp142SDL2() {
  g++ -std=gnu++14 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp142SDL2bgi() {
  g++ -std=gnu++14 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp143SDL2() {
  g++ -std=gnu++14 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp143SDL2bgi() {
  g++ -std=gnu++14 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp17SDL2() {
  g++ -std=gnu++17 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp17SDL2bgi() {
  g++ -std=gnu++17 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp171SDL2() {
  g++ -std=gnu++17 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp171SDL2bgi() {
  g++ -std=gnu++17 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp172SDL2() {
  g++ -std=gnu++17 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp172SDL2bgi() {
  g++ -std=gnu++17 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp173SDL2() {
  g++ -std=gnu++17 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp173SDL2bgi() {
  g++ -std=gnu++17 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp20SDL2() {
  g++ -std=gnu++20 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp20SDL2bgi() {
  g++ -std=gnu++20 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp201SDL2() {
  g++ -std=gnu++20 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp201SDL2bgi() {
  g++ -std=gnu++20 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp202SDL2() {
  g++ -std=gnu++20 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp202SDL2bgi() {
  g++ -std=gnu++20 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp203SDL2() {
  g++ -std=gnu++20 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp203SDL2bgi() {
  g++ -std=gnu++20 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp23SDL2() {
  g++ -std=gnu++23 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp23SDL2bgi() {
  g++ -std=gnu++23 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp231SDL2() {
  g++ -std=gnu++23 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp231SDL2bgi() {
  g++ -std=gnu++23 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp232SDL2() {
  g++ -std=gnu++23 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp232SDL2bgi() {
  g++ -std=gnu++23 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

gpp233SDL2() {
  g++ -std=gnu++23 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

gpp233SDL2bgi() {
  g++ -std=gnu++23 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}
