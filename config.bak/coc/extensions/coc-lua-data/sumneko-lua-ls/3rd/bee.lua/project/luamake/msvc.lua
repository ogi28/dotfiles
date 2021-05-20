local lm = require 'luamake'

lm.defines = {
    "_WIN32_WINNT=0x0601",
}

local STACK_SIZE = lm.mode == "debug" and lm.target == "x64" and lm.plat == "msvc"

lm:shared_library 'lua54' {
    sources = {
        "3rd/lua/*.c",
        "!3rd/lua/lua.c",
        "!3rd/lua/luac.c",
        "!3rd/lua/utf8_lua.c",
    },
    defines = {
        "LUA_BUILD_AS_DLL",
    }
}

lm:executable 'lua' {
    deps = "lua54",
    sources = {
        "3rd/lua/utf8_lua.c",
        "3rd/lua/utf8_crt.c",
        EXE_RESOURCE,
    },
    ldflags = {
        STACK_SIZE and "/STACK:"..0x160000
    }
}

lm:shared_library 'bee' {
    deps = "lua54",
    includes = {
        "3rd/lua",
        "3rd/lua-seri",
        "bee/nonstd",
        "."
    },
    defines = {
        "BEE_INLINE",
        "_CRT_SECURE_NO_WARNINGS",
    },
    sources = {
        "3rd/lua-seri/*.c",
        "bee/*.cpp",
        "bee/nonstd/fmt/*.cc",
        "binding/*.cpp",
        "!bee/*_osx.cpp",
        "!bee/*_linux.cpp",
        "!bee/*_posix.cpp",
    },
    links = {
        "advapi32",
        "ws2_32",
        "ole32",
        "user32",
        "version",
        "wbemuuid",
        "oleAut32",
        lm.plat == "mingw" and "stdc++fs",
        lm.plat == "mingw" and "stdc++"
    }
}

lm:executable 'bootstrap' {
    deps = "lua54",
    includes = {
        "3rd/lua"
    },
    sources = {
        "bootstrap/*.cpp",
        "3rd/lua/utf8_crt.c",
        EXE_RESOURCE,
    },
    ldflags = {
        STACK_SIZE and "/STACK:"..0x160000
    }
}
