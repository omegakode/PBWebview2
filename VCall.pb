; VCall (Variadic Call) module by Wilbert

; Last updated : November 26, 2019

DeclareModule VCall
 
  ; A cross platform module to make calls to variadic functions
 
  ; VCall  (*Function, *Arguments, *Types)
  ; VCallQ (*Function, *Arguments, *Types)
  ; VCallF (*Function, *Arguments, *Types)
  ; VCallD (*Function, *Arguments, *Types)
 
  ; *Function  : a pointer to the function to call
  ; *Arguments : an array of VCArgument elements
  ; *Types     : a pointer to a null terminated string of types
 
  ; Possible types are "i", "q", "f" and "d"
 
  ; For 64 bit macOS and Linux there are two additional types :
  ; "m" moves the argument to the stack even if a register is free
  ; "r" requires a pointer to a VCReturn structure which will be
  ; filled after the call has been made.
  ; Both of these types are useful for passing structures.
 
  Structure VCArgument
    StructureUnion
      i.i
      q.q
      f.f
      d.d
    EndStructureUnion
  EndStructure
 
  Structure VCReturn
    rax.i
    rdx.i
    xmm0.d
    xmm1.d
  EndStructure
 
  PrototypeC.i VCall  (*Function, *Arguments, *Types)
  PrototypeC.q VCallQ (*Function, *Arguments, *Types)
  PrototypeC.f VCallF (*Function, *Arguments, *Types)
  PrototypeC.d VCallD (*Function, *Arguments, *Types)
 
  Global VCall.VCall, VCallQ.VCallQ
  Global VCallF.VCallF, VCallD.VCallD
 
EndDeclareModule

Module VCall
 
  DisableDebugger
  EnableExplicit
 
  ;->> Procedures <<
 
  Procedure _VCall()
    CompilerIf #PB_Compiler_Unicode
      !.cSize equ 2
    CompilerElse
      !.cSize equ 1
    CompilerEndIf
    !jmp .ret_proc_addr
    !align 8
    !.proc_start:
    ;->> VCall procedure start <<
   
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      ; ->> x86 Cross platform <<
      !push ebp
      !mov ebp, esp
      !push esi
      !push edi
      ; Get length of types string
      !mov edx, [ebp + 16]
      !mov ecx, -1
      !.l0:
      !add ecx, 1
      !cmp byte [edx + ecx*.cSize], 0
      !jne .l0
      ; Adjust stack
      !lea ecx, [ecx*8]
      !sub esp, ecx
      !and esp, -16
      ; Copy arguments
      !mov esi, [ebp + 12]
      !mov edi, esp
      !.l1:
      !movzx eax, byte [edx]  ; get type
      !add edx, .cSize
      !cmp eax, 'i'
      !je .l3
      !cmp eax, 'f'
      !je .l3
      !cmp eax, 'd'
      !je .l2
      !cmp eax, 'q'
      !jne .l4
      !.l2:
      !mov eax, [esi]         ; copy double or quad
      !mov ecx, [esi + 4]
      !mov [edi], eax
      !mov [edi + 4], ecx
      !add esi, 8
      !add edi, 8
      !jmp .l1
      !.l3:
      !mov eax, [esi]         ; copy other types
      !mov [edi], eax
      !add esi, 8
      !add edi, 4
      !jmp .l1     
      ; Call function pointer   
      !.l4:
      !call dword [ebp + 8]   
      ; Restore stack
      !lea esp, [ebp - 8]
      !pop edi
      !pop esi
      !pop ebp
      !ret     
    CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
      ; ->> x64 Windows <<     
      !push rbp
      !mov rbp, rsp
      ; r11 = *Function
      !mov r11, rcx
      ; Get length of types string
      !mov ecx, -1
      !.l0:
      !add ecx, 1
      !cmp byte [r8 + rcx*.cSize], 0
      !jne .l0
      ; Adjust stack
      !lea ecx, [ecx*8 + 32]
      !sub rsp, rcx
      !and rsp, -16
      ; Copy arguments
      !mov r9, rsp
      !.l1:
      !movzx eax, byte [r8]   ; get type
      !add r8, .cSize
      !cmp eax, 'i'
      !je .l2
      !cmp eax, 'd'
      !je .l2
      !cmp eax, 'q'
      !je .l2
      !cmp eax, 'f'
      !jne .l3
      !movd xmm0, [rdx]       ; copy float
      !movq [r9], xmm0
      !add rdx, 8
      !add r9, 8
      !jmp .l1
      !.l2:
      !mov rax, [rdx]         ; copy other types
      !mov [r9], rax
      !add rdx, 8
      !add r9, 8
      !jmp .l1
      ; Load registers
      !.l3:
      !mov r9,  [rsp + 24]
      !mov r8,  [rsp + 16]
      !mov rdx, [rsp + 8]
      !mov rcx, [rsp]
      !movq xmm3, r9
      !movq xmm2, r8
      !movq xmm1, rdx
      !movq xmm0, rcx
      ; Call function pointer   
      !call r11
      ; Restore stack
      !mov rsp, rbp
      !pop rbp
      !ret
    CompilerElse
      ; ->> x64 macOS, Linux <<
      !push rbp
      !mov rbp, rsp
      ; r11 = *Function
      !mov r11, rdi
      ; Get length of types string
      !mov ecx, -1
      !.l0:
      !add ecx, 1
      !cmp byte [rdx + rcx*.cSize], 0
      !jne .l0
      ; Adjust stack
      !lea ecx, [ecx*8 + 128]
      !sub rsp, rcx
      !and rsp, -16
      ; Copy arguments
      !xor ecx, ecx
      !mov [rbp - 128], rcx   ; clear struct return
      !mov [rbp - 120], rcx   ; clear reg counters
      !mov rdi, rsp
      !.l1:
      !movzx eax, byte [rdx]  ; get type
      !add rdx, .cSize
      !cmp eax, 'i'
      !je .l6
      !cmp eax, 'd'
      !je .l3
      !cmp eax, 'q'
      !je .l6
      !cmp eax, 'f'
      !je .l2
      !cmp eax, 'm'
      !je .l8
      !cmp eax, 'r'
      !jne .l9
      !mov rax, [rsi]         ; set struct return
      !add rsi, 8
      !mov [rbp - 128], rax
      !jmp .l1
      !.l2:
      !movd xmm0, [rsi]       ; copy float
      !jmp .l4
      !.l3:
      !movq xmm0, [rsi]       ; copy double
      !.l4:
      !add rsi, 8
      !mov ecx, [rbp - 116]   ; fp reg count
      !cmp ecx, 8             ; >= 8 ?
      !jae .l5
      !movq [rbp - 112 + rcx*8], xmm0
      !add ecx, 1
      !mov [rbp - 116], ecx   ; fp reg count
      !jmp .l1
      !.l5:
      !movq [rdi], xmm0       ; to stack
      !add rdi, 8
      !jmp .l1
      !.l6:
      !mov rax, [rsi]         ; copy other types
      !add rsi, 8
      !mov ecx, [rbp - 120]   ; gp reg count     
      !cmp ecx, 6             ; >= 6 ?
      !jae .l7
      !mov [rbp - 48 + rcx*8], rax
      !add ecx, 1
      !mov [rbp - 120], ecx   ; gp reg count
      !jmp .l1
      !.l7:
      !mov [rdi], rax         ; to stack
      !add rdi, 8
      !jmp .l1
      !.l8:
      !mov rax, [rsi]
      !add rsi, 8
      !jmp .l7
      ; Load registers
      !.l9:
      !mov eax, [rbp - 116]
      !and eax, 0xff
      !jz .l10
      !movq xmm0, [rbp - 112]
      !movq xmm1, [rbp - 104]
      !movq xmm2, [rbp - 96]
      !movq xmm3, [rbp - 88]
      !movq xmm4, [rbp - 80]
      !movq xmm5, [rbp - 72]
      !movq xmm6, [rbp - 64]
      !movq xmm7, [rbp - 56]
      !.l10:
      !mov rdi, [rbp - 48]
      !mov rsi, [rbp - 40]
      !mov rdx, [rbp - 32]
      !mov rcx, [rbp - 24]
      !mov r8, [rbp - 16]
      !mov r9, [rbp - 8]
      ; Call function pointer   
      !call r11
      ; Struct return
      !mov rdi, [rbp - 128]
      !and rdi, rdi
      !jz .l11
      !mov [rdi], rax
      !mov [rdi + 8], rdx
      !movq [rdi + 16], xmm0
      !movq [rdi + 24], xmm1
      ; Restore stack
      !.l11:
      !mov rsp, rbp
      !pop rbp
      !ret   
    CompilerEndIf
   
    ;->> VCall procedure end <<
    !.ret_proc_addr:
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !lea eax, [.proc_start]
    CompilerElse
      !lea rax, [.proc_start]
    CompilerEndIf
    ProcedureReturn
  EndProcedure
 
  ;->> Prototype assignments <<
 
  VCall  = _VCall() 
  VCallQ = _VCall() 
  VCallF = _VCall() 
  VCallD = _VCall() 
 
EndModule
