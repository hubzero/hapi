#! /usr/bin/env expect

if {[llength $argv] != 3} {
    error "wrong # args: should be octave_forge_installer.tcl OCTAVE_VERSION PKGNAME VERSION"
}

set OCTAVE_VERSION [lindex $argv 0]
set PKGNAME [lindex $argv 1]
set VERSION [lindex $argv 2]

set octaveurl "http://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases"
set err 0

# start up a bash shell in expect
set prompt {(%|#|\$) $}
set timeout 10
log_user 0

# exp_internal 1

exp_spawn -noecho /bin/bash --norc --noprofile
expect -re $prompt

# turn off bash history
exp_send "export HISTFILE=\r"
expect -re $prompt

if {![file isdir /apps/octave/tars]} {
    error "/apps/octave/tars is not a directory"
}

if {![file writable /apps/octave/tars]} {
    error "/apps/octave/tars is not writable"
}

exp_send "cd /apps/octave/tars\r"
expect -re $prompt

if {![file exists ${PKGNAME}-${VERSION}.tar.gz]} {
    set timeout 120
    exp_send "wget $octaveurl/${PKGNAME}-${VERSION}.tar.gz\r"
    expect {
        "100%" {}
        timeout {error "could not download \"${PKGNAME}-${VERSION}.tar.gz\""}
    }
    expect -re $prompt
    set timeout 60
}

set octavePrompt "octave:"
set envsetup ""

if {[file readable "/etc/environ.sh"]} {
    set envsetup "/etc/environ.sh"
} elseif {[file readable "/apps/environ/.setup.sh"]} {
    set envsetup "/apps/environ/.setup.sh"
} else {
    # exit bash
    exp_send "exit\r"
    expect "exit\r\nexit\r\n"
    set err [catch {exp_close;exp_wait} out]
    set result "while installing octave package ${PKGNAME}-${VERSION}: "
    append result "No environ.sh file exists"
    error $result
}

exp_send "source $envsetup\r"
exp_send "use -e -r octave-${OCTAVE_VERSION}\r"
expect -re $prompt
exp_send "octave\r"
expect $octavePrompt

exp_send "cd /apps/octave/tars\r"
expect $octavePrompt

set timeout -1
exp_send "pkg -global install ${PKGNAME}-${VERSION}.tar.gz\r"
#regsub OP {error:(.*)OP\d+>\r\n$} $octavePrompt errorre
expect {
    $octavePrompt {}
    -re {\r\n(warning:[^\r\n]*)\r\n} {
        puts "$expect_out(1,string)"
        exp_continue
    }
    -re "(error:.*)$octavePrompt\d>\$" {
        error "$expect_out(1,string)"
        set err 1
        exp_continue
    }
}

# exit octave
exp_send "exit\r"

# exit bash
exp_send "exit\r"

if {$err == 0} {
    puts "installed ${PKGNAME}-${VERSION}"
}

set err [catch {exp_close;exp_wait} out]
