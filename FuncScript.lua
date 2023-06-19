--- RPC Control Functions
function RPC_Cntrl ()
    local d = -1
--    for i = 1, #RPC_ID do
    for i, ve in pairs(RPC_ID) do
        d = RPC_Cmd(ve)
        if d ~= NO_DATA then
            if RPC_CM ~= i or RPC_VAL ~= d then --If the values are dissimilar
                print("RPC : ".. i .. "-" .. d)
                RPC_CM= i   RPC_VAL = d    RPC_TRIG = true
            end
            
        end
    end 

    if RPC_TRIG == true then

        if(RPC_CM >= 1 and RPC_CM <= 8) then
            CntrlDev(VFD, RPC_CM, RPC_VAL, RPC_VAL, FB_TYM)
        
        elseif(RPC_CM == 13) then
            CntrlDev(CHLR, RPC_CM, RPC_VAL, RPC_VAL, FB_TYM)
--[[        
        elseif(RPC_CM >= 9 and RPC_CM <= 10) then
            CntrlDev(VALVE1, RPC_CM, RPC_VAL, RPC_VAL, FB_TYM)
]]--
        end
        if STATE_NEW == 1 then
            RPC_TRIG = false
        end
    end            
end

---comment Read the status of the selected Devices with explicit names
---@param cluster table Device Table
---@param Stname string Device Naming
function Read_DevStat(cluster, Stname)
    local str = Stname.." : "
    local keys = {}
    for k in pairs(cluster[Stat]) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _,k in ipairs(keys) do
        str = str..Buff_Read(cluster[Stat][k])..","
    end
    print(str)
end

---comment Read the Values blocks of the selected Devices
---@param cluster table Device Table
---@param cluster_blk integer cluster block
---@param Stname string Device Naming
function Disp_Dev(cluster, cluster_blk, Stname)
    local str = Stname.." : "
    local keys = {}
    for k in pairs(cluster[cluster_blk]) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _,k in ipairs(keys) do
        str = str..Buff_Read(cluster[cluster_blk][k])..","
    end
    print(str)
end

---comment Control Func for any device
---@param cluster any Device table
---@param clusterNum integer Selected Device
---@param val integer Write Value
---@param exp_rslt integer Expected result
---@param seq_tym integer Time Value
---@return integer 0 - Inprogress, 1 - Sucess FB, 2 - Fail FB  
function CntrlDev(cluster, clusterNum, val, exp_rslt, seq_tym)  
    local d_flg = 0
    if STATE_NEW == 1 then
        print("Selected : " .. cluster[Keys][clusterNum])        
        local e = Buff_Write_Wait(cluster[Write][clusterNum], val)
        print("Res: ".. e)
        if e == WRITE_SUCCESS then print("Success on Write")
        else print("Failed on Write")
        end
        Curr_MS = millis()
        STATE_NEW = 0
        
    elseif millis() - Curr_MS >= seq_tym then
        local d = 0
        local str_fail = "Failed FB"
        local str_succ = "Success FB"
        d = Buff_Read(cluster[Stat][clusterNum])
        if(d == exp_rslt) then d_flg = 1; print(str_succ) 
        else d_flg = 2; print(str_fail)
        end
        STATE_NEW = 1; print("LBI:"..cluster[Stat][clusterNum]..", d:"..d) 
    end

    return d_flg
end


---comment VFD initial commands for setting
---@param cluster table cluster VFD table
function VFD_init(cluster)
    local e1, e2 = 0, 0 
    for i = 1, #cluster[Set1] do
        local strg = ""
        e1 = Buff_Write_Wait(cluster[Set1][i], SET1_CMD)
        if e1 ~= WRITE_SUCCESS then
            strg = "Fail to set device at LBI "
        else
            strg = "Success to set device at LBI "
        end
        print(strg .. cluster[Set1][i] .. " : " .. SET1_CMD)

        e2 = Buff_Write_Wait(cluster[Set2][i], SET2_CMD)
        if e1 ~= WRITE_SUCCESS then
            strg = "Fail to set device at LBI "
        else
            strg = "Success to set device at LBI "
        end
        print(strg .. cluster[Set2][i] .. " : " .. SET2_CMD)
    end
end

---comment Command Sequence of Device Functions
---@param Cmd_ID integer Cmd ID
---@param func any DevFunction
---@param ... unknown parameters
function Cmd_Seq(Cmd_ID, func, ...)
    local dx = 0
    if(Cmd_Cnt == Cmd_ID) then
        dx = func(...)
        if(dx ~= 0) then Cmd_Cnt = Cmd_Cnt+1 end
    end
end

---comment Command Sequence of Device Functions with next Cmd_ID
---@param Cmd_ID integer Cmd ID
---@param Nxt_CmdID integer Nxt_CmdID 
---@param func any DevFunction
---@param ... unknown parameters
function Cmd_Seq2(Cmd_ID, Nxt_CmdID, func, ...)
    local dx = 0
    if(Cmd_Cnt == Cmd_ID) then
        dx = func(...)
        if(dx ~= 0) then 
            Cmd_Cnt = Nxt_CmdID
        end
    end
end

---comment Device Command execution on a condition
---@param Cmd_ID integer Cmd ID
---@param cmd_Cond any Condition parameter
---@param Cond_rslt any Expected result
---@param Tr_CmdID any Nxt_CmdID if True
---@param Fal_CmdID any Nxt_CmdID if False
---@param func any Function
---@param ... unknown all parameters of the function
function Cmd_CondSeq(Cmd_ID, cmd_Cond, Cond_rslt, Tr_CmdID, Fal_CmdID, func, ...)
    if(Cmd_Cnt == Cmd_ID) then
        if(cmd_Cond == Cond_rslt) then 
            print("CMID:"..Cmd_ID..", Succ, Mov-CMID:"..Tr_CmdID)
            Cmd_Seq2(Cmd_ID, Tr_CmdID, func, ...)
        else 
            Cmd_Cnt = Fal_CmdID
            print("CMID:"..Cmd_ID..", fail, Mov-CMID:"..Fal_CmdID)
        end
    end
end

---comment Command Sequence start, Setting Cmd_Cnt to 1
---@param Seq_No integer Seq No
function Cmd_Start(Seq_No)
    if(Cmd_Cnt == 0) then 
        Seq_Set = Seq_No
        Cmd_Cnt = 1
        print("Start Trig - " .. Seq_Set) 
    end
end

---comment Ending the Sequence
---@param Cmd_ID integer Cmd ID
function Cmd_End(Cmd_ID)
    if(Cmd_Cnt == Cmd_ID) then
        print("End Trig - " .. Seq_Set)
        Seq_Set = 0
        Cmd_Cnt = 0
    end
end

---comment Check if the Seq
---@param Seq_No integer Seq_No
---@return boolean true matching 
function Cmd_SeqCheck(Seq_No)
    return(Seq_No == Seq_Set and true or false)
end

---comment Start Chiller_Sys Function
---@param Seq_No integer Seq_No
---@param Time_st string Time
function Start_ChlrSys_Seq(Seq_No, Time_st)
    local np = Time_Trig(Time_st)
    if(np == true) then Cmd_Start(Seq_No) end     
    if(Cmd_SeqCheck(Seq_No)) then --Start Logic
        Cmd_Seq(1, CntrlDev, VFD, CW_PMP_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_Seq(2, CntrlDev, VFD, CW_PMP_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_Seq(3, CntrlDev, VFD, CW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(4, CntrlDev, VFD, ChW_PMP_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_Seq(5, CntrlDev, VFD, ChW_PMP_VFD2, VFD_RUN_ON, VFD_RUN_ON, 300000)
        --Cmd_Seq(6, CntrlDev, VFD, ChW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Cmd_Seq(7, CntrlDev, CHLR, CHILLER, ON, ON, 600000)

        --Cmd_Seq(8, CntrlDev, VFD, CT_FN_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_Seq(9, CntrlDev, VFD, CT_FN_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        
        Cmd_End(10) -- Sequence end
    end
end

---comment Start Chiller_Sys Logic with Alarm condition
---@param Seq_No integer Seq_No
function Start_ChlrSys_Logic(Seq_No)
    if(Cmd_SeqCheck(Seq_No)) then --Start Logic
        Cmd_CondSeq(1, Buff_Read(VFD[ALARM][ChW_PMP_VFD1]), 0, 2, 2, CntrlDev, VFD, ChW_PMP_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_CondSeq(2, Buff_Read(VFD[ALARM][ChW_PMP_VFD2]), 0, 3, 3, CntrlDev, VFD, ChW_PMP_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_CondSeq(3, Buff_Read(VFD[ALARM][ChW_PMP_VFD3]), 0, 4, 4, CntrlDev, VFD, ChW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Cmd_CondSeq(4, Buff_Read(VFD[ALARM][CW_PMP_VFD1]), 0, 5, 5, CntrlDev, VFD, CW_PMP_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_CondSeq(5, Buff_Read(VFD[ALARM][CW_PMP_VFD2]), 0, 6, 6, CntrlDev, VFD, CW_PMP_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_CondSeq(6, Buff_Read(VFD[ALARM][CW_PMP_VFD3]), 0, 7, 7, CntrlDev, VFD, CW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Cmd_CondSeq(7, Buff_Read(VFD[ALARM][CT_FN_VFD1]), 0, 8, 8, CntrlDev, VFD, CT_FN_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Cmd_CondSeq(8, Buff_Read(VFD[ALARM][CT_FN_VFD2]), 0, 9, 9, CntrlDev, VFD, CT_FN_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        
        --Cmd_Seq(9, CntrlDev, CHLR, CHILLER, ON, ON, FB_TYM)

        Cmd_End(10) -- Sequence end
    end
end

---comment Stopping Chiller_Sys Logic
---@param Seq_No integer Seq_No
function Stop_ChlrSys_Logic(Seq_No)
    if(Cmd_SeqCheck(Seq_No)) then --Start Logic
       -- Cmd_Seq(1, CntrlDev, CHLR, CHILLER, OFF, OFF, 180000)

        Cmd_Seq(2, CntrlDev, VFD, CT_FN_VFD1, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(3, CntrlDev, VFD, CT_FN_VFD2, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)

        --Cmd_Seq(4, CntrlDev, VFD, ChW_PMP_VFD1, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(5, CntrlDev, VFD, ChW_PMP_VFD2, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(6, CntrlDev, VFD, ChW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(7, CntrlDev, VFD, CW_PMP_VFD1, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(8, CntrlDev, VFD, CW_PMP_VFD2, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        --Cmd_Seq(9, CntrlDev, VFD, CW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        Cmd_End(10) -- Sequence end
    end
end

---comment Stop AHU Function
---@param Seq_No integer Seq_No
---@param Time_st string Time
function Stop_Chiller_Sys(Seq_No, Time_st)

    local np = Time_Trig(Time_st)
    if(np == true) then Cmd_Start(Seq_No) end     
    Stop_ChlrSys_Logic(Seq_No)
end

---comment Start AHU Function with Alarm status
---@param Seq_No integer Seq_No
---@param Time_st string Time
function Start_Chiller_Sys(Seq_No, Time_st)
    local np = Time_Trig(Time_st)
    if(np == true) then Cmd_Start(Seq_No) end     
    Start_ChlrSys_Logic(Seq_No)
end

---comment Control Func for any device without Feedback check
---@param cluster any Device table
---@param clusterNum integer Selected Device
---@param val integer Write value
---@param Wrt_ExpRslt integer Expected value
function CntrlDev_NoFB(cluster, clusterNum, val, Wrt_ExpRslt)
    print("Selected : " .. cluster[Keys][clusterNum])        
    local e = Buff_Write_Wait(cluster[Write][clusterNum], val)
    print("Res: ".. e)
    if e == WRITE_SUCCESS then print("Success on Write")
    else print("Failed on Write")
    end    
end

--- Start AHU in Auto Sheduling
---@param Seq_No integer Seq_No
---@param AutStat integer The status
---@param AutCmd integer Expected Cmd
---@param Lg_fnc function Logic function
function AutoShed(Seq_No, AutStat, AutCmd, Lg_fnc)
    if(AutStat == AutCmd) then Cmd_Start(Seq_No) end
    Lg_fnc(Seq_No)
end

---comment Action Command
function Act_Com()
    local Aid = Read_ActCmdID()
    local Aval = Read_ActCmdVal()
    
    print("Com_Act : "..Aid..", "..Aval)
    if(Aid ~= 0) then --If succ/fail read
        Insrt_ActCom(Aid, Aval, 1, 1, CntrlDev, VFD, CW_PMP_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        Insrt_ActCom(Aid, Aval, 1, 0, CntrlDev, VFD, CW_PMP_VFD1, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Insrt_ActCom(Aid, Aval, 2, 1, CntrlDev, VFD, CW_PMP_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
       -- Insrt_ActCom(Aid, Aval, 2, 0, CntrlDev, VFD, CW_PMP_VFD2, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Insrt_ActCom(Aid, Aval, 3, 1, CntrlDev, VFD, CW_PMP_VFD3, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 3, 0, CntrlDev, VFD, CW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Insrt_ActCom(Aid, Aval, 4, 1, CntrlDev, VFD, ChW_PMP_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 4, 0, CntrlDev, VFD, ChW_PMP_VFD1, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
    
        --Insrt_ActCom(Aid, Aval, 5, 1, CntrlDev, VFD, ChW_PMP_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 5, 0, CntrlDev, VFD, ChW_PMP_VFD2, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
    
        --Insrt_ActCom(Aid, Aval, 6, 1, CntrlDev, VFD, ChW_PMP_VFD3, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 6, 0, CntrlDev, VFD, ChW_PMP_VFD3, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
    
        --Insrt_ActCom(Aid, Aval, 7, 1, CntrlDev, VFD, CT_FN_VFD1, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 7, 0, CntrlDev, VFD, CT_FN_VFD1, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
        
        --Insrt_ActCom(Aid, Aval, 8, 1, CntrlDev, VFD, CT_FN_VFD2, VFD_RUN_ON, VFD_RUN_ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 8, 0, CntrlDev, VFD, CT_FN_VFD2, VFD_RUN_OFF, VFD_RUN_OFF, FB_TYM)
    
        --Insrt_ActCom(Aid, Aval, 9, 1, CntrlDev, CHLR, CHILLER, ON, ON, FB_TYM)
        --Insrt_ActCom(Aid, Aval, 9, 0, CntrlDev, CHLR, CHILLER, OFF, OFF, FB_TYM)
    end
end

---comment Insert Action_Cmd
---@param AI integer Act id
---@param AVAL integer Act val
---@param AI_rslt integer Act id exp
---@param AVAL_rslt integer Act val exp
---@param func any DevFunction
---@param ... unknown parameters
function Insrt_ActCom(AI, AVAL, AI_rslt, AVAL_rslt, func, ...)
    if((AI == AI_rslt)and(AVAL == AVAL_rslt)) then
        local rs = func(...)
        if(rs ~= 0) then ActCMD_Reset() end
    end
end