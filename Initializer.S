
#ifdef __LP64__
	.section	__TEXT,__objc_classname,cstring_literals
L_OBJC_CLASS_NAME_:                     ; @"\01L_OBJC_CLASS_NAME_"
	.asciz	"__ARCLITE__"
; ===

	.section	__DATA,__objc_const
	.align	3                       ; @"\01l_OBJC_CLASS_RO_$___ARCLITE__"
l_OBJC_CLASS_RO_$___ARCLITE__:
	.long	0                       ; 0x0
	.long	8                       ; 0x8
	.long	8                       ; 0x8
	.space	4
	.quad	0
	.quad	L_OBJC_CLASS_NAME_
	.quad	0
	.quad	0
	.quad	0
	.quad	0
	.quad	0

; ====


	.section	__TEXT,__objc_methname,cstring_literals
L_OBJC_METH_VAR_NAME_:
	.asciz	"load"

	.section	__TEXT,__objc_methtype,cstring_literals
L_OBJC_METH_VAR_TYPE_:
	.asciz	"v16@0:8"

	.section	__DATA,__objc_const
	.align	3                       
l_OBJC_METACLASS_RO_$___ARCLITE__:
	.long	19									; flags 		0x13
	.long	40									; instanceStart 0x28
	.long	40									; instanceSize	0x28
	.space	4 									; reserved
	.quad	0 									; ivarLayout
	.quad	L_OBJC_CLASS_NAME_					; name
	.quad	l_OBJC_$_CLASS_METHODS___ARCLITE__ 	; baseMethods
	.quad	0 									; baseProtocols
	.quad	0 									; ivars
	.quad	0 									; weakIvarLayout
	.quad	0 									; baseProperties

	.align	3                       
l_OBJC_$_CLASS_METHODS___ARCLITE__:
	.long	24                      ; 0x18
	.long	1                       ; 0x1
	.quad	L_OBJC_METH_VAR_NAME_
	.quad	L_OBJC_METH_VAR_TYPE_
	.quad	"_initialize"



; 	====================================   ;
	.section	__DATA,__objc_data
	.align 3
_OBJC_CLASS_$___ARCLITE__:
	.quad	_OBJC_METACLASS_$___ARCLITE__ 	; metaclass
	.quad	0								; superclass
	.quad	0								; cache
	.quad	0								; vtable
	.quad	l_OBJC_CLASS_RO_$___ARCLITE__	; data


	.section	__DATA,__objc_data
	.align	3
_OBJC_METACLASS_$___ARCLITE__:
	.quad	_OBJC_METACLASS_$___ARCLITE__ 		; isa
	.quad	_OBJC_CLASS_$___ARCLITE__			; superclass
	.quad	__objc_empty_cache					; cache
	.quad	0									; vtable
	.quad 	l_OBJC_METACLASS_RO_$___ARCLITE__	; data


	.section	__DATA,__objc_nlclslist,regular,no_dead_strip
	.align	3
L_OBJC_LABEL_NONLAZY_CLASS_$:
	.quad	_OBJC_CLASS_$___ARCLITE__


#else

@ 32-bit


	.section	__TEXT,__objc_classname,cstring_literals
L_OBJC_CLASS_NAME_:                     @ @"\01L_OBJC_CLASS_NAME_"
	.asciz	"__ARCLITE__"
@ ===

	.section	__DATA,__objc_const
	.align	3                       @ @"\01l_OBJC_CLASS_RO_$___ARCLITE__"
l_OBJC_CLASS_RO_$___ARCLITE__:
	.long	0                       @ 0x0
	.long	4                       @ 0x8
	.long	4                       @ 0x8
	.long	0
	.long	L_OBJC_CLASS_NAME_
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0

@ ====


	.section	__TEXT,__objc_methname,cstring_literals
L_OBJC_METH_VAR_NAME_:
	.asciz	"load"

	.section	__TEXT,__objc_methtype,cstring_literals
L_OBJC_METH_VAR_TYPE_:
	.asciz	"v16@0:8"

	.section	__DATA,__objc_const
	.align	3                       
l_OBJC_METACLASS_RO_$___ARCLITE__:
	.long	19									@ flags 		0x13
	.long	20									@ instanceStart 0x28
	.long	20									@ instanceSize	0x28
	.long	0 									@ ivarLayout
	.long	L_OBJC_CLASS_NAME_					@ name
	.long	l_OBJC_$_CLASS_METHODS___ARCLITE__ 	@ baseMethods
	.long	0 									@ baseProtocols
	.long	0 									@ ivars
	.long	0 									@ weakIvarLayout
	.long	0 									@ baseProperties

	.align	3                       
l_OBJC_$_CLASS_METHODS___ARCLITE__:
	.long	12                      @ 0x18
	.long	1                       @ 0x1
	.long	L_OBJC_METH_VAR_NAME_
	.long	L_OBJC_METH_VAR_TYPE_
	.long	"_initialize"



@ 	====================================   @
	.section	__DATA,__objc_data
	.align 3
_OBJC_CLASS_$___ARCLITE__:
	.long	_OBJC_METACLASS_$___ARCLITE__ 	@ metaclass
	.long	0								@ superclass
	.long	0								@ cache
	.long	0								@ vtable
	.long	l_OBJC_CLASS_RO_$___ARCLITE__	@ data


	.section	__DATA,__objc_data
	.align	3
_OBJC_METACLASS_$___ARCLITE__:
	.long	_OBJC_METACLASS_$___ARCLITE__ 		@ isa
	.long	_OBJC_CLASS_$___ARCLITE__			@ superclass
	.long	__objc_empty_cache					@ cache
	.long	0									@ vtable
	.long 	l_OBJC_METACLASS_RO_$___ARCLITE__	@ data


	.section	__DATA,__objc_nlclslist,regular,no_dead_strip
	.align	3
L_OBJC_LABEL_NONLAZY_CLASS_$:
	.long	_OBJC_CLASS_$___ARCLITE__

#endif