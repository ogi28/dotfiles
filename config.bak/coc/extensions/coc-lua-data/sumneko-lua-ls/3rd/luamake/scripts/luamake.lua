local fs = require "bee.filesystem"
local sp = require "bee.subprocess"
local memfile = require "memfile"
local util = require 'util'
local arguments = require "arguments"

local compiler = (function ()
    if arguments.plat == 'mingw' then
        return "gcc"
    elseif arguments.plat == "msvc" then
        return "cl"
    elseif arguments.plat == "linux" then
        return "gcc"
    elseif arguments.plat == "macos" then
        return "clang"
    end
end)()

local cc = require("compiler." .. compiler)

local function isWindows()
    return arguments.plat == "msvc" or arguments.plat == "mingw"
end

local function fmtpath(path)
    if arguments.plat == "msvc" then
        path = path:gsub('/', '\\')
    else
        path = path:gsub('\\', '/')
    end
    return path
end

local function fmtpath_v3(rootdir, path)
    path = fs.path(path)
    if not path:is_absolute() and path:string():sub(1, 1) ~= "$" then
        path = fs.relative(fs.absolute(path, rootdir), WORKDIR)
    end
    return fmtpath(path:string())
end

-- TODO 在某些平台上忽略大小写？
local function glob_compile(pattern)
    return ("^%s$"):format(pattern:gsub("[%^%$%(%)%%%.%[%]%+%-%?]", "%%%0"):gsub("%*", ".*"))
end
local function glob_match(pattern, target)
    return target:match(pattern) ~= nil
end

local function accept_path(t, path)
    assert(fs.exists(path), ("source `%s` is not exists."):format(path:string()))
    local repath = fs.relative(path, WORKDIR):string()
    if t[repath] then
        return
    end
    t[#t+1] = repath
    t[repath] = #t
end
local function expand_dir(t, pattern, dir)
    assert(fs.exists(dir), ("source dir `%s` is not exists."):format(dir:string()))
    for file in dir:list_directory() do
        if fs.is_directory(file) then
            expand_dir(t, pattern, file)
        else
            if glob_match(pattern, file:filename():string()) then
                accept_path(t, file)
            end
        end
    end
end
local function expand_path(t, path)
    local filename = path:filename():string()
    if filename:find("*", 1, true) == nil then
        accept_path(t, path)
        return
    end
    local pattern = glob_compile(filename)
    expand_dir(t, pattern, path:parent_path())
end
local function get_sources(root, sources)
    if type(sources) ~= "table" then
        return {}
    end
    local result = {}
    local ignore = {}
    for _, source in ipairs(sources) do
        if source:sub(1,1) ~= "!" then
            expand_path(result, root / source)
        else
            expand_path(ignore, root / source:sub(2))
        end
    end
    for _, path in ipairs(ignore) do
        local pos = result[path]
        if pos then
            result[pos] = result[#result]
            result[result[pos]] = pos
            result[path] = nil
            result[#result] = nil
        end
    end
    table.sort(result)
    return result
end

local file_type = {
    cxx = "cxx",
    cpp = "cxx",
    cc = "cxx",
    mm = "cxx",
    c = "c",
    m = "c",
    rc = "rc",
    s = "asm",
}

local function tbl_append(t, a)
    table.move(a, 1, #a, #t + 1, t)
end

local function get_warnings(warnings)
    local error = nil
    local level = 'on'
    for _, warn in ipairs(warnings) do
        if warn == 'error' then
            error = true
        else
            level = warn
        end
    end
    return {error = error, level = level}
end

local function merge_attribute(from, to)
    if type(from) == 'string' then
        to[#to+1] = from
    elseif type(from) == 'userdata' then
        to[#to+1] = from
    elseif type(from) == 'table' then
        for _, e in ipairs(from) do
            merge_attribute(e, to)
        end
    end
    return to
end

local multiattr = {
    'sources',
    'warnings',
    'defines',
    'undefs',
    'includes',
    'links',
    'linkdirs',
    'flags',
    'ldflags',
    'deps',
}

local function init_multi_attribute(attribute, globals, multiattr)
    for _, name in ipairs(multiattr) do
        local res = {}
        merge_attribute(globals[name], res)
        if isWindows() and globals.windows then
            merge_attribute(globals.windows[name], res)
        end
        if globals[arguments.plat] then
            merge_attribute(globals[arguments.plat][name], res)
        end
        merge_attribute(attribute[name], res)
        if isWindows() and attribute.windows then
            merge_attribute(attribute.windows[name], res)
        end
        if attribute[arguments.plat] then
            merge_attribute(attribute[arguments.plat][name], res)
        end
        attribute[name] = res
    end
end

local function array_remove(t, k)
    for pos, m in ipairs(t) do
        if m == k then
            table.remove(t, pos)
            return true
        end
    end
    return false
end

local function generate(self, rule, name, attribute, globals)
    assert(self._targets[name] == nil, ("`%s`: redefinition."):format(name))

    init_multi_attribute(attribute, globals, multiattr)

    local function init_single(attr_name, default)
        local attr = attribute[attr_name] or globals[attr_name] or default
        assert(type(attr) ~= 'table')
        attribute[attr_name] = attr
        return attr
    end

    local ninja = self.ninja
    local workdir = fs.path(init_single('workdir', '.'))
    local rootdir = fs.absolute(fs.path(init_single('rootdir', '.')), workdir)
    local sources = get_sources(rootdir, attribute.sources)
    local mode = init_single('mode', 'release')
    local crt = init_single('crt', 'dynamic')
    local optimize = init_single('optimize', (mode == "debug" and "off" or "speed"))
    local warnings = get_warnings(attribute.warnings)
    local defines = attribute.defines
    local undefs = attribute.undefs
    local includes = attribute.includes
    local links = attribute.links
    local linkdirs = attribute.linkdirs
    local ud_flags = attribute.flags
    local ud_ldflags = attribute.ldflags
    local deps = attribute.deps
    local pool = init_single('pool')
    local implicit = {}
    local input = {}

    init_single('c')
    init_single('cxx')
    init_single('permissive')
    init_single('visibility')

    local flags =  {}
    local ldflags =  {}

    tbl_append(flags, cc.flags)
    tbl_append(ldflags, cc.ldflags)

    flags[#flags+1] = cc.optimize[optimize]
    flags[#flags+1] = cc.warnings[warnings.level]
    if warnings.error then
        flags[#flags+1] = cc.warnings.error
    end

    if cc.name == 'cl' then
        if not attribute.permissive then
            flags[#flags+1] = '/permissive-'
        end
    end

    if arguments.plat == "linux" or arguments.plat == "macos" then
        if attribute.visibility ~= "default" then
            flags[#flags+1] = ('-fvisibility=%s'):format(attribute.visibility or 'hidden')
        end
    end

    cc.mode(name, mode, crt, flags, ldflags)

    for _, inc in ipairs(includes) do
        flags[#flags+1] = cc.includedir(fmtpath_v3(rootdir, inc))
    end

    if mode == "release" then
        defines[#defines+1] = "NDEBUG"
    end

    local pos = 1
    while pos <= #undefs do
        local macro = undefs[pos]
        if array_remove(defines, macro) then
            table.remove(undefs, pos)
        else
            pos = pos + 1
        end
    end

    for _, macro in ipairs(defines) do
        flags[#flags+1] = cc.define(macro)
    end

    for _, macro in ipairs(undefs) do
        flags[#flags+1] = cc.undef(macro)
    end

    if rule == "shared_library" and not isWindows() then
        flags[#flags+1] = "-fPIC"
    end

    if cc.name == "clang" and self.target then
        flags[#flags+1] = "-target"
        flags[#flags+1] = self.target
        ldflags[#ldflags+1] = "-target"
        ldflags[#ldflags+1] = self.target
    end

    for _, dep in ipairs(deps) do
        local target = self._targets[dep]
        assert(target ~= nil, ("`%s`: can`t find deps `%s`"):format(name, dep))
        if target.includedir then
            flags[#flags+1] = cc.includedir(fmtpath_v3(target.rootdir, target.includedir))
        end
        if target.links then
            tbl_append(links, target.links)
        end
        if target.linkdirs then
            for _, linkdir in ipairs(target.linkdirs) do
                ldflags[#ldflags+1] = cc.linkdir(fmtpath_v3(target.rootdir, linkdir))
            end
        end
    end

    tbl_append(flags, ud_flags)
    tbl_append(ldflags, ud_ldflags)

    local fin_flags = table.concat(flags, " ")
    local fmtname = name:gsub("[^%w_]", "_")
    local has_c = false
    local has_cxx = false
    local has_rc = false
    local has_asm = false
    for _, source in ipairs(sources) do
        local objname = fs.path("$obj") / name / fs.path(source):filename():replace_extension(".obj")
        input[#input+1] = objname
        local ext = fs.path(source):extension():string():sub(2):lower()
        local type = file_type[ext]
        if type == "c" then
            if not has_c then
                has_c = true
                local c = attribute.c or self.c or "c89"
                local cflags = assert(cc.c[c], ("`%s`: unknown std c: `%s`"):format(name, c))
                cc.rule_c(ninja, name, fin_flags, cflags, attribute)
            end
            ninja:build(objname, "C_"..fmtname, source)
        elseif type == "cxx" then
            if not has_cxx then
                has_cxx = true
                local cxx = attribute.cxx or self.cxx or "c++17"
                local cxxflags = assert(cc.cxx[cxx], ("`%s`: unknown std c++: `%s`"):format(name, cxx))
                cc.rule_cxx(ninja, name, fin_flags, cxxflags, attribute)
            end
            ninja:build(objname, "CXX_"..fmtname, source)
        elseif isWindows() and type == "rc" then
            if not has_rc then
                cc.rule_rc(ninja, name)
            end
            ninja:build(objname, "RC_"..fmtname, source)
        elseif type == "asm" then
            if cc.name == "cl" then
                error "TODO"
            end
            if not has_asm then
                has_asm = true
                cc.rule_asm(ninja, name, fin_flags, attribute)
            end
            ninja:build(objname, "ASM_"..fmtname, source)
        else
            error(("`%s`: unknown file extension: `%s` in `%s`"):format(name, ext, source))
        end
    end

    local outname
    if rule == "executable" then
        if isWindows() then
            outname = fs.path("$bin") / (name .. ".exe")
        else
            outname = fs.path("$bin") / name
        end
    elseif rule == "shared_library" then
        if isWindows() then
            outname = fs.path("$bin") / (name .. ".dll")
        else
            outname = fs.path("$bin") / (name .. ".so")
        end
    elseif rule == "static_library" then
        if isWindows() then
            outname = fs.path("$bin") / (name .. ".lib")
        else
            outname = fs.path("$bin") / ("lib"..name .. ".a")
        end
    end
    ninja:build(name, 'phony', outname)

    local t = {
        rootdir = rootdir,
        includedir = ".",
        outname = outname,
        rule = rule,
    }
    self._targets[name] = t

    for _, dep in ipairs(deps) do
        local target = self._targets[dep]
        if target.output then
            if type(target.output) == 'table' then
                tbl_append(input, target.output)
            else
                input[#input+1] = target.output
            end
        else
            implicit[#implicit+1] = target.outname
        end
    end
    assert(#input > 0, ("`%s`: no source files found."):format(name))

    if rule == 'source_set' then
        assert(#input > 0, ("`%s`: no source files found."):format(name))
        t.output = input
        t.links = links
        t.linkdirs = linkdirs
        return
    end

    local tbl_links = {}
    for _, link in ipairs(links) do
        tbl_links[#tbl_links+1] = cc.link(link)
    end
    for _, linkdir in ipairs(linkdirs) do
        ldflags[#ldflags+1] = cc.linkdir(fmtpath_v3(rootdir, linkdir))
    end
    local fin_links = table.concat(tbl_links, " ")
    local fin_ldflags = table.concat(ldflags, " ")

    if attribute.input or self.input then
        tbl_append(input, attribute.input or self.input)
    end

    local vars = pool and {pool=pool} or nil
    if rule == "shared_library" then
        cc.rule_dll(ninja, name, fin_links, fin_ldflags, mode, attribute)
        if cc.name == 'cl' then
            local lib = (fs.path('$bin') / name)..".lib"
            t.output = lib
            ninja:build(outname, "LINK_"..fmtname, input, implicit, nil, vars, lib)
        else
            if isWindows() then
                t.output = outname
            end
            ninja:build(outname, "LINK_"..fmtname, input, implicit, nil, vars)
        end
    elseif rule == "executable" then
        cc.rule_exe(ninja, name, fin_links, fin_ldflags, mode, attribute)
        ninja:build(outname, "LINK_"..fmtname, input, implicit, nil, vars)
    elseif rule == "static_library" then
        t.output = outname
        cc.rule_lib(ninja, name)
        ninja:build(outname, "LINK_"..fmtname, input, implicit, nil, vars)
    end
end

local GEN = {}

local ruleCommand = false
local ruleCopy = false

local NAMEIDX = 0
local function generateTargetName()
    NAMEIDX = NAMEIDX + 1
    return ("_target_0x%08x_"):format(NAMEIDX)
end

function GEN.default(self, attribute)
    local ninja = self.ninja
    if type(attribute) == "table" then
        local targets = {}
        for _, name in ipairs(attribute) do
            if name then
                assert(self._targets[name] ~= nil, ("`%s`: undefine."):format(name))
                targets[#targets+1] = self._targets[name].outname
            end
        end
        ninja:default(targets)
    elseif type(attribute) == "string" then
        local name = attribute
        assert(self._targets[name] ~= nil, ("`%s`: undefine."):format(name))
        ninja:default {
            self._targets[name].outname
        }
    end
end

function GEN.phony(self, name, attribute, globals)
    local ninja = self.ninja
    local function init_single(attr_name, default)
        local attr = attribute[attr_name] or globals[attr_name] or default
        assert(type(attr) ~= 'table')
        attribute[attr_name] = attr
        return attr
    end
    local workdir = fs.path(init_single('workdir', '.'))
    local rootdir = fs.absolute(fs.path(init_single('rootdir', '.')), workdir)
    init_multi_attribute(attribute, globals, {"input","output","deps"})
    local input = attribute.input
    local output = attribute.output
    local deps = attribute.deps
    local implicit = {}
    for i = 1, #input do
        input[i] = fmtpath_v3(rootdir, input[i])
    end
    for i = 1, #output do
        output[i] = fmtpath_v3(rootdir, output[i])
    end
    for _, dep in ipairs(deps) do
        local depsTarget = self._targets[dep]
        assert(depsTarget ~= nil, ("`%s`: can`t find deps `%s`"):format(name, dep))
        implicit[#implicit+1] = depsTarget.outname
    end
    if name then
        if #output == 0 then
            ninja:build(name, 'phony', input, implicit)
        else
            ninja:build(name, 'phony', output)
            ninja:build(output, 'phony', input, implicit)
        end
        self._targets[name] = {
            outname = name,
            rule = 'phony',
        }
    else
        if #output == 0 then
            error(("`%s`: no output."):format(name))
        else
            ninja:build(output, 'phony', input, implicit)
        end
    end
end

function GEN.build(self, name, attribute, globals, shell)
    local tmpName = not name
    name = name or generateTargetName()
    assert(self._targets[name] == nil, ("`%s`: redefinition."):format(name))
    init_multi_attribute(attribute, globals, {"deps","input","output"})

    local function init_single(attr_name, default)
        local attr = attribute[attr_name] or globals[attr_name] or default
        assert(type(attr) ~= 'table')
        attribute[attr_name] = attr
        return attr
    end

    local ninja = self.ninja
    local workdir = fs.path(init_single('workdir', '.'))
    local rootdir = fs.absolute(fs.path(init_single('rootdir', '.')), workdir)
    local deps = attribute.deps
    local input = attribute.input
    local output = attribute.output
    local pool =  init_single('pool')
    local implicit = {}

    for i = 1, #input do
        input[i] = fmtpath_v3(rootdir, input[i])
    end
    for i = 1, #output do
        output[i] = fmtpath_v3(rootdir, output[i])
    end

    local command = {}
    local function push(v)
        command[#command+1] = sp.quotearg(v)
    end
    local function push_command(t)
        for _, v in ipairs(t) do
            if type(v) == 'nil' then
            elseif type(v) == 'table' then
                push_command(v)
            elseif type(v) == 'userdata' then
                push(fmtpath_v3(rootdir, v))
            elseif type(v) == 'string' then
                if v:sub(1,1) == '@' then
                    push(fmtpath_v3(rootdir, v:sub(2)))
                else
                    push(v)
                end
            end
        end
    end
    push_command(attribute)

    for _, dep in ipairs(deps) do
        local depsTarget = self._targets[dep]
        assert(depsTarget ~= nil, ("`%s`: can`t find deps `%s`"):format(name, dep))
        implicit[#implicit+1] = depsTarget.outname
    end

    if not ruleCommand then
        ruleCommand = true
        ninja:rule('command', '$COMMAND', {
            description = '$DESC'
        })
    end
    if shell then
        if arguments.plat == "msvc" then
            table.insert(command, 1, "cmd")
            table.insert(command, 2, "/c")
        elseif arguments.plat == "mingw" then
            local s = {}
            for _, opt in ipairs(command) do
                s[#s+1] = opt
            end
            command = {
                "sh",
                "-e",
                "-c", sp.quotearg(table.concat(s, " "))
            }
        else
            local s = {}
            for _, opt in ipairs(command) do
                s[#s+1] = opt
            end
            command = {
                "/bin/sh",
                "-e",
                "-c", sp.quotearg(table.concat(s, " "))
            }
        end
    end
    local outname
    if #output == 0 then
        outname = '$builddir/_/' .. name:gsub("[^%w_]", "_")
    else
        outname = output
    end
    ninja:build(outname, 'command', input, implicit, nil, {
        COMMAND = command,
        pool = pool,
    })
    if not tmpName then
        ninja:build(name, 'phony', outname)
        self._targets[name] = {
            outname = name,
            rule = 'build',
        }
    end
end

function GEN.copy(self, name, attribute, globals)
    local tmpName = not name
    name = name or generateTargetName()
    assert(self._targets[name] == nil, ("`%s`: redefinition."):format(name))
    init_multi_attribute(attribute, globals, {"deps","input","output"})

    local function init_single(attr_name, default)
        local attr = attribute[attr_name] or globals[attr_name] or default
        assert(type(attr) ~= 'table')
        attribute[attr_name] = attr
        return attr
    end

    local ninja = self.ninja
    local workdir = fs.path(init_single('workdir', '.'))
    local rootdir = fs.absolute(fs.path(init_single('rootdir', '.')), workdir)
    local deps = attribute.deps
    local input = attribute.input
    local output = attribute.output
    local pool =  init_single('pool')
    local implicit = {}

    for i = 1, #input do
        local v = input[i]
        if type(v) == 'string' and v:sub(1,1) == '@' then
            v =  v:sub(2)
        end
        input[i] = fmtpath_v3(rootdir, v)
    end
    for i = 1, #output do
        local v = output[i]
        if type(v) == 'string' and v:sub(1,1) == '@' then
            v =  v:sub(2)
        end
        output[i] = fmtpath_v3(rootdir, v)
    end

    for _, dep in ipairs(deps) do
        local depsTarget = self._targets[dep]
        assert(depsTarget ~= nil, ("`%s`: can`t find deps `%s`"):format(name, dep))
        implicit[#implicit+1] = depsTarget.outname
    end

    if not ruleCopy then
        ruleCopy = true
        if arguments.plat == "msvc" then
            ninja:rule('copy', 'cmd /c copy 1>NUL 2>NUL /y $in$input $out', {
                description = 'Copy $in$input $out',
                restat = 1,
            })
        elseif arguments.plat == "mingw" then
            ninja:rule('copy', 'sh -c "cp -afv $in$input $out 1>/dev/null"', {
                description = 'Copy $in$input $out',
                restat = 1,
            })
        else
            ninja:rule('copy', 'cp -afv $in$input $out 1>/dev/null', {
                description = 'Copy $in$input $out',
                restat = 1,
            })
        end
    end
    if #implicit == 0 then
        ninja:build(output, 'copy', input, nil, nil, {
            pool = pool,
        })
    else
        ninja:build(output, 'copy', nil, implicit, nil, {
            input = input,
            pool = pool,
        })
    end
    if not tmpName then
        ninja:build(name, 'phony', output)
        self._targets[name] = {
            outname = name,
            rule = 'build',
        }
    end
end

function GEN.shell(self, name, attribute, globals)
    GEN.build(self, name, attribute, globals, true)
end

function GEN.lua_library(self, name, locals, globals)
    local lua_library = require "lua_library"
    generate(lua_library(self, name, locals, globals))
end

local lm = {}

lm._scripts = {}
lm._targets = {}
lm.cc = cc

function lm:add_script(filename)
    if fs.path(filename:sub(1, #(MAKEDIR:string()))) == MAKEDIR then
        return
    end
    filename = fs.relative(fs.path(filename), WORKDIR):string()
    if filename == arguments.f then
        return
    end
    if self._scripts[filename] then
        return
    end
    self._scripts[filename] = true
    self._scripts[#self._scripts+1] = filename
end

local function getexe()
    return fs.exe_path():string()
end

function lm:finish()
    local globals = self._export_globals
    fs.create_directories(WORKDIR / 'build' / arguments.plat)

    local ninja_syntax = require "ninja_syntax"
    local ninja_script = util.script():string()
    local ninja = ninja_syntax.Writer(assert(memfile(ninja_script)))

    ninja:variable("builddir", fmtpath(('build/%s'):format(arguments.plat)))
    if arguments.rebuilt ~= 'no' then
        ninja:variable("luamake", fmtpath(getexe()))
    end
    if globals.bindir then
        ninja:variable("bin", fmtpath(globals.bindir))
    else
        ninja:variable("bin", fmtpath("$builddir/bin"))
    end
    if globals.objdir then
        ninja:variable("obj", fmtpath(globals.objdir))
    else
        ninja:variable("obj", fmtpath("$builddir/obj"))
    end

    self.ninja = ninja
    self.target = globals.target

    if cc.name == "cl" then
        self.winsdk = globals.winsdk
        local msvc = require "msvc_util"
        msvc.createEnvConfig(self.target, self.winsdk)
        if arguments.rebuilt ~= 'no' then
            ninja:variable("msvc_deps_prefix", msvc.getprefix())
        end
    elseif cc.name == "gcc"  then
        ninja:variable("gcc", globals.gcc or "gcc")
        ninja:variable("gxx", globals.gxx or "g++")
    elseif cc.name == "clang" then
        ninja:variable("gcc", globals.gcc or "clang")
        ninja:variable("gxx", globals.gxx or "clang++")
    end

    if arguments.rebuilt ~= 'no' then
        local build_ninja = (fs.path '$builddir' / arguments.f):replace_extension ".ninja"
        ninja:rule('configure', '$luamake init -f $in', { generator = 1 })
        ninja:build(build_ninja, 'configure', arguments.f, self._scripts)
    end

    for _, target in ipairs(self._export_targets) do
        local rule = target[1]
        if GEN[rule] then
            GEN[rule](self, target[2], target[3], target[4])
        else
            generate(self, rule, target[2], target[3], target[4])
        end
    end
    ninja:close()
end

return lm
