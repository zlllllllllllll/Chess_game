local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

--local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.GameViewLayer")
local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local ScoreControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ScoreControl")
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function GameLayer:ctor(frameEngine, scene)
  	self._scene = scene
self:dismissPopWait()
    GameLayer.super.ctor(self, frameEngine, scene)
end

function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

function GameLayer:ResetVariable()    --原文件中 bool CGameClientEngine::OnInitGameEngine() bool CGameClientEngine::OnResetGameEngine() 相同部分

  --游戏变量
  self.m_wBankerUser= yl.INVALID_CHAIR
  self.m_wCurrentUser= yl.INVALID_CHAIR

  --状态变量
  self.m_bHearStatus=false
  self.m_bWillHearStatus=false

  --堆立变量
  self.m_wHeapHand=0
  self.m_wHeapTail=0
  --	BYTE	m_cbHeapCardInfo[4][2];		--堆牌信息  lua  索引值是以 1 为起始 不是0
  --ZeroMemory(m_cbHeapCardInfo,sizeof(m_cbHeapCardInfo))
  self.m_cbHeapCardInfo=GameLogic:ergodicList(4)

  --托管变量
  self.m_bStustee=false
  self.m_wTimeOutCount =0

  --出牌信息
  self.m_cbOutCardData=0
  self.m_wOutCardUser= yl.INVALID_CHAIR
  --  BYTE		m_cbDiscardCount[GAME_PLAYER];		--丢弃数目
  --	BYTE		m_cbDiscardCard[GAME_PLAYER][55];	--丢弃记录
  --ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard))
  --ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount))   下同
  self.m_cbDiscardCard=GameLogic:ergodicList(cmd.GAME_PLAYER)
  self.m_cbDiscardCount=GameLogic:sizeM(cmd.GAME_PLAYER)


  --组合扑克
  -- BYTE	m_cbWeaveCount[GAME_PLAYER];		--组合数目
  -- tagWeaveItem	m_WeaveItemArray[GAME_PLAYER][MAX_WEAVE];	--组合扑克
  self.m_cbWeaveCount=GameLogic:sizeM(cmd.GAME_PLAYER)
  self.m_WeaveItemArray=GameLogic:ergodicList(cmd.GAME_PLAYER)

  --扑克变量
  self.m_cbLeftCardCount=0
  --BYTE	m_cbCardIndex[MAX_INDEX];			--手中扑克
  self.m_cbCardIndex=GameLogic:sizeM(cmd.MAX_INDEX)
  self.m_bySicboAnimCount = 0
  self.m_sGamePlay={}
  self.m_sGamePlay.byUserDingDi={}
  self.m_sGamePlay.cbCardData=GameLogic:ergodicList(17)

	self.m_cbUserAction=0
end

function GameLayer:OnInitGameEngine()
  GameLayer.super:OnInitGameEngine()
  self:ResetVariable()

  ----------------------------------------------
  --计时器 列表
  self._ClockList={}

	--设置图标
	-- HICON hIcon=LoadIcon(AfxGetInstanceHandle(),MAKEINTRESOURCE(IDR_MAINFRAME));
	-- m_pIClientKernel->SetGameAttribute(KIND_ID,GAME_PLAYER,VERSION_CLIENT,hIcon,GAME_NAME);
	-- SetIcon(hIcon,TRUE);
	-- SetIcon(hIcon,FALSE);

	--加载资源
	-- g_CardResource.LoadResource();
  self.g_CardResource=CardControl:create_CCardResource(self)
	self.g_CardResource:LoadResource(self)

  --打开注册表
  --xxxxxxx m_bChineseVoice=true 估计无用

	-- CGlobalUnits *pGlobalUnits=CGlobalUnits::GetInstance();
	-- IGameFrameWnd * pIGameFrameWnd=(IGameFrameWnd *)pGlobalUnits->QueryGlobalModule(MODULE_GAME_FRAME_WND,IID_IGameFrameWnd,VER_IGameFrameWnd);
	-- if(pIGameFrameWnd)pIGameFrameWnd->RestoreWindow();
print("GetMeChairID",self:GetMeChairID())
	print("Hello Hello!")
end

function GameLayer:OnResetGameEngine()
print("GameLayer:OnResetGameEngin")
  GameLayer.super:OnResetGameEngine(self)
  --self._gameView:onResetData()   未确定需要

  self:ResetVariable()

  --KillGameClock(IDI_START_GAME);
  self:KillGameClock(cmd.IDI_START_GAME)

	--m_GameClientView.m_btStart.ShowWindow(SW_HIDE);
	self._gameView.m_btStart:setVisible(false)
	self._gameView.m_ControlWnd:setVisible(false)
  --mark
	ScoreControl:RestorationData()

	--设置界面
	self._gameView:SetDiscUser(yl.INVALID_CHAIR)
	self._gameView:SetHuangZhuang(false)
	self._gameView:SetStatusFlag(false,false)
	self._gameView:SetBankerUser(yl.INVALID_CHAIR)
	self._gameView:SetUserAction(yl.INVALID_CHAIR,0)
	self._gameView:SetOutCardInfo(yl.INVALID_CHAIR,0)
	self._gameView:SetUserListenStatus(yl.INVALID_CHAIR,false)

	--扑克设置
	self._gameView.m_UserCard[1]:SetCardData(0,false)        --  mark 多个相同的子类 下同
	self._gameView.m_UserCard[2]:SetCardData(0,false)
	self._gameView.m_HandCardControl:SetCardData(NULL,0,0)
	self._gameView:SetGodsCard( 0x00 )
	self._gameView.m_HandCardControl:SetGodsCard( 0x00 )
	self._gameView:SetDingMaiValue(NULL)


	--扑克设置
  for i=1,cmd.GAME_PLAYER,1 do
		self._gameView.m_TableCard[i]:SetCardData(NULL,0)
		self._gameView.m_DiscardCard[i]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][1]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][2]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][3]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][4]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][5]:SetCardData(NULL,0)
  end

	--堆立扑克
  for i=1,4,1 do
		self.m_cbHeapCardInfo[i][1]=0
		self.m_cbHeapCardInfo[i][2]=0
		self._gameView.m_HeapCard[i]:SetGodsCard( 0x00, 0x00, 0x00)
print("== 堆立扑克11 SetCardData")
print(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
		self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
  end

  --self:ResetVariable()
end

--SetTimer  to self._gameView:OnTimer()
function GameLayer:F_GVSetTimer(id,time)
  if self._gameView._GVSetTimer==nil then  self._gameView._GVSetTimer={}  end
  self._gameView._GVSetTimer[id] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
          if self._gameView~=nil and self._gameView.OnTimer then self._gameView:OnTimer(id)  else print("self._gameView.OnTimer is nil") end
      end, time, false)
end

function GameLayer:F_GVKillTimer(id)
	if self._gameView and self._gameView._GVSetTimer and nil ~= self._gameView._GVSetTimer[id] then
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._gameView._GVSetTimer[id])
    self._gameView._GVSetTimer[id] = nil
	end
end

-- 设置计时器   多ID
function GameLayer:SetGameClock(Fid,chair,id,time)
		--GameLayer.super:SetGameClock(chair,id,time)
    --GameLayer.super.SetGameClock(self,chair,id,time)
    -- self._ClockList[Fid]={}
    -- if not self._ClockList[Fid]._ClockFun then
    --     local this = self
    --   self._ClockList[Fid]._ClockFun = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
    --             this:OnClockUpdata(Fid)
    --         end, 1, false)
    -- end
    -- self._ClockList[Fid]._ClockChair = chair
    -- self._ClockList[Fid]._ClockID = id
    -- self._ClockList[Fid]._ClockTime = time
    -- self._ClockList[Fid]._ClockViewChair = self:SwitchViewChairID(chair)
    -- self:OnUpdataClockView(Fid)
print("==SetGameClock",chair,id,time)
    if not self._ClockFun then
        local this = self
				self._ClockFun = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
							if this.OnClockUpdata then this:OnClockUpdata()	else print("SetGameClock  this OnClockUpdata is nil  self._ClockFun",self._ClockFun) end
            end, 1, false)
    end
    self._ClockChair = chair
    self._ClockID = id
    self._ClockTime = time 
    self._ClockViewChair = self:SwitchViewChairID(chair)
    self:OnUpdataClockView()
print("==SetGameClock self._ClockFun self._ClockTime",self._ClockFun,self._ClockTime)
end
--[[
function GameLayer:GetClockViewID()
    return self._ClockViewChair --ViewChair
end
--]]
-- 关闭计时器   多ID
function GameLayer:KillGameClock(Fid,notView)
    print("KillGameClock self._ClockFun self._ClockTime",self._ClockFun,Fid,self._ClockTime,notView)
		GameLayer.super:KillGameClock(notView)
-- print("KillGameClock",Fid,notView)
-- dump(self._ClockList,"self._ClockList",6)
--     self._ClockList[Fid]._ClockID = yl.INVALID_ITEM
--     self._ClockList[Fid]._ClockTime = 0
--     self._ClockList[Fid]._ClockChair = yl.INVALID_CHAIR
--     self._ClockList[Fid]._ClockViewChair = yl.INVALID_CHAIR
--     if self._ClockList[Fid]._ClockFun then
--         --注销时钟
--         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ClockList[Fid]._ClockFun)
--         self._ClockList[Fid]._ClockFun = nil
--     end
--     if not notView then
--         self:OnUpdataClockView(Fid)
--     end

    self._ClockID = yl.INVALID_ITEM
    self._ClockTime = 0
    self._ClockChair = yl.INVALID_CHAIR
    self._ClockViewChair = yl.INVALID_CHAIR
    if self._ClockFun then
        --注销时钟
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ClockFun) 
        self._ClockFun = nil
    end
    if not notView then
        self:OnUpdataClockView(100001)
    end
end

--计时器更新 多ID
function GameLayer:OnClockUpdata(Fid)
print("计时器更新 OnClockUpdata Fid",Fid)
    if  self._ClockID ~= yl.INVALID_ITEM then
        self._ClockTime = self._ClockTime - 1
				local result = self:OnEventGameClockInfo(self._ClockChair,self._ClockTime,self._ClockID)
        if result == true   or self._ClockTime < 1 then
            self:KillGameClock(Fid)
        end
    end
    self:OnUpdataClockView(Fid)
    -- if  self._ClockList[Fid]._ClockID ~= yl.INVALID_ITEM then
    --     self._ClockList[Fid]._ClockTime = self._ClockList[Fid]._ClockTime - 1
    --     local result = self:OnEventGameClockInfo(self._ClockList[Fid]._ClockChair,self._ClockList[Fid]._ClockTime,self._ClockList[Fid]._ClockID)
    --     if result == true   or self._ClockList[Fid]._ClockTime < 1 then
    --         self:KillGameClock(Fid)
    --     end
    -- end
    -- self:OnUpdataClockView(Fid)
end

--更新计时器显示 多ID
-- function GameLayer:OnUpdataClockView(Fid)
--     if self._gameView and self._gameView.OnUpdataClockView then
--         self._gameView:OnUpdataClockView(self._ClockViewChair,self._ClockTime)
--     end
--     -- if self._gameView and self._gameView.OnUpdataClockView then
--     --     self._gameView:OnUpdataClockView(self._ClockList[Fid]._ClockViewChair,self._ClockList[Fid]._ClockTime)
--     -- end
-- end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 退出桌子
function GameLayer:onExitTable()
 	print("===GameLayer:onExitTable")
    self:stopAllActions()
    self:KillGameClock()


    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        local wait = self._gameFrame:StandUp(1)
        if wait then
            self:showPopWait()
            return
        end
    end
    self:dismissPopWait()
    self._scene:onKeyBack()
end

--退出桌子
-- function GameLayer:onExitTable()

-- 	local MeItem = self:GetMeUserItem()
-- 	if MeItem and MeItem.cbUserStatus > yl.US_FREE then
-- 			self:runAction(cc.Sequence:create(
-- 					cc.DelayTime:create(2),
-- 					cc.CallFunc:create(
-- 							function ()   
-- 									self._gameFrame:StandUp(1)
-- 							end
-- 							),
-- 					cc.DelayTime:create(10),
-- 					cc.CallFunc:create(
-- 							function ()
-- 									--强制离开游戏(针对长时间收不到服务器消息的情况)
-- 									print("delay leave")
-- 									--self:onExitRoom()
-- 							end
-- 							)
-- 					)
-- 			)
-- 			return
-- 	end

--   self:onExitRoom()
--  end

 function GameLayer:onExitRoom()
 print("===GameLayer:onExitRoom")
    self._gameFrame:onCloseSocket()
    self:stopAllActions()
--     --mark
    self:KillGameClock()
    self:dismissPopWait()
		for k, v in pairs(self._ClockList) do
print("onExitRoom KillGameClock",k,v)
    	self:KillGameClock(k)
    end
    self._scene:onChangeShowMode(yl.SCENE_ROOMLIST)
    --self._scene:onKeyBack()
 end

--显示等待
function GameLayer:showPopWait()
    if self._scene and self._scene.showPopWait then
        self._scene:showPopWait()
    end
end

--关闭等待
function GameLayer:dismissPopWait()
    if self._scene and self._scene.dismissPopWait then
        self._scene:dismissPopWait()
    end
end

-- 椅子号转视图位置,注意椅子号从0~nChairCount-1,返回的视图位置从1~nChairCount
--[[
function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    local nChairCount = self._gameFrame:GetChairCount()
    nChairCount = cmd.GAME_PLAYER
    local nChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < nChairCount then
        viewid = math.mod(chair + math.floor(nChairCount * 3/2) - nChairID, nChairCount) + 1
    end
    return viewid
end
--]]

function GameLayer:getRoomHostViewId()
	return self.wRoomHostViewId
end

function GameLayer:getUserInfoByChairID(chairId)
	local viewId = self:SwitchViewChairID(chairId)
	return self._gameView.m_sparrowUserItem[viewId]
end

function GameLayer:getMaCount()
	print("返回码数", self.cbMaCount)
	return self.cbMaCount
end

function GameLayer:onGetSitUserNum()
	local num = 0
	for i = 1, cmd.GAME_PLAYER do
		if nil ~= self._gameView.m_sparrowUserItem[i] then
			num = num + 1
		end
	end

    return num
end

function GameLayer:onEnterTransitionFinish()
    --self._scene:createVoiceBtn(cc.p(1250, 300))
    GameLayer.super:onEnterTransitionFinish(self)
end

-- room中 刷新所有桌子
-- function GameLayer:upDataTableStatus(wTableID)
-- end

--用户状态
function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    print("change user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    if newstatus.cbUserStatus == yl.US_FREE or newstatus.cbUserStatus == yl.US_NULL then
      if (oldstatus.wTableID ~= self:GetMeUserItem().wTableID) then return end
         self._gameView:deleteUserInfo(useritem)
         print("删除")
    else        
			--刷新用户信息
			if useritem == self:GetMeUserItem() then return end
			self._gameView:showUserInfo(useritem)
			self._otherNick = useritem.szNickName
			if newstatus.cbUserStatus == yl.US_READY then
					self._gameView:showReady(1)
			end
    end 
end       
    
-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
print("OnEventGameClockInfo",chair,time,clockId)
  local switch = {
			[cmd.IDI_START_GAME] = function(chair,time,clockId)    --开始游戏 开始定时器
					if self._gameView.DrawUserTimerEx then
						self._gameView:DrawUserTimerEx(pDC,yl.WIDTH/2,yl.HEIGHT/2,time)
					end
					if time>0 then
    				--AfxGetMainWnd()->PostMessage(WM_CLOSE);   --mark
      			--self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊，如果有的话
    				return false
          end
          if time<=5 then
    					--PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
          		self:PlaySound(cmd.RES_PATH.."mahjong/GAME_WARN.wav")
          end
  				return true
  		end,
  		[cmd.IDI_DINGDI_CARD] = function(chair,time,clockId)    --
          --[[   一律返回false 不许旁观
      			if (IsLookonMode())
      			{
      				return true;
      			}
          --]]
					local wMeChairID=self:GetMeChairID()
					if self.m_wCurrentUser == wMeChairID and 0 == time  then
    				self:OnDingDi(1, 0)
    				return true
					end

					if time<=3 and chair==wMeChairID then
            --PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
            self:PlaySound(cmd.RES_PATH.."mahjong/GAME_WARN.wav")
					end
    			return true
  		end,
			[cmd.IDI_OPERATE_CARD] = function(chair,time,clockId)    --操作定时器

					--自动出牌
	print("====self.m_bHearStatus",self.m_bHearStatus,self._gameView.m_ControlWnd:isVisible(),self.m_bStustee,self.m_wTimeOutCount)
    			local bAutoOutCard=self.m_bHearStatus
          if (bAutoOutCard==true) and self._gameView.m_ControlWnd:isVisible() then
            bAutoOutCard=false
          end
          if (bAutoOutCard==false) and (self.m_bStustee==true) then
    				bAutoOutCard=true
          end

    			--超时判断
          --if (IsLookonMode()==false) and ((time==0) or (bAutoOutCard==true)) then   一律返回false 不许旁观
          if (time==0) or (bAutoOutCard==true) then
            --获取位置
		        local wMeChairID=self:GetMeChairID()

            --动作处理
            if chair==wMeChairID then

              self.m_wTimeOutCount=self.m_wTimeOutCount+1
              if self.m_bStustee==false and self.m_bHearStatus==false and self.m_wTimeOutCount>=3 then
                self.m_wTimeOutCount=0
    						self:OnStusteeControl(0,0)
								--m_pIStringMessage->InsertSystemString(TEXT("由于您多次超时，切换为“系统托管”模式.")); -mark
								print("由于您多次超时，切换为“系统托管”模式.")
              end

              if self.m_wCurrentUser==wMeChairID then

                if bit:_and(self.m_cbUserAction, GameLogic.WIK_CHI_HU) then
      							self:OnCardOperate( GameLogic.WIK_CHI_HU,0 )
      							self:KillGameClock(cmd.IDI_OPERATE_CARD)
      							return true
                end

                --先出字牌。
	              local cbCardData=self._gameView.m_HandCardControl:GetMeOutCard()
                if cbCardData~= 0x00 then
    							self:OnOutCard(cbCardData,cbCardData)
                  self:KillGameClock(cmd.IDI_OPERATE_CARD)
    							return true
                else
                  self:KillGameClock(cmd.IDI_OPERATE_CARD)
                  if self.m_bStustee then
                    self:OnStusteeControl(0,0)
                  end
                	self:SetGameClock(cmd.IDI_OPERATE_CARD, self:GetMeChairID(), cmd.IDI_OPERATE_CARD, cmd.TIME_OPERATE_CARD)
                  --取消托管
                  return true
                end

                local cbGods=self._gameView:GetGodsCard()
                local iGodsIndex=GameLogic:SwitchToCardIndex(cbGods)
                for i=27,cmd.MAX_INDEX-1,1 do
                  while true do
                    if self.m_cbCardIndex[i]==0 then break	end
                    if i == iGodsIndex then break	end     --财神不能出
                    if self.m_cbCardIndex[i]==1 then
      								cbCardData=GameLogic:SwitchToCardData(i)
      								self:OnOutCard(cbCardData,cbCardData)
                      self:KillGameClock(cmd.IDI_OPERATE_CARD)
      								return true
                    end
                  break	end
                end

                for i=27,cmd.MAX_INDEX-1,1 do
                  while true do
                    if self.m_cbCardIndex[i]==0 then break	end
                    if i == iGodsIndex then break	end     --财神不能出
                    if self:VerdictOutCard(GameLogic:SwitchToCardData(i))==false then break	end
    								cbCardData=GameLogic:SwitchToCardData(i)
    								self:OnOutCard(cbCardData,cbCardData)
                    self:KillGameClock(cmd.IDI_OPERATE_CARD)
    								return true
                  end
                end


                local cbCardData=self._gameView.m_HandCardControl:GetMeOutCard()
                --出牌效验
                if self:VerdictOutCard(cbCardData)==true then
                  self:OnOutCard(cbCardData,cbCardData)
                  self:KillGameClock(cmd.IDI_OPERATE_CARD)
                  return true
                end

                for i=cmd.MAX_INDEX-1,0,-1 do
                  while true do
                    if self.m_cbCardIndex[i]==0 then break	end
                    if i == iGodsIndex then break	end     --财神不能出
                    if self:VerdictOutCard(GameLogic:SwitchToCardData(i))==false then break	end
    								cbCardData=GameLogic:SwitchToCardData(i)
    								self:OnOutCard(cbCardData,cbCardData)
                    self:KillGameClock(cmd.IDI_OPERATE_CARD)
    								return true
                  end
                end

                for i=1,cmd.MAX_INDEX,1 do
                  while true do
                    --出牌效验
                    if self.m_cbCardIndex[i]==0 then break	end
                    if i == iGodsIndex then break	end     --财神不能出
                    if self:VerdictOutCard(GameLogic:SwitchToCardData(i))==false then break	end
    								cbCardData=GameLogic:SwitchToCardData(i)
    								self:OnOutCard(cbCardData,cbCardData)
                    self:KillGameClock(cmd.IDI_OPERATE_CARD)
    								return true
                  end
                end
    					else
    						self:OnCardOperate(GameLogic.WIK_NULL,0)
              end
            end
            return true

          end

    			--播放声音
          --if (time<=3) and (chair==self:GetMeChairID()) and (IsLookonMode()==false) then  --IsLookonMode  一律返回false 不许旁观
          if (time<=3) and (chair==self:GetMeChairID())  then
              self:PlaySound(cmd.RES_PATH.."mahjong/GAME_WARN.wav")
          end

    			return true
  		end
  }
  -- mark
  if GlobalUserItem.bPrivateRoom then
    return
  end

  local f = switch[clockId]
  if(f) then
  		f(chair,time,clockId)
  else   									-- for case default
  		print "Case default."
  end

  return
end

--旁观状态
function GameLayer:OnEventLookonMode(pData, wDataSize)
	--扑克控制
	--self._gameView.m_HandCardControl:SetDisplayItem(IsAllowLookon()) IsAllowLookon也为false
	self._gameView.m_HandCardControl:SetDisplayItem(false)
	self._gameView:RefreshGameView()
	return true
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
print("onEventGameMessage sub",sub)
    -- body
	if sub == cmd.SUB_S_GAME_START then 					  --游戏开始
		return self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_OUT_CARD then 					--用户出牌
		return self:onSubOutCard(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_CARD then 					--发牌消息
		return self:onSubSendCard(dataBuffer)
	elseif sub == cmd.SUB_S_LISTEN_CARD then 				--听牌处理
		return self:onSubListenCard(dataBuffer)
	elseif sub == cmd.SUB_S_OPERATE_NOTIFY then 		--操作提示
		return self:onSubOperateNotify(dataBuffer)
	elseif sub == cmd.SUB_S_OPERATE_RESULT then 		--操作结果
		return self:onSubOperateResult(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then 	    		--游戏结束
		return self:OnSubGameEnd(dataBuffer)
	elseif sub == cmd.SUB_S_TRUSTEE then 			   		--用户托管
		return self:onSubTrustee(dataBuffer)
	elseif sub == cmd.SUB_S_DINGDI then 			    	--庄家买底
		return self:OnSubDingDi(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_PLAY then 			  	--
		return self:OnSubGamePlay(dataBuffer)
	elseif sub == cmd.SUB_C_CHECK_SUPER then 				--弹出提牌器
		print("弹出提牌器")
    --[[ --mark
		CCardExtractor ret 
		ret.m_pClientDlg = this
		ret.DoModal()
		return true
    --]]

	elseif sub == cmd.SUB_S_HU_CARD then 					   --听牌提示
		return self:onSubListenNotify(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_CONCLUDE then 			--游戏结束
		return self:onSubGameConclude(dataBuffer)
	elseif sub == cmd.SUB_S_RECORD then 				   	--游戏记录
		return self:onSubGameRecord(dataBuffer)
	elseif sub == cmd.SUB_S_SET_BASESCORE then 			--设置基数
		self.lCellScore = dataBuffer:readint()
		return true
	else
	end

	return true
end

--
function GameLayer:OnLookonViewChange(bLookon)
    self._gameView:RefreshGameView()
end

--游戏场景   OnEventSceneMessage
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
  --[[
	self.m_cbGameStatus = cbGameStatus
	self.nGameSceneLimit = self.nGameSceneLimit + 1
	if self.nGameSceneLimit > 1 then
		--限制只进入场景消息一次
		return true
	end
	local wTableId = self:GetMeTableID()
	local wMyChairId = self:GetMeChairID()
	self._gameView:setRoomInfo(wTableId, wMyChairId)
	--初始化用户信息
	for i = 1, cmd.GAME_PLAYER do
		local wViewChairId = self:SwitchViewChairID(i - 1)
		local userItem = self._gameFrame:getTableUserItem(wTableId, i - 1)
		self._gameView:OnUpdateUser(wViewChairId, userItem)
		if userItem then
			self.cbGender[wViewChairId] = userItem.cbGender
			if PriRoom and GlobalUserItem.bPrivateRoom then
				if userItem.dwUserID == PriRoom:getInstance().m_tabPriData.dwTableOwnerUserID then
					self.wRoomHostViewId = wViewChairId
				end
			end
		end
	end
	--]]
print("onEventGameScene cbGameStatus",cbGameStatus)
  if cbGameStatus == cmd.GS_MJ_FREE then              --空闲状态
		print("空闲状态")
		local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)
    self.m_wBankerUser = cmd_data.wBankerUser
		self._gameView:SetBaseScore(cmd_data.lCellScore)
		self._gameView.m_HandCardControl:SetDisplayItem(true)
		--托管设置
    for i=1,cmd.GAME_PLAYER,1 do
		    self._gameView:SetTrustee(self:SwitchViewChairID(i-1),cmd_data.bTrustee[i])
    end

    --设置界面
    for i=1,4,1 do
      self.m_cbHeapCardInfo[i][1]=0
      self.m_cbHeapCardInfo[i][2]=0
print("== 堆立扑克22 SetCardData")
print(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
      self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
    end

    --设置控件
    --if self:IsLookonMode()==false then  一律返回false 不许旁观
    if true then
      self._gameView.m_btStart:setVisible(true) --ShowWindow(SW_SHOW)
      --self._gameView.m_btStart.SetFocus()                                   --=========================！！！！！ 等写完gameview后回来.SetFocus()  mark
      --self._gameView.m_btStusteeControl.EnableWindow(TRUE)                  --=========================！！！！！ 等写完gameview后回来.SetFocus()
      self:SetGameClock(cmd.IDI_START_GAME, self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_START_GAME)
    end
		self._gameView.m_btMaiDi:setVisible(false)
		self._gameView.m_btDingDi:setVisible(false)
		self._gameView.m_btMaiCancel:setVisible(false)
		self._gameView.m_btDingCancel:setVisible(false)

		--丢弃效果
		self._gameView:SetDiscUser(yl.INVALID_CHAIR)
		--m_GameClientView.SetTimer(IDI_DISC_EFFECT,250,NULL);   mark    --回调 CGameClientView::OnTimer
    self:F_GVSetTimer(self._gameView.IDI_DISC_EFFECT,250)

		--更新界面
		self._gameView:RefreshGameView()

    return true
	elseif cbGameStatus == cmd.GS_MJ_MAIDI then         --买庄状态
    local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusMaiDi, dataBuffer)
print("买庄状态 ",self.m_wBankerUser,self:GetMeChairID())
dump(cmd_data,"CMD_S_StatusMaiDi",6)

		--设置数据
    self.m_wBankerUser = cmd_data.wBankerUser
		self._gameView:SetBaseScore(cmd_data.lCellScore)
		self._gameView.m_HandCardControl:SetDisplayItem(true)
		self.m_wCurrentUser = yl.INVALID_CHAIR
    --托管设置
    for i=1,cmd.GAME_PLAYER,1 do
			self._gameView:SetTrustee(self:SwitchViewChairID(i-1),cmd_data.bTrustee[i])
    end

    --设置界面
    for i=1,4,1 do
      self.m_cbHeapCardInfo[i][1]=0
      self.m_cbHeapCardInfo[i][2]=0
print("== 堆立扑克 设置界面 33 SetCardData")
print(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
      self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
    end

		self._gameView.m_btMaiDi:setVisible(false)
		self._gameView.m_btDingDi:setVisible(false)
		self._gameView.m_btMaiCancel:setVisible(false)
		self._gameView.m_btDingCancel:setVisible(false)
		self._gameView.m_btStart:setVisible(false)

    --旁观界面
    --if (IsLookonMode())
    if false then
      --[[
			m_GameClientView.SetHuangZhuang(false);
			m_GameClientView.SetStatusFlag(false,false);
			m_GameClientView.SetUserAction(INVALID_CHAIR,0);
			m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
      --]]
    else
      --TCHAR szMsg[MAX_PATH]; #define MAX_PATH          260 windef.h
      local szMsg={}
      if cmd_data.bBankerMaiDi then
        --庄家显示买庄，取消
        if self.m_wBankerUser==self:GetMeChairID() then
						--_sntprintf(szMsg, sizeof(szMsg),TEXT(""));// TEXT("本盘底数为：%I64d"), pStatusMaiDi->lBaseScore*2);
            szMsg=""
						self._gameView:SetCenterText(szMsg)
						self._gameView.m_btMaiDi:setVisible(true)
						self._gameView.m_btMaiCancel:setVisible(true)
						--self._gameView.m_btMaiDi.EnableWindow(TRUE)       --=========================！！！！！ 等写完gameview后回来.SetFocus()  mark
						--self._gameView.m_btMaiCancel.EnableWindow(TRUE)   --=========================！！！！！ 等写完gameview后回来.SetFocus()
						self.m_wCurrentUser = self.m_wBankerUser;
        else
            --显示等待庄家买底
            local szNickName="庄家"
            if yl.INVALID_CHAIR~=self.m_wBankerUser then
              if nil~=self._gameFrame:getTableUserItem(self:GetMeTableID(),self.m_wBankerUser) then
                --_sntprintf(szNickName, sizeof(szNickName), TEXT("%s"),getTableUserItem(m_wBankerUser)->GetNickName());
                szNickName=self._gameFrame:getTableUserItem(self:GetMeTableID(),self.m_wBankerUser):GetNickName()       -- mark 确定有GetNickName么
              end
            end

            szMsg="等待 "..szNickName.." 买底 ..."
            --[[ mark pStatusMaiDi->lBaseScore*2 是否被注释
						_sntprintf(szMsg, sizeof(szMsg), TEXT("等待 %s 买底 ..."),
							pStatusMaiDi->lBaseScore*2, szNickName);
            --]]
						self._gameView:SetCenterText(szMsg)
        end

					self._gameView:SetCurrentUser(self:SwitchViewChairID(self.m_wBankerUser))
          self:SetGameClock(cmd.IDI_DINGDI_CARD, self.m_wBankerUser, cmd.IDI_DINGDI_CARD, cmd.TIME_OPERATE_CARD)
      else  --庄家已经叫了
        local wMeChair = self:GetMeChairID()
        --设置显示
        if self.m_wBankerUser == wMeChair then
          self._gameView:SetCenterText("等待闲家顶底……")
        else
					local szMsg={0}
          szMsg=""
          self._gameView:SetCenterText(szMsg)
					--if (pStatusMaiDi->bMeDingDi && !IsLookonMode())
          if cmd_data.bMeDingDi then
            --ActiveGameFrame(); mark  下EnableWindow
						self._gameView.m_btDingDi:setVisible(true)
						self._gameView.m_btDingCancel:setVisible(true)
						--self._gameView.m_btDingDi.EnableWindow(TRUE);
						--self._gameView.m_btDingCancel.EnableWindow(TRUE);
						self.m_wCurrentUser = wMeChair
          end
        end

				self._gameView:SetCurrentUser(self:SwitchViewChairID(wMeChair))
        self:SetGameClock(cmd.IDI_DINGDI_CARD, wMeChair, cmd.IDI_DINGDI_CARD, cmd.TIME_OPERATE_CARD)
      end
    end
	elseif cbGameStatus == cmd.GS_MJ_PLAY then          --游戏状态
		print("游戏状态")
		local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
		dump(cmd_data,"CMD_S_StatusPlay",6)

    --设置变量
    self.m_wBankerUser=cmd_data.wBankerUser
    self.m_wCurrentUser=cmd_data.wCurrentUser
    self.m_cbLeftCardCount=cmd_data.cbLeftCardCount
    self.m_bStustee=cmd_data.bTrustee[self:GetMeChairID()]
    self._gameView.m_btMaiDi:setVisible(false)
    self._gameView.m_btDingDi:setVisible(false)
    self._gameView.m_btMaiCancel:setVisible(false)
    self._gameView.m_btDingCancel:setVisible(false)
    local byUserDingDi={}

    --托管设置
    for i=1,cmd.GAME_PLAYER,1 do
      local wChairID = self:SwitchViewChairID(i-1)
      byUserDingDi[wChairID] = cmd_data.byDingDi[1][i]
      self._gameView:SetTrustee(wChairID,cmd_data.bTrustee[i])
    end

		GameLogic:SetGodsCard(cmd_data.byGodsCardData)
		self._gameView.m_HandCardControl:SetGodsCard(cmd_data.byGodsCardData)
		self._gameView:SetDingMaiValue(byUserDingDi)
		self._gameView:SetGodsCard(cmd_data.byGodsCardData)

    --旁观
		--[[
    	if( IsLookonMode()==true )
				m_GameClientView.m_HandCardControl.SetDisplayItem(IsAllowLookon());
    --]]
    self.m_wTimeOutCount=0
    if cmd_data.bTrustee[self:GetMeChairID()] then         --=========================！！！！！  mark 待完成界面后修改
    	--self._gameView.m_btStusteeControl.SetButtonImage(IDB_BT_STOP_TRUSTEE,AfxGetInstanceHandle(),false,false);
    else
    	--self._gameView.m_btStusteeControl.SetButtonImage(IDB_BT_START_TRUSTEE,AfxGetInstanceHandle(),false,false);
    end

    --听牌状态
    local wMeChairID=self:GetMeChairID()
    self.m_bHearStatus=(cmd_data.cbHearStatus[wMeChairID]==TRUE) and true or false

    --历史变量
    self.m_wOutCardUser=cmd_data.wOutCardUser
    self.m_cbOutCardData=cmd_data.cbOutCardData
    self.m_cbDiscardCard=GameLogic:deepcopy(cmd_data.cbDiscardCard)
    self.m_cbDiscardCount=GameLogic:deepcopy(cmd_data.cbDiscardCount[1])

    --丢弃效果
    if self.m_wOutCardUser~= yl.INVALID_CHAIR then
      self._gameView:SetDiscUser(self:SwitchViewChairID(self.m_wOutCardUser))
    end
    self:F_GVSetTimer(self._gameView.IDI_DISC_EFFECT,250)

    --扑克变量
    self.m_cbWeaveCount=GameLogic:deepcopy(cmd_data.cbWeaveCount[1])
		self.m_WeaveItemArray=GameLogic:deepcopy(cmd_data.WeaveItemArray)
print("===mark 1") --之前GameLogic 中的形参 中参数变成类似self 所有方法改为:
dump(cmd_data,"cmd_data",6)
		--GameLogic:SwitchToCardIndex(cmd_data.cbCardData[1],cmd_data.cbCardCount,self.m_cbCardIndex)
		local arg1,arg2=GameLogic:SwitchToCardIndex(cmd_data.cbCardData,cmd_data.cbCardCount,self.m_cbCardIndex)
		self.m_cbCardIndex=arg2
    self._gameView.m_HandCardControl:SetOutCardData(cmd_data.byOutCardIndex, cmd.MAX_INDEX)

    --辅助变量
    local wViewChairID={0,0}
    for i=1,cmd.GAME_PLAYER,1 do
      wViewChairID[i]=self:SwitchViewChairID(i-1)
    end

    --界面设置
    self._gameView:SetBaseScore(cmd_data.lCellScore)
    --self._gameView:SetBankerUser(wViewChairID[self.m_wBankerUser])
    self._gameView:SetBankerUser(self.m_wBankerUser)

    --组合扑克
		local cbWeaveCard={0,0,0,0}
dump(self.m_cbWeaveCount,"self.m_cbWeaveCount",6)
dump(self.m_WeaveItemArray,"self.m_WeaveItemArray",6)
	-- BYTE							cbWeaveCount[GAME_PLAYER];		2			//组合数目
	-- CMD_WeaveItem					WeaveItemArray[GAME_PLAYER][MAX_WEAVE];	2 5	//组合扑克
    for i=1,cmd.GAME_PLAYER,1 do
			local wOperateViewID = self:SwitchViewChairID(i-1)
			for j=1,self.m_cbWeaveCount[i],1 do
			--for j=1,self.m_cbWeaveCount[i],1 do
				if j<=5 then
print(i,j)
				local cbWeaveKind=self.m_WeaveItemArray[i][j].cbWeaveKind
				local cbCenterCard=self.m_WeaveItemArray[i][j].cbCenterCard
				local cbWeaveCardCount=GameLogic:GetWeaveCard(cbWeaveKind,cbCenterCard,cbWeaveCard)
				self._gameView.m_WeaveCard[wViewChairID[i]][j]:SetCardData(cbWeaveCard,cbWeaveCardCount,self.m_WeaveItemArray[i][j].cbCenterCard)
        if bit:_and(cbWeaveKind,GameLogic.WIK_GANG) and (self.m_WeaveItemArray[i][j].wProvideUser==(i-1)) then
					self._gameView.m_WeaveCard[wViewChairID[i]][j]:SetDisplayItem(false)
        end
        local wProviderViewID = self:SwitchViewChairID(self.m_WeaveItemArray[i][j].wProvideUser)
        self._gameView.m_WeaveCard[wOperateViewID][j]:SetDirectionCardPos(3-(wOperateViewID-wProviderViewID+4)%4)
				end
      end
			--听牌状态
      if cmd_data.cbHearStatus[i]==true then
				local wViewChairID=self:SwitchViewChairID(i)
				self._gameView:SetUserListenStatus(wViewChairID,true)
      end
    end

		--用户扑克
    if self.m_wCurrentUser==self:GetMeChairID() then
			--调整扑克
      if cmd_data.cbSendCardData ~= 0x00 then
				--变量定义
				local cbCardCount=cmd_data.cbCardCount
				local cbRemoveCard={cmd_data.cbSendCardData}

				--调整扑克
		dump(cmd_data.cbCardData,"cmd_data.cbCardData",6)
	--断线重连时 cbCardCount cmd_data.cbCardCount 为0 RemoveCard 返回为false 不正确 error 
				cmd_data.cbCardData[1]=GameLogic:RemoveCard(cmd_data.cbCardData[1],cbCardCount,cbRemoveCard,1)
		dump(cmd_data.cbCardData,"cmd_data.cbCardData",6)
				--cmd_data.cbCardData[cmd_data.cbCardCount-1]=cmd_data.cbSendCardData
				cmd_data.cbCardData[cmd_data.cbCardCount+1]=cmd_data.cbSendCardData
		dump(cmd_data.cbCardData,"cmd_data.cbCardData",6)
      end
      --设置扑克
      local cbCardCount=cmd_data.cbCardCount
			self._gameView.m_HandCardControl:SetCardData(cmd_data.cbCardData,cbCardCount-1,cmd_data.cbCardData[cbCardCount-1])
    else
			self._gameView.m_HandCardControl:SetCardData(cmd_data.cbCardData,cmd_data.cbCardCount,0)
    end

		--扑克设置
    for i=1,cmd.GAME_PLAYER,1 do
      -- 用户扑克
      if i ~= self:GetMeChairID()+1 then
				local cbCardCount=13-self.m_cbWeaveCount[i]*3
				local wUserCardIndex=(wViewChairID[i]<2) and wViewChairID[i] or 2
				self._gameView.m_UserCard[wUserCardIndex]:SetCardData(cbCardCount,(self.m_wCurrentUser==i))
      end

			--丢弃扑克
			local wViewChairID=self:SwitchViewChairID(i-1)
			self._gameView.m_DiscardCard[wViewChairID]:SetCardData(self.m_cbDiscardCard[i],self.m_cbDiscardCount[i])
    end

    --控制设置
		--if (IsLookonMode()==false)
    if true then
			self._gameView.m_HandCardControl:SetPositively(true)
			self._gameView.m_HandCardControl:SetDisplayItem(true)
			--self._gameView.m_btStusteeControl.EnableWindow(TRUE);    --=========================！！！！！  mark 待完成界面后修改
      if self.m_wOutCardUser == self:GetMeChairID() then
        if GameLogic.WIK_NULL == cmd_data.cbActionMask then
					self._gameView.m_HandCardControl:UpdateCardDisable(true)
        end
      end
    end

    --堆立扑克
    for i=1,cmd.GAME_PLAYER,1 do
      self.m_cbHeapCardInfo[i][1]=0
      self.m_cbHeapCardInfo[i][2]=0
    end

    --分发扑克
		--第一把骰子的玩家 门前开始数牌
	print("游戏场景 第一把骰子的玩家 门前开始数牌")
		local cbSiceFirst=(bit:_rshift(cmd_data.wSiceCount1,8) + bit:_and(cmd_data.wSiceCount1, 0xff) -1)%4
		local wTakeChairID = (self.m_wBankerUser + 4 - cbSiceFirst)%4
		local cbSiceSecond= bit:_rshift(cmd_data.wSiceCount2,8) + bit:_and(cmd_data.wSiceCount2, 0xff)
			+ (bit:_rshift(cmd_data.wSiceCount1,8)  + bit:_and(cmd_data.wSiceCount1, 0xff))
    if cbSiceSecond*2>CardControl.HEAP_FULL_COUNT then
      wTakeChairID = (wTakeChairID + 1)%4
      cbSiceSecond = cbSiceSecond-(CardControl.HEAP_FULL_COUNT/2)
    end
    self.m_wHeapTail = wTakeChairID%4
		--cbTakeCount = 最大库存 -剩余数目 -手牌*玩家数量
		local cbTakeCount=cmd.MAX_REPERTORY-self.m_cbLeftCardCount-(cmd.MAX_COUNT-1)*cmd.GAME_PLAYER
		self.m_wHeapHand = (self.m_wHeapTail+1)%4
print("剩余数量 m_cbLeftCardCount",self.m_cbLeftCardCount,cbTakeCount,self.m_wHeapHand,self.m_cbHeapCardInfo[self.m_wHeapHand],self.m_cbHeapCardInfo[self.m_wHeapHand+1])
		self.m_cbHeapCardInfo[self.m_wHeapHand+1][1] = cbTakeCount
    if cbTakeCount >= CardControl.HEAP_FULL_COUNT then
			self.m_cbHeapCardInfo[self.m_wHeapHand+1][1] = CardControl.HEAP_FULL_COUNT
			cbTakeCount = cbTakeCount - CardControl.HEAP_FULL_COUNT
			self.m_wHeapHand = (self.m_wHeapHand+1)%4
			self.m_cbHeapCardInfo[self.m_wHeapHand+1][1] = self.m_wHeapHand
    end
dump(self.m_cbHeapCardInfo,"self.m_cbHeapCardInfo",6)

  	--堆立界面
		for i=1,4.1 do
	print("===堆立界面 44SetCardData ")
	print(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
      self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
    end
		--换算出财神牌的位置
		local byCount = CardControl.HEAP_FULL_COUNT - self.m_cbHeapCardInfo[self.m_wHeapTail+0][2]
		local bySicbo = bit:_rshift(cmd_data.wSiceCount3,8) + bit:_and(cmd_data.wSiceCount3, 0xff)
		local byChairID = wMeChairID
    if byCount >= bySicbo then
			byChairID = self.m_wHeapTail
    else
			byChairID = (self.m_wHeapTail + 4 - 1)%4
			bySicbo =  bySicbo - byCount
		end
	print(self:SwitchHeapViewChairID(byChairID))
		self._gameView.m_HeapCard[self:SwitchHeapViewChairID(byChairID)+1]:SetGodsCard(cmd_data.byGodsCardData,bySicbo, self.m_cbHeapCardInfo[byChairID][2])

		--历史扑克
    if self.m_wOutCardUser~=yl.INVALID_CHAIR then
			local wOutChairID=self:SwitchViewChairID(self.m_wOutCardUser)
			self._gameView:SetOutCardInfo(wOutChairID,self.m_cbOutCardData)
    end

    --操作界面
    --if ((IsLookonMode()==false)&&(pStatusPlay->cbActionMask!=WIK_NULL))
    if cmd_data.cbActionMask ~= GameLogic.WIK_NULL then
			--获取变量
			local cbActionMask=cmd_data.cbActionMask
			local cbActionCard=cmd_data.cbActionCard

			--变量定义
			--tagGangCardResult GangCardResult; GameLogic
			local GangCardResult={}
			GangCardResult.cbCardCount=0
			GangCardResult.cbGangType=0
      GangCardResult.cbCardData=GameLogic:sizeF(4)

      --杠牌判断
      if (bit:_and(cbActionMask, GameLogic.WIK_GANG)) ~= 0 then
        --桌面杆牌
        if (self.m_wCurrentUser==yl.INVALID_CHAIR) and (cbActionCard~=0) then
					GangCardResult.cbCardCount=1
					GangCardResult.cbCardData[1]=cbActionCard
        end

				--自己杆牌
        if (self.m_wCurrentUser==self:GetMeChairID()) or (cbActionCard == 0) then
					local wMeChairID=self:GetMeChairID()
					local arg1
					arg1,GangCardResult=GameLogic:AnalyseGangCard(self.m_cbCardIndex,self.m_WeaveItemArray[wMeChairID],self.m_cbWeaveCount[wMeChairID],GangCardResult)
        end
      end
			--设置界面
      if self.m_wCurrentUser ==  yl.INVALID_CHAIR then
        self:SetGameClock(cmd.IDI_OPERATE_CARD, self:GetMeChairID(), cmd.IDI_OPERATE_CARD, cmd.TIME_OPERATE_CARD)
      end
      --if (IsLookonMode()==false)
      if true then
				self._gameView.m_ControlWnd:SetControlInfo(cbActionCard,cbActionMask,GangCardResult)
				self.m_cbUserAction = cbActionMask
      end
    end

		--设置时间
    if self.m_wCurrentUser~=yl.INVALID_CHAIR then
			--计算时间
			local wTimeCount=cmd.TIME_OPERATE_CARD
      if self.m_bHearStatus==true and self.m_wCurrentUser==self:GetMeChairID() then
				wTimeCount=cmd.TIME_HEAR_STATUS
      end

      if self.m_wCurrentUser == self:GetMeChairID() then
        if GameLogic.WIK_NULL==cmd_data.cbActionMask then
					self._gameView.m_HandCardControl:UpdateCardDisable(true)
        end
      end

      --设置时间
      self:SetGameClock(cmd.IDI_OPERATE_CARD, self.m_wCurrentUser, cmd.IDI_OPERATE_CARD, wTimeCount)
    end

    --丢弃效果
    self._gameView:SetDiscUser(self:SwitchViewChairID(self.m_wOutCardUser))
    --self._gameView.SetTimer(IDI_DISC_EFFECT,250,NULL);
    self:F_GVSetTimer(self._gameView.IDI_DISC_EFFECT,250)

    --取消托管
    if self.m_bStustee then
		    self:OnStusteeControl(0,0)
    end

		--更新界面
		self._gameView:RefreshGameView()

    return true

  end
  return true
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
	print("游戏开始")
  --变量定义
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)
	dump(cmd_data, "CMD_S_GameStart")
  --设置状态
  self._gameFrame:SetGameStatus(cmd.GS_MJ_MAIDI)
	self._gameView.m_ScoreControl:RestorationData()
	self._gameView:SetCurrentUser(yl.INVALID_CHAIR)
	-- 设置变量
	self.m_bHearStatus=false
	self.m_bWillHearStatus=false
	self.m_wBankerUser=cmd_data.wBankerUser
  self.m_wCurrentUser=yl.INVALID_CHAIR

	--设置界面
	--bool bPlayerMode=(IsLookonMode()==false);
	local bPlayerMode=true
	self._gameView:SetUserListenStatus(yl.INVALID_CHAIR,false)
	self._gameView.m_HandCardControl:SetPositively(false)
	--self._gameView:SetBankerUser(self:SwitchViewChairID(self.m_wBankerUser))
	self._gameView:SetBankerUser(self.m_wBankerUser)
	self._gameView.m_bBankerCount=cmd_data.bBankerCount
	self._gameView:SetDiscUser(yl.INVALID_CHAIR)
	self._gameView:SetGodsCard( 0x00 )
	self._gameView.m_HandCardControl:SetGodsCard( 0x00 )
	self._gameView.m_HandCardControl:SetOutCardData(NULL, 0)
	self._gameView.m_HandCardControl:UpdateCardDisable()

  --旁观界面
  if bPlayerMode==false then
    --[[
  	m_GameClientView.SetHuangZhuang(false);
  	m_GameClientView.SetStatusFlag(false,false);
  	m_GameClientView.SetUserAction(INVALID_CHAIR,0);
  	m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
    --]]
  else
		local szMsg={}
		--目前一直false
    --if cmd_data.bMaiDi then
			--庄家显示买庄，取消
print(self.m_wBankerUser,self:GetMeChairID())
      if self.m_wBankerUser==self:GetMeChairID() then
        szMsg=""
  			self._gameView:SetCenterText(szMsg)
        self._gameView.m_btMaiDi:setVisible(true)
        self._gameView.m_btMaiCancel:setVisible(true)
        --self._gameView.m_btMaiDi.EnableWindow(TRUE)       --  mark
        --self._gameView.m_btMaiCancel.EnableWindow(TRUE)   --
      else  --显示等待庄家买底
        local szNickName="庄家"
        if yl.INVALID_CHAIR ~= self.m_wBankerUser then
          if nil ~= self._gameFrame:getTableUserItem(self:GetMeTableID(),self.m_wBankerUser) then
            szNickName=self._gameFrame:getTableUserItem(self:GetMeTableID(),self.m_wBankerUser).szNickName       -- mark 确定有GetNickName么 下同GetNickName
          end
        end

        szMsg="等待 "..szNickName.." 买底"
        self._gameView:SetCenterText(szMsg)
      end
    --end
  end

	--新界面
	self._gameView:RefreshGameView()

	--激活框架
  if bPlayerMode==true then
    --ActiveGameFrame(); mark
  end

	--环境处理
  self:PlaySound(cmd.RES_PATH.."mahjong/GAME_START.wav")

  for i=1,cmd.GAME_PLAYER,1 do
		self._gameView.m_HeapCard[i]:SetGodsCard(0,0,0)
  end

	--设置时间
  if self.m_wBankerUser ~=  yl.INVALID_CHAIR then
  	self._gameView:SetCurrentUser(self:SwitchViewChairID(self.m_wBankerUser))
		self.m_wCurrentUser = self.m_wBankerUser
    self:SetGameClock(cmd.IDI_DINGDI_CARD, self.m_wBankerUser, cmd.IDI_DINGDI_CARD, cmd.TIME_OPERATE_CARD)
  end

	--托管设置
  for i=1,cmd.GAME_PLAYER,1 do
		self._gameView:SetTrustee(self:SwitchViewChairID(i-1),cmd_data.bTrustee[1][i])
  end

	return true
end

--游戏正式开始
function GameLayer:OnSubGamePlay(dataBuffer)
	print("OnSubGamePlay 游戏正式开始")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_GamePlay, dataBuffer)
	dump(cmd_data,"CMD_S_GamePlay",6)

	--变量定义
	--memcpy(&m_sGamePlay,pBuffer, sizeof(m_sGamePlay));   mark m_sGamePlay
	self:KillGameClock(cmd.IDI_DINGDI_CARD)
	self.m_sGamePlay=cmd_data 

  --设置状态
  self._gameView.m_ScoreControl:RestorationData()
  self._gameView:SetCurrentUser(yl.INVALID_CHAIR)

	--设置变量
	self.m_bHearStatus=false
	self.m_bWillHearStatus=false
	self.m_wCurrentUser=cmd_data.wCurrentUser

	--出牌信息
	self.m_cbOutCardData=0
	self.m_wOutCardUser=yl.INVALID_CHAIR
  self.m_cbDiscardCard=GameLogic:ergodicList(cmd.GAME_PLAYER)
  self.m_cbDiscardCount=GameLogic:sizeM(cmd.GAME_PLAYER)

	--组合扑克
  self.m_cbWeaveCount=GameLogic:sizeM(cmd.GAME_PLAYER)
  self.m_WeaveItemArray=GameLogic:ergodicList(cmd.GAME_PLAYER)
  self.m_bySicboAnimCount = 0

	--设置界面
	--bool bPlayerMode=(IsLookonMode()==false);
	local bPlayerMode=true
	self._gameView:SetDiscUser(yl.INVALID_CHAIR)
	--移除双方准备显示
	self._gameView:canceShowlReady()

	--旁观界面
  --[[
	if (bPlayerMode==false)
	{
		m_GameClientView.SetHuangZhuang(false);
		m_GameClientView.SetStatusFlag(false,false);
		m_GameClientView.SetUserAction(INVALID_CHAIR,0);
		m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
	}
  --]]
  for i=1,cmd.GAME_PLAYER,1 do
    self.m_cbHeapCardInfo[i][1]=0
    self.m_cbHeapCardInfo[i][2]=0
	end

	local byDingMaiRet={}
	--堆立扑克
	local szMessage="\r\n"
	local szMsg=""
  for i=1,cmd.GAME_PLAYER,1 do
    while true do
      local byViewChair=self:SwitchViewChairID(i-1)
  		byDingMaiRet[byViewChair] = self:SwitchViewChairID(i-1)

      local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),i)
			if nil==pUserData then break	end
			-- dump(cmd_data,"cmd_data",6)
			-- print(cmd_data.byUserDingDi[i],i)
			--      "byUserDingDi" = {
			--          1 = {
			--              1 = 1
			--              2 = 2
			--          }
			--      }
  		byDingMaiRet[byViewChair] = (cmd_data.byUserDingDi[1][i]<2) and 0 or cmd_data.byUserDingDi[1][i]
      if i == self.m_wBankerUser then
  			--_sntprintf(szMsg, sizeof(szMsg), TEXT("[%s]买底\r\n"),pUserData->GetNickName(),byDingMaiRet[byViewChair]);
        szMsg="["..pUserData.szNickName.."]买底\r\n"
      else
  			--_sntprintf(szMsg, sizeof(szMsg), TEXT("[%s]顶底\r\n"),pUserData->GetNickName(), byDingMaiRet[byViewChair]);
        szMsg="["..pUserData.szNickName.."]顶底\r\n"
      end
    	--/*_tcscat_s*/ _tcscat(szMessage, /*sizeof),*/ szMsg);
			szMessage=szMessage..szMsg
			print("OnSubGamePlay 正式开始",szMessage)
    break	end
	end

	self._gameView:SetDingMaiValue(byDingMaiRet)

	--扑克设置
  for i=1,cmd.GAME_PLAYER,1 do
    --变量定义
		local wViewChairID=self:SwitchViewChairID(i-1)

		--旁观界面
		--if (bPlayerMode==false)
		if true then
dump(self._gameView.m_TableCard,"self._gameView.m_TableCard",6)
print(wViewChairID,i)
			self._gameView.m_TableCard[wViewChairID]:SetCardData(nil,0)
			self._gameView.m_DiscardCard[wViewChairID]:SetCardData(nil,0)
			self._gameView.m_WeaveCard[wViewChairID][1]:SetCardData(nil,0)
			self._gameView.m_WeaveCard[wViewChairID][2]:SetCardData(nil,0)
			self._gameView.m_WeaveCard[wViewChairID][3]:SetCardData(nil,0)
			self._gameView.m_WeaveCard[wViewChairID][4]:SetCardData(nil,0)
			self._gameView.m_WeaveCard[wViewChairID][5]:SetCardData(nil,0)
    end
  end

	local wMeChairID=self:GetMeChairID()

	--出牌提示
	--if ((bPlayerMode==true)&&(m_wCurrentUser!=INVALID_CHAIR))
  if self.m_wCurrentUser~=yl.INVALID_CHAIR then
    if self.m_wCurrentUser==wMeChairID then
      --ActiveGameFrame(); mark
    end
  end

	self._gameView.m_HandCardControl:SetOutCardData(nil, 0)
	
--临时添加测试 start ==========================================================================================
	--设置游戏状态
	self._gameFrame:SetGameStatus(cmd.GS_MJ_PLAY)
	--添加设置财神
	GameLogic:SetGodsCard(cmd_data.byGodsCardData)
	self._gameView:SetGodsCard(cmd_data.byGodsCardData)
	self._gameView.m_HandCardControl:SetGodsCard(cmd_data.byGodsCardData)

	for i=1,4,1 do
		self.m_cbHeapCardInfo[i][1]=0
		self.m_cbHeapCardInfo[i][2]=0
	end
	--第一把骰子的玩家 门前开始数牌
	print(" 第一把骰子的玩家 门前开始数牌")
		local cbSiceFirst=(bit:_rshift(cmd_data.wSiceCount1,8) + bit:_and(cmd_data.wSiceCount1, 0xff)-1)%4
		local wTakeChairID = (self.m_wBankerUser*2 + 4 - cbSiceFirst)%4
		local cbSiceSecond= bit:_rshift(cmd_data.wSiceCount2,8) + bit:_and(cmd_data.wSiceCount2, 0xff)
			+ (bit:_rshift(cmd_data.wSiceCount1,8) + bit:_and(cmd_data.wSiceCount1, 0xff))
    if (cbSiceSecond*2)>CardControl.HEAP_FULL_COUNT then
			wTakeChairID = (wTakeChairID + 1)%4
			cbSiceSecond = cbSiceSecond-(CardControl.HEAP_FULL_COUNT/2)
    end
		self.m_wHeapTail = wTakeChairID%4
		------------------------------------------------------------------
		local cbTakeCount=(cmd.MAX_COUNT-1)*2+1

dump(self.m_cbHeapCardInfo,"正式开始 添加 m_cbHeapCardInfo",6)
    while true do
      for i=1,2,1 do
  			--计算数目
  			local cbValidCount=CardControl.HEAP_FULL_COUNT-self.m_cbHeapCardInfo[wTakeChairID+1][2]-((i==0+1) and (cbSiceSecond-1)*2 or 0)
				cbValidCount=cbValidCount+2
				local cbRemoveCount=(cbValidCount < cbTakeCount) and cbValidCount or cbTakeCount
	print("i: ",i,cbValidCount , cbTakeCount ,cbRemoveCount)
	print(wTakeChairID)
        if i==2 then cbRemoveCount=cbTakeCount end
        self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]=self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]+cbRemoveCount
	print("正式开始 添加",wTakeChairID,"等待",cbSiceSecond,"点数为",cbRemoveCount,cbTakeCount)

        --提取扑克
        cbTakeCount=cbTakeCount-cbRemoveCount

  			--完成判断
      	if cbTakeCount==0 then
  				self.m_wHeapHand=wTakeChairID
        break	end

  			--切换索引
				wTakeChairID=(wTakeChairID+1)%4
				self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]=self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]+cbTakeCount-1
				break
      end
    break end
    -------------------------------------------------------------------
		self.m_wHeapHand = (self.m_wHeapTail+1)%4
dump(self.m_cbHeapCardInfo," 正式开始 添加 m_cbHeapCardInfo",6)
--why
		self.m_cbHeapCardInfo[self.m_wHeapHand+1][1]=1
print(self.m_wBankerUser,cbSiceFirst,cbSiceSecond,wTakeChairID)
print(self.m_wHeapHand,self.m_wHeapTail)
dump(self.m_cbHeapCardInfo," 正式开始 添加 m_cbHeapCardInfo",6)

		for i=1,4,1 do
			--变量定义
			local wViewChairID=self:SwitchHeapViewChairID(i-1)
print(wViewChairID,i,wMeChairID)
print("== m_HeapCard",self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
			self._gameView.m_HeapCard[wViewChairID+1]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
    end
    -------------------------------------------------------------------
		local cbCardCount=(wMeChairID==self.m_wBankerUser) and cmd.MAX_COUNT or (cmd.MAX_COUNT-1)  --添加
		local byCardsIndex=GameLogic:sizeM(cmd.MAX_INDEX)
		local arg1,arg2=GameLogic:SwitchToCardIndex(cmd_data.cbCardData[wMeChairID+1],cbCardCount,byCardsIndex)
	--dump(byCards,"byCards",6)
		byCardsIndex=arg2
	print(cmd_data.cbCardData[wMeChairID+1],(cmd.MAX_COUNT-1),byCardsIndex)

	--dump(byCardsIndex,"byCardsIndex",6)
		local byCards=GameLogic:sizeM(cmd.MAX_COUNT)
		local arg1,arg2=GameLogic:SwitchToCardData(byCardsIndex, byCards)
		byCards = arg2
	dump(byCards,"byCards",6)

  	--扑克设置
    for i=1,cmd.GAME_PLAYER,1 do
      --变量定义
			local wViewChairID=self:SwitchViewChairID(i-1)

			--组合界面
			self._gameView.m_WeaveCard[i][1]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][2]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][3]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][4]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][5]:SetDisplayItem(true)

			--用户扑克
      if i~=wMeChairID+1 then
				local wIndex=(wViewChairID>=3) and 2 or wViewChairID
print("对手扑克== ",wIndex,wViewChairID)
				local count=GameLogic:table_leng(cmd_data.cbCardData[wMeChairID+1])
				if (i-1)~=self.m_wBankerUser then	count=count-1	end
				--self._gameView.m_UserCard[wIndex]:SetCardData(GameLogic:table_leng((cmd_data.cbCardData[wMeChairID+1])),(i==self.m_wBankerUser))
				self._gameView.m_UserCard[wIndex]:SetCardData(count,(i==self.m_wBankerUser))
      else
				local cbBankerCard=(i==self.m_wBankerUser) and cmd_data.cbCardData[wMeChairID+1][cmd.MAX_COUNT-1] or 0
				local count=((i-1)==self.m_wBankerUser) and cmd.MAX_COUNT or cmd.MAX_COUNT-1
print("-=-= gameView.m_HandCardControl:SetCardDat",byCards,count,cbBankerCard)
				self._gameView.m_HandCardControl:SetDisplayItem(true)						--添加 设置显示
				self._gameView.m_HandCardControl:SetCardData(byCards,count,cbBankerCard)
      end
    end
----临时添加测试 end	==========================================================================================

	--更新界面
	self._gameView:SetCenterText("")
print("更新界面 色子 StartSicboAnim")
	local bySicbo = {bit:_rshift(cmd_data.wSiceCount1,8) , bit:_and(cmd_data.wSiceCount1, 0xff)}
dump(bySicbo,"bySicbo",6)
	self._gameView:StartSicboAnim(bySicbo,20)

--添加 

	return true

end

--用户出牌
function GameLayer:onSubOutCard(dataBuffer)
  --消息处理
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_OutCard, dataBuffer)
	dump(cmd_data, "CMD_S_OutCard")
	print("用户出牌", cmd_data.cbOutCardData)
	--变量定义
	local wMeChairID=self:GetMeChairID()
	local wOutViewChairID=self:SwitchViewChairID(cmd_data.wOutCardUser)
	print(cmd_data.wOutCardUser , wMeChairID,cmd.GS_MJ_PLAY , self._gameFrame:GetGameStatus())
  if (cmd_data.wOutCardUser ~= wMeChairID) and (cmd.GS_MJ_PLAY ~= self._gameFrame:GetGameStatus()) then
    while true do
      self:OnDispatchCard(1,0)
      if cmd.GS_MJ_PLAY == self._gameFrame:GetGameStatus() then break	end
    end
  end

	--设置变量
	self.m_wCurrentUser=yl.INVALID_CHAIR
	self.m_wOutCardUser=cmd_data.wOutCardUser
	self.m_cbOutCardData=cmd_data.cbOutCardData
print("===mark 2")
	local byCardIndex = GameLogic:SwitchToCardIndex(self.m_cbOutCardData)
	self._gameView.m_HandCardControl:SetOutCardData(byCardIndex)
	self._gameView.m_HandCardControl:UpdateCardDisable()

	--其他用户
	--if ((IsLookonMode()==true)||(pOutCard->wOutCardUser!=wMeChairID))
  if cmd_data.wOutCardUser~=wMeChairID then
    --环境设置
    self:KillGameClock(cmd.IDI_OPERATE_CARD)
		self:PlayCardSound(cmd_data.wOutCardUser,cmd_data.cbOutCardData)
		--出牌界面
		self._gameView:SetUserAction(yl.INVALID_CHAIR,0)
		self._gameView:SetOutCardInfo(wOutViewChairID,cmd_data.cbOutCardData)
		--设置扑克
    if wMeChairID == cmd_data.wOutCardUser then
			--删除扑克
			local cbCardData={}
			self.m_cbCardIndex=GameLogic:RemoveCard(self.m_cbCardIndex,cmd_data.cbOutCardData)

			--设置扑克
			local cbCardCount,arg2=GameLogic:SwitchToCardData(self.m_cbCardIndex,cbCardData)
			cbCardData=arg2
	print("-=-= gameView.m_HandCardControl:SetCardDat",cbCardData,cbCardCount)
			self._gameView.m_HandCardControl:SetCardData(cbCardData,cbCardCount,0)
    else
			local wUserIndex=wOutViewChairID
			self._gameView.m_UserCard[wUserIndex]:SetCurrentCard(false)
    end
  else
		self._gameView:RefreshGameView()
  end

	return true

end

--发牌消息
function GameLayer:onSubSendCard(dataBuffer)
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_SendCard, dataBuffer)
	dump(cmd_data, "CMD_S_SendCard")
	print("发送扑克", cmd_data.cbCardData)

	--设置变量
	local wMeChairID=self:GetMeChairID()
	self.m_wCurrentUser=cmd_data.wCurrentUser

	--丢弃扑克
  if (self.m_wOutCardUser~=yl.INVALID_CHAIR) and (self.m_cbOutCardData~=0) then
    --丢弃扑克
		local wOutViewChairID=self:SwitchViewChairID(self.m_wOutCardUser)
		self._gameView.m_DiscardCard[wOutViewChairID]:AddCardItem(self.m_cbOutCardData)
		self._gameView:SetDiscUser(wOutViewChairID)

		--设置变量
		self.m_cbOutCardData=0
		self.m_wOutCardUser=yl.INVALID_CHAIR
  end

  --发牌处理
  if cmd_data.cbCardData~=0 then
    --取牌界面
		local wViewChairID=self:SwitchViewChairID(self.m_wCurrentUser)
    if self.m_wCurrentUser~=wMeChairID then
			local wUserIndex=wViewChairID
			self._gameView.m_UserCard[wUserIndex]:SetCurrentCard(true)
		else
print("==== onSubSendCard ",self.m_wCurrentUser,wMeChairID,GameLogic:SwitchToCardIndex(cmd_data.cbCardData))
			self.m_cbCardIndex[GameLogic:SwitchToCardIndex(cmd_data.cbCardData)+1]=self.m_cbCardIndex[GameLogic:SwitchToCardIndex(cmd_data.cbCardData)+1]+1
			self._gameView.m_HandCardControl:SetCurrentCard(cmd_data.cbCardData)
    end

    --扣除扑克
    self:DeductionTableCard(true)
  end

	--当前用户
	--if ((IsLookonMode()==false)&&(m_wCurrentUser==wMeChairID))
	print("当前用户",self.m_wCurrentUser,wMeChairID)
  if self.m_wCurrentUser==wMeChairID then
		--激活框架
		--ActiveGameFrame();

    --听牌判断
    if self.m_bHearStatus==false then
			local cbChiHuRight=0
			local cbWeaveCount=self.m_cbWeaveCount[wMeChairID]
			cmd_data.cbActionMask=bit:_or(cmd_data.cbActionMask,GameLogic:AnalyseTingCard(self.m_cbCardIndex,self.m_WeaveItemArray[wMeChairID],cbWeaveCount,cbChiHuRight))
    end

    --动作处理
    if cmd_data.cbActionMask~=GameLogic.WIK_NULL then
			--获取变量
			local cbActionCard=cmd_data.cbCardData
			local cbActionMask=cmd_data.cbActionMask

			--变量定义
			local GangCardResult={}
			GangCardResult.cbCardCount=0
			GangCardResult.cbGangType=0
      GangCardResult.cbCardData=GameLogic:sizeF(4)

			--杠牌判断
      if bit:_and(cbActionMask,GameLogic.WIK_GANG)~=0 then
				local wMeChairID=self:GetMeChairID()
				local arg1
				arg1,GangCardResult=GameLogic:AnalyseGangCard(self.m_cbCardIndex,self.m_WeaveItemArray[wMeChairID],self.m_cbWeaveCount[wMeChairID],GangCardResult)
		print(arg1,GangCardResult)
		dump(GangCardResult,"GangCardResult====",6)
      end

			--设置界面
			self._gameView.m_ControlWnd:SetControlInfo(cbActionCard,cbActionMask,GangCardResult)
			self.m_cbUserAction = cbActionMask
    end
  end

	--出牌提示
	--self._gameView:SetStatusFlag((IsLookonMode()==false)&&(m_wCurrentUser==wMeChairID),false);
	self._gameView:SetStatusFlag((self.m_wCurrentUser==wMeChairID),false)

  --if (!IsLookonMode() && m_wCurrentUser == wMeChairID)
	print("当前用户",self.m_wCurrentUser,wMeChairID)
  if self.m_wCurrentUser == wMeChairID then
		self._gameView.m_HandCardControl:UpdateCardDisable(true)
  end

	--更新界面
print("发牌-更新界面")
	self._gameView:RefreshGameView()

	--计算时间
	local wTimeCount=cmd.TIME_OPERATE_CARD
  if (self.m_bHearStatus==true) and (self.m_wCurrentUser == wMeChairID) then
		wTimeCount=cmd.TIME_HEAR_STATUS
  end

	--设置时间
	self._gameView:SetCurrentUser(self:SwitchViewChairID(self.m_wCurrentUser))
  self:SetGameClock(cmd.IDI_OPERATE_CARD, self.m_wCurrentUser, cmd.IDI_OPERATE_CARD, wTimeCount)
print("发牌消息 end")
	return true

end

--用户听牌
function GameLayer:onSubListenCard(dataBuffer)
	print("用户听牌")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_ListenCard, dataBuffer)
	--dump(cmd_data, "CMD_S_ListenCard")

	--设置界面
	local wViewChairID=self:SwitchViewChairID(cmd_data.wListenUser)
	self._gameView:SetUserListenStatus(wViewChairID,true)
	self:PlayActionSound(cmd_data.wListenUser,GameLogic.WIK_LISTEN)

	return true
end

--操作提示
function GameLayer:onSubOperateNotify(dataBuffer)
	print("操作提示")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_OperateNotify, dataBuffer)
	dump(cmd_data, "CMD_S_OperateNotify")

	--用户界面
	--if ((IsLookonMode()==false)&&(pOperateNotify->cbActionMask!=WIK_NULL))
  if cmd_data.cbActionMask~=GameLogic.WIK_NULL then
		--获取变量
		local wMeChairID=self:GetMeChairID()
		local cbActionMask=cmd_data.cbActionMask
		local cbActionCard=cmd_data.cbActionCard

		--变量定义
		local GangCardResult={}
		GangCardResult.cbCardCount=0
		GangCardResult.cbGangType=0
		GangCardResult.cbCardData=GameLogic:sizeF(4)

    --杠牌判断
    if bit:_and(cbActionMask,GameLogic.WIK_GANG) then
      --桌面杆牌
      if (self.m_wCurrentUser==yl.INVALID_CHAIR) and (cbActionCard~=0) then
				GangCardResult.cbCardCount=1
				GangCardResult.cbCardData[1]=cbActionCard
      end
      --自己杆牌
      if (self.m_wCurrentUser==wMeChairID) or (cbActionCard==0) then
		    local wMeChairID=self:GetMeChairID()
				local arg1
				arg1,GangCardResult=GameLogic:AnalyseGangCard(self.m_cbCardIndex,self.m_WeaveItemArray[wMeChairID],self.m_cbWeaveCount[wMeChairID],GangCardResult)
      end
    end

		--设置界面
		--ActiveGameFrame();
		self._gameView.m_ControlWnd:SetControlInfo(cbActionCard,cbActionMask,GangCardResult)
		self.m_cbUserAction = cbActionMask

		--设置时间
		self._gameView:SetCurrentUser(yl.INVALID_CHAIR)
    self:SetGameClock(cmd.IDI_OPERATE_CARD, self:GetMeChairID(), cmd.IDI_OPERATE_CARD, cmd.TIME_OPERATE_CARD)

  end

	return true
end

--操作结果
function GameLayer:onSubOperateResult(dataBuffer)
	print("操作结果")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_OperateResult, dataBuffer)
	--dump(cmd_data, "CMD_S_OperateResult")

	--变量定义
	local cbPublicCard=true
	local wOperateUser=cmd_data.wOperateUser
	local cbOperateCard=cmd_data.cbOperateCard
	local wOperateViewID=self:SwitchViewChairID(wOperateUser)
	local wProviderViewID = self:SwitchViewChairID(cmd_data.wProvideUser)

	--出牌变量
  if cmd_data.cbOperateCode~=GameLogic.WIK_NULL then
    self.m_cbOutCardData=0
    self.m_wOutCardUser=yl.INVALID_CHAIR
  end

  --设置组合
  if bit:_and(cmd_data.cbOperateCode,GameLogic.WIK_GANG) then
    --设置变量
		self.m_wCurrentUser=yl.INVALID_CHAIR

		--组合扑克
		local cbWeaveIndex= 0xFF
    while true do
      for i=1,self.m_cbWeaveCount[wOperateUser],1 do
  			local cbWeaveKind=self.m_WeaveItemArray[wOperateUser][i].cbWeaveKind
  			local cbCenterCard=self.m_WeaveItemArray[wOperateUser][i].cbCenterCard
        if (cbCenterCard==cbOperateCard) and (cbWeaveKind==GameLogic.WIK_PENG) then
  				cbWeaveIndex=i
  				self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard=true
  				self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=cmd_data.cbOperateCode
  				self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=cmd_data.wProvideUser
        break	end
      end
    break end

  	--组合扑克
    if cbWeaveIndex == 0xFF then
      --暗杠判断 : ? he  and or 有区别 第二个值不能为false 否之一直返回第三个
  		--cbPublicCard=(cmd_data.wProvideUser==wOperateUser) and false or true
  		cbPublicCard=not (cmd_data.wProvideUser==wOperateUser)

  		--设置扑克
      self.m_cbWeaveCount[wOperateUser]=self.m_cbWeaveCount[wOperateUser]+1
  		cbWeaveIndex=self.m_cbWeaveCount[wOperateUser]
  		self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard=cbPublicCard
  		self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterCard=cbOperateCard
  		self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=cmd_data.cbOperateCode
  		self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=cmd_data.wProvideUser
    end

		--组合界面
		local cbWeaveCard,cbWeaveKind={0,0,0,0},cmd_data.cbOperateCode
		local cbWeaveCardCount=GameLogic:GetWeaveCard(cbWeaveKind,cbOperateCard,cbWeaveCard)
		self._gameView.m_WeaveCard[wOperateViewID][cbWeaveIndex]:SetCardData(cbWeaveCard,cbWeaveCardCount,0)
		self._gameView.m_WeaveCard[wOperateViewID][cbWeaveIndex]:SetDisplayItem((cbPublicCard==true) and true or false)

		--扑克设置
    if self:GetMeChairID() == wOperateUser then
			self.m_cbCardIndex[GameLogic:SwitchToCardIndex(cmd_data.cbOperateCard)]=0
    end

		--设置扑克
    if self:GetMeChairID() == wOperateUser then
			local cbCardData={}
			local cbCardCount,arg2=GameLogic:SwitchToCardData(self.m_cbCardIndex,cbCardData)
			cbCardData=arg2
			self._gameView.m_HandCardControl:SetCardData(cbCardData,cbCardCount,0)
    else
			local wUserIndex=(wOperateViewID>=3)and 2 or wOperateViewID
			local cbCardCount=cmd.MAX_COUNT-self.m_cbWeaveCount[wOperateUser]*3
			self._gameView.m_UserCard[wUserIndex]:SetCardData(cbCardCount-1,false)
    end

  elseif cmd_data.cbOperateCode~=GameLogic.WIK_NULL then
		--设置变量
		self.m_wCurrentUser=cmd_data.wOperateUser

		--设置组合
    self.m_cbWeaveCount[wOperateUser]=self.m_cbWeaveCount[wOperateUser]+1
    cbWeaveIndex=self.m_cbWeaveCount[wOperateUser]
    self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard=true
    self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterCard=cbOperateCard
    self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=cmd_data.cbOperateCode
    self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=cmd_data.wProvideUser

		--组合界面
		local cbWeaveCard,cbWeaveKind={0,0,0,0},cmd_data.cbOperateCode
		local cbWeaveCardCount=GameLogic:GetWeaveCard(cbWeaveKind,cbOperateCard,cbWeaveCard)
		self._gameView.m_WeaveCard[wOperateViewID][cbWeaveIndex]:SetCardData(cbWeaveCard,cbWeaveCardCount,cbWeaveKind==GameLogic.WIK_PENG and 0 or cmd_data.cbOperateCard)
		self._gameView.m_WeaveCard[wOperateViewID][cbWeaveIndex]:SetDisplayItem(3-(wOperateViewID-wProviderViewID+4)%4)

		--删除扑克
    if self:GetMeChairID() == wOperateUser then
			cbWeaveCard=GameLogic:RemoveCard(cbWeaveCard,cbWeaveCardCount,cbOperateCard,1)
			self.m_cbCardIndex=GameLogic:RemoveCard(self.m_cbCardIndex,cbWeaveCard,cbWeaveCardCount-1)
    end

		--设置扑克
    if self:GetMeChairID() == wOperateUser then
			local cbCardData={}
			local cbCardCount,arg2=GameLogic:SwitchToCardData(self.m_cbCardIndex,cbCardData)
			cbCardData=arg2
			self._gameView.m_HandCardControl:SetCardData(cbCardData,cbCardCount-1,cbCardData[cbCardCount-1])
    else
			local wUserIndex=(wOperateViewID>=3)and 2 or wOperateViewID
			local cbCardCount=cmd.MAX_COUNT-self.m_cbWeaveCount[wOperateUser]*3
			self._gameView.m_UserCard[wUserIndex]:SetCardData(cbCardCount-1,true)
    end
  end

  --设置界面
  self._gameView:SetOutCardInfo(yl.INVALID_CHAIR,0)
  self._gameView.m_ControlWnd:setVisible(false)
  self._gameView:SetUserAction(wOperateViewID,cmd_data.cbOperateCode)
  self._gameView:SetStatusFlag(self.m_wCurrentUser==self:GetMeChairID(),false)

  --更新界面
  self._gameView:RefreshGameView()

  --环境设置
  self:PlayActionSound(cmd_data.wOperateUser,cmd_data.cbOperateCode)

  --设置时间
  if self.m_wCurrentUser~=yl.INVALID_CHAIR then
    --听牌判断
    if (self.m_bHearStatus==false) and (self.m_wCurrentUser==self:GetMeChairID()) then
      self._gameView.m_HandCardControl:UpdateCardDisable(true)
      --听牌判断
      local cbChiHuRight=0
      local wMeChairID=self:GetMeChairID()
      local cbWeaveCount=self.m_cbWeaveCount[wMeChairID]
      local cbActionMask=GameLogic:AnalyseTingCard(self.m_cbCardIndex,self.m_WeaveItemArray[wMeChairID],cbWeaveCount,cbChiHuRight)

      --操作提示
      if cbActionMask~=nil then
				local GangCardResult={}
				GangCardResult.cbCardCount=0
				GangCardResult.cbGangType=0
				GangCardResult.cbCardData=GameLogic:sizeF(4)
        self._gameView.m_ControlWnd:SetControlInfo(0,cbActionMask,GangCardResult)
        self.m_cbUserAction = cbActionMask
      end
    end

    --计算时间
    local wTimeCount=cmd.TIME_OPERATE_CARD
    if (self.m_bHearStatus==true) and (self.m_wCurrentUser==self:GetMeChairID()) then
       wTimeCount=cmd.TIME_HEAR_STATUS
    end

    --设置时间
    self._gameView:SetCurrentUser(self:SwitchViewChairID(self.m_wCurrentUser))
    self:SetGameClock(cmd.IDI_OPERATE_CARD, self.m_wCurrentUser, cmd.IDI_OPERATE_CARD, wTimeCount)
  end

  return true

end


--游戏结束
function GameLayer:OnSubGameEnd(dataBuffer)
	print("游戏结束")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)
	dump(cmd_data, "CMD_S_GameEnd")

	--设置状态
  self._gameFrame:SetGameStatus(cmd.GS_MJ_FREE)
	self._gameView:SetStatusFlag(false,false)

	--删除定时器
  self:KillGameClock(cmd.IDI_OPERATE_CARD)

	--设置控件
	self._gameView:SetStatusFlag(false,false)   -- 一样的
	self._gameView.m_ControlWnd:setVisible(false)
	self._gameView.m_btMaiCancel:setVisible(false)
	self._gameView.m_btDingCancel:setVisible(false)
	self._gameView.m_btMaiDi:setVisible(false)
	self._gameView.m_btDingDi:setVisible(false)
	self._gameView.m_HandCardControl:SetPositively(false)

	--*设置扑克
  for i=1,cmd.GAME_PLAYER,1 do
		self._gameView.m_WeaveCard[i][1]:SetDisplayItem(true)
		self._gameView.m_WeaveCard[i][2]:SetDisplayItem(true)
		self._gameView.m_WeaveCard[i][3]:SetDisplayItem(true)
		self._gameView.m_WeaveCard[i][4]:SetDisplayItem(true)
		self._gameView.m_WeaveCard[i][5]:SetDisplayItem(true)
  end

	--变量定义
	--tagScoreInfo ScoreInfo;
	--tagWeaveInfo WeaveInfo;
  local ScoreInfo,WeaveInfo={},{}
	--ScoreInfo.cbCardData=GameLogic:sizeM(cmd.MAX_COUNT)
  ScoreInfo.cbCardData={}  ScoreInfo.szUserName=GameLogic:ergodicList(cmd.GAME_PLAYER)  ScoreInfo.lGameScore={}
  ScoreInfo.lGodsScore={}  ScoreInfo.byDingDi={}  ScoreInfo.dwChiHuKind={} ScoreInfo.dwChiHuRight={}
  WeaveInfo.cbCardCount={}  WeaveInfo.cbPublicWeave={}  WeaveInfo.cbCardData=GameLogic:ergodicList(4)

	--成绩变量
	ScoreInfo.wBankerUser=self.m_wBankerUser
	ScoreInfo.wProvideUser=cmd_data.wProvideUser
	ScoreInfo.cbProvideCard=cmd_data.cbProvideCard

	--设置积分
	--m_pIStringMessage->InsertNormalString(TEXT("本局结算信息:"));          --mark  自定义方法
	print("本局结算信息:")
	local szBuffer=""
	--_sntprintf(szBuffer,CountArray(szBuffer),TEXT("%-14s%-10s%-6s\n"),TEXT("用户昵称"),TEXT("成绩"),TEXT("财神"));
  szBuffer="          用户昵称        成绩    财神\n"
	--m_pIStringMessage->InsertNormalString(szBuffer); ------------同上
	print(szBuffer)
  for i=1,cmd.GAME_PLAYER,1 do
			local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),i-1)
	print(pUserData,self:GetMeTableID())
	dump(pUserData,"pUserData",6)
  		ScoreInfo.byDingDi[i] = cmd_data.byDingDi[1][i]
  		--胡牌类型
  		ScoreInfo.dwChiHuKind[i]=cmd_data.dwChiHuKind[1][i]
  		ScoreInfo.dwChiHuRight[i]=cmd_data.dwChiHuRight[1][i]

  		--设置成绩
  		ScoreInfo.lGameScore[i]=cmd_data.lGameScore[1][i]
  		ScoreInfo.lGodsScore[i]=cmd_data.lGodsScore[1][i]
			--lstrcpyn(ScoreInfo.szUserName[i],pUserData->GetNickName(),CountArray(ScoreInfo.szUserName[i]))
      --ScoreInfo.szUserName[i]=ScoreInfo.szUserName[i]..pUserData:GetNickName()
      ScoreInfo.szUserName[i]=pUserData.szNickName

      local str
      --str=pUserData:GetNickName()
      str=pUserData.szNickName
  		--DWORD  le0 = CStringA(str).GetLength();        --这里不明白在干嘛 mark 可能是cstring和char转换 ？！？！？！？！？！？ 好像用不到我这
  		--local  le0 = GameLogic:table_leng(str)

  		local strFormat
		  --strFormat.Format(TEXT("%%-%ds%%+-12I64d%%+-8I64d"),18-(le0-str.GetLength()));
  		--strFormat=="%%-%ds%%+-12I64d%%+-8I64d" 未知空格 暂时2个

      --szBuffer=pUserData:GetNickName().."  "..cmd_data.lGameScore[i].."  "..cmd_data.lGodsScore[i]
      szBuffer=pUserData.szNickName.."  "..cmd_data.lGameScore[1][i].."  "..cmd_data.lGodsScore[1][i]
  		--m_pIStringMessage->InsertNormalString(szBuffer); ------------同上
			print(szBuffer)

      --胡牌扑克
      if (ScoreInfo.cbCardCount==0) and (cmd_data.dwChiHuKind[1][i]~=GameLogic.CHK_NULL) then
        -- 组合扑克
  			WeaveInfo.cbWeaveCount=self.m_cbWeaveCount[i]
        for j=1,WeaveInfo.cbWeaveCount,1 do
  				local cbWeaveKind=self.m_WeaveItemArray[i][j].cbWeaveKind
  				local cbCenterCard=self.m_WeaveItemArray[i][j].cbCenterCard
  				WeaveInfo.cbPublicWeave[j]=self.m_WeaveItemArray[i][j].cbPublicCard
  				WeaveInfo.cbCardCount[j]=GameLogic:GetWeaveCard(cbWeaveKind,cbCenterCard,WeaveInfo.cbCardData[j])
        end

  			--设置扑克
  			ScoreInfo.cbCardCount=cmd_data.cbCardCount[1][i]
      	ScoreInfo.cbCardData=GameLogic:deepcopy(cmd_data.cbCardData[i])

        --提取胡牌
        while true do
          for j=1,ScoreInfo.cbCardCount,1 do
          	if (ScoreInfo.cbCardData[j]==cmd_data.cbProvideCard) and (j<ScoreInfo.cbCardCount-1) then
    					--MoveMemory(&ScoreInfo.cbCardData[j],&ScoreInfo.cbCardData[j+1],(ScoreInfo.cbCardCount-j-1)*sizeof(BYTE));
            	ScoreInfo.cbCardData[j]=GameLogic:deepcopy(ScoreInfo.cbCardData[j+1])
    					ScoreInfo.cbCardData[ScoreInfo.cbCardCount-1]=cmd_data.cbProvideCard
            break	end
          end
        break end
      end
  end

print("成绩界面 ")
dump(ScoreInfo,"ScoreInfo",6)
	--成绩界面
	self._gameView.m_ScoreControl:SetScoreInfo(ScoreInfo,WeaveInfo,self:GetMeChairID())
	--添加 重画
	self._gameView.m_ScoreControl:OnPaint()

	local iHuType=self._gameView.m_ScoreControl:GetHardSoftHu()
	--用户扑克
  for i=1,cmd.GAME_PLAYER,1 do
		local wViewChairID=self:SwitchViewChairID(i-1)
    if cmd_data.dwChiHuKind[1][i]~=GameLogic.CHK_NULL then
      self._gameView:SetUserAction(wViewChairID,GameLogic.WIK_CHI_HU)
    end
		self._gameView.m_TableCard[wViewChairID]:SetCardData(cmd_data.cbCardData[i],cmd_data.cbCardCount[1][i])
  end

	--设置扑克
	self._gameView.m_UserCard[1]:SetCardData(0,false)
	self._gameView.m_UserCard[2]:SetCardData(0,false)
	self._gameView.m_HandCardControl:SetCardData(nil,0,0)

	--播放声音
	local lScore=cmd_data.lGameScore[1][self:GetMeChairID()+1]
  local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),1)
	--local bGirl = ((pUserData->GetGender()==GENDER_MANKIND) ?  false:true);    --mark  getTableUserItem 中 确定存在GetGender？
	local bGirl = not (pUserData.cbGender==yl.GENDER_MANKIND)

	local switch = {
	    [1] = function()    -- 软胡
        if bGirl then
          self:PlaySound(cmd.RES_PATH.."mahjong/female/Soft.wav")
        else
          self:PlaySound(cmd.RES_PATH.."mahjong/male/Soft.wav")
        end
	    end,
	    [2] = function()    -- 硬胡
        if bGirl then
          self:PlaySound(cmd.RES_PATH.."mahjong/female/Hard.wav")
        else
          self:PlaySound(cmd.RES_PATH.."mahjong/male/Hard.wav")
        end
	    end,
	    [3] = function()    --双翻
        if bGirl then
          self:PlaySound(cmd.RES_PATH.."mahjong/female/Double.wav")
        else
          self:PlaySound(cmd.RES_PATH.."mahjong/male/Double.wav")
        end
	    end
	}
	local f = switch[iHuType]
	if(f) then
	    f()
	else  	-- for case default
    if lScore> 0 then
      self:PlaySound(cmd.RES_PATH.."mahjong/GAME_WIN.wav")
    elseif lScore< 0 then
      self:PlaySound(cmd.RES_PATH.."mahjong/GAME_LOST.wav")
    else
      self:PlaySound(cmd.RES_PATH.."mahjong/GAME_END.wav")
    end
	end

	--设置界面
	--if (IsLookonMode()==false)
  if true then
		self._gameView.m_btStart:setVisible(true)
		self._gameView:SetCurrentUser(yl.INVALID_CHAIR)
    self:SetGameClock(cmd.IDI_START_GAME, self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_START_GAME)
  end

	--取消托管
  if self.m_bStustee then
    self:OnStusteeControl(0,0)
  end

	--更新界面
	self._gameView:RefreshGameView()
	return true
end

--用户托管
function GameLayer:onSubTrustee(dataBuffer)
	print("用户托管")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_Trustee, dataBuffer)
	--dump(cmd_data, "trustee")

	self._gameView:SetTrustee(self:SwitchViewChairID(cmd_data.wChairID),cmd_data.bTrustee)
  if cmd_data.wChairID~=self:GetMeChairID() then
    local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),cmd_data.wChairID)
    if nil==pUserData then return true  end
    local szBuffer
    if cmd_data.bTrustee==true then
      szBuffer="玩家["..pUserData.szNickName.."]选择了托管功能."
    else
      szBuffer="玩家["..pUserData.szNickName.."]取消了托管功能."
		--m_pIStringMessage->InsertSystemString(szBuffer);    -------此处
		print(szBuffer)
    end
  end

	return true
end

--庄家买底
function GameLayer:OnSubDingDi(dataBuffer)
	print("庄家买底")
	--可能cmd_data.wChairID 不一定为0 1
	self.m_wCurrentUser = yl.INVALID_CHAIR
  self:KillGameClock(cmd.IDI_DINGDI_CARD)
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_DingDi, dataBuffer)
dump(cmd_data,"cmd_data",6)
print(" mark !!!!!!!!!! 临时去除 判断 cmd_data.wChairID",cmd_data.wChairID,self.m_wBankerUser)
  --if self.m_wBankerUser==cmd_data.wChairID then
    local wMeChair=self:GetMeChairID()
		-- 设置显示
    if self.m_wBankerUser ==wMeChair then
			self._gameView:SetCenterText("等待闲家顶底……")
    else
			local szMsg
      szMsg=""
			self._gameView:SetCenterText(szMsg)
			--一直为 false 同游戏开始的判断条件
      --if cmd_data.bDingDi then
				--ActiveGameFrame();
				self._gameView.m_btDingDi:setVisible(true)
				self._gameView.m_btDingCancel:setVisible(true);
				--m_GameClientView.m_btDingDi.EnableWindow(TRUE);
				--m_GameClientView.m_btDingCancel.EnableWindow(TRUE);
				self.m_wCurrentUser = wMeChair
      --end
    end
		self._gameView:SetCurrentUser(self:SwitchViewChairID(wMeChair))
    self:SetGameClock(cmd.IDI_DINGDI_CARD, wMeChair, cmd.IDI_DINGDI_CARD, cmd.TIME_OPERATE_CARD)
  --end

	return true
end

--播放出牌声音
function GameLayer:PlayCardSound(wChairID, cbCardData)
  if GameLogic:IsValidCard(cbCardData) == false then
    return
  end
  if wChairID < 0 or wChairID > 3 then
    return
  end

	--判断性别
  local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),wChairID)
  if pUserData==0 then
		--assert(0 && "得不到玩家信息");
		return
  end
	local bGirl = (pUserData.cbGender~=yl.GENDER_MANKIND) and true or false
	local cbType= bit:_and(cbCardData,GameLogic.MASK_COLOR)
	local cbValue= bit:_and(cbCardData,GameLogic.MASK_VALUE)
  if cbType== 0x30 and cbValue==7 then --白板，打财神的牌
		local cbGods=self._gameView:GetGodsCard()
		cbType= bit:_and(cbGods,GameLogic.MASK_COLOR)
		cbValue= bit:_and(cbGods,GameLogic.MASK_VALUE)
  end
  local strSoundName
  if cbType==0X30 then --风
    if cbValue==1 then
      strSoundName = "F_1"
    elseif cbValue==2 then
      strSoundName = "F_2"
    elseif cbValue==3 then
      strSoundName = "F_3"
    elseif cbValue==4 then
      strSoundName = "F_4"
    elseif cbValue==5 then
      strSoundName = "F_5"
    elseif cbValue==6 then
      strSoundName = "F_6"
    elseif cbValue==7 then
      strSoundName = "F_7"
    else
      --BU_HUA?
      strSoundName = "BU_HUA"
    end
  elseif cbType==0X20 then --筒
    strSoundName="T_"..cbValue
  elseif cbType==0X10 then --索
    strSoundName="S_"..cbValue
  elseif cbType==0X00 then --万
    strSoundName= "W_"..cbValue
  end

  if not bGirl then
		strSoundName = "male"..strSoundName
  else
		strSoundName = "female"..strSoundName
  end

  self:PlaySound(cmd.RES_PATH.."mahjong/"..strSoundName..".wav")
end

--播放声音
function GameLayer:PlayActionSound(wChairID, cbAction)
	--判断性别
  local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),wChairID)
  if pUserData == 0 then
		--assert(0 && "得不到玩家信息");
		return
  end
  if wChairID < 0 or wChairID > 3 then
		return
  end
	local bGirl = (pUserData.cbGender~=yl.GENDER_MANKIND) and true or false

  if cbAction==GameLogic.WIK_NULL then          --取消
    if not bGirl then
      --BOY_OUT_CARD
      self:PlaySound(cmd.RES_PATH.."mahjong/OUT_CARD.wav")
    else
      --GIRL_OUT_CARD
      self:PlaySound(cmd.RES_PATH.."mahjong/OUT_CARD.wav")
    end
  elseif cbAction==GameLogic.WIK_LEFT then
  elseif cbAction==GameLogic.WIK_CENTER then
  elseif cbAction==GameLogic.WIK_RIGHT then      --上牌
    if not bGirl then
      self:PlaySound(cmd.RES_PATH.."mahjong/male/CHI.wav")
    else
      self:PlaySound(cmd.RES_PATH.."mahjong/female/CHI.wav")
    end
  elseif cbAction==GameLogic.WIK_PENG then       --碰牌
    if not bGirl then
      self:PlaySound(cmd.RES_PATH.."mahjong/male/PENG.wav")
    else
      self:PlaySound(cmd.RES_PATH.."mahjong/female/PENG.wav")
    end
  elseif cbAction==GameLogic.WIK_GANG then       --杠牌
    if not bGirl then
      self:PlaySound(cmd.RES_PATH.."mahjong/male/GANG.wav")
    else
      self:PlaySound(cmd.RES_PATH.."mahjong/female/GANG.wav")
    end
  elseif cbAction==GameLogic.WIK_CHI_HU then     --吃胡
    if not bGirl then
      self:PlaySound(cmd.RES_PATH.."mahjong/male/CHI_HU.wav")
    else
      self:PlaySound(cmd.RES_PATH.."mahjong/female/CHI_HU.wav")
    end
  elseif cbAction==GameLogic.WIK_LISTEN then     --听牌
    if not bGirl then
      self:PlaySound(cmd.RES_PATH.."mahjong/male/TING.wav")
    else
      self:PlaySound(cmd.RES_PATH.."mahjong/female/TING.wav")
    end
  end

  return
end

--出牌判断
function GameLayer:VerdictOutCard(cbCardData)
	--听牌判断
  if (self.m_bHearStatus==true) or (self.m_bWillHearStatus==true) then
		--变量定义
		ChiHuResult={}
    local wMeChairID=self:GetMeChairID()
		local cbWeaveCount=self.m_cbWeaveCount[wMeChairID]

		--构造扑克
		local cbCardIndexTemp={}
  	local cbCardIndexTemp=GameLogic:deepcopy(self.m_cbCardIndex)

		--删除扑克
		cbCardIndexTemp=GameLogic:RemoveCard(cbCardIndexTemp,cbCardData)
    while true do
      for i=1,cmd.MAX_INDEX,1 do
  			--胡牌分析
  			local wChiHuRight=0;
  			local cbCurrentCard=GameLogic:SwitchToCardData(i)
  			local cbHuCardKind=GameLogic:AnalyseChiHuCard(cbCardIndexTemp,self.m_WeaveItemArray[wMeChairID],cbWeaveCount,cbCurrentCard,wChiHuRight,ChiHuResult)

  			--结果判断
        if cbHuCardKind~=GameLogic.CHK_NULL then break end
      end
    break end

		--听牌判断
		return (i~=cmd.MAX_INDEX)

  end

	return true
end

--扣除扑克
function GameLayer:DeductionTableCard(bHeadCard)
  if bHeadCard==true then
		--切换索引
print("== 扣除扑克")
dump(self.m_cbHeapCardInfo,"self.m_cbHeapCardInfo",6)
print(self.m_wHeapHand,self.m_cbHeapCardInfo[self.m_wHeapHand],self.m_cbHeapCardInfo[self.m_wHeapHand+1])
		local cbHeapCount=self.m_cbHeapCardInfo[self.m_wHeapHand+1][1]+self.m_cbHeapCardInfo[self.m_wHeapHand+1][2]

    if cbHeapCount==CardControl.HEAP_FULL_COUNT then
			self.m_wHeapHand=(self.m_wHeapHand+1)%(GameLogic:table_leng(self.m_cbHeapCardInfo))
    end

		--减少扑克
		self.m_cbLeftCardCount=self.m_cbLeftCardCount-1
		self.m_cbHeapCardInfo[self.m_wHeapHand+1][1]=self.m_cbHeapCardInfo[self.m_wHeapHand+1][1]+1

		--堆立扑克
		local wHeapViewID=self:SwitchHeapViewChairID(self.m_wHeapHand)  --m_wHeapHand+6-GetMeChairID()*2)%4;
		local wMinusHeadCount=self.m_cbHeapCardInfo[self.m_wHeapHand+1][1]
		local wMinusLastCount=self.m_cbHeapCardInfo[self.m_wHeapHand+1][2]
	print("===堆立扑克 55SetCardData ",self.m_wHeapHand)
	print("index ->",wHeapViewID+1,wMinusHeadCount,wMinusLastCount,CardControl.HEAP_FULL_COUNT)
		self._gameView.m_HeapCard[wHeapViewID+1]:SetCardData(wMinusHeadCount,wMinusLastCount,CardControl.HEAP_FULL_COUNT)
  else
		--切换索引
		local cbHeapCount=self.m_cbHeapCardInfo[self.m_wHeapTail+1][1]+self.m_cbHeapCardInfo[self.m_wHeapTail+1][2]
    if cbHeapCount==CardControl.HEAP_FULL_COUNT then
  		self.m_wHeapTail=(self.m_wHeapTail+1)%(GameLogic:table_leng(self.m_cbHeapCardInfo))
    end

		--减少扑克
		self.m_cbLeftCardCount=self.m_cbLeftCardCount-1
		self.m_cbHeapCardInfo[self.m_wHeapTail+1][2]=self.m_cbHeapCardInfo[self.m_wHeapTail+1][2]+1

		--堆立扑克
		local wHeapViewID=self:SwitchHeapViewChairID(self.m_wHeapTail-1)
		local wMinusHeadCount=self.m_cbHeapCardInfo[self.m_wHeapTail+1][1]
		local wMinusLastCount=self.m_cbHeapCardInfo[self.m_wHeapTail+1][2]
	print("===堆立扑克 66 SetCardData ")
	print("index ->",wHeapViewID+1,wMinusHeadCount,wMinusLastCount,CardControl.HEAP_FULL_COUNT)
		self._gameView.m_HeapCard[wHeapViewID+1]:SetCardData(wMinusHeadCount,wMinusLastCount,CardControl.HEAP_FULL_COUNT)
  end

dump(self.m_cbHeapCardInfo,"self.m_cbHeapCardInfo",6)
	return
end

--显示控制
function GameLayer:ShowOperateControl(cbUserAction, cbActionCard)
	--变量定义
	local GangCardResult={}
	GangCardResult.cbCardCount=0
	GangCardResult.cbGangType=0
	GangCardResult.cbCardData=GameLogic:sizeF(4)

  --杠牌判断
  if bit:_and(cbUserAction,GameLogic.WIK_GANG)~=0 then
		--桌面杆牌
    if cbActionCard~=0 then
			GangCardResult.cbCardCount=1
			GangCardResult.cbCardData[1]=cbActionCard
    end

    --自己杆牌
    if cbActionCard==0 then
      local wMeChairID=self:GetMeChairID()
			local arg1
			arg1,GangCardResult=GameLogic:AnalyseGangCard(self.m_cbCardIndex,self.m_WeaveItemArray[wMeChairID],self.m_cbWeaveCount[wMeChairID],GangCardResult)
    end
  end

	--显示界面
	--if (IsLookonMode()==false)
  if true then
		self._gameView.m_ControlWnd:SetControlInfo(cbActionCard,cbUserAction,GangCardResult)
		self.m_cbUserAction = cbUserAction
  end

	return true
end


--*****************************    发送消息     *********************************--
--开始按钮
--LRESULT CGameClientEngine::OnStart(WPARAM wParam, LPARAM lParam)   --   LRESULT   !!  mark
function GameLayer:OnStart()
	--环境设置
	self:KillGameClock(cmd.IDI_START_GAME)
print("self._gameView.m_btStart",self._gameView.m_btStart)
	self._gameView.m_btStart:setVisible(false)
	self._gameView.m_ControlWnd:setVisible(false)
	self._gameView.m_ScoreControl:RestorationData()
	--时间显示
	if self._gameView.DrawUserTimerEx then
		self._gameView:DrawUserTimerEx(nil,yl.WIDTH/2,yl.HEIGHT/2,"00")
	end
	print(self._gameView.mARROW,self._gameView.m_ImageCenter,self._gameView.ImageTimeNumber)
	self._gameView.mARROW:setVisible(false)
	self._gameView.m_ImageCenterTime:setVisible(false)
	self._gameView.ImageTimeNumber:setVisible(false)

	-- self._gameView.m_btMaiDi:setVisible(true)
	-- self._gameView.m_btDingDi:setVisible(true)
	-- self._gameView.m_btMaiCancel:setVisible(true)
	-- self._gameView.m_btDingCancel:setVisible(true)
	self._gameView:showReady(0)

	--设置界面
	self._gameView:SetDiscUser(yl.INVALID_CHAIR)
	self._gameView:SetHuangZhuang(false)
	self._gameView:SetStatusFlag(false,false)
	self._gameView:SetBankerUser(yl.INVALID_CHAIR)
	self._gameView:SetUserAction(yl.INVALID_CHAIR,0)
	self._gameView:SetOutCardInfo(yl.INVALID_CHAIR,0)
	self._gameView:SetUserListenStatus(yl.INVALID_CHAIR,false)

	--扑克设置
	self._gameView.m_UserCard[1]:SetCardData(0,false)
	self._gameView.m_UserCard[2]:SetCardData(0,false)
	self._gameView.m_HandCardControl:SetCardData(nil,0,0)
	self._gameView:SetGodsCard( 0x00 )
	self._gameView.m_HandCardControl:SetGodsCard( 0x00 )
	self._gameView:SetDingMaiValue(nil)

	--扑克设置
  for i=1,cmd.GAME_PLAYER,1 do
		self._gameView.m_TableCard[i]:SetCardData(nil,0)
		self._gameView.m_DiscardCard[i]:SetCardData(nil,0)
		self._gameView.m_WeaveCard[i][1]:SetCardData(nil,0)
		self._gameView.m_WeaveCard[i][2]:SetCardData(nil,0)
		self._gameView.m_WeaveCard[i][3]:SetCardData(nil,0)
		self._gameView.m_WeaveCard[i][4]:SetCardData(nil,0)
		self._gameView.m_WeaveCard[i][5]:SetCardData(nil,0)
  end

	--堆立扑克
  for i=1,4,1 do
		self.m_cbHeapCardInfo[i][1]=0
		self.m_cbHeapCardInfo[i][2]=0
		self._gameView.m_HeapCard[i]:SetGodsCard( 0x00, 0x00, 0x00)
	print("===堆立扑克 OnStart SetCardData ")
	print("i -> ",i,self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
		self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
  end

	--状态变量
	self.m_bHearStatus=false
	self.m_bWillHearStatus=false

	--游戏变量
	self.m_wCurrentUser=yl.INVALID_CHAIR

	--出牌信息
	self.m_cbOutCardData=0
	self.m_wOutCardUser=yl.INVALID_CHAIR
  self.m_cbDiscardCard=GameLogic:ergodicList(cmd.GAME_PLAYER)
  self.m_cbDiscardCount=GameLogic:sizeM(cmd.GAME_PLAYER)

	--组合扑克
  self.m_cbWeaveCount=GameLogic:sizeM(cmd.GAME_PLAYER)
  self.m_WeaveItemArray=GameLogic:ergodicList(cmd.GAME_PLAYER)

	--堆立扑克
  self.m_wHeapHand=0
  self.m_wHeapTail=0
  self.m_cbHeapCardInfo=GameLogic:ergodicList(4)

	--扑克变量
  self.m_cbLeftCardCount=0
  self.m_cbCardIndex=GameLogic:sizeM(cmd.MAX_INDEX)

	--更新界面
	self._gameView:RefreshGameView()

	--发送消息
	--SendUserReady(NULL,0);
	self:SendUserReady()

	return 0
end

function GameLayer:OnOutInvalidCard()
  if cmd.GS_MJ_PLAY ~= self._gameFrame:GetGameStatus() then
		return 0
  end

	--出牌判断
  if self.m_wCurrentUser~=self:GetMeChairID() then	return 0  end

	self._gameView.m_bTipSingle=true
	--self._gameView.SetTimer(102/*IDI_TIP_SINGLE*/,2500,NULL);
  self:F_GVSetTimer(102,250)
	self._gameView:RefreshGameView()

	return 0
end

function GameLayer:OnOutCard(wParam, lParam)
print("出牌 OnOutCard ",wParam, lParam)
print(self.m_wCurrentUser,self:GetMeChairID(),cmd.GS_MJ_PLAY , self._gameFrame:GetGameStatus())
  self:KillGameClock(cmd.IDI_OPERATE_CARD)

  if cmd.GS_MJ_PLAY ~= self._gameFrame:GetGameStatus() then
		return 0
  end

	--出牌判断
  if self.m_wCurrentUser~=self:GetMeChairID() then	return 0  end

	--听牌判断
  if ((self.m_bHearStatus==true) or (self.m_bWillHearStatus==true)) and ((self:VerdictOutCard(wParam)==false) or (self:VerdictOutCard(wParam)==0)) then
		--m_pIStringMessage->InsertSystemString(TEXT("出此牌不符合游戏规则!"));  --此处
		print("出此牌不符合游戏规则")
		return 0
  end

	--听牌设置
  if self.m_bWillHearStatus==true then
		self.m_bHearStatus=true
		self.m_bWillHearStatus=false
  end

	--设置变量
	self.m_wCurrentUser=yl.INVALID_CHAIR
	local cbOutCardData=wParam
	self.m_cbCardIndex=GameLogic:RemoveCard(self.m_cbCardIndex,cbOutCardData)

	--设置扑克
	local cbCardData={}
	local cbCardCount,arg2=GameLogic:SwitchToCardData(self.m_cbCardIndex,cbCardData)
	cbCardData=arg2
print("-=-= gameView.m_HandCardControl:SetCardDat",cbCardData,cbCardCount,0)
	self._gameView.m_HandCardControl:SetCardData(cbCardData,cbCardCount,0)

	--设置界面
  self:KillGameClock(cmd.IDI_OPERATE_CARD)
	self._gameView:RefreshGameView()
	self._gameView:SetStatusFlag(false,false)
	self._gameView:SetUserAction(yl.INVALID_CHAIR,0)
	self._gameView:SetOutCardInfo(1,cbOutCardData)
	self._gameView.m_ControlWnd:setVisible(false)

	--播放声音
  self:PlayCardSound(self:GetMeChairID(),cbOutCardData)

	--发送数据
	local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_OutCard)
	cmd_data:pushbyte(cbOutCardData)
	self:SendData(cmd.SUB_C_OUT_CARD, cmd_data)

	return 0
end

--听牌操作
function GameLayer:OnListenCard()
	return 0
end

--扑克操作
function GameLayer:OnCardOperate(wParam, lParam)
	--变量定义
	local cbOperateCode=wParam
	local cbOperateCard=lParam
print("==扑克操作 OnCardOperate",cbOperateCode, cbOperateCard)

	--状态判断
  if (self.m_wCurrentUser==self:GetMeChairID()) and (cbOperateCode==GameLogic.WIK_NULL) then
		self._gameView.m_ControlWnd:setVisible(false)
		return 0
  end

	--删除时间
  self:KillGameClock(cmd.IDI_OPERATE_CARD)

	--环境设置
	self._gameView:SetStatusFlag(false,true)
	self._gameView.m_ControlWnd:setVisible(false)

	--发送命令
	local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_OperateCard)
	cmd_data:pushbyte(cbOperateCode)
	cmd_data:pushbyte(cbOperateCard)
	self:SendData(cmd.SUB_C_OPERATE_CARD, cmd_data)

	return 0
end

--扑克操作
function GameLayer:OnStusteeControl(wParam, lParam)
	--设置变量
  self.m_wTimeOutCount=0

	--设置状态
  if self.m_bStustee==true then
		self.m_bStustee=false
		--self._gameView.m_btStusteeControl.SetButtonImage(IDB_BT_START_TRUSTEE,AfxGetInstanceHandle(),false,false);     mark 待完成界面后修改
		print("您取消了托管功能")
		--m_pIStringMessage->InsertSystemString(_T("您取消了托管功能."));   --
  	local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_Trustee)
  	cmd_data:pushbool(false)
  	self:SendData(cmd.SUB_C_TRUSTEE, cmd_data)
  else
		self.m_bStustee=true
		--self._gameView.m_btStusteeControl.SetButtonImage(IDB_BT_STOP_TRUSTEE,AfxGetInstanceHandle(),false,false);        mark 待完成界面后修改
		print("您选择了托管功能")
		--m_pIStringMessage->InsertSystemString(_T("您选择了托管功能."));   --
  	local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_Trustee)
  	cmd_data:pushbool(true)
  	self:SendData(cmd.SUB_C_TRUSTEE, cmd_data)
  end
end

--
function GameLayer:OnDingDi(wParam, lParam)
print("====顶买",wParam, lParam)
	self._gameView.m_btMaiDi:setVisible(false)
	self._gameView.m_btDingDi:setVisible(false)
	self._gameView.m_btMaiCancel:setVisible(false)
	self._gameView.m_btDingCancel:setVisible(false)
  if cmd.GS_MJ_MAIDI ~= self._gameFrame:GetGameStatus() then
		return 0
  end
	self.m_wCurrentUser = yl.INVALID_CHAIR
	-- 发送顶底消息
  local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_DingDi)
  cmd_data:pushbyte((2==wParam) and 0x02 or 0x01)
  self:SendData(cmd.SUB_C_DINGDI, cmd_data)
	return 0
end

function GameLayer:IsFreeze(void)
	return false
end

--
function GameLayer:OnDispatchCard(wParam, lParam)
print("OnDispatchCard ",wParam, lPara,self.m_bySicboAnimCount)
  self:KillGameClock(cmd.IDI_DINGDI_CARD)
	self._gameView:StopSicboAnim()
	self.m_bySicboAnimCount=self.m_bySicboAnimCount+1
  if 1 == self.m_bySicboAnimCount then
    local pGamePlay=self.m_sGamePlay
    if 0 == wParam then
			-- 打第二次骰子
			local bySicbo = {bit:_rshift(pGamePlay.wSiceCount3,8) , bit:_and(pGamePlay.wSiceCount3, 0xff)}
print("打第二次骰子 色子 StartSicboAnim")
dump(bySicbo,"bySicbo",6)
			self._gameView:StartSicboAnim(bySicbo)
    end
		return 0
  elseif 2 == self.m_bySicboAnimCount then
		-- 显示出牌
    local pGamePlay=self.m_sGamePlay

    local wMeChairID=self:GetMeChairID()
		local bPlayerMode=true

		self.m_wCurrentUser=pGamePlay.wCurrentUser
		GameLogic:SetGodsCard(pGamePlay.byGodsCardData)
		self._gameView:SetGodsCard(pGamePlay.byGodsCardData)

  	self.m_cbCardIndex=GameLogic:sizeM(cmd.MAX_INDEX)

		--设置扑克
		local cbCardCount=(wMeChairID==self.m_wBankerUser) and cmd.MAX_COUNT or (cmd.MAX_COUNT-1)
		--GetMeChairID 0 ~ 1 此处1起始 为 1 ~ 2
		local arg1,arg2=GameLogic:SwitchToCardIndex(pGamePlay.cbCardData[wMeChairID+1],cbCardCount,self.m_cbCardIndex)
		self.m_cbCardIndex=arg2
		-- 换算出财神牌的位置
		local byCount = CardControl.HEAP_FULL_COUNT - self.m_cbHeapCardInfo[self.m_wHeapTail+1][2]
		local bySicbo = bit:_rshift(pGamePlay.wSiceCount3,8) + bit:_and(pGamePlay.wSiceCount3, 0xff)
		local byChairID = wMeChairID
    if byCount >= bySicbo then
			byChairID = self.m_wHeapTail
    else
			byChairID = (self.m_wHeapTail + 4 - 1)%4
			bySicbo =  bySicbo - byCount
    end
		--转换椅子
		local wViewChairID=self:SwitchHeapViewChairID(byChairID)
    --mark 不确定wViewChairID 下标是否正确
		self._gameView.m_HeapCard[wViewChairID+1]:SetGodsCard(pGamePlay.byGodsCardData,bySicbo, self.m_cbHeapCardInfo[byChairID+1][2])

		--更新界面
		self._gameView:SetCenterText("")
		-- 发牌，并打第三次骰子
    if 0 == wParam then
      local bySicbo = {bit:_rshift(pGamePlay.wSiceCount2,8) , bit:_and(pGamePlay.wSiceCount2, 0xff)}
print("发牌，并打第三次骰子  StartSicboAnim")
dump(bySicbo,"bySicbo",6)
			self._gameView:StartSicboAnim(bySicbo)
    end
		return 0
  else
		--设置变量
    local pGamePlay=self.m_sGamePlay
		self.m_bHearStatus=false
		self.m_bWillHearStatus=false
		self.m_cbLeftCardCount=cmd.MAX_REPERTORY-cmd.GAME_PLAYER*(cmd.MAX_COUNT-1)-1

		self._gameView.m_HandCardControl:SetGodsCard(pGamePlay.byGodsCardData)

		--出牌信息
		self.m_cbOutCardData=0
		self.m_wOutCardUser=yl.INVALID_CHAIR
    self.m_cbDiscardCard=GameLogic:ergodicList(cmd.GAME_PLAYER)
    self.m_cbDiscardCount=GameLogic:sizeM(cmd.GAME_PLAYER)

		--组合扑克
  	self.m_cbWeaveCount=GameLogic:sizeM(cmd.GAME_PLAYER)
    self.m_WeaveItemArray=GameLogic:ergodicList(cmd.GAME_PLAYER)
  	self.m_cbCardIndex=GameLogic:sizeM(cmd.MAX_INDEX)

    local wMeChairID=self:GetMeChairID()

		--设置扑克
		local cbCardCount=(wMeChairID==self.m_wBankerUser) and cmd.MAX_COUNT or (cmd.MAX_COUNT-1)
		local aarg1,arg2=GameLogic:SwitchToCardIndex(pGamePlay.cbCardData[wMeChairID+1],cbCardCount,self.m_cbCardIndex)
		self.m_cbCardIndex=arg2

		--设置界面
		local bPlayerMode=true
		self._gameView:SetUserListenStatus(yl.INVALID_CHAIR,false)
		self._gameView.m_HandCardControl:SetPositively(false)
		--self._gameView:SetBankerUser(self:SwitchViewChairID(self.m_wBankerUser))
		self._gameView:SetBankerUser(self.m_wBankerUser)
		self._gameView:SetDiscUser(yl.INVALID_CHAIR)

		--旁观界面
    if bPlayerMode==false then
			self._gameView:SetHuangZhuang(false)
			self._gameView:SetStatusFlag(false,false)
			self._gameView:SetUserAction(yl.INVALID_CHAIR,0)
			self._gameView:SetOutCardInfo(yl.INVALID_CHAIR,0)
    end

    for i=1,4,1 do
			self.m_cbHeapCardInfo[i][1]=0
			self.m_cbHeapCardInfo[i][2]=0
    end

		-- 分发扑克
		--第一把骰子的玩家 门前开始数牌
	print(" 第一把骰子的玩家 门前开始数牌")
		local cbSiceFirst=(bit:_rshift(pGamePlay.wSiceCount1,8) + bit:_and(pGamePlay.wSiceCount1, 0xff)-1)%4
		local wTakeChairID = (self.m_wBankerUser*2 + 4 - cbSiceFirst)%4
		local cbSiceSecond= bit:_rshift(pGamePlay.wSiceCount2,8) + bit:_and(pGamePlay.wSiceCount2, 0xff)
			+ (bit:_rshift(pGamePlay.wSiceCount1,8) + bit:_and(pGamePlay.wSiceCount1, 0xff))
    if (cbSiceSecond*2)>CardControl.HEAP_FULL_COUNT then
			wTakeChairID = (wTakeChairID + 1)%4
			cbSiceSecond = cbSiceSecond-(CardControl.HEAP_FULL_COUNT/2)
    end
		self.m_wHeapTail = wTakeChairID%4
		------------------------------------------------------------------
		local cbTakeCount=(cmd.MAX_COUNT-1)*2+1

dump(self.m_cbHeapCardInfo,"self.m_cbHeapCardInfo",6)
    while true do
      for i=1,2,1 do
  			--计算数目
				local cbValidCount=CardControl.HEAP_FULL_COUNT-self.m_cbHeapCardInfo[wTakeChairID+1][2]-((i==0+1) and (cbSiceSecond-1)*2 or 0)
				cbValidCount=cbValidCount+2
				local cbRemoveCount=(cbValidCount < cbTakeCount) and cbValidCount or cbTakeCount
        if i==2 then cbRemoveCount=cbTakeCount end
				self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]=self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]+cbRemoveCount
				print(wTakeChairID,"等待",cbSiceSecond,"点数为",cbRemoveCount,cbTakeCount)

        --提取扑克
        cbTakeCount=cbTakeCount-cbRemoveCount

  			--完成判断
      	if cbTakeCount==0 then
  				self.m_wHeapHand=wTakeChairID
        break	end

  			--切换索引
				wTakeChairID=(wTakeChairID+1)%4
				self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]=self.m_cbHeapCardInfo[wTakeChairID+1][(i==0+1) and 1+1 or 0+1]+cbTakeCount-1
				break

      end
    break end
    -------------------------------------------------------------------
		self.m_wHeapHand = (self.m_wHeapTail+1)%4
		self.m_cbHeapCardInfo[self.m_wHeapHand+1][1]=1
dump(self.m_cbHeapCardInfo,"self.m_cbHeapCardInfo",6)

    for i=1,4,1 do
			--变量定义
			local wViewChairID=self:SwitchHeapViewChairID(i-1)
print("== m_HeapCard",self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][1],CardControl.HEAP_FULL_COUNT)
			self._gameView.m_HeapCard[wViewChairID+1]:SetCardData(self.m_cbHeapCardInfo[i][1],self.m_cbHeapCardInfo[i][2],CardControl.HEAP_FULL_COUNT)
    end
    -------------------------------------------------------------------
		local byCardsIndex=GameLogic:sizeM(cmd.MAX_INDEX)
		-- BYTE byCardsIndex[MAX_INDEX]={0};
		-- ZeroMemory(byCardsIndex,sizeof(byCardsIndex));
		local arg1,arg2=GameLogic:SwitchToCardIndex(pGamePlay.cbCardData[wMeChairID+1],(cmd.MAX_COUNT-1),byCardsIndex)
		byCardsIndex=arg2

		local byCards=GameLogic:sizeM(cmd.MAX_COUNT)
		-- BYTE byCards[MAX_COUNT]={0};
		-- ZeroMemory(byCards,sizeof(byCards));
		local arg1,arg2=GameLogic:SwitchToCardData(byCardsIndex, byCards)
		byCards=arg2

  	--扑克设置
    for i=1,cmd.GAME_PLAYER,1 do
      --变量定义
			local wViewChairID=self:SwitchViewChairID(i-1)

			--组合界面
			self._gameView.m_WeaveCard[i][1]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][2]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][3]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][4]:SetDisplayItem(true)
			self._gameView.m_WeaveCard[i][5]:SetDisplayItem(true)

			--用户扑克
print("===mark 3",wMeChairID)
dump(pGamePlay,"pGamePlay",6)
      if i~=wMeChairID+1 then
				local wIndex=(wViewChairID>=3) and 2 or wViewChairID
				self._gameView.m_UserCard[wIndex]:SetCardData(GameLogic:table_leng((pGamePlay.cbCardData[wMeChairID+1]))-1,(i==self.m_wBankerUser))
      else
				local cbBankerCard=(i==self.m_wBankerUser) and pGamePlay.cbCardData[wMeChairID+1][cmd.MAX_COUNT-1] or 0
print("-=-= gameView.m_HandCardControl:SetCardDat",byCards,cmd.MAX_COUNT-1,cbBankerCard)
				self._gameView.m_HandCardControl:SetCardData(byCards,cmd.MAX_COUNT-1,cbBankerCard)
      end

			--旁观界面
      -- if bPlayerMode==false then
			-- 	self._gameView.m_TableCard[wViewChairID]:SetCardData(nil,0)
			-- 	self._gameView.m_DiscardCard[wViewChairID]:SetCardData(nil,0)
			-- 	self._gameView.m_WeaveCard[wViewChairID][1]:SetCardData(nil,0)
			-- 	self._gameView.m_WeaveCard[wViewChairID][2]:SetCardData(nil,0)
			-- 	self._gameView.m_WeaveCard[wViewChairID][3]:SetCardData(nil,0)
			-- 	self._gameView.m_WeaveCard[wViewChairID][4]:SetCardData(nil,0)
			-- 	self._gameView.m_WeaveCard[wViewChairID][5]:SetCardData(nil,0)
      -- end
    end
		self._gameView.m_HandCardControl:SetOutCardData(nil, 0)

		--更新界面
		self._gameView:SetCenterText("")

    self._gameFrame:SetGameStatus(cmd.GS_MJ_PLAY)
		--出牌提示
    if (bPlayerMode==true) and (self.m_wCurrentUser~=yl.INVALID_CHAIR) then
      if self.m_wCurrentUser==wMeChairID then
				--ActiveGameFrame();
				self._gameView:SetStatusFlag(true,false)
      end
    end
		self._gameView.m_HandCardControl:SetOutCardData(nil, 0)
		self._gameView.m_HandCardControl:SetPositively(bPlayerMode)  -- 现在才可以出牌

		--动作处理
    if (bPlayerMode==true) and (pGamePlay.cbUserAction~=GameLogic.WIK_NULL) then
			self:ShowOperateControl(pGamePlay.cbUserAction,0)
      self:SetGameClock(cmd.IDI_OPERATE_CARD, self:GetMeChairID(), cmd.IDI_OPERATE_CARD, cmd.TIME_OPERATE_CARD)
    end

		--设置时间
    if self.m_wCurrentUser~=yl.INVALID_CHAIR then
      if (self.m_wCurrentUser == wMeChairID) and (GameLogic.WIK_NULL==pGamePlay.cbUserAction) then
				self._gameView.m_HandCardControl:UpdateCardDisable(true)
      end
			self._gameView:SetCurrentUser(self:SwitchViewChairID(self.m_wCurrentUser))
      self:SetGameClock(cmd.IDI_OPERATE_CARD, self.m_wCurrentUser, cmd.IDI_OPERATE_CARD, cmd.TIME_OPERATE_CARD)
    end
  end
  return 0
end

function GameLayer:SwitchHeapViewChairID(wChairID)
	-- 转换椅子0位置为0， 1的位置为2
	local wViewChairID=(wChairID+4-self:GetMeChairID()*2)
	wViewChairID =wViewChairID + 2
print("SwitchHeapViewChairID",wChairID,self:GetMeChairID(),wViewChairID%4)
	return wViewChairID%4
end

return GameLayer
