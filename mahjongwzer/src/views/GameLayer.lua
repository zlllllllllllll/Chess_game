local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.GameViewLayer")
local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local ScoreControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ScoreControl")
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function GameLayer:ctor(frameEngine, scene)
    GameLayer.super.ctor(self, frameEngine, scene)
end

function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

--ZeroMemory
function GameLayer:ergodicList(b)
	a={}
	for i=0,b-1,1 do
		a[i]={}
	end
	return a
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
  self.m_cbHeapCardInfo=ergodicList(4)

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
  self.m_cbDiscardCard=ergodicList(cmd.GAME_PLAYER)
  self.m_cbDiscardCount={}


  --组合扑克
  -- BYTE	m_cbWeaveCount[GAME_PLAYER];		--组合数目
  -- tagWeaveItem	m_WeaveItemArray[GAME_PLAYER][MAX_WEAVE];	--组合扑克
  self.m_cbWeaveCount={}
  self.m_WeaveItemArray=ergodicList(cmd.GAME_PLAYER)

  --扑克变量
  self.m_cbLeftCardCount=0
  --BYTE	m_cbCardIndex[MAX_INDEX];			--手中扑克
  self.m_cbCardIndex={}
  self.m_bySicboAnimCount = 0
  -- CMD_S_GamePlay   m_sGamePlay;  -- 游戏发牌消息
  self.m_sGamePlay={}

	self.m_cbUserAction=0
end

function GameLayer:OnInitGameEngine()

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
  CardControl.LoadResource()

  --打开注册表
  --xxxxxxx m_bChineseVoice=true 估计无用

	-- CGlobalUnits *pGlobalUnits=CGlobalUnits::GetInstance();
	-- IGameFrameWnd * pIGameFrameWnd=(IGameFrameWnd *)pGlobalUnits->QueryGlobalModule(MODULE_GAME_FRAME_WND,IID_IGameFrameWnd,VER_IGameFrameWnd);
	-- if(pIGameFrameWnd)pIGameFrameWnd->RestoreWindow();

	print("Hello Hello!")
end

function GameLayer:OnResetGameEngine()
  GameLayer.super.OnResetGameEngine(self)
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
	self._gameView.m_UserCard[0]:SetCardData(0,false)        --  mark 多个相同的子类 下同
	self._gameView.m_UserCard[1]:SetCardData(0,false)
	self._gameView.m_HandCardControl:SetCardData(NULL,0,0)
	self._gameView:SetGodsCard( 0x00 )
	self._gameView.m_HandCardControl:SetGodsCard( 0x00 )
	self._gameView:SetDingMaiValue(NULL)


	--扑克设置
  for i=0,cmd.GAME_PLAYER-1,1 do
		self._gameView.m_TableCard[i]:SetCardData(NULL,0)
		self._gameView.m_DiscardCard[i]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][0]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][1]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][2]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][3]:SetCardData(NULL,0)
		self._gameView.m_WeaveCard[i][4]:SetCardData(NULL,0)
  end

	--堆立扑克
  for i=0,cmd.4-1,1 do
		self.m_cbHeapCardInfo[i][0]=0
		self.m_cbHeapCardInfo[i][1]=0
		self._gameView.m_HeapCard[i]:SetGodsCard( 0x00, 0x00, 0x00)
		self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][0],self.m_cbHeapCardInfo[i][1],CardControl.HEAP_FULL_COUNT)
  end

  --self:ResetVariable()
end

-- 设置计时器   多ID
function GameLayer:SetGameClock(Fid,chair,id,time)
    self._ClockList[Fid]={}
    if not self._ClockList[Fid]._ClockFun then
        local this = self
      self._ClockList[Fid]._ClockFun = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                this:OnClockUpdata(Fid)
            end, 1, false)
    end
    self._ClockList[Fid]._ClockChair = chair
    self._ClockList[Fid]._ClockID = id
    self._ClockList[Fid]._ClockTime = time
    self._ClockList[Fid]._ClockViewChair = self:SwitchViewChairID(chair)
    self:OnUpdataClockView(Fid)
end
--[[
function GameLayer:GetClockViewID()
    return self._ClockViewChair --ViewChair
end
--]]
-- 关闭计时器   多ID
function GameLayer:KillGameClock(Fid,notView)
    print("KillGameClock")
    self._ClockList[Fid]._ClockID = yl.INVALID_ITEM
    self._ClockList[Fid]._ClockTime = 0
    self._ClockList[Fid]._ClockChair = yl.INVALID_CHAIR
    self._ClockList[Fid]._ClockViewChair = yl.INVALID_CHAIR
    if self._ClockList[Fid]._ClockFun then
        --注销时钟
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ClockList[Fid]._ClockFun)
        self._ClockList[Fid]._ClockFun = nil
    end
    if not notView then
        self:OnUpdataClockView(Fid)
    end
end

--计时器更新 多ID
function GameLayer:OnClockUpdata(Fid)
    if  self._ClockList[Fid]._ClockID ~= yl.INVALID_ITEM then
        self._ClockList[Fid]._ClockTime = self._ClockList[Fid]._ClockTime - 1
        local result = self:OnEventGameClockInfo(self._ClockList[Fid]._ClockChair,self._ClockList[Fid]._ClockTime,self._ClockList[Fid]._ClockID)
        if result == true   or self._ClockList[Fid]._ClockTime < 1 then
            self:KillGameClock(Fid)
        end
    end
    self:OnUpdataClockView(Fid)
end

--更新计时器显示 多ID
function GameModel:OnUpdataClockView(Fid)
    if self._gameView and self._gameView.OnUpdataClockView then
        self._gameView:OnUpdataClockView(self._ClockList[Fid]._ClockViewChair,self._ClockList[Fid]._ClockTime)
    end
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

function GameLayer:onExitRoom()
    self._gameFrame:onCloseSocket()
    self:stopAllActions()
    --mark
    --self:KillGameClock()
    for k, v in pairs(self._ClockList) do
    	self:KillGameClock(k)
    end
    self:dismissPopWait()
    --self._scene:onChangeShowMode(yl.SCENE_ROOMLIST)
    self._scene:onKeyBack()
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
    self._scene:createVoiceBtn(cc.p(1250, 300))
    GameLayer.super.onEnterTransitionFinish(self)
end

-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
  local switch = {
  		[cmd.IDI_START_GAME] = function()    --开始游戏 开始定时器
          if time==0 then
    				--AfxGetMainWnd()->PostMessage(WM_CLOSE);   --mark
      			self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊，如果有的话
    				return false
          end
          --if (time<=5) and (IsLookonMode()==false) then    -- 一律返回false 不许旁观
          if time<=5 then
    					--PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
          		self:PlaySound(cmd.RES_PATH.."sound/GAME_WARN.wav")
          end
  				return true
  		end,
  		[cmd.IDI_DINGDI_CARD] = function()    --开始游戏
          --[[   一律返回false 不许旁观
      			if (IsLookonMode())
      			{
      				return true;
      			}
          --]]
    			local wMeChairID=self:GetMeChairID()
    			if (self.m_wCurrentUser == wMeChairID) and (0 == time)
    			{
    				self:OnDingDi(1, 0)
    				return true
    			}

    			if (time<=3) and (chair==wMeChairID)
    			{
            --PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
            self:PlaySound(cmd.RES_PATH.."sound/GAME_WARN.wav")
    			}
    			return true
  		end,
  		[cmd.IDI_OPERATE_CARD] = function()    --操作定时器

    			--自动出牌
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
                	self:SetGameClock(self:GetMeChairID(), cmd.IDI_OPERATE_CARD, cmd.TIME_OPERATE_CARD)
                  --取消托管
                  return true
                end

                local cbGods=self._gameView:GetGodsCard()
                local iGodsIndex=GameLogic:SwitchToCardIndex(cbGods)
                for i=27,cmd.MAX_INDEX-1,1 do
                  while true do
                    if self.m_cbCardIndex[i]==0 break	end
                    if i == iGodsIndex break	end     --财神不能出
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
                    if self.m_cbCardIndex[i]==0 break	end
                    if i == iGodsIndex break	end     --财神不能出
                    if self:VerdictOutCard(GameLogic:SwitchToCardData(i))==false break	end
    								cbCardData=GameLogic:SwitchToCardData(i)
    								self:OnOutCard(cbCardData,cbCardData)
                    self:KillGameClock(cmd.IDI_OPERATE_CARD)
    								return true
                  break	end
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
                    if self.m_cbCardIndex[i]==0 break	end
                    if i == iGodsIndex break	end     --财神不能出
                    if self:VerdictOutCard(GameLogic:SwitchToCardData(i))==false break	end
    								cbCardData=GameLogic:SwitchToCardData(i)
    								self:OnOutCard(cbCardData,cbCardData)
                    self:KillGameClock(cmd.IDI_OPERATE_CARD)
    								return true
                  break	end
                end

                for i=0,cmd.MAX_INDEX-1,1 do
                  while true do
                    --出牌效验
                    if self.m_cbCardIndex[i]==0 break	end
                    if i == iGodsIndex break	end     --财神不能出
                    if self:VerdictOutCard(GameLogic:SwitchToCardData(i))==false break	end
    								cbCardData=GameLogic:SwitchToCardData(i)
    								self:OnOutCard(cbCardData,cbCardData)
                    self:KillGameClock(cmd.IDI_OPERATE_CARD)
    								return true
                  break	end
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
              self:PlaySound(cmd.RES_PATH.."sound/GAME_WARN.wav")
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
  		f()
  else   									-- for case default
  		print "Case default."
  end

  return true
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
		CCardExtractor ret
    --[[ --mark
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
  if cbGameStatus == cmd.GS_MJ_FREE then              --空闲状态
		print("空闲状态")
		local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)
    self.m_wBankerUser = cmd_data.wBankerUser
		self._gameView:SetBaseScore(cmd_data.lCellScore)
		self._gameView.m_HandCardControl:SetDisplayItem(true)
		--托管设置
    for i=0,cmd.GAME_PLAYER-1,1 do
		    self._gameView:SetTrustee(self:SwitchViewChairID(i),cmd_data.bTrustee[i])
    end

    --设置界面
    for i=0,4-1,1 do
      self.m_cbHeapCardInfo[i][0]=0
      self.m_cbHeapCardInfo[i][1]=0
      self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][0],self.m_cbHeapCardInfo[i][1],CardControl.HEAP_FULL_COUNT)
    end

    --设置控件
    --if self:IsLookonMode()==false then  一律返回false 不许旁观
    if true then
      self._gameView.m_btStart:setVisible(true) --ShowWindow(SW_SHOW)
      --self._gameView.m_btStart.SetFocus()                                   --=========================！！！！！ 等写完gameview后回来.SetFocus()  mark
      --self._gameView.m_btStusteeControl.EnableWindow(TRUE)                  --=========================！！！！！ 等写完gameview后回来.SetFocus()
      self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_START_GAME)
    end
		self._gameView.m_btMaiDi:setVisible(false)
		self._gameView.m_btDingDi:setVisible(false)
		self._gameView.m_btMaiCancel:setVisible(false)
		self._gameView.m_btDingCancel:setVisible(false)

		--丢弃效果
		self._gameView:SetDiscUser(yl.INVALID_CHAIR)
		--m_GameClientView.SetTimer(IDI_DISC_EFFECT,250,NULL);   mark    --回调 CGameClientView::OnTimer
    if self._gameView._GVSetTimer==nil then  self._gameView._GVSetTimer={}  end
    self._gameView._GVSetTimer[self._gameView.IDI_DISC_EFFECT] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            self._gameView:OnTimer(self._gameView.IDI_DISC_EFFECT)
        end, 250, false)

		--更新界面
		self._gameView:RefreshGameView()

    return true
	elseif cbGameStatus == cmd.GS_MJ_MAIDI then         --买庄状态
    local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusMaiDi, dataBuffer)

		--设置数据
    self.m_wBankerUser = cmd_data.wBankerUser
		self._gameView:SetBaseScore(cmd_data.lCellScore)
		self._gameView.m_HandCardControl:SetDisplayItem(true)
		self.m_wCurrentUser = yl.INVALID_CHAIR
    --托管设置
    for i=0,cmd.GAME_PLAYER-1,1 do
			self._gameView:SetTrustee(self:SwitchViewChairID(i),cmd_data.bTrustee[i])
    end

    --设置界面
    for i=0,4-1,1 do
      self.m_cbHeapCardInfo[i][0]=0
      self.m_cbHeapCardInfo[i][1]=0
      self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][0],self.m_cbHeapCardInfo[i][1],CardControl.HEAP_FULL_COUNT)
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
              if nil~=self._gameFrame:GetTableUserItem(self:GetMeTableID(),self.m_wBankerUser) then
                --_sntprintf(szNickName, sizeof(szNickName), TEXT("%s"),GetTableUserItem(m_wBankerUser)->GetNickName());
                szNickName=self._gameFrame:GetTableUserItem(self:GetMeTableID(),self.m_wBankerUser).GetNickName       -- mark 确定有GetNickName么
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
          self:SetGameClock(self.m_wBankerUser, cmd.IDI_DINGDI_CARD, cmd.TIME_OPERATE_CARD)
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
        self:SetGameClock(wMeChair, cmd.IDI_DINGDI_CARD, cmd.TIME_OPERATE_CARD)
      end
    end
	elseif cbGameStatus == cmd.GS_MJ_PLAY then          --游戏状态
		print("游戏状态")
		local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)

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
    for i=0,cmd.GAME_PLAYER-1,1 do
      local wChairID = self:SwitchViewChairID(i)
      byUserDingDi[wChairID] = cmd_data.byDingDi[i]
      self._gameView:SetTrustee(wChairID,cmd_data.bTrustee[i])
    end

		GameLogic.SetGodsCard(cmd_data.byGodsCardData)
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
    self.m_cbDiscardCard=GameLogic.deepcopy(cmd_data.cbDiscardCard)
    self.m_cbDiscardCount=GameLogic.deepcopy(cmd_data.cbDiscardCount)

    --丢弃效果
    if self.m_wOutCardUser~= yl.INVALID_CHAIR then
      self._gameView:SetDiscUser(self:SwitchViewChairID(self:m_wOutCardUser))
    end
    if self._gameView._GVSetTimer==nil then  self._gameView._GVSetTimer={}  end
    self._gameView._GVSetTimer[self._gameView.IDI_DISC_EFFECT] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            self._gameView:OnTimer(self._gameView.IDI_DISC_EFFECT)
        end, 250, false)

    --扑克变量
    self.m_cbWeaveCount=GameLogic.deepcopy(cmd_data.cbWeaveCount)
    self.m_WeaveItemArray=GameLogic.deepcopy(cmd_data.WeaveItemArray)
    GameLogic:SwitchToCardIndex(cmd_data.cbCardData,cmd_data.cbCardCount,self.m_cbCardIndex)
    self._gameView.m_HandCardControl:SetOutCardData(cmd_data.byOutCardIndex, cmd.MAX_INDEX)

    --辅助变量
    local wViewChairID={0,0}
    for i=0,cmd.GAME_PLAYER-1,1 do
      wViewChairID[i]=self:SwitchViewChairID(i)
    end

    --界面设置
    self._gameView:SetBaseScore(cmd_data.lCellScore)
    self._gameView:SetBankerUser(wViewChairID[self.m_wBankerUser])

    --组合扑克
		local cbWeaveCard={0,0,0,0}
    for i=0,cmd.GAME_PLAYER-1,1 do
			local wOperateViewID = self:SwitchViewChairID(i)
      for j=0,self.m_cbWeaveCount[i]-1,1 do
				local cbWeaveKind=self.m_WeaveItemArray[i][j].cbWeaveKind
				local cbCenterCard=self.m_WeaveItemArray[i][j].cbCenterCard
				local cbWeaveCardCount=GameLogic.GetWeaveCard(cbWeaveKind,cbCenterCard,cbWeaveCard)
				self._gameView.m_WeaveCard[wViewChairID[i]][j]:SetCardData(cbWeaveCard,cbWeaveCardCount,m_WeaveItemArray[i][j].cbCenterCard)
        if bit:_and(cbWeaveKind,GameLogic.WIK_GANG) and (elf.m_WeaveItemArray[i][j].wProvideUser==i) then
					self._gameView.m_WeaveCard[wViewChairID[i]][j].SetDisplayItem(false)
        end
        local wProviderViewID = self:SwitchViewChairID(self.m_WeaveItemArray[i][j].wProvideUser)
        self._gameView.m_WeaveCard[wOperateViewID][j]:SetDirectionCardPos(3-(wOperateViewID-wProviderViewID+4)%4)
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
				GameLogic.RemoveCard(cmd_data.cbCardData,cbCardCount,cbRemoveCard,1)
				cmd_data.cbCardData[cmd_data.cbCardCount-1]=cmd_data.cbSendCardData
      end
      --设置扑克
      local cbCardCount=cmd_data.cbCardCount
			self._gameView.m_HandCardControl:SetCardData(cmd_data.cbCardData,cbCardCount-1,cmd_data.cbCardData[cbCardCount-1])
    else
			self._gameView.m_HandCardControl.SetCardData(cmd_data.cbCardData,cmd_data.cbCardCount,0)
    end

		--扑克设置
    for i=0,cmd.GAME_PLAYER-1,1 do
      -- 用户扑克
      if i ~= self:GetMeChairID() then
				local cbCardCount=13-self.m_cbWeaveCount[i]*3
				local wUserCardIndex=(wViewChairID[i]<2) and wViewChairID[i] or 2
				self._gameView.m_UserCard[wUserCardIndex]:SetCardData(cbCardCount,(self.m_wCurrentUser==i))
      end

			--丢弃扑克
			local wViewChairID=self:SwitchViewChairID(i)
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
    for i=0,cmd.GAME_PLAYER-1,1 do
      self.m_cbHeapCardInfo[i][0]=0
      self.m_cbHeapCardInfo[i][1]=0
    end

    --分发扑克
    --第一把骰子的玩家 门前开始数牌

		local cbSiceFirst=(bit:_rshift(cmd_data.wSiceCount1,8) + bit:_and(cmd_data.wSiceCount1, 0xff) -1)%4
		local wTakeChairID = (self.m_wBankerUser + 4 - cbSiceFirst)%4
		local cbSiceSecond= bit:_rshift(cmd_data.wSiceCount2,8) + bit:_and(cmd_data.wSiceCount2, 0xff)
			+ (bit:_rshift(cmd_data.wSiceCount1,8)  + bit:_and(cmd_data.wSiceCount1, 0xff))
    if cbSiceSecond*2>CardControl.HEAP_FULL_COUNT then
      wTakeChairID = (wTakeChairID + 1)%4
      cbSiceSecond = cbSiceSecond-(CardControl.HEAP_FULL_COUNT/2)
    end
    self.m_wHeapTail = wTakeChairID%4

		local cbTakeCount=cmd.MAX_REPERTORY-self.m_cbLeftCardCount-(cmd.MAX_COUNT-1)*cmd.GAME_PLAYER
		self.m_wHeapHand = (self.m_wHeapTail+1)%4
		self.m_cbHeapCardInfo[self.m_wHeapHand][0] = cbTakeCount
    if cbTakeCount >= CardControl.HEAP_FULL_COUNT then
			self.m_cbHeapCardInfo[self.m_wHeapHand][0] = CardControl.HEAP_FULL_COUNT
			cbTakeCount = cbTakeCount - CardControl.HEAP_FULL_COUNT
			self.m_wHeapHand = (self.m_wHeapHand+1)%4
			self.m_cbHeapCardInfo[self.m_wHeapHand][0] = self.m_wHeapHand
    end

  	--堆立界面
    for i=0,4-1.1 do
      self._gameView.m_HeapCard[i]:SetCardData(self.m_cbHeapCardInfo[i][0],self.m_cbHeapCardInfo[i][1],CardControl.HEAP_FULL_COUNT)
    end
		--换算出财神牌的位置
		local byCount = CardControl.HEAP_FULL_COUNT - self.m_cbHeapCardInfo[self.m_wHeapTail][1]
		local bySicbo = bit:_rshift(cmd_data.wSiceCount3,8) + bit:_and(cmd_data.wSiceCount3, 0xff)
		local byChairID = wMeChairID
    if byCount >= bySicbo then
			byChairID = self.m_wHeapTail
    else
			byChairID = (self.m_wHeapTail + 4 - 1)%4
			bySicbo =  bySicbo - byCount
    end
		self._gameView.m_HeapCard[self:SwitchHeapViewChairID(byChairID)]:SetGodsCard(cmd_data.byGodsCardData,bySicbo, self.m_cbHeapCardInfo[byChairID][1])

		--历史扑克
    if self.m_wOutCardUser~=yl.INVALID_CHAIR then
			local wOutChairID=self:SwitchViewChairID(self.m_wOutCardUser)
			self._gameView:SetOutCardInfo(wOutChairID,self.m_cbOutCardData);
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
      GangCardResult.cbCardData={}

      --杠牌判断
      if (bit:_and(cbActionMask, GameLogic.WIK_GANG)) ~= 0 then
        --桌面杆牌
        if (self.m_wCurrentUser==yl.INVALID_CHAIR) and (cbActionCard~=0) then
					GangCardResult.cbCardCount=1
					GangCardResult.cbCardData[0]=cbActionCard
        end

				--自己杆牌
        if self.m_wCurrentUser==self:GetMeChairID()xxxx then
          --body...
        end
				if ((m_wCurrentUser==GetMeChairID())||(cbActionCard==0))
				{
					WORD wMeChairID=GetMeChairID();
					m_GameLogic.AnalyseGangCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangCardResult);
				}
      end
    end

		//操作界面
		if ((IsLookonMode()==false)&&(pStatusPlay->cbActionMask!=WIK_NULL))
		{
			//获取变量
			BYTE cbActionMask=pStatusPlay->cbActionMask;
			BYTE cbActionCard=pStatusPlay->cbActionCard;

			//变量定义
			tagGangCardResult GangCardResult;
			ZeroMemory(&GangCardResult,sizeof(GangCardResult));

			//杠牌判断
			if ((cbActionMask&WIK_GANG)!=0)
			{
				//桌面杆牌
				if ((m_wCurrentUser==INVALID_CHAIR)&&(cbActionCard!=0))
				{
					GangCardResult.cbCardCount=1;
					GangCardResult.cbCardData[0]=cbActionCard;
				}

				//自己杆牌
				if ((m_wCurrentUser==GetMeChairID())||(cbActionCard==0))
				{
					WORD wMeChairID=GetMeChairID();
					m_GameLogic.AnalyseGangCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangCardResult);
				}
			}

			//设置界面
			if (m_wCurrentUser==INVALID_CHAIR)
				SetGameClock(GetMeChairID(),IDI_OPERATE_CARD,TIME_OPERATE_CARD);
			if (IsLookonMode()==false)
			{
				m_GameClientView.m_ControlWnd.SetControlInfo(cbActionCard,cbActionMask,GangCardResult);
				m_cbUserAction = cbActionMask;
			}
		}

  end
  return true
end
-- 场景消息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)

	if cbGameStatus == cmd.GAME_SCENE_FREE then
	elseif cbGameStatus == cmd.GAME_SCENE_PLAY then
		print("游戏状态")
		local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
		--dump(cmd_data.cbHuCardData, "cbHuCardData")
		--dump(cmd_data.cbOutCardDataEx, "cbOutCardDataEx")

		self.lCellScore = cmd_data.lCellScore
		self.cbTimeOutCard = cmd_data.cbTimeOutCard
		self.cbTimeOperateCard = cmd_data.cbTimeOperateCard
		self.cbTimeStartGame = cmd_data.cbTimeStartGame
		self.wCurrentUser = cmd_data.wCurrentUser
		self.wBankerUser = cmd_data.wBankerUser
		self.cbPlayerCount = cmd_data.cbPlayerCount or 4
		self.cbMaCount = cmd_data.cbMaCount

		--庄家
		self._gameView:setBanker(self:SwitchViewChairID(self.wBankerUser))
		--设置手牌
		local viewCardCount = {}
		for i = 1, cmd.GAME_PLAYER do
			local viewId = self:SwitchViewChairID(i - 1)
			viewCardCount[viewId] = cmd_data.cbCardCount[1][i]
			if viewCardCount[viewId] > 0 then
				self.cbPlayStatus[viewId] = 1
			end
		end
		local cbHandCardData = {}
		for i = 1, cmd.MAX_COUNT do
			local data = cmd_data.cbCardData[1][i]
			if data > 0 then 				--去掉末尾的0
				cbHandCardData[i] = data
			else
				break
			end
		end
		GameLogic.SortCardList(cbHandCardData) 		--排序
		local cbSendCard = cmd_data.cbSendCardData
		if cbSendCard > 0 and self.wCurrentUser == wMyChairId then
			for i = 1, #cbHandCardData do
				if cbHandCardData[i] == cbSendCard then
					table.remove(cbHandCardData, i)				--把刚抓的牌放在最后
					break
				end
			end
			table.insert(cbHandCardData, cbSendCard)
		end
		for i = 1, cmd.GAME_PLAYER do
			self._gameView._cardLayer:setHandCard(i, viewCardCount[i], cbHandCardData)
		end
		self.bSendCardFinsh = true
		--记录已出现牌
		self:insertAppearCard(cbHandCardData)
		--组合牌
		for i = 1, cmd.GAME_PLAYER do
			local wViewChairId = self:SwitchViewChairID(i - 1)
			for j = 1, cmd_data.cbWeaveItemCount[1][i] do
				local cbOperateData = {}
				for v = 1, 4 do
					local data = cmd_data.WeaveItemArray[i][j].cbCardData[1][v]
					if data > 0 then
						table.insert(cbOperateData, data)
					end
				end
				local nShowStatus = GameLogic.SHOW_NULL
				local cbParam = cmd_data.WeaveItemArray[i][j].cbParam
				if cbParam == GameLogic.WIK_GANERAL then
					if cbOperateData[1] == cbOperateData[2] then 	--碰
						nShowStatus = GameLogic.SHOW_PENG
					else 											--吃
						nShowStatus = GameLogic.SHOW_CHI
					end
				elseif cbParam == GameLogic.WIK_MING_GANG then
					nShowStatus = GameLogic.SHOW_MING_GANG
				elseif cbParam == GameLogic.WIK_FANG_GANG then
					nShowStatus = GameLogic.SHOW_FANG_GANG
				elseif cbParam == GameLogic.WIK_AN_GANG then
					nShowStatus = GameLogic.SHOW_AN_GANG
				end
				--dump(cmd_data.WeaveItemArray[i][j], "weaveItem")
				self._gameView._cardLayer:bumpOrBridgeCard(wViewChairId, cbOperateData, nShowStatus)
				--记录已出现牌
				self:insertAppearCard(cbOperateData)
			end
		end
		--设置牌堆
		local wViewHeapHead = self:SwitchViewChairID(cmd_data.wHeapHead)
		local wViewHeapTail = self:SwitchViewChairID(cmd_data.wHeapTail)
		for i = 1, cmd.GAME_PLAYER do
			local viewId = self:SwitchViewChairID(i - 1)
			for j = 1, cmd_data.cbDiscardCount[1][i] do
				--已出的牌
				self._gameView._cardLayer:discard(viewId, cmd_data.cbDiscardCard[i][j])
				--记录已出现牌
				local cbAppearCard = {cmd_data.cbDiscardCard[i][j]}
				self:insertAppearCard(cbAppearCard)
			end
			--牌堆
			self._gameView._cardLayer:setTableCardByHeapInfo(viewId, cmd_data.cbHeapCardInfo[i], wViewHeapHead, wViewHeapTail)
			--托管
			self._gameView:setUserTrustee(viewId, cmd_data.bTrustee[1][i])
			if viewId == cmd.MY_VIEWID then
				self.bTrustee = cmd_data.bTrustee[1][i]
			end
		end
		--刚出的牌
		if cmd_data.cbOutCardData and cmd_data.cbOutCardData > 0 then
			local wOutUserViewId = self:SwitchViewChairID(cmd_data.wOutCardUser)
			self._gameView:showCardPlate(wOutUserViewId, cmd_data.cbOutCardData)
		end
		--计时器
		self:SetGameClock(self.wCurrentUser, cmd.IDI_OUT_CARD, self.cbTimeOutCard)

		--提示听牌数据
		self.cbListenPromptOutCard = {}
		self.cbListenCardList = {}
		for i = 1, cmd_data.cbOutCardCount do
			self.cbListenPromptOutCard[i] = cmd_data.cbOutCardDataEx[1][i]
			self.cbListenCardList[i] = {}
			for j = 1, cmd_data.cbHuCardCount[1][i] do
				self.cbListenCardList[i][j] = cmd_data.cbHuCardData[i][j]
			end
		end
		local cbPromptHuCard = self:getListenPromptHuCard(cmd_data.cbOutCardData)
		self._gameView:setListeningCard(cbPromptHuCard)
		--提示操作
		self._gameView:recognizecbActionMask(cmd_data.cbActionMask, cmd_data.cbActionCard)
		if self.wCurrentUser == wMyChairId then
			self._gameView._cardLayer:promptListenOutCard(self.cbListenPromptOutCard)
		end
	else
		print("\ndefault\n")
		return false
	end

    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end

	self:dismissPopWait()

	return true
end

--===========================================2017年11月27日18:36:00


--用户聊天
function GameLayer:onUserChat(chat, wChairId)
    self._gameView:userChat(self:SwitchViewChairID(wChairId), chat.szChatString)
end

--用户表情
function GameLayer:onUserExpression(expression, wChairId)
    self._gameView:userExpression(self:SwitchViewChairID(wChairId), expression.wItemIndex)
end

-- 语音播放开始
function GameLayer:onUserVoiceStart( useritem, filepath )
    self._gameView:onUserVoiceStart(self:SwitchViewChairID(useritem.wChairID))
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    self._gameView:onUserVoiceEnded(self:SwitchViewChairID(useritem.wChairID))
end



--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
	print("游戏开始")
    self.m_cbGameStatus = cmd.GAME_SCENE_PLAY
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)
	--dump(cmd_data, "CMD_S_GameStart")
	for i = 1, cmd.GAME_PLAYER do
		local viewId = self:SwitchViewChairID(i - 1)
		local head = cmd_data.cbHeapCardInfo[i][1]
		local tail = cmd_data.cbHeapCardInfo[i][2]
	end

	self.wBankerUser = cmd_data.wBankerUser
	local wViewBankerUser = self:SwitchViewChairID(self.wBankerUser)
	self._gameView:setBanker(wViewBankerUser)
	local cbCardCount = {0, 0, 0, 0}
	for i = 1, cmd.GAME_PLAYER do
		local userItem = self._gameFrame:getTableUserItem(self:GetMeTableID(), i - 1)
		local wViewChairId = self:SwitchViewChairID(i - 1)
		self._gameView:OnUpdateUser(wViewChairId, userItem)
		if userItem then
			self.cbPlayStatus[wViewChairId] = 1
			cbCardCount[wViewChairId] = 13
			if wViewChairId == wViewBankerUser then
				cbCardCount[wViewChairId] = cbCardCount[wViewChairId] + 1
			end
		end
	end

	if self.wBankerUser ~= self:GetMeChairID() then
		cmd_data.cbCardData[1][cmd.MAX_COUNT] = nil
	end

	--筛子
	local cbSiceCount1 = math.mod(cmd_data.wSiceCount, 256)
	local cbSiceCount2 = math.floor(cmd_data.wSiceCount/256)
	--起始位置
	local wStartChairId = math.mod(self.wBankerUser + cbSiceCount1 + cbSiceCount2 - 1, cmd.GAME_PLAYER)
	local wStartViewId = self:SwitchViewChairID(wStartChairId)
	--起始位置数的起始牌
	local nStartCard = math.min(cbSiceCount1, cbSiceCount2)*2 + 1
	--开始发牌
	self._gameView:gameStart(wStartViewId, nStartCard, cmd_data.cbCardData[1], cbCardCount, cbSiceCount1, cbSiceCount2)

	--记录已出现的牌
	self:insertAppearCard(cmd_data.cbCardData[1])

	self.wCurrentUser = cmd_data.wBankerUser
	self.cbActionMask = cmd_data.cbUserAction
	self.bMoPaiStatus = true
	self.bSendCardFinsh = false
	self:PlaySound(cmd.RES_PATH.."sound/GAME_START.wav")
	-- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
        	PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
            self._gameView._priView:onRefreshInfo()
        end
    end

    --计时器
	self:SetGameClock(self.wCurrentUser, cmd.IDI_OUT_CARD, self.cbTimeOutCard)
	return true
end

--用户出牌
function GameLayer:onSubOutCard(dataBuffer)
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_OutCard, dataBuffer)
	--dump(cmd_data, "CMD_S_OutCard")
	print("用户出牌", cmd_data.cbOutCardData)

	local wViewId = self:SwitchViewChairID(cmd_data.wOutCardUser)
	self._gameView:gameOutCard(wViewId, cmd_data.cbOutCardData)

	--记录已出现的牌
	if wViewId ~= cmd.MY_VIEWID then
		local cbAppearCard = {cmd_data.cbOutCardData}
		self:insertAppearCard(cbAppearCard)
	end

	self.bMoPaiStatus = false
	self:KillGameClock()
	self._gameView:HideGameBtn()
	self:PlaySound(cmd.RES_PATH.."sound/OUT_CARD.wav")
	self:playCardDataSound(wViewId, cmd_data.cbOutCardData)
	--轮到下一个
	self.wCurrentUser = cmd_data.wOutCardUser
	local wTurnUser = self.wCurrentUser + 1
	local wViewTurnUser = self:SwitchViewChairID(wTurnUser)
	while self.cbPlayStatus[wViewTurnUser] ~= 1 do
		wTurnUser = wTurnUser + 1
		if wTurnUser > 3 then
			wTurnUser = 0
		end
		wViewTurnUser = self:SwitchViewChairID(wTurnUser)
	end
	--设置听牌
	self._gameView._cardLayer:promptListenOutCard(nil)
	if wViewId == cmd.MY_VIEWID then
		local cbPromptHuCard = self:getListenPromptHuCard(cmd_data.cbOutCardData)
		self._gameView:setListeningCard(cbPromptHuCard)
		--听牌数据置空
		self.cbListenPromptOutCard = {}
		self.cbListenCardList = {}
	end
	--设置时间
	self:SetGameClock(wTurnUser, cmd.IDI_OUT_CARD, self.cbTimeOutCard)
	return true
end

--发送扑克(抓牌)
function GameLayer:onSubSendCard(dataBuffer)
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_SendCard, dataBuffer)
	--dump(cmd_data, "CMD_S_SendCard")
	print("发送扑克", cmd_data.cbCardData)

	self.wCurrentUser = cmd_data.wCurrentUser
	local wCurrentViewId = self:SwitchViewChairID(self.wCurrentUser)
	self._gameView:gameSendCard(wCurrentViewId, cmd_data.cbCardData, cmd_data.bTail)

	self:SetGameClock(self.wCurrentUser, cmd.IDI_OUT_CARD, self.cbTimeOutCard)

	self._gameView:HideGameBtn()
	if self.wCurrentUser == self:GetMeChairID()  then
		self._gameView:recognizecbActionMask(cmd_data.cbActionMask, cmd_data.cbCardData)
		--自动胡牌
		if cmd_data.cbActionMask >= GameLogic.WIK_CHI_HU and self.bTrustee then
			self._gameView:onButtonClickedEvent(GameViewLayer.BT_WIN)
		end
	end

	--记录已出现的牌
	if wCurrentViewId == cmd.MY_VIEWID then
		local cbAppearCard = {cmd_data.cbCardData}
		self:insertAppearCard(cbAppearCard)
	end

	self.bMoPaiStatus = true
	self:PlaySound(cmd.RES_PATH.."sound/SEND_CARD.wav")
	if cmd_data.bTail then
		self:playCardOperateSound(wOperateViewId, true, nil)
	end
	return true
end

--操作提示
function GameLayer:onSubOperateNotify(dataBuffer)
	print("操作提示")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_OperateNotify, dataBuffer)
	--dump(cmd_data, "CMD_S_OperateNotify")

	if self.bSendCardFinsh then 	--发牌完成
		self._gameView:recognizecbActionMask(cmd_data.cbActionMask, cmd_data.cbActionCard)
	else
		self.cbActionMask = cmd_data.cbActionMask
		self.cbActionCard = cmd_data.cbActionCard
	end
	return true
end

--听牌提示
function GameLayer:onSubListenNotify(dataBuffer)
	print("听牌提示")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_Hu_Data, dataBuffer)
	--dump(cmd_data, "CMD_S_Hu_Data")

	self.cbListenPromptOutCard = {}
	self.cbListenCardList = {}
	for i = 1, cmd_data.cbOutCardCount do
		self.cbListenPromptOutCard[i] = cmd_data.cbOutCardData[1][i]
		self.cbListenCardList[i] = {}
		for j = 1, cmd_data.cbHuCardCount[1][i] do
			self.cbListenCardList[i][j] = cmd_data.cbHuCardData[i][j]
		end
		print("self.cbListenCardList"..i, table.concat(self.cbListenCardList[i], ","))
	end
	print("self.cbListenPromptOutCard", table.concat(self.cbListenPromptOutCard, ","))

	return true
end

--操作结果
function GameLayer:onSubOperateResult(dataBuffer)
	print("操作结果")

	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_OperateResult, dataBuffer)
	--dump(cmd_data, "CMD_S_OperateResult")
	if cmd_data.cbOperateCode == GameLogic.WIK_NULL then
		assert(false, "没有操作也会进来？")
		return true
	end

	local wOperateViewId = self:SwitchViewChairID(cmd_data.wOperateUser)
	if cmd_data.cbOperateCode < GameLogic.WIK_LISTEN then 		--并非听牌
		local nShowStatus = GameLogic.SHOW_NULL
		local data1 = cmd_data.cbOperateCard[1][1]
		local data2 = cmd_data.cbOperateCard[1][2]
		local data3 = cmd_data.cbOperateCard[1][3]
		local cbOperateData = {}
		local cbRemoveData = {}
		if cmd_data.cbOperateCode == GameLogic.WIK_GANG then
			cbOperateData = {data1, data1, data1, data1}
			cbRemoveData = {data1, data1, data1}
			--检查杠的类型
			local cbCardCount = self._gameView._cardLayer.cbCardCount[wOperateViewId]
			if math.mod(cbCardCount - 2, 3) == 0 then
				if self._gameView._cardLayer:checkBumpOrBridgeCard(wOperateViewId, data1) then
					nShowStatus = GameLogic.SHOW_MING_GANG
				else
					nShowStatus = GameLogic.SHOW_AN_GANG
				end
			else
				nShowStatus = GameLogic.SHOW_FANG_GANG
			end
		elseif cmd_data.cbOperateCode == GameLogic.WIK_PENG then
			cbOperateData = {data1, data1, data1}
			cbRemoveData = {data1, data1}
			nShowStatus = GameLogic.SHOW_PENG
		elseif cmd_data.cbOperateCode == GameLogic.WIK_RIGHT then
			cbOperateData = cmd_data.cbOperateCard[1]
			cbRemoveData = {data1, data2}
			nShowStatus = GameLogic.SHOW_CHI
		elseif cmd_data.cbOperateCode == GameLogic.WIK_CENTER then
			cbOperateData = cmd_data.cbOperateCard[1]
			cbRemoveData = {data1, data3}
			nShowStatus = GameLogic.SHOW_CHI
		elseif cmd_data.cbOperateCode == GameLogic.WIK_LEFT then
			cbOperateData = cmd_data.cbOperateCard[1]
			cbRemoveData = {data2, data3}
			nShowStatus = GameLogic.SHOW_CHI
		end
		local bAnGang = nShowStatus == GameLogic.SHOW_AN_GANG
		self._gameView._cardLayer:bumpOrBridgeCard(wOperateViewId, cbOperateData, nShowStatus)
		local bRemoveSuccess = false
		if nShowStatus == GameLogic.SHOW_AN_GANG then
			self._gameView._cardLayer:removeHandCard(wOperateViewId, cbOperateData, false)
		elseif nShowStatus == GameLogic.SHOW_MING_GANG then
			self._gameView._cardLayer:removeHandCard(wOperateViewId, {data1}, false)
		else
			self._gameView._cardLayer:removeHandCard(wOperateViewId, cbRemoveData, false)
			--self._gameView._cardLayer:recycleDiscard(self:SwitchViewChairID(cmd_data.wProvideUser))
			print("提供者不正常？", cmd_data.wProvideUser, self:GetMeChairID())
		end
		self:PlaySound(cmd.RES_PATH.."sound/PACK_CARD.wav")
		self:playCardOperateSound(wOperateViewId, false, cmd_data.cbOperateCode)

		--记录已出现的牌
		if wOperateViewId ~= cmd.MY_VIEWID then
			if nShowStatus == GameLogic.SHOW_AN_GANG then
				self:insertAppearCard(cbOperateData)
			elseif nShowStatus == GameLogic.SHOW_MING_GANG then
				self:insertAppearCard({data1})
			else
				self:insertAppearCard(cbRemoveData)
			end
		end
		--提示听牌
		if wOperateViewId == cmd.MY_VIEWID and cmd_data.cbOperateCode == GameLogic.WIK_PENG then
			self._gameView._cardLayer:promptListenOutCard(self.cbListenPromptOutCard)
		end
	end
	self._gameView:showOperateFlag(wOperateViewId, cmd_data.cbOperateCode)

	local cbTime = self.cbTimeOutCard - self.cbTimeOperateCard
	self:SetGameClock(cmd_data.wOperateUser, cmd.IDI_OUT_CARD, cbTime > 0 and cbTime or self.cbTimeOutCard)

	return true
end

--用户听牌
function GameLayer:onSubListenCard(dataBuffer)
	--print("用户听牌")
	--local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_ListenCard, dataBuffer)
	--dump(cmd_data, "CMD_S_ListenCard")
	return true
end

--用户托管
function GameLayer:onSubTrustee(dataBuffer)
	print("用户托管")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_Trustee, dataBuffer)
	--dump(cmd_data, "trustee")

	local wViewChairId = self:SwitchViewChairID(cmd_data.wChairID)
	self._gameView:setUserTrustee(wViewChairId, cmd_data.bTrustee)
	if cmd_data.wChairID == self:GetMeChairID() then
		self.bTrustee = cmd_data.bTrustee
	end

	if cmd_data.bTrustee then
		self:PlaySound(cmd.RES_PATH.."sound/GAME_TRUSTEE.wav")
	else
		self:PlaySound(cmd.RES_PATH.."sound/UNTRUSTEE.wav")
	end

	return true
end

--游戏结束
function GameLayer:OnSubGameEnd(dataBuffer)
	print("游戏结束")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_GameConclude, dataBuffer)
	--dump(cmd_data, "CMD_S_GameConclude")

	local bMeWin = nil  	--nil：没人赢，false：有人赢但我没赢，true：我赢
	--剩余牌
	local cbTotalCardData = clone(GameLogic.TotalCardData)
	local cbRemainCard = GameLogic.RemoveCard(cbTotalCardData, self.cbAppearCardData)
	--提示胡牌标记
	for i = 1, cmd.GAME_PLAYER do
		local wViewChairId = self:SwitchViewChairID(i - 1)
		if cmd_data.cbChiHuKind[1][i] >= GameLogic.WIK_CHI_HU then
			bMeWin = false
			self:playCardOperateSound(wOperateViewId, false, GameLogic.WIK_CHI_HU)
			self._gameView:showOperateFlag(wViewChairId, GameLogic.WIK_CHI_HU)
			if wViewChairId == cmd.MY_VIEWID then
				bMeWin = true
			end
		end
	end
	--显示结算图层
	local resultList = {}
	local cbBpBgData = self._gameView._cardLayer:getBpBgCardData()
	for i = 1, cmd.GAME_PLAYER do
		local wViewChairId = self:SwitchViewChairID(i - 1)
		local lScore = cmd_data.lGameScore[1][i]
		local user = self._gameFrame:getTableUserItem(self:GetMeTableID(), i - 1)
		if user then
			local result = {}
			result.userItem = user
			result.lScore = lScore
			result.cbChHuKind = cmd_data.cbChiHuKind[1][i]
			result.cbCardData = {}
			--手牌
			for j = 1, cmd_data.cbCardCount[1][i] do
				result.cbCardData[j] = cmd_data.cbHandCardData[i][j]
			end
			--碰杠牌
			result.cbBpBgCardData = cbBpBgData[wViewChairId]
			--奖码
			result.cbAwardCard = {}
			for j = 1, cmd_data.cbMaCount[1][i] do
				result.cbAwardCard[j] = cmd_data.cbMaData[1][j]
			end
			--插入
			table.insert(resultList, result)
			--剩余牌里删掉对手的牌
			if wViewChairId ~= cmd.MY_VIEWID then
				cbRemainCard = GameLogic.RemoveCard(cbRemainCard, result.cbCardData)
			end
		end
	end
	--全部奖码
	local meIndex = self:GetMeChairID() + 1
	local cbAwardCardTotal = {}
	for i = 1, 7 do
		local value = cmd_data.cbMaData[1][i]
		if value and value > 0 then
			table.insert(cbAwardCardTotal, value)
		end
	end
	--删掉奖码
	cbRemainCard = GameLogic.RemoveCard(cbRemainCard, cbAwardCardTotal)
	if bMeWin == false then 			--有人赢但赢的人不是我
		cbRemainCard = GameLogic.RemoveCard(cbRemainCard, {cmd_data.cbProvideCard})
	end
	--打散剩余牌
	cbRemainCard = GameLogic.RandCardList(cbRemainCard)
	--在首位插入奖码（将奖码伪装成剩余牌）
	for i = 1, #cbAwardCardTotal do
		table.insert(cbRemainCard, i, cbAwardCardTotal[i])
	end
	print("通过已显示牌统计，剩余多少张？", #cbRemainCard)
	--显示结算框
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function(ref)
		self._gameView._resultLayer:showLayer(resultList, cbAwardCardTotal, cbRemainCard, self.wBankerUser, cmd_data.cbProvideCard)
	end)))
	--播放音效
	if bMeWin then
		self:PlaySound(cmd.RES_PATH.."sound/ZIMO_WIN.wav")
	else
		self:PlaySound(cmd.RES_PATH.."sound/ZIMO_LOSE.wav")
	end

	self.cbPlayStatus = {0, 0, 0, 0}
    self.bTrustee = false
    self.bSendCardFinsh = false
	self._gameView:gameConclude()

	-- if GlobalUserItem.bPrivateRoom then
	-- 	--self._gameView.spClock:setVisible(false)
	-- 	self._gameView.asLabTime:setString("0")
	-- else
		self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, self.cbTimeStartGame)
	--end

	return true
end

--游戏记录（房卡）
function GameLayer:onSubGameRecord(dataBuffer)
	print("游戏记录")
	local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_Record, dataBuffer)
	--dump(cmd_data, "CMD_S_Record")

	self.m_userRecord = {}
	local nInningsCount = cmd_data.nCount
	for i = 1, self.cbPlayerCount do
		self.m_userRecord[i] = {}
		self.m_userRecord[i].cbHuCount = cmd_data.cbHuCount[1][i]
		self.m_userRecord[i].cbMingGang = cmd_data.cbMingGang[1][i]
		self.m_userRecord[i].cbAnGang = cmd_data.cbAnGang[1][i]
		self.m_userRecord[i].cbMaCount = cmd_data.cbMaCount[1][i]
		self.m_userRecord[i].lDetailScore = {}
		for j = 1, nInningsCount do
			self.m_userRecord[i].lDetailScore[j] = cmd_data.lDetailScore[i][j]
		end
	end
	--dump(self.m_userRecord, "m_userRecord", 5)
end

--*****************************    普通函数     *********************************--
--发牌完成
function GameLayer:sendCardFinish()
	--self:SetGameClock(self.wCurrentUser, cmd.IDI_OUT_CARD, self.cbTimeOutCard)

	--提示操作
	if self.cbActionMask then
		self._gameView:recognizecbActionMask(self.cbActionMask, self.cbActionCard)
	end

	--提示听牌
	if self.wBankerUser == self:GetMeChairID() then
		self._gameView._cardLayer:promptListenOutCard(self.cbListenPromptOutCard)
	end

	self.bSendCardFinsh = true
end

--解析筛子
function GameLayer:analyseSice(wSiceCount)
	local cbSiceCount1 = math.mod(wSiceCount, 256)
	local cbSiceCount2 = math.floor(wSiceCount/256)
	return cbSiceCount1, cbSiceCount2
end

--设置操作时间
function GameLayer:SetGameOperateClock()
	self:SetGameClock(self:GetMeChairID(), cmd.IDI_OPERATE_CARD, self.cbTimeOperateCard)
end

--播放麻将数据音效（哪张）
function GameLayer:playCardDataSound(viewId, cbCardData)
	local strGender = ""
	if self.cbGender[viewId] == 1 then
		strGender = "BOY"
	else
		strGender = "GIRL"
	end
	local color = {"W_", "S_", "T_", "F_"}
	local nCardColor = math.floor(cbCardData/16) + 1
	local nValue = math.mod(cbCardData, 16)
	if cbCardData == GameLogic.MAGIC_DATA then
		nValue = 5
	end
	local strFile = cmd.RES_PATH.."sound/"..strGender.."/"..color[nCardColor]..nValue..".wav"
	self:PlaySound(strFile)
end
--播放麻将操作音效
function GameLayer:playCardOperateSound(viewId, bTail, operateCode)
	assert(operateCode ~= GameLogic.WIK_NULL)

	local strGender = ""
	if self.cbGender[viewId] == 1 then
		strGender = "BOY"
	else
		strGender = "GIRL"
	end
	local strName = ""
	if bTail then
		strName = "REPLACE.wav"
	else
		if operateCode >= GameLogic.WIK_CHI_HU then
			strName = "CHI_HU.wav"
		elseif operateCode == GameLogic.WIK_LISTEN then
			strName = "TING.wav"
		elseif operateCode == GameLogic.WIK_GANG then
			strName = "GANG.wav"
		elseif operateCode == GameLogic.WIK_PENG then
			strName = "PENG.wav"
		elseif operateCode <= GameLogic.WIK_RIGHT then
			strName = "CHI.wav"
		end
	end
	local strFile = cmd.RES_PATH.."sound/"..strGender.."/"..strName
	self:PlaySound(strFile)
end
--播放随机聊天音效
function GameLayer:playRandomSound(viewId)
	local strGender = ""
	if self.cbGender[viewId] == 1 then
		strGender = "BOY"
	else
		strGender = "GIRL"
	end
	local nRand = math.random(25) - 1
	if nRand <= 6 then
		local num = 6603000 + nRand
		local strName = num..".wav"
		local strFile = cmd.RES_PATH.."sound/PhraseVoice/"..strGender.."/"..strName
		self:PlaySound(strFile)
	end
end

--插入到已出现牌中
function GameLayer:insertAppearCard(cbCardData)
	assert(type(cbCardData) == "table")
	for i = 1, #cbCardData do
		table.insert(self.cbAppearCardData, cbCardData[i])
		--self._gameView:reduceListenCardNum(cbCardData[i])
	end
	table.sort(self.cbAppearCardData)
	local str = ""
	for i = 1, #self.cbAppearCardData do
		str = str..string.format("%x,", self.cbAppearCardData[i])
	end
	--print("已出现的牌:", str)
end

function GameLayer:getDetailScore()
	return self.m_userRecord
end

function GameLayer:getListenPromptOutCard()
	return self.cbListenPromptOutCard
end

function GameLayer:getListenPromptHuCard(cbOutCard)
	if not cbOutCard then
		return nil
	end

	for i = 1, #self.cbListenPromptOutCard do
		if self.cbListenPromptOutCard[i] == cbOutCard then
			assert(#self.cbListenCardList > 0 and self.cbListenCardList[i] and #self.cbListenCardList[i] > 0)
			return self.cbListenCardList[i]
		end
	end

	return nil
end

-- 刷新房卡数据
function GameLayer:updatePriRoom()
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end

--*****************************    发送消息     *********************************--
--开始游戏
function GameLayer:sendGameStart()
	self:SendUserReady()
	self:OnResetGameEngine()
end
--出牌
function GameLayer:sendOutCard(card)
	-- body
	if card == GameLogic.MAGIC_DATA then
		return false
	end

	self._gameView:HideGameBtn()
	print("发送出牌", card)

	local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_OutCard)
	cmd_data:pushbyte(card)
	return self:SendData(cmd.SUB_C_OUT_CARD, cmd_data)
end
--操作扑克
function GameLayer:sendOperateCard(cbOperateCode, cbOperateCard)
	print("发送操作提示：", cbOperateCode, table.concat(cbOperateCard, ","))
	assert(type(cbOperateCard) == "table")

	--听牌数据置空
	self.cbListenPromptOutCard = {}
	self.cbListenCardList = {}
	self._gameView:setListeningCard(nil)
	self._gameView._cardLayer:promptListenOutCard(nil)

	--发送操作
	--local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_OperateCard)
    local cmd_data = CCmd_Data:create(4)
	cmd_data:pushbyte(cbOperateCode)
	for i = 1, 3 do
		cmd_data:pushbyte(cbOperateCard[i])
	end
	--dump(cmd_data, "operate")
	self:SendData(cmd.SUB_C_OPERATE_CARD, cmd_data)
end
--用户听牌
function GameLayer:sendUserListenCard(bListen)
	local cmd_data = CCmd_Data:create(1)
	cmd_data:pushbool(bListen)
	self:SendData(cmd.SUB_C_LISTEN_CARD, cmd_data)
end
--用户托管
function GameLayer:sendUserTrustee()
	if not self.bSendCardFinsh then
		return
	end

	local cmd_data = CCmd_Data:create(1)
	cmd_data:pushbool(not self.bTrustee)
	self:SendData(cmd.SUB_C_TRUSTEE, cmd_data)
end
--用户补牌
-- function GameLayer:sendUserReplaceCard(card)
-- 	local cmd_data = ExternalFun.create_netdate(cmd.CMD_C_ReplaceCard)
-- 	cmd_data:pushbyte(card)
-- 	self:SendData(cmd.SUB_C_REPLACE_CARD, cmd_data)
-- end
--发送扑克
function GameLayer:sendControlCard(cbControlGameCount, cbCardCount, wBankerUser, cbCardData)
	local cmd_data = ExternalFun.create_netdata(cmd.CMD_C_SendCard)
	cmd_data:pushbyte(cbControlGameCount)
	cmd_data:pushbyte(cbCardCount)
	cmd_data:pushword(wBankerUser)
	for i = 1, #cbCardData do
		cmd_data:pushbyte(cbCardData[i])
	end
	self:SendData(cmd.SUB_C_SEND_CARD, cmd_data)
end

return GameLayer
