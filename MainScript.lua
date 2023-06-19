-- Devices 
-- Usr Inp
CW_PMP_VFD1 = 1 -- CW_PMP_VFD2 = 2 CW_PMP_VFD3 = 3 
-- ChW_PMP_VFD1 = 4 ChW_PMP_VFD2 = 5 ChW_PMP_VFD3 = 6
-- CT_FN_VFD1 = 7 CT_FN_VFD2 = 8
-- CHILLER = 13
--End Usr Inp

-- Device structure
Write = 1 Stat = 2 Keys = 3
Set1 = 4 Set2 = 5 ALARM = 6

-- VFD Action Command
VFD_RUN_OFF = 4 VFD_RUN_ON = 1 NO_FAULT = 0 VFD_ON_REV = 2
SET1_CMD = 2  SET2_CMD = 4

-- Types of values
NO_DATA = -1 OFF = 0 ON = 1 -- RPC buffer values
WRITE_SUCCESS = 1 VERIFY_FAIL = 3 -- Modbus write status

--Device tables & LBI inputs
-- Usr Inp --
--VFD = {}
--VFD[Write] = {[CW_PMP_VFD1] = 2, [CW_PMP_VFD2] = 7, [CW_PMP_VFD3] = 12, [ChW_PMP_VFD1] = 17, [ChW_PMP_VFD2] = 22, [ChW_PMP_VFD3] = 27, [CT_FN_VFD1] = 32, [CT_FN_VFD2] = 37} -- VFD Write Lua variables
--VFD[Stat] = {[CW_PMP_VFD1] = 1, [CW_PMP_VFD2] = 6, [CW_PMP_VFD3] = 11, [ChW_PMP_VFD1] = 16, [ChW_PMP_VFD2] = 21, [ChW_PMP_VFD3] = 26, [CT_FN_VFD1] = 31, [CT_FN_VFD2] = 36} -- VFD Stat Read Lua variables
--VFD[Keys] = {[CW_PMP_VFD1] = "CW PMP VFD1", [CW_PMP_VFD2] = "CW PMP VFD2", [CW_PMP_VFD3] = "CW PMP VFD3", [ChW_PMP_VFD1] = "ChW PMP VFD1", [ChW_PMP_VFD2] = "ChW PMP VFD2", [ChW_PMP_VFD3] = "ChW PMP VFD3", [CT_FN_VFD1] = "CT FN VFD1", [CT_FN_VFD2] = "CT FN VFD2"}
--VFD[Set1] = {[CW_PMP_VFD1] = 4, [CW_PMP_VFD2] = 9, [CW_PMP_VFD3] = 14, [ChW_PMP_VFD1] = 19, [ChW_PMP_VFD2] = 24, [ChW_PMP_VFD3] = 29, [CT_FN_VFD1] = 34, [CT_FN_VFD2] = 39} 
--VFD[Set2] = {[CW_PMP_VFD1] = 5, [CW_PMP_VFD2] = 10, [CW_PMP_VFD3] = 15, [ChW_PMP_VFD1] = 20, [ChW_PMP_VFD2] = 25, [ChW_PMP_VFD3] = 30, [CT_FN_VFD1] = 35, [CT_FN_VFD2] = 40}
--VFD[ALARM] = {[CW_PMP_VFD1] = 41, [CW_PMP_VFD2] = 42, [CW_PMP_VFD3] = 43, [ChW_PMP_VFD1] = 44, [ChW_PMP_VFD2] = 45, [ChW_PMP_VFD3] = 46, [CT_FN_VFD1] = 47, [CT_FN_VFD2] = 48}
VFD = {}
VFD[Write] = {[CW_PMP_VFD1] = 3} -- VFD Write Lua variables
VFD[Stat] = {[CW_PMP_VFD1] = 1} -- VFD Stat Read Lua variables
VFD[Keys] = {[CW_PMP_VFD1] = "CW PMP VFD1"}
VFD[Set1] = {[CW_PMP_VFD1] = 5} 
VFD[Set2] = {[CW_PMP_VFD1] = 6}
VFD[ALARM] = {[CW_PMP_VFD1] = 2}

--CHLR = {}
--CHLR[Write] = {[CHILLER] = 59}
--CHLR[Stat] = {[CHILLER] = 58}
--CHLR[Keys] = {[CHILLER] = "Chiller"}

-- RPC & LBI inputs
RPC_ID = {}
--RPC_ID = {[CW_PMP_VFD1] = 60, [CW_PMP_VFD2] = 61, [CW_PMP_VFD3] = 62, [ChW_PMP_VFD1] = 63, [ChW_PMP_VFD2] = 64, [ChW_PMP_VFD3] = 65, [CT_FN_VFD1] = 66, [CT_FN_VFD2] = 67, [CHILLER] = 72}
RPC_ID = {[CW_PMP_VFD1] = 7}

-- FB Delay time
FB_TYM = 8000 
-- End Usr Inp --

-- RPC values
RPC_CM = 0  RPC_VAL = 0  RPC_TRIG = false 

STATE_IDX = 0
STATE_NEW = 1

Curr_MS = 0

SHED_FLG = 0  SHED_ID = 0

-- Command Seq Var
Cmd_Cnt = 0
Seq_Set = 0 

-- Auto Schedule
ON1_TYM = 1
OFF1_TYM = 2

-- Initializations of equipment
do
    delay(5000)

    print("Starting int")
    VFD_init(VFD) -- VFD init

    delay(15000)
end


-- Main while loop
while true do
    print("Script version: From computer-1")

 ----   RPC_Cntrl()

 --   Act_Com()
    
    Disp_Dev(VFD, Stat, "VFD_Stat")
    Disp_Dev(VFD, ALARM, "VFD_Alrm")

    --Start_ChlrSys_Seq(1, "05:00:00")
    --Start_Chiller_Sys(1, "04:44:00")
    --Stop_Chiller_Sys(2, "04:48:00")

    local Shd = Check_Shedule()
    print("Shed Stat = "..Shd)

    --AutoShed(1, Shd, ON1_TYM, Start_ChlrSys_Logic)
    --AutoShed(2, Shd, OFF1_TYM, Stop_ChlrSys_Logic)

    if Script_Restart() then break end

    delay(1000)
end