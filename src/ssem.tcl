# ssem.tcl
#
#    Manchester Small-Scale Experimental Machine (SSEM) Simulator
#
# Copyright (c) 2010 Sebastián Reguera Candal

package provide ssem 1.0
package require Tcl  8.5

namespace eval ::ssem {

    namespace export reset step mget mset mreset

    # Memory
    variable Store [lrepeat 32 0]

    # Accumulator
    variable A 0

    # Program counter
    variable C 0

    # Current instruction
    variable PI 0
}

# ::ssem::reset
#    Reset the computer
# Results:
#    All the registers and memory locations are set to 0
proc ::ssem::reset {} {
    variable A
    variable C
    variable PI
    mreset
    set A 0
    set C 0
    set PI 0
    return
}

# ::ssem::step1
#    Execute the next instruction
# Results:
#    The registers and memory change according to the executed instruction
proc ::ssem::step1 {} {
    variable A 
    variable C
    variable PI
    incr C
    set PI [mget $C]
    set op [IOpcode $PI]
    set s [IAddress $PI]
    if {$op == 0b000} {
        # JMP S
        set C [mget $s]
    } elseif {($op == 0b001) || ($op == 0b101)} {
        # SUB S
        set A [expr {int($A - [mget $s])}]
    } elseif {$op == 0b010} {
        # LDN S
        set A [expr {- [mget $s]}]
    } elseif {$op == 0b011} {
        # CMP
        if {$A < 0} {
            incr C
        }
    } elseif {$op == 0b100} {
        # JRP S
        set C [expr {int($C + [mget $s])}]
    } elseif {$op == 0b110} {
        # STO S
        mset $s $A
    } elseif {$op == 0b111} {
        # STP
        return 0
    }
    return 1
}

proc ::ssem::step {{n 1}} {
    for {set i 0} {$i < $n} {incr i} {
        if {![::ssem::step1]} {
            return 0
        } 
    }
    return 1
}

# ::ssem::mget
#    Read from the memory
# Arguments:
#    pos : memory position (only low 5 bits are used)
# Results:
#    Return the value of the memory location at position pos
proc ::ssem::mget {pos} {
    variable Store
    set apos [expr {$pos & 0x1F}]
    return [lindex $Store $apos]
}

# ::ssem::mset
#    Write to the memory
# Arguments:
#    pos : memory position (only low 5 bits are used)
#    val : memory value
# Results:
#    The memory location at position pos has the value val
proc ::ssem::mset {pos val} {
    variable Store
    set apos [expr {$pos & 0x1F}]
    lset Store $apos $val
    return
}

# ::ssem::mreset
#    Resets the memory
# Results:
#    All the memory locations have the value 0
proc ::ssem::mreset {} {
    variable Store
    set Store [lrepeat 32 0]
    return
}

# ::ssem::IOpcode
#    Return the instruction opcode field
proc ::ssem::IOpcode {inst} {
    return [expr {($inst >> 12) & 0b111}]
}

# ::ssem::IAddress
#    Return the instruction address field
proc ::ssem::IAddress {inst} {
    return [expr {$inst & 0xFFF}]
}

# ::ssem::encode
#    Return the integer encoding the instruction
proc ::ssem::encode {inst {addr 0}} {
    array set codes {
        jmp 0b000
        sub 0b001
        ldn 0b010
        cmp 0b011
        jrp 0b100
        sto 0b110
        stp 0b111
    }
    return [expr {($codes($inst) << 12) | ($addr & 0xFFF)}]
}