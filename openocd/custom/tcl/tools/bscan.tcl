# by RAM <rmelo@inti.gob.ar>
#
# Bscan is a wrapper of the commands drscan and irscan to make simplier the use of boundary scan.
# It is based on what I learned using info and code from:
# http://sourceforge.net/p/openocd/mailman/openocd-devel/thread/20130621135124.GC2326@home.lan/
#

#
# The work flow is:
# 1. Include this file;
# 2. Run bscan_config
# 3. Initialize DR with bscan_set_bit * 0 (or 1)
# 4. Set and get data:
#    a. Set bits of DR with bscan_set_bit;
#    b. Run bscan_update;
#    c1. Get bits of DR with bscan_get_bit; or
#    c2. Check the awaited values of the bits of DR with bscan_check_bit;
# Notes:
# * In set/get functions, the bit parameter can be:
#   - A natural number: denotate the cell number; or
#   - A string (between "") of space separated natural numbers; or
#   - A * character: denotate all the cells (only to set functions);
# * Others devices in the JTAG chain must be in BYPASS mode (bscan_config
#   can be used for that).
# Others functions:
# * Debug information can be printed with bscan_info
#

#
# Example:
#
# source [find tools/bscan.tcl]
# ...
# bscan_config $_CHIPNAME.cpu 346 0x4
# bscan_set_bit * 0
# bscan_set_bit 10 1
# bscan_update
# bscan_check_bit 10 1
# echo [bscan_get_bit 10]
# bscan_set_bit "11 12" 1
# bscan_update
# bscan_check_bit "11 12" 1
# echo [bscan_get_bit "11 12"]
#

#
# Info about DR (length, available internal registers), IR (supported
# instructions opcodes) and cells to manage I/O, can be obtained from the
# BSDL file of the device. Search the vendor website or http://www.bsdl.info
#

###############################################################################

#
# bscan_config:
# Configures global variables and IR.
# * tap_name: name of the device to use in the chain. It could be obtained from
#             the used target config file or by running the scan_chain command.
# * dr_len:   length of the DR.
# * ir_val:   opcode of the instruction to be set in the IR.
#
proc bscan_config {tap_name dr_len ir_val} {
   global _BSCAN_TAP _BSCAN_DR_LEN _BSCAN_DR_IN _BSCAN_DR_PREV _BSCAN_DR_OUT _BSCAN_IR_VAL
   poll off
   set _BSCAN_TAP $tap_name
   set _BSCAN_DR_LEN $dr_len
   set _BSCAN_IR_VAL $ir_val
   irscan $_BSCAN_TAP $_BSCAN_IR_VAL
}

#
# bscan_update:
# Push a new output value of DR and read the resultant new input value.
#
# Note: the bit order for the drscan command is 31..0 63..32 95..64 and so on.
#
proc bscan_update {} {
    global _BSCAN_TAP _BSCAN_DR_IN _BSCAN_DR_PREV _BSCAN_DR_OUT
    # With the first drscan we read the previous value of DR and push a new output value.
    set _BSCAN_DR_PREV $_BSCAN_DR_OUT
    set state [eval drscan [concat $_BSCAN_TAP $_BSCAN_DR_OUT]]
    set i 1
    foreach word $state {
	set _BSCAN_DR_PREV [lreplace $_BSCAN_DR_PREV $i $i 0x$word]
	incr i 2
    }
    # With the second drscan we read the resultant new input value of DR.
    set _BSCAN_DR_IN $_BSCAN_DR_OUT
    set state [eval drscan [concat $_BSCAN_TAP $_BSCAN_DR_OUT]]
    set i 1
    foreach word $state {
	set _BSCAN_DR_IN [lreplace $_BSCAN_DR_IN $i $i 0x$word]
	incr i 2
    }
}

###############################################################################
# Setters and Getters                                                         #
###############################################################################

#
# bscan_set_bit: set value on bits
#
proc bscan_set_bit {bits value} {
   if {$bits == "*"} {
      _bscan_set_all $value
   } else {
      foreach bit $bits {
         _bscan_set_bit $bit $value
      }
   }
}

# internally used: set value on bit
proc _bscan_set_bit {bit value} {
   global _BSCAN_DR_OUT
   set index [expr ($bit / 32) * 2 + 1]
   set bit [expr $bit % 32]
   set val [expr 2**$bit]
   set word [lindex $_BSCAN_DR_OUT $index]
   if {$value == 0} {
      set word [format %08X [expr $word & ~$val]]
   } else {
      set word [format %08X [expr $word | $val]]
   }
   set _BSCAN_DR_OUT [lreplace $_BSCAN_DR_OUT $index $index 0x$word]
}

# internally used: fill DR with 0s or 1s (if val = 1)
proc _bscan_set_all {val} {
   global _BSCAN_DR_LEN _BSCAN_DR_OUT
   if {$val == 1} {
      set bits 0xFFFFFFFF
   } else {
      set bits 0x00000000
   }
   set _BSCAN_DR_OUT ""
   for {set i $_BSCAN_DR_LEN} {$i > 32} {incr i -32} {
       append _BSCAN_DR_OUT 32 " " $bits " "
   }
   if {$i > 0} {
      append _BSCAN_DR_OUT $i " " $bits " "
   }
}

#
# bscan_get_bit: get values of bits
#
proc bscan_get_bit {bits} {
   set aux ""
   foreach bit $bits {
      append aux [_bscan_get_bit $bit] " "
   }
   return $aux
}

# internally used: get value of bit
proc _bscan_get_bit {bit} {
   global _BSCAN_DR_IN
   set index [expr ($bit / 32) * 2 + 1]
   set bit [expr $bit % 32]
   set val [expr 2**$bit]
   return [expr ([lindex $_BSCAN_DR_IN $index] & $val) != 0]
}

#
# bscan_check_bit: cheack if the values of bits are equal to value
#
proc bscan_check_bit {bits value} {
   foreach bit $bits {
      _bscan_check_bit $bit $value
   }
}

# internally used: cheack if the value of bit is equal to value
proc _bscan_check_bit {bit value} {
   set rvalue [_bscan_get_bit $bit]
   if { $rvalue != $value} {
      echo "Bscan ERROR: bit \"$bit\" must be \"$value\" but it is \"$rvalue\"."
   }
}

###############################################################################
# Debug                                                                       #
###############################################################################

#
# bscan_info: print low level info. Useful for debug.
#
proc bscan_info {} {
   global _BSCAN_DR_IN _BSCAN_DR_PREV _BSCAN_DR_OUT _BSCAN_IR_VAL
   echo "Bscan INFO:"
   echo "* IR           $_BSCAN_IR_VAL"
   echo "* in (prev)    $_BSCAN_DR_PREV"
   echo "* out          $_BSCAN_DR_OUT"
   echo "* in (actual)  $_BSCAN_DR_IN"
}
