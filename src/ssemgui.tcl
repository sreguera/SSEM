# ssem.tcl
#
#    Manchester Small-Scale Experimental Machine (SSEM) Simulator GUI
#
# Copyright (c) 2010 Sebastián Reguera Candal

package require Tk
#package require ssem
source ssem.tcl

namespace eval ::ssem::gui {

    variable stopFlag false
}

proc ::ssem::gui::stopEmu {} {
    variable stopFlag
    set stopFlag true
}

proc ::ssem::gui::runEmu {} {
    variable stopFlag
    set stopFlag false
    .c.step configure -state disabled
    .c.run configure -state disabled
    while {! $stopFlag} {
        ::ssem::steps 1001
        update
    }
    .c.step configure -state enabled
    .c.run configure -state enabled
}

proc ::ssem::gui::mainFrame {} {
    grid [ttk::frame .c] -column 0 -row 0

    grid [ttk::label .c.aregl -text "A:"] \
        -column 0 -row 0
    grid [ttk::label .c.areg -textvariable ::ssem::A] \
        -column 1 -row 0

    grid [ttk::label .c.cregl -text "C:"] \
        -column 0 -row 1
    grid [ttk::label .c.creg -textvariable ::ssem::C] \
        -column 1 -row 1

    grid [ttk::label .c.piregl -text "PI:"] \
        -column 0 -row 2
    grid [ttk::label .c.pireg -textvariable ::ssem::PI] \
        -column 1 -row 2

    grid [ttk::label .c.meml -text "M:"] \
        -column 0 -row 3
    grid [tk::listbox .c.mem -height 32 -listvariable ::ssem::Store] \
        -column 1 -row 3

    grid [ttk::button .c.step -text "Step" -command ::ssem::steps] \
        -column 0 -row 4
    grid [ttk::button .c.run  -text "Run"  -command ::ssem::gui::runEmu] \
        -column 1 -row 4
    grid [ttk::button .c.stop -text "Stop" -command ::ssem::gui::stopEmu] \
        -column 2 -row 4
}

wm title . "SSEM Emulator"
::ssem::gui::mainFrame

set ::ssem::A -1
::ssem::mset 1 0x00003000

