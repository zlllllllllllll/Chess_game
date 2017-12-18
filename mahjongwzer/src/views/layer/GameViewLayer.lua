local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")

local GameViewLayer = class("GameViewLayer",function(scene)
	--local gameViewLayer =  cc.CSLoader:createNode(cmd.RES_PATH.."game/GameScene.csb")
	local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

--require("client/src/plaza/models/yl")
local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local ScoreControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ScoreControl")
local ControlWnd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ControlWnd")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var 
--按钮标识

GameViewLayer.IDC_START						=	100								--开始按钮
GameViewLayer.IDC_TRUSTEE_CONTROL			=	104								--托管控制
GameViewLayer.IDC_MAI_DI				    =   105								-- 买底
GameViewLayer.IDC_DING_DI				    =   106								-- 顶底
GameViewLayer.IDC_MAI_CANCEL				=   107								--托管控制
GameViewLayer.IDC_DING_CANCEL				=	108

--动作标识
GameViewLayer.IDI_BOMB_EFFECT				=	101								--动作标识
GameViewLayer.IDI_TIP_SINGLE				=	102
GameViewLayer.IDI_SIBO_PLAY       	    	=	220
--动作数目
GameViewLayer.BOMB_EFFECT_COUNT				=	12								--动作数目
GameViewLayer.DISC_EFFECT_COUNT				=	8								--丢弃效果

GameViewLayer.IDI_DISC_EFFECT				=	102								--丢弃效果     重复了什么情况

function GameViewLayer:onButtonClickedEvent(tag, ref)
	if tag == GameViewLayer.IDC_START then
		print("开始按钮")
		self:OnStart()
	elseif tag == GameViewLayer.IDC_TRUSTEE_CONTROL then
		print("托管控制 IDC_TRUSTEE_CONTROL")
		self:OnStusteeControl()
	elseif tag == GameViewLayer.IDC_MAI_DI then
		print("买底")
		self:OnMaiDi()
	elseif tag == GameViewLayer.IDC_DING_DI then
		print("顶底")
		self:OnDingDi()
	elseif tag == GameViewLayer.IDC_MAI_CANCEL then
		print("_IDC_MAI_CANCEL")
		self:OnMaiCancel()
	elseif tag == GameViewLayer.IDC_DING_CANCEL then
		print("_IDC_DING_CANCEL")
		self:OnMaiCancel()
	else
		print("default")
	end
end

function GameViewLayer:ctor(scene)
	this = self
	self._scene = scene
	self._gameFrame = scene._gameFrame
	self:addSerchPaths()
	-- self:onInitData()
	self:preloadUI()
	-- self:initButtons()

	self.m_nXFace=48
	self.m_nYFace=48
	self.m_nXTimer=65
	self.m_nYTimer=69
	self.m_nXBorder=0
	self.m_nYBorder=0
	--标志变量
	self.m_bOutCard=false
	self.m_bWaitOther=false
	self.m_bHuangZhuang=false
	self.m_bListenStatus={}

	--游戏属性
	self.m_lBaseScore=0
	self.m_wBankerUser=yl.INVALID_CHAIR
	self.m_wCurrentUser=yl.INVALID_CHAIR

	--动作动画
	self.m_bBombEffect=false
	self.m_cbBombFrameIndex=0

	--丢弃效果
	self.m_wDiscUser=yl.INVALID_CHAIR
	self.m_cbDiscFrameIndex=0

	--用户状态
	self.m_cbCardData=0
	self.m_wOutCardUser=yl.INVALID_CHAIR
	self.m_cbUserAction={}
	self.m_bTrustee={}
	self.m_szCenterText=""

	--加载位图
	--[[

	m_ImageDingMai.LoadFromResource(hInstance,IDB_DINGMAI);;						// 顶买
	m_ImageDingMaiFrame.LoadFromResource(hInstance,IDB_DINGMAI_FRAME);			// 顶买框
	m_ImageNumber.LoadFromResource(hInstance,IDB_NUMBER);;				        // 数字

	m_ImageReady.LoadFromResource(hInstance,IDB_READY);							//准备
	--]]
	self.m_ImageWait=display.newSprite("res/game/WAIT_TIP.png"):setVisible(false):addTo(self)
	self.m_ImageBack=display.newSprite("res/game/VIEW_BACK.png"):setVisible(false):addTo(self)
	self.m_ImageUserFlag=display.newSprite("res/game/USER_FLAG.png"):setVisible(false):addTo(self)
	self.m_ImageUserAction=display.newSprite("res/game/USER_ACTION.png"):setVisible(false):addTo(self)
	self.m_ImageActionBack=display.newSprite("res/game/ACTION_BACK.png"):setVisible(false):addTo(self)
	self.m_ImageCS=display.newSprite("res/game/CS_BACK.png"):setVisible(false):addTo(self)
	self.m_ImageHuangZhuang=display.newSprite("res/game/HUANG_ZHUANG.png"):setVisible(false):addTo(self)
	self.m_ImageListenStatusH=display.newSprite("res/game/LISTEN_FLAG_H.png"):setVisible(false):addTo(self)
	self.m_ImageListenStatusV=display.newSprite("res/game/LISTEN_FLAG_V.png"):setVisible(false):addTo(self)
	self.m_ImageTrustee=display.newSprite("res/game/TRUSTEE.png"):setVisible(false):addTo(self)
	self.m_ImageActionAni=display.newSprite("res/game/ActionAni.png"):setVisible(false):addTo(self)
	self.m_ImageArrow=display.newSprite("res/game/ARROW.png"):setVisible(false):addTo(self)
	self.m_ImageCenter=display.newSprite("res/game/VIEW_CENTER.png"):setVisible(false):addTo(self)
	self.m_ImageSaizi=display.newSprite("res/game/SaiZi.png"):setVisible(false):addTo(self)

	self.m_ImageTipSingle=display.newSprite("res/game/TIP_SINGLE.png"):setVisible(false):addTo(self)

	self.ImageTimeBack=display.newSprite("res/game/TIME_BACK.png"):setVisible(false):addTo(self)
	self.ImageTimeNumber=display.newSprite("res/game/TIME_NUMBER.png"):setVisible(false):addTo(self)

	self.m_ImageDingMai=display.newSprite("res/game/dingmai.png"):setVisible(false):addTo(self)
	self.m_ImageDingMaiFrame=display.newSprite("res/game/DingMaiFrame.png"):setVisible(false):addTo(self)
	self.m_ImageNumber=display.newSprite("res/game/num.png"):setVisible(false):addTo(self)

	self.m_ImageReady=display.newSprite("res/game/READY.png"):setVisible(false):addTo(self)

	self.m_byGodsData = 0x00
	--m_pGameClientDlg=CONTAINING_RECORD(this,CGameClientEngine,m_GameClientView);  父指针
	--self.m_arBall.RemoveAll(); typedef struct tagBall
	self.m_arBall={}				--其实是二维
	self.m_iSicboAnimIndex = -1                                                 -- 骰子动画当前
	self.m_bySicbo={}
	self.m_byDingMai={}
	--self.m_SicboAnimPoint = CPoint(0,0);
	self.m_SicboAnimPoint = cc.p(0, 0)

	self.m_bTipSingle=false
	self.m_bBankerCount = 1
	return
end

function GameViewLayer:addSerchPaths( )
	--搜索路径
	local gameList = self._scene._scene:getApp()._gameList;
	local gameInfo = {};
	for k,v in pairs(gameList) do
		if tonumber(v._KindID) == tonumber(cmd.KIND_ID) then
			gameInfo = v
			break
		end
	end

	if nil ~= gameInfo._KindName then
		self._searchPath = device.writablePath.."game/" .. gameInfo._Module
		cc.FileUtils:getInstance():addSearchPath(self._searchPath)
	end
	print(self._searchPath)
	print(cc.FileUtils:getInstance():isFileExist("res/game/SCORE_WIN.png"))   --正常
	print(cc.FileUtils:getInstance():isFileExist("game/SCORE_WIN.png"))		  --正常 
	print(cc.FileUtils:getInstance():isFileExist("SCORE_WIN.png"))
end

--批量创建
function GameViewLayer:batchCreate(num,type)   --改长度需要使用 GameLogic.table_leng 不能使用 # 起始值不同 （此处键名不中断）
		a={}
		if type=="CHeapCard" then
			for i=1,num,1 do
				a[i]=CardControl:create_CHeapCard(self)				end
		elseif type=="CTableCard" then
			for i=1,num,1 do
				a[i]=CardControl:create_CTableCard(self)			end
		elseif type=="CDiscardCard" then
			for i=1,num,1 do
				a[i]=CardControl:create_CDiscardCard(self)		end
		elseif type=="CWeaveCard" then
			for i=1,num,1 do
				a[i]=CardControl:create_CWeaveCard(self)		end
		elseif type=="CUserCard" then
			for i=1,num,1 do
				a[i]=CardControl:create_CUserCard(self)		end
		elseif type=="" then
			--待补充
		end
		return a
end

function GameViewLayer:preloadUI()
		--变量定义
		self.Direction={CardControl.Direction_North,CardControl.Direction_East,CardControl.Direction_South,CardControl.Direction_West};
		--用户扑克
		self.m_HeapCard=self:batchCreate(4,"CHeapCard")

		self.m_HeapCard[1]:SetDirection(self.Direction[1])
		self.m_HeapCard[1]:SetGodsCard(0,0,0)
		--用户扑克
		self.m_HeapCard[2]:SetDirection(self.Direction[2])
		self.m_HeapCard[2]:SetGodsCard(0,0,0)
		--用户扑克
		self.m_HeapCard[3]:SetDirection(self.Direction[3])
		self.m_HeapCard[3]:SetGodsCard(0,0,0)
		--用户扑克
		self.m_HeapCard[4]:SetDirection(self.Direction[4])
		self.m_HeapCard[4]:SetGodsCard(0,0,0)

		--设置控件
		self.m_TableCard=self:batchCreate(cmd.GAME_PLAYER,"CTableCard")
		self.m_DiscardCard=self:batchCreate(cmd.GAME_PLAYER,"CDiscardCard")
		self.m_WeaveCard={} 
		for i=1,cmd.GAME_PLAYER,1 do
			self.m_WeaveCard[i] = {} 
			self.m_WeaveCard[i]=self:batchCreate(cmd.MAX_WEAVE,"CWeaveCard")
		end
		for i=1,cmd.GAME_PLAYER,1 do
			--用户扑克
			self.m_TableCard[i]:SetDirection(self.Direction[i*2])
			self.m_DiscardCard[i]:SetDirection(self.Direction[i*2])

			--组合扑克
			self.m_WeaveCard[i][1]:SetDisplayItem(true)
			self.m_WeaveCard[i][2]:SetDisplayItem(true)
			self.m_WeaveCard[i][3]:SetDisplayItem(true)
			self.m_WeaveCard[i][4]:SetDisplayItem(true)
			self.m_WeaveCard[i][5]:SetDisplayItem(true)
			self.m_WeaveCard[i][1]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][2]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][3]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][4]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][5]:SetDirection(self.Direction[i*2])
		end

		--设置控件
		self.m_UserCard=self:batchCreate(cmd.GAME_PLAYER,"CUserCard")
		self.m_UserCard[1]:SetDirection(CardControl.Direction_North)
		self.m_UserCard[2]:SetDirection(CardControl.Direction_East)


		--创建控件
		--CRect rcCreate(0,0,0,0);  mark 可能不显示
		--m_ScoreControl.Create(NULL,NULL,WS_CHILD|WS_CLIPCHILDREN|WS_CLIPSIBLINGS,rcCreate,this,200);
		self.m_ScoreControl=ScoreControl:create(self):addTo(self)
		self.m_ScoreControl:setTag(200)
		self.m_ScoreControl:move(0,0)
		self.m_ControlWnd=ControlWnd:create(self):addTo(self)
		self.m_ControlWnd:setTag(10)
		self.m_ControlWnd:move(0,0)
		--m_ControlWnd.m_cardControl=&m_HandCardControl;
		self.m_HandCardControl=CardControl:create_CCardControl(self)
		self.m_ControlWnd.m_cardControl=self.m_HandCardControl
		--用户扑克
		--self.m_ControlWnd:SetSinkWindow(AfxGetMainWnd());  --mark
		--创建控件
		local  btcallback = function(ref, type)
		if type == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(ref:getTag(),ref)
		end
		end
		ccui.Button:create("res/game/BT_START.png","res/game/BT_START.png")
			:move(yl.WIDTH/2,150)
            :setName("m_btStart")
			:setTag(GameViewLayer.IDC_START)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btStart=self:getChildByName("m_btStart")

		--托管按钮
		ccui.Button:create("res/game/BT_START_TRUSTEE.png","res/game/BT_START_TRUSTEE.png")
			:move(yl.WIDTH-100,50)
            :setName("m_btStusteeControl")
			:setTag(GameViewLayer.IDC_TRUSTEE_CONTROL)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btStusteeControl=self:getChildByName("m_btStusteeControl")
		ccui.Button:create("res/game/maidi.png","res/game/maidi.png")
			:move(yl.WIDTH-200,90)
            :setName("m_btMaiDi")
			:setTag(GameViewLayer.IDC_MAI_DI)
			:setScale(1)
			:setVisible(false) 
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btMaiDi=self:getChildByName("m_btMaiDi")
		ccui.Button:create("res/game/mai_dingdi.png","res/game/mai_dingdi.png")
			:move(yl.WIDTH-300,80)
            :setName("m_btDingDi")
			:setTag(GameViewLayer.IDC_DING_DI)
			:setScale(1)
			--:setVisible(false) 
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btDingDi=self:getChildByName("m_btDingDi")
		ccui.Button:create("res/game/mai_cancel.png","res/game/mai_cancel.png")
			:move(yl.WIDTH-300,70)
            :setName("m_btMaiCancel")
			:setTag(GameViewLayer.IDC_MAI_CANCEL)
			:setScale(1)
			:setVisible(false) 
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btMaiCancel=self:getChildByName("m_btMaiCancel")
		ccui.Button:create("res/game/di_cancel.png","res/game/di_cancel.png")
			:move(yl.WIDTH-300,60)
            :setName("m_btDingCancel")
			:setTag(GameViewLayer.IDC_DING_CANCEL)
			:setScale(1)
			:setVisible(false) 
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btDingCancel=self:getChildByName("m_btDingCancel")

		self.m_HandCardControl.pWnd=self
end

--重置界面     --有用到么？
function GameViewLayer:ResetGameView()
print("重置界面 GameViewLayer:ResetGameView")
	--标志变量
	self.m_bOutCard=false
	self.m_bWaitOther=false
	self.m_bHuangZhuang=false
	self.m_bListenStatus={}

	--游戏属性
	self.m_lBaseScore=0
	self.m_wBankerUser=yl.INVALID_CHAIR
	self.m_wCurrentUser=yl.INVALID_CHAIR

	--动作动画
	self.m_bBombEffect=false
	self.m_cbBombFrameIndex=0

	--丢弃效果
	self.m_wDiscUser=yl.INVALID_CHAIR
	self.m_cbDiscFrameIndex=0

	--用户状态
	self.m_cbCardData=0
	self.m_byGodsData = 0x00
	self.m_wOutCardUser=yl.INVALID_CHAIR
	self.m_cbUserAction={}
	self.m_szCenterText=""

	--界面设置

	self.m_btStart:setVisible(false)
	self.m_ControlWnd:setVisible(false)
	self.m_ScoreControl:RestorationData()
	self.m_btMaiDi:setVisible(false)
	self.m_btDingDi:setVisible(false)
	self.m_btMaiCancel:setVisible(false)
	self.m_btDingCancel:setVisible(false)

	--禁用控件
	--m_btStusteeControl.EnableWindow(FALSE);

	--扑克设置
	self.m_UserCard[1]:SetCardData(0,false)
	self.m_UserCard[2]:SetCardData(0,false)
	self.m_HandCardControl:SetPositively(false)
	self.m_HandCardControl:SetDisplayItem(false)
	self.m_HandCardControl:SetCardData(nil,0,0)

	for i=1,cmd.GAME_PLAYER,1 do          --创建的时候为 4个呀  GAME_PLAYER才2
		self.m_HeapCard[i]:SetCardData(0,0,0)
		self.m_HeapCard[i]:SetGodsCard(0,0,0)
	end

	--扑克设置
	for i=1,cmd.GAME_PLAYER,1 do
		self.m_TableCard[i]:SetCardData(nil,0)
		self.m_DiscardCard[i]:SetCardData(nil,0)
		self.m_WeaveCard[i][1]:SetCardData(nil,0)
		self.m_WeaveCard[i][2]:SetCardData(nil,0)
		self.m_WeaveCard[i][3]:SetCardData(nil,0)
		self.m_WeaveCard[i][4]:SetCardData(nil,0)
		self.m_WeaveCard[i][5]:SetCardData(nil,0)
	end

	--销毁定时器
	self._scene:F_GVKillTimer(GameViewLayer.IDI_DISC_EFFECT)
	self._scene:F_GVKillTimer(GameViewLayer.IDI_BOMB_EFFECT)
	self.m_arBall={}
	self.m_iSicboAnimIndex = -1                                                 -- 骰子动画当前
	self.m_bySicbo={}
	self.m_byDingMai={}
	return
end

--调整控件
function GameViewLayer:RectifyControl(nWidth,nHeight)
	--
	self.m_iSavedWidth=nWidth
	self.m_iSavedHeight=nHeight
	--设置坐标
	--CGameFrameView CPoint		m_ptReady[MAX_CHAIR];			//准备位置  MAX_CHAIR 100
	self.m_ptReady=GameLogic:ergodicList(100)
	self.m_ptReady[1].x=nWidth/2-33
	self.m_ptReady[1].y=70
	self.m_ptReady[2].x=nWidth/2-33
	self.m_ptReady[2].y=nHeight-100
	--CPoint							m_ptAvatar[MAX_CHAIR];				//头像位置
	self.m_ptAvatar=GameLogic:ergodicList(100)
	self.m_ptAvatar[1].x=nWidth/2-self.m_nXFace
	self.m_ptAvatar[1].y=5+self.m_nYBorder
	--CPoint							m_ptNickName[MAX_CHAIR];			//昵称位置
	self.m_ptNickName=GameLogic:ergodicList(100)
	self.m_ptNickName[1].x=nWidth/2-50
	self.m_ptNickName[1].y=20+self.m_nYBorder
	--CPoint							m_ptClock[MAX_CHAIR];					//时间位置
	self.m_ptClock=GameLogic:ergodicList(100)
	self.m_ptClock[1].x=nWidth/2-self.m_nXFace-self.m_nXTimer-2
	self.m_ptClock[1].y=17+self.m_nYBorder

	self.m_UserFlagPos=GameLogic:ergodicList(cmd.GAME_PLAYER)
	self.m_UserFlagPos[1].x=self.m_ptNickName[1].x+100										--nWidth/2-m_nXFace-m_nXTimer-32;
	self.m_UserFlagPos[1].y=5+self.m_nYBorder
	self.m_UserListenPos=GameLogic:ergodicList(cmd.GAME_PLAYER)
	self.m_UserListenPos[1].x=nWidth/2
	self.m_UserListenPos[1].y=self.m_nYBorder+100
	self.m_PointTrustee=GameLogic:ergodicList(cmd.GAME_PLAYER)
	self.m_PointTrustee[1].x=nWidth/2-self.m_nXFace-20-self.m_nXFace/2
	self.m_PointTrustee[1].y=5+self.m_nYBorder
	self.m_ptDingMai=GameLogic:ergodicList(cmd.GAME_PLAYER)
	self.m_ptDingMai[1].x =self.m_ptNickName[1].x+160											-- nWidth/2-m_nXFace-m_nXTimer + 40;
	self.m_ptDingMai[1].y = 21+self.m_nYBorder

	self.m_ptAvatar[2].x=nWidth/2-self.m_nXFace
	self.m_ptAvatar[2].y=nHeight-self.m_nYBorder-self.m_nYFace-5
	self.m_ptNickName[2].x=nWidth/2-50																		--+5+self.m_nXFace/2
	self.m_ptNickName[2].y=nHeight-self.m_nYBorder-self.m_nYFace+8
	self.m_ptClock[2].x=nWidth/2-self.m_nXFace/2-self.m_nXTimer-2
	self.m_ptClock[2].y=nHeight-self.m_nYBorder-self.m_nYTimer-8+40
	self.m_UserFlagPos[2].x=self.m_ptNickName[2].x+100										--nWidth/2-self.m_nXFace-self.m_nXTimer-32
	self.m_UserFlagPos[2].y=nHeight-self.m_nYBorder-35
	self.m_UserListenPos[2].x=nWidth/2
	self.m_UserListenPos[2].y=nHeight-self.m_nYBorder-123
	self.m_PointTrustee[2].x=nWidth/2-self.m_nXFace-20-self.m_nXFace/2
	self.m_PointTrustee[2].y=nHeight-self.m_nYBorder-self.m_nYFace-5
	self.m_ptDingMai[2].x = self.m_ptNickName[2].x+160										--nWidth/2-self.m_nXFace-self.m_nXTimer+40
	self.m_ptDingMai[2].y = nHeight-self.m_nYBorder-20

	self.m_SicboAnimPoint = cc.p(nWidth/2,nHeight/2)

	--对方在游戏过程中，手中的牌
	self.m_UserCard[1]:SetControlPoint(nWidth/2-210,self.m_nYBorder+self.m_nYFace+20)
	--自己在游戏过程中，手中的牌
	self.m_HandCardControl:SetBenchmarkPos(nWidth/2-20,nHeight-self.m_nYFace-self.m_nYBorder-20,CardControl.enXCenter,CardControl.enYBottom)

	--桌面扑克，即游戏结束后显示的牌
	self.m_TableCard[1]:SetControlPoint(nWidth/2-179,self.m_nYBorder+self.m_nYFace+20)							--对方的
	self.m_TableCard[2]:SetControlPoint(nWidth/2+330,nHeight-self.m_nYFace-self.m_nYBorder-20)	 		--自己的

	--组合扑克
	self.m_WeaveCard[1][1]:SetControlPoint(nWidth/2+230,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[1][2]:SetControlPoint(nWidth/2+155,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[1][3]:SetControlPoint(nWidth/2+80,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[1][4]:SetControlPoint(nWidth/2+5,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[1][5]:SetControlPoint(nWidth/2-60,self.m_nYBorder+self.m_nYFace+20)

	--组合扑克
	self.m_WeaveCard[2][1]:SetControlPoint(nWidth/2-380,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[2][2]:SetControlPoint(nWidth/2-260,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[2][3]:SetControlPoint(nWidth/2-140,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[2][4]:SetControlPoint(nWidth/2-20,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[2][5]:SetControlPoint(nWidth/2+100,nHeight-self.m_nYFace-self.m_nYBorder-20)

	--堆积扑克
	local nXCenter=nWidth/2
	local nYCenter=nHeight/2-40

	self.m_HeapCard[1]:SetControlPoint(nXCenter-152,nYCenter-207)
	self.m_HeapCard[2]:SetControlPoint(nXCenter+256,nYCenter-95)
	self.m_HeapCard[3]:SetControlPoint(nXCenter-152,nYCenter+207)
	self.m_HeapCard[4]:SetControlPoint(nXCenter-251,nYCenter-95)

	--丢弃扑克
	self.m_DiscardCard[1]:SetControlPoint(nXCenter-158,nYCenter-100)
	self.m_DiscardCard[2]:SetControlPoint(nXCenter+158,nYCenter+102)


	--控制窗口
	self.m_ControlWnd:SetBenchmarkPos(nWidth-10,nHeight-self.m_nYBorder-180)

	--移动按钮
	--CRect rcButton;
	--HDWP hDwp=BeginDeferWindowPos(6);
	--m_btStart.GetWindowRect(&rcButton);
	--const UINT uFlags=SWP_NOACTIVATE|SWP_NOZORDER|SWP_NOCOPYBITS|SWP_NOSIZE;

	--移动调整
	local rcButton=self.m_btStart:getContentSize()
	self.m_btStart:setPosition(cc.p((nWidth-rcButton.width)/2,nHeight-120-self.m_nYBorder))
	--移动调整
	self.m_btStusteeControl:setPosition( cc.p( nWidth-self.m_nXBorder-(rcButton.width+5),nHeight-self.m_nYBorder-rcButton.height+5 ))  
	--移动成绩
	--CRect rcScoreControl;
	--m_ScoreControl.GetWindowRect(&rcScoreControl);
	local xxcoreControl=self.m_ScoreControl:getContentSize()
	self.m_ScoreControl:setPosition( cc.p( (nWidth-xxcoreControl.width)/2,(nHeight-xxcoreControl.height)*2/5 ) )

	--m_btMaiDi.GetWindowRect(&rcButton);
	rcButton=self.m_btMaiDi:getContentSize()
print(" ==RectifyControl  ")
print("self.m_btMaiDi setP ",nWidth/2-rcButton.width-10,nHeight-120-self.m_nYBorder)
	self.m_btMaiDi:setPosition( cc.p( nWidth/2-rcButton.width-10,nHeight-120-self.m_nYBorder ) )
	self.m_btDingDi:setPosition( cc.p( nWidth/2-rcButton.width-10,nHeight-120-self.m_nYBorder ) )
	self.m_btMaiCancel:setPosition( cc.p( nWidth/2 + 10,nHeight-120-self.m_nYBorder ) )
	self.m_btDingCancel:setPosition( cc.p( nWidth/2 + 10,nHeight-120-self.m_nYBorder ) )
	--视频窗口
	return
end

--pDC 包含指针到子窗口中显示上下文。是瞬态的。
function GameViewLayer:DrawUserTimerEx(pDC,nXPos,nYPos,wTime)

	--获取属性 const INT  ImageTimeNumber等之前加载资源
	local nNumberHeight=self.ImageTimeNumber:getContentSize().height
	local nNumberWidth=self.ImageTimeNumber:getContentSize().width/11

	--计算数目
	local lNumberCount=2
	local wNumberTemp=wTime

	--位置定义
	local nYDrawPos=nYPos-nNumberHeight/2+1
	local nXDrawPos=nXPos+(lNumberCount*nNumberWidth)/2-nNumberWidth

	--self.ImageTimeBack.TransDrawImage(pDC,nXDrawPos-30,nYDrawPos-10,RGB(255,0,255));
	self.m_ImageCenter=display.newSprite("res/game/TIME_BACK.png")
		:move(nXDrawPos-30,nYDrawPos-10)
		:setColor(cc.c3b(255, 0, 255))
		:setVisible(true)
		:addTo(self)
	--绘画号码
	for i=1,lNumberCount,1 do
		--绘画号码
		local wCellNumber=wTime%10
		--self.ImageTimeNumber.TransDrawImage(pDC,nXDrawPos,nYDrawPos,nNumberWidth-5,nNumberHeight,wCellNumber*nNumberWidth,0,RGB(0,0,0)) 	--mark
		self.ImageTimeNumber=display.newSprite("res/game/TIME_NUMBER.png")
			:move(nXDrawPos,nYDrawPos)
			:setColor(cc.c3b(0, 0, 0))
			:setVisible(true)
			:addTo(self)

		--设置变量
		wTime=wTime /10
		nXDrawPos=nXDrawPos- nNumberWidth+1
	end

end

--绘画界面
function GameViewLayer:DrawGameView(pDC,nWidth,nHeight)
	--绘画背景  CImage::BitBlt	将源设备上下文的位图复制到此当前的设备上下文。 	CImage::StretchBlt	将位图从源矩形复制到目标矩形，可拉伸或压缩位图以符合目标矩形的尺寸，如有必要。
	-- DRAW_MODE_SPREAD:		//平铺模式
	-- DRAW_MODE_CENTENT:		//居中模式
	-- DRAW_MODE_ELONGGATE:	//拉伸模式
	--DrawViewImage(pDC,m_ImageBack,DRAW_MODE_SPREAD);
	--DrawViewImage(pDC,m_ImageCenter,DRAW_MODE_CENTENT);
	self.m_ImageBack=cc.Scale9Sprite:create("res/game/VIEW_BACK.png")
		:setCapInsets(CCRectMake(40,40,20,20))
		:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
		:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
		:setVisible(true)
		:addTo(self)

	self.m_ImageCenter=display.newSprite("res/game/VIEW_CENTER.png")
		:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
		:setVisible(true)
		:addTo(self)

	--[[
	CString strScore1;
	strScore1.Format(_T("财富:%d,%d"),nWidth,nHeight);
	//AfxMessageBox(strScore1);
	--]]

	if #self.m_szCenterText > 0 then		--提示字符串
		-- 设置字体  700
		local font = cc.Label:createWithTTF(self.m_szCenterText,"fonts/round_body.ttf", 28)
		font:move(nWidth/2-200,nHeight/2-100)
		font:setTextColor(cc.c4b(255,255,255,255))
	end

	--用户标志
	if self.m_wBankerUser~=yl.INVALID_CHAIR then
		--加载位图
		local nImageWidth=self.m_ImageUserFlag:getContentSize().width/4
		local nImageHeight=self.m_ImageUserFlag:getContentSize().height
		local iFrameW = self.m_ImageDingMaiFrame:getContentSize().width
		local iFrameH = self.m_ImageDingMaiFrame:getContentSize().height

		local iDingW = self.m_ImageDingMai:getContentSize().width/2
		local iDingH = self.m_ImageDingMai:getContentSize().height

		--绘画标志
		for i=1,cmd.GAME_PLAYER,1 do
			if i == self.m_wBankerUser then
				--self.m_ImageUserFlag.TransDrawImage(pDC,m_UserFlagPos[i].x-20,m_UserFlagPos[i].y,nImageWidth,nImageHeight,(m_bBankerCount-1)*nImageWidth,0,RGB(255,0,255));
				self.m_ImageUserFlag=cc.Scale9Sprite:create("res/game/VIEW_BACK.png")
					:setCapInsets(CCRectMake(40,40,20,20))
					:setContentSize(cc.size(nImageWidth, nImageHeight))
					:setPosition(self.m_UserFlagPos[i].x-20,self.m_UserFlagPos[i].y)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
					:addTo(self)
			end
			if self.m_byDingMai[i]>0 then
				self.m_ImageDingMai=display.newSprite("res/game/dingmai.png")
					:setPosition(self.m_ptDingMai[i].x-15-iDingW/2,self.m_ptDingMai[i].y-iDingH/2)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
					:addTo(self)
			end
		end
	end

	--桌面扑克
	for i=1,cmd.GAME_PLAYER,1 do
		self.m_TableCard[i]:DrawCardControl(pDC)					--桌面麻将，在结束以后才显示
		self.m_DiscardCard[i]:DrawCardControl(pDC)				--丢弃麻将
		self.m_WeaveCard[i][1]:DrawCardControl(pDC)				--吃碰杠麻将
		self.m_WeaveCard[i][2]:DrawCardControl(pDC)				--吃碰杠麻将
		self.m_WeaveCard[i][3]:DrawCardControl(pDC)				--吃碰杠麻将
		self.m_WeaveCard[i][4]:DrawCardControl(pDC)				--吃碰杠麻将
		self.m_WeaveCard[i][5]:DrawCardControl(pDC)				--吃碰杠麻将
	end

	--堆积扑克
	self.m_HeapCard[1]:DrawCardControl(pDC,"")
	self.m_HeapCard[2]:DrawCardControl(pDC,"")
	self.m_HeapCard[3]:DrawCardControl(pDC,"")
	self.m_HeapCard[4]:DrawCardControl(pDC,"")

	--用户扑克
	self.m_UserCard[1]:DrawCardControl(pDC)						--对方手中的麻将，游戏进行中显示
	self.m_HandCardControl:DrawCardControl(pDC)				--自己手中的麻将，游戏进行中显示

	--等待提示
	if self.m_bWaitOther==true then
		self.m_ImageWait=display.newSprite("res/game/WAIT_TIP.png")
			:setPosition((nWidth-self.m_ImageWait:getContentSize().width)/2,nHeight-145)
			:setColor(cc.c3b(255, 0, 255))
			:setVisible(true)
			:addTo(self)
	end

	--荒庄标志
	if self.m_bHuangZhuang==true then
		self.m_ImageHuangZhuang=display.newSprite("res/game/HUANG_ZHUANG.png")
			:setPosition((nWidth-self.m_ImageHuangZhuang:getContentSize().width)/2,nHeight/2-103)
			:setColor(cc.c3b(255, 0, 255))
			:setVisible(true)
			:addTo(self)
	end

	--听牌标志
	for i=1,cmd.GAME_PLAYER,1 do
		if self.m_bListenStatus[i]==true then
			--加载资源
			--CImageHandle HandleListenStatus(((i%2)==0)?&m_ImageListenStatusH:&m_ImageListenStatusV);
			if ((i-1)%2)==0 then
				--获取信息
				local nImageWidth=self.m_ImageListenStatusH:getContentSize().width
				local nImageHeight=self.m_ImageListenStatusH:getContentSize().height

				--绘画标志
				self.m_ImageListenStatusH=display.newSprite("res/game/HUANG_ZHUANG.png")
					:setPosition(self.m_UserListenPos[i].x-nImageWidth/2,self.m_UserListenPos[i].y-nImageHeight/2-10)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
					:addTo(self)
			else
				--获取信息
				local nImageWidth=self.m_ImageListenStatusV:getContentSize().width
				local nImageHeight=self.m_ImageListenStatusV:getContentSize().height

				--绘画标志
				self.m_ImageListenStatusV=display.newSprite("res/game/HUANG_ZHUANG.png")
					:setPosition(self.m_UserListenPos[i].x-nImageWidth/2,self.m_UserListenPos[i].y-nImageHeight/2-10)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
					:addTo(self)
			end
		end
	end

	if self.m_bTipSingle then
		self.m_ImageTipSingle=display.newSprite("res/game/TIP_SINGLE.png")
			:setPosition(nWidth/2-self.m_ImageTipSingle:getContentSize().width/2,nHeight/2+220)
			:setColor(cc.c3b(255, 0, 255))
			:setVisible(true)
			:addTo(self)
	end
	--用户状态
	for i=1,cmd.GAME_PLAYER,1 do
		if (self.m_wOutCardUser==i) or (self.m_cbUserAction[i]~=0) then
			--计算位置
			local nXPos,nYPos=0,0
			if (i-1)==0 then						--北向
				nXPos=nWidth/2-32
				nYPos=self.m_nYBorder+95
			elseif i==1 then				--南向
				nXPos=nWidth/2-32
				nYPos=nHeight-self.m_nYBorder-240
			end

			--绘画动作
			if self.m_cbUserAction[i]~=GameLogic.WIK_NULL then
				--绘画动作
				if self.m_bBombEffect==true and (i-1)==0 then
					local nXImagePos=-1
					if bit:_and(self.m_cbUserAction[i], GameLogic.WIK_PENG) then nXImagePos=59
					elseif bit:_and(self.m_cbUserAction[i], GameLogic.WIK_GANG) then	nXImagePos=118
					elseif bit:_and(self.m_cbUserAction[i], GameLogic.WIK_LISTEN) then	nXImagePos=-1
					elseif bit:_and(self.m_cbUserAction[i], GameLogic.WIK_CHI_HU) then	nXImagePos=-1
					else	nXImagePos=0
					end

					if nXImagePos~=-1 then
						--动作背景
						--mark
						-- self.m_ImageActionBack.BlendDrawImage(pDC,nXPos,nYPos,m_ImageActionBack.GetWidth(),m_ImageActionBack.GetHeight(),
						-- 	0,0,RGB(255,255,255),180);
						self.m_ImageActionBack=display.newSprite("res/game/ACTION_BACK.png")
							:setPosition(nXPos,nYPos)
							:setColor(cc.c3b(255, 255, 255))
        			:setOpacity(180)
							:setVisible(true)
							:addTo(self)
						self.m_ImageActionAni=display.newSprite("res/game/ActionAni.png")
							:setPosition(nXPos+29,nYPos+29)
							:setVisible(true)
							:addTo(self)
					end
				end
			else
				if i==0 then
					--动作背景
					self.m_ImageActionBack=display.newSprite("res/game/ACTION_BACK.png")
						:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 255, 255))
						:setOpacity(180)
						:setVisible(true)
						:addTo(self)
					--绘画扑克 CCardResource g_CardResource  DrawCardItem mark  下同
					self.g_CardResource=CardControl:create_CCardListImage(self)
					self.g_CardResource:DrawCardItem("m_ImageUserBottom",pDC,self.cbCardData,nXPos+39,nYPos+29)
				else
					--动作背景
					self.m_ImageActionBack=display.newSprite("res/game/ACTION_BACK.png")
						:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 255, 255))
						:setOpacity(180)
						:setVisible(true)
						:addTo(self)
					--绘画扑克
					self.g_CardResource=CardControl:create_CCardListImage(self)
					self.g_CardResource:DrawCardItem("m_ImageUserBottom",pDC,self.cbCardData,nXPos+39,nYPos+29)
				end
			end
		end
	end

	local nXPos,nYPos=15,10
	--动作背景
	self.m_ImageCS.BlendDrawImage(pDC,nXPos,nYPos,m_ImageCS.GetWidth(),m_ImageCS.GetHeight(),0,0,RGB(255,0,255),255);
	self.m_ImageCS:setPosition(nXPos,nYPos)
		:setColor(cc.c3b(255, 255, 255))
		:setOpacity(255)
		:setVisible(true)

	if self.m_byGodsData>0 then
		--绘画扑克
		self.g_CardResource=CardControl:create_CCardListImage(self)
		self.g_CardResource:DrawCardItem("m_ImageUserBottom",pDC,self.m_byGodsData,nXPos+55,nYPos+13)
	end

---------------=======================================================================================

	-- HFONT hFont=CreateFont(-14,0,0,0,400,0,0,0,134,3,2,1,2,TEXT("宋体"));
	-- HFONT hOldFont=(HFONT)pDC->SelectObject(hFont);

	--绘画用户
	local strScore
	for i=1,cmd.GAME_PLAYER,1 do
		--变量定义
		 --IClientUserItem * pUserData=GetClientUserItem(i);  mark 估计同
		 local pUserData=self._gameFrame:getTableUserItem(self:GetMeTableID(),i)
		 if pUserData~=nil then
 			--用户名字

			cc.Label:createWithTTF(pUserData:GetNickName(),"fonts/round_body.ttf", 24)
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
					:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
					:move(self.m_ptNickName[i].x,self.m_ptNickName[i].y)
					:setTextColor(cc.c4b(255,255,255,255))

			strScore="财富:"..pUserData:GetUserScore()

			cc.Label:createWithTTF(strScore,"fonts/round_body.ttf", 24)
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
					:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
					:move(self.m_ptDingMai[i].x+30,self.m_ptNickName[i].y)
					:setTextColor(cc.c4b(255,255,0,255))

			--其他信息
			local wUserTimer=GetUserClock(i) 								--mark  GetUserClock 未定义
			if (wUserTimer~=0) and (self.m_wCurrentUser~=yl.INVALID_CHAIR) then
				self:DrawUserTimerEx(pDC,nWidth/2,nHeight/2,wUserTimer)
				if self.m_wCurrentUser==0 then
					self.m_ImageArrow:setPosition(nWidth/2-15 +self.m_ImageArrow:getContentSize().width/4*self.m_wCurrentUser,nHeight/2-self.m_ImageArrow:getContentSize().height*2)
        		:setScaleX(1/4)
						:setVisible(true)
				end
				if self.m_wCurrentUser==1 then
					self.m_ImageArrow:setPosition(nWidth/2-15 +self.m_ImageArrow:getContentSize()/4*2,nHeight/2+self.m_ImageArrow:getContentSize().height)
        		:setScaleX(1/4)
						:setVisible(true)
				end
			end
			if (wUserTimer~=0) and (self.m_wCurrentUser==yl.INVALID_CHAIR) then
				self:DrawUserTimerEx(pDC,nWidth/2,nHeight/2,wUserTimer)
				if (i-1)==0 then
					self.m_ImageArrow:setPosition(nWidth/2-15 +self.m_ImageArrow:getContentSize().width/4*i,nHeight/2-self.m_ImageArrow:getContentSize().height*2)
        		:setScaleX(1/4)
						:setVisible(true)
				end
				if (i-1)==1 then
					self.m_ImageArrow:setPosition(nWidth/2-15 +self.m_ImageArrow:getContentSize()/4*2,nHeight/2+self.m_ImageArrow:getContentSize().height)
						:setScaleX(1/4)
						:setVisible(true)
				end
			end
			if pUserData:GetUserStatus()==yl.US_READY then
print("self.m_ImageReady:setPositio",self.m_ptReady[i].x,self.m_ptReady[i].y)
				self.m_ImageReady:setPosition(self.m_ptReady[i].x,self.m_ptReady[i].y)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end
		 end
	end

	self:DrawSicboAnim(pDC)
	return
end

--基础积分
function GameViewLayer:SetBaseScore(lBaseScore)
	--设置扑克
	if lBaseScore~=self.m_lBaseScore then
		--设置变量
		self.m_lBaseScore=lBaseScore

		--更新界面
		self:RefreshGameView()
	end

	return
end


--海底扑克
function GameViewLayer:SetHuangZhuang(bHuangZhuang)
	--设置扑克
	if bHuangZhuang~=self.m_bHuangZhuang then
		--设置变量
		self.m_bHuangZhuang=bHuangZhuang

		--更新界面
		self:RefreshGameView()
	end

	return
end

--庄家用户
function GameViewLayer:SetBankerUser(wBankerUser)
	--设置扑克
	if wBankerUser~=self.m_wBankerUser then
		--设置变量
		self.m_wBankerUser=wBankerUser

		--更新界面
		self:RefreshGameView()
	end

	return
end

--状态标志
function GameViewLayer:SetStatusFlag(bOutCard,bWaitOther)
		--设置变量
		self.m_bOutCard=bOutCard
		self.m_bWaitOther=bWaitOther

		--更新界面
		self:RefreshGameView()

	return
end

--出牌信息
function GameViewLayer:SetOutCardInfo(wViewChairID,cbCardData)
		--设置变量
		self.m_cbCardData=cbCardData
		self.m_wOutCardUser=wViewChairID

		--更新界面
		self:RefreshGameView()

	return
end

--动作信息
function GameViewLayer:SetUserAction(wViewChairID,bUserAction)
	--设置变量
	if wViewChairID<cmd.GAME_PLAYER then
		self.m_cbUserAction[wViewChairID]=bUserAction
		self:SetBombEffect(true)
	else
		self.m_cbUserAction={}
		if self.m_bBombEffect then
			self:SetBombEffect(false)
		end
	end
	-- self.m_iSavedWidth,self.m_iSavedHeight 目前无值 暂时为1300 300
	self.m_iSavedWidth,self.m_iSavedHeight=1300,300
	self:RectifyControl(self.m_iSavedWidth,self.m_iSavedHeight)

	--更新界面
	self:RefreshGameView()

	return
end

--听牌标志
function GameViewLayer:SetUserListenStatus(wViewChairID,bListenStatus)
	--设置变量
	if wViewChairID<cmd.GAME_PLAYER then
		SetBombEffect(true)
		self.m_cbUserAction[wViewChairID]=GameLogic.WIK_LISTEN
		self.m_bListenStatus[wViewChairID]=bListenStatus
	else
		self.m_bListenStatus={}
	end
	--更新界面
	self:RefreshGameView()

	return
end

--设置动作
function GameViewLayer:SetBombEffect(bBombEffect)
	if bBombEffect==true then
		--设置变量
		self.m_bBombEffect=true
		self.m_cbBombFrameIndex=0

		--启动时间
    self._scene:F_GVSetTimer(GameViewLayer.IDI_BOMB_EFFECT,250)
	else
		--停止动画
		if self.m_bBombEffect==true then
			--删除时间
			self._scene:F_GVKillTimer(GameViewLayer.IDI_BOMB_EFFECT)

			--设置变量
			self.m_bBombEffect=false
			self.m_cbBombFrameIndex=0

			--更新界面
			self:RefreshGameView()
		end
	end
	return true
end

--丢弃用户
function GameViewLayer:SetDiscUser(wDiscUser)
	if self.m_wDiscUser ~= wDiscUser then
		--更新变量
		self.m_wDiscUser=wDiscUser

		--更新界面
		self:RefreshGameView()
	end

	return
end

--定时玩家
function GameViewLayer:SetCurrentUser(wCurrentUser)
	if self.m_wCurrentUser ~= wCurrentUser then
		--更新变量
		self.m_wCurrentUser=wCurrentUser

		--更新界面
		self:RefreshGameView()
	end

	return
end

--设置托管
function GameViewLayer:SetTrustee(wTrusteeUser,bTrustee)
	if self.m_bTrustee[wTrusteeUser] ~=bTrustee then
		--更新变量
		self.m_bTrustee[wTrusteeUser]=bTrustee

		--更新界面
		self:RefreshGameView()
	end

	return
end

--设置中心文字
function GameViewLayer:SetCenterText(szText)
	if nil==szText then
		self.m_szCenterText=""
	else
		self.m_szCenterText=szText
	end
	self:RefreshGameView()
end

function GameViewLayer:SetGodsCard(byGodsCard)
	self.m_byGodsData = byGodsCard
	self:RefreshGameView()
end

function GameViewLayer:GetGodsCard()
	return self.m_byGodsData
end

function GameViewLayer:SetDingMaiValue(byDingMai)
	if nil == byDingMai then
		self.m_byDingMai={}
	else
		for i=1,cmd.GAME_PLAYER,1 do
			self.m_byDingMai[i] = byDingMai[i]
		end
	end
	self:RefreshGameView()
end

--艺术字体
function GameViewLayer:DrawTextString(pDC,pszString,crText,crFrame,nXPos,nYPos)
	--变量定义
	local nStringLength=#pszString
	local nXExcursion={1,1,1,0,-1,-1,-1,0}
	local nYExcursion={-1,0,1,1,1,0,-1,-1}

	--绘画边框
	--pDC->SetTextColor(crFrame);
	for i=1,GameLogic.table_leng(nXExcursion),1 do
		cc.Label:createWithTTF(pszString,"fonts/round_body.ttf", 24)
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
				:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
				:move(nXPos+nXExcursion[i],nYPos+nYExcursion[i])
				:setTextColor(cc.c4b(255,255,0,255))
		--TextOut(pDC,nXPos+nXExcursion[i],nYPos+nYExcursion[i],pszString,nStringLength);  nStringLength 不清楚作用 下同
	end

	--绘画字体
	cc.Label:createWithTTF(pszString,"fonts/round_body.ttf", 24)
			:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
			:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			:move(nXPos,nYPos)
			:setTextColor(crText)

	return
end


--光标消息
function GameViewLayer:OnSetCursor(pWnd,nHitTest,uMessage)
	--[[
	--获取光标
	CPoint MousePoint;
	GetCursorPos(&MousePoint);
	ScreenToClient(&MousePoint);

	--点击测试
	local bRePaint=false;
	local bHandle=m_HandCardControl.OnEventSetCursor(MousePoint,bRePaint);

	--重画控制
	if (bRePaint==true)
		RefreshGameView();

	--光标控制
	if (bHandle==false)
		__super::OnSetCursor(pWnd,nHitTest,uMessage);

	return true
	--]]
end

--鼠标消息
function GameViewLayer:OnLButtonDown(nFlags,Point)
--[[
	__super::OnLButtonDown(nFlags, Point);

	--获取扑克
	BYTE cbHoverCard=m_HandCardControl.GetHoverCard();
	if (cbHoverCard!=0)
		SendEngineMessage(IDM_OUT_CARD,cbHoverCard,cbHoverCard);
	else
		SendEngineMessage(IDM_OUT_INVALID_CARD,0,0);

	return
	--]]
end

--开始按钮
function GameViewLayer:OnStart()
	self.m_bTipSingle=false
	--发送消息
	self._scene:OnStart(0,0)
	return
end

--拖管控制
function GameViewLayer:OnStusteeControl()
	self._scene:OnStusteeControl(0,0)
	return
end

function GameViewLayer:OnMaiDi()
	self._scene:OnDingDi(2,0)						 -- 买底
end

function GameViewLayer:OnDingDi()
	self._scene:OnDingDi(2,0)						 -- 顶底
end

function GameViewLayer:OnMaiCancel()
	self._scene:OnDingDi(1,0)						 -- 取消
end

------------------------------------------------------------------------------------------------------------------

function GameViewLayer:OnTimer(nIDEvent)
	if nIDEvent==GameViewLayer.IDI_TIP_SINGLE then
		self.m_bTipSingle=false
		self._scene:F_GVKillTimer(GameViewLayer.IDI_TIP_SINGLE)
		self:RefreshGameView()
	end
	--动作动画
	if nIDEvent==GameViewLayer.IDI_BOMB_EFFECT then
		--停止判断
		if self.m_bBombEffect==false then
			self._scene:F_GVKillTimer(GameViewLayer.IDI_BOMB_EFFECT)
			return
		end

		--设置变量
		if (self.m_cbBombFrameIndex+1)>=GameViewLayer.BOMB_EFFECT_COUNT then
			--删除时间
			self._scene:F_GVKillTimer(GameViewLayer.IDI_BOMB_EFFECT)

			--设置变量
			self.m_bBombEffect=false
			self.m_cbBombFrameIndex=0
		else
			self.m_cbBombFrameIndex=self.m_cbBombFrameIndex+1
		end

		--更新界面
		self:RefreshGameView()

		return
	end
	if nIDEvent==GameViewLayer.IDI_DISC_EFFECT then
		--设置变量
		if (self.m_cbDiscFrameIndex+1)>=GameViewLayer.DISC_EFFECT_COUNT then
			self.m_cbDiscFrameIndex=0
		else
			self.m_cbDiscFrameIndex=self.m_cbDiscFrameIndex+1
		end

		--更新界面
		self:RefreshGameView()

		return
	end
	if GameViewLayer.IDI_SIBO_PLAY == nIDEvent then
		--CGameClientEngine					*m_pGameClientDlg;					//父类指针
		--if (NULL == m_pGameClientDlg)
		if nil == self._gameFrame then
			self:StopSicboAnim()
			return
		end

		if cmd.GS_MJ_MAIDI~=self._gameFrame:GetGameStatus() then
			self:StopSicboAnim()
			return
		end

		-- 绘制动画
		self.m_iSicboAnimIndex=self.m_iSicboAnimIndex+1
		if self.m_iSicboAnimIndex<13 then
			--播放声音
			if nil ~= self._gameFrame and (self.m_iSicboAnimIndex<13)
				and (0 == self.m_iSicboAnimIndex%5) then
					-- //if (m_pGameClientDlg->IsEnableSound())
					-- {
					-- 	//m_pGameClientDlg->PlayGameSound(AfxGetInstanceHandle(),TEXT("SICBO_WAV"));
					-- }
			end
			self.OnEnterRgn(150)
		end

		if self.m_iSicboAnimIndex > 20 then
			self.m_iSicboAnimIndex = -1
			self._scene:F_GVKillTimer(GameViewLayer.IDI_SIBO_PLAY)
			self._scene:OnDispatchCard(0,0)
		end
		if self.m_iSicboAnimIndex > 13 then
			self._scene:F_GVKillTimer(GameViewLayer.IDI_SIBO_PLAY)
	    self._scene:F_GVSetTimer(GameViewLayer.IDI_SIBO_PLAY,100)
		elseif self.m_iSicboAnimIndex >9 then
			self._scene:F_GVKillTimer(GameViewLayer.IDI_SIBO_PLAY)
	    self._scene:F_GVSetTimer(GameViewLayer.IDI_SIBO_PLAY,80)
		elseif self.m_iSicboAnimIndex > 5 then
			self._scene:F_GVKillTimer(GameViewLayer.IDI_SIBO_PLAY)
	    self._scene:F_GVSetTimer(GameViewLayer.IDI_SIBO_PLAY,50)
		elseif self.m_iSicboAnimIndex>1 then
			self._scene:F_GVKillTimer(GameViewLayer.IDI_SIBO_PLAY)
	    self._scene:F_GVSetTimer(GameViewLayer.IDI_SIBO_PLAY,20)
		end
		self:RefreshGameView()
		return
	end
	--__super::OnTimer(nIDEvent)
end

function GameViewLayer:OnLButtonDblClk(nFlags,point)
	-- // TODO: 在此添加消息处理程序代码和/或调用默认值
	--
	-- __super::OnLButtonDblClk(nFlags, point);
	-- CRect rect(0,0,200,200);
	-- if (rect.PtInRect(point))
	-- {
	-- 	//需要确认身份
	-- 	m_pGameClientDlg->SendSocketData(SUB_C_CHECK_SUPER);
	-- }

end

-- 绘画掷骰子动画
function GameViewLayer:DrawSicboAnim(pDC)
	if (self.m_iSicboAnimIndex < 0) or (nil == self._gameFrame) then
		return
	end
	if cmd.GS_MJ_MAIDI ~= self._gameFrame:GetGameStatus() then
		return
	end
	if self.m_iSicboAnimIndex > 0 then
		--画骰子动画
		local nImageHeight=self.m_ImageSaizi:getContentSize().height
		local nImageWidth=self.m_ImageSaizi:getContentSize().width/21
		--mark  i<m_arBall.GetCount()  m_arBall 尚未完全初始化
		for i=1,GameLogic.table_leng(self.m_arBall),1 do
			local byIndex = self.m_arBall[i].iIndex%15+6
			local iX = int(m_SicboAnimPoint.x+self.m_arBall[i].dbX-nImageWidth/2)
			local iY = int(m_SicboAnimPoint.y+self.m_arBall[i].dbY-nImageHeight/2)
			if self.m_iSicboAnimIndex>13 then
				byIndex = self.m_bySicbo[i]-1
			end
			--self.m_ImageSaizi.TransDrawImage(pDC, iX,iY, nImageWidth, nImageHeight,byIndex *nImageWidth, 0,RGB(255,0,255))
			self.m_ImageSaizi:setPosition(iX,iY)
				:setColor(cc.c3b(255, 0, 255))
				:setVisible(true)
		end
	end
end

function GameViewLayer:OnEnterRgn(dbR)
	-- 边界反弹
	for i=1,GameLogic.table_leng(self.m_arBall),1 do
		-- 是否在圆内
		--CRect rect(-dbR, -dbR, +dbR, +dbR)
		local Trect=cc.rect(-dbR, -dbR, dbR*2, dbR*2)
		local ptTemp=cc.p((self.m_arBall[i].dbX + self.m_arBall[i].dbDx),(self.m_arBall[i].dbY + self.m_arBall[i].dbDy))
		if not cc.rectContainsPoint(Trect, ptTemp) then
			self:mcFanTang(self.m_arBall[i])
			self.m_arBall[i].dbX = self.m_arBall[i].dbX +self.m_arBall[i].dbDx
			self.m_arBall[i].dbY = self.m_arBall[i].dbY +self.m_arBall[i].dbDy
		end

		if (self.m_arBall[i].dbX<-dbR + self.m_arBall[i].dbWidth/2 and self.m_arBall[i].dbDx<0)
			or (self.m_arBall[i].dbX>dbR-self.m_arBall[i].dbWidth/2 and self.m_arBall[i].dbDx>0) then
				self.m_arBall[i].dbDx=self.m_arBall[i].dbDx* -1
		end

		if (self.m_arBall[i].dbY<-dbR + self.m_arBall[i].dbHeight/2 and self.m_arBall[i].dbDy<0)
			or (self.m_arBall[i].dbY>dbR-self.m_arBall[i].dbHeight/2 and self.m_arBall[i].dbDy>0) then
				self.m_arBall[i].dbDy=self.m_arBall[i].dbDy* -1
		end

		--检测所有MC之间是否有碰撞，有就根据情况改变“增量”方向
		for j=i+1,GameLogic.table_leng(self.m_arBall)-1,1 do
			if self:myHitTest(self.m_arBall[i],self.m_arBall[j]) then
					self:mc12(self.m_arBall[i], self.m_arBall[j])
					self.m_arBall[i].dbX = self.m_arBall[i].dbX +self.m_arBall[i].dbDx
					self.m_arBall[j].dbX = self.m_arBall[j].dbX +self.m_arBall[j].dbDx
					self.m_arBall[i].dbY = self.m_arBall[i].dbY +self.m_arBall[i].dbDy
					self.m_arBall[j].dbY = self.m_arBall[j].dbY +self.m_arBall[j].dbDy
			end
		end

		--移动一个“增量”
		self.m_arBall[i].dbX = self.m_arBall[i].dbX +self.m_arBall[i].dbDx
		self.m_arBall[i].dbY = self.m_arBall[i].dbY +self.m_arBall[i].dbDy
		if (math.abs(self.m_arBall[i].dbDx) < 0.5) and (math.abs(self.m_arBall[i].dbDy) < 0.5) then
			self.m_arBall[i].dbDx=1.6
			self.m_arBall[i].dbDy=2.7
		end
		self.m_arBall[i].iIndex=self.m_arBall[i].iIndex+1
	end
end

--碰撞函数，根据两球碰撞方向和自身运动方向合成新的增量值
function GameViewLayer:mc12(mc1,mc2)
	--碰撞角
	--local  ang = atan2((mc2.dbY-mc1.dbY),mc2.dbX-mc1.dbX);
	local  ang = math.deg(math.atan((mc2.dbY-mc1.dbY),mc2.dbX-mc1.dbX))
	--运动角
	local ang1 = math.deg(math.atan(mc1.dbDy,mc1.dbDx))
	local ang2 = math.deg(math.atan(mc2.dbDy, mc2.dbDx))

	--反射角
	local _ang1 = 2*ang-ang1-math.pi
	local _ang2 = 2*ang-ang2-math.pi

	--运动矢量
	local r1=math.sqrt(mc1.dbDx*mc1.dbDx+mc1.dbDy*mc1.dbDy)
	local r2=math.sqrt(mc2.dbDx*mc2.dbDx+mc2.dbDy*mc2.dbDy)

	--碰撞矢量
	local a1 = (mc1.dbDy/math.sin(math.rad(ang1)))*	math.cos(math.rad(ang-ang1))
	local a2 = (mc2.dbDy/math.sin(math.rad(ang2)))*	math.cos(math.rad(ang-ang2))

	--碰撞矢量合成
	local dx1 = a1*math.cos(math.rad(ang))+a2*math.cos(math.rad(ang))
	local dy1 = a1*math.sin(math.rad(ang))+a2*math.sin(math.rad(ang))

	--碰撞后的增量
	mc1.dbDx = r1*math.cos(math.rad(_ang1))+dx1
	mc1.dbDy = r1*math.sin(math.rad(_ang1))+dy1
	mc2.dbDx = r2*math.cos(math.rad(_ang2))+dx1
	mc2.dbDy = r2*math.sin(math.rad(_ang2))+dy1
end

--碰撞侦测
function GameViewLayer:myHitTest(mc1,mc2)
	local a=math.sqrt((mc1.dbX-mc2.dbX)*(mc1.dbX-mc2.dbX)
		+(mc1.dbY-mc2.dbY)*(mc1.dbY-mc2.dbY))

	if a-5 <(mc1.dbWidth+mc2.dbWidth)/2 then
		return true
	else
		return false
	end
end

--碰撞函数
function GameViewLayer:mcFanTang(mc)
	-- 小球运动方向与x坐标轴的夹角
	local  ang = math.deg(math.atan(mc.dbDy,mc.dbDx))

	-- 碰撞点与x坐标夹角
	local ang1 = math.deg(math.atan(mc.dbY,mc.dbX))

	-- 反射角
	local _ang1 = 2*ang1-ang- math.pi

	--运动矢量
	local r1=math.sqrt(mc.dbDx*mc.dbDx+mc.dbDy*mc.dbDy)

	-- 碰撞后的增量
	mc.dbDx = r1*math.cos(math.rad(_ang1))
	mc.dbDy = r1*math.sin(math.rad(_ang1))
end

function GameViewLayer:StartSicboAnim(bySicbo,iStartIndex)
	--memcpy(m_bySicbo, bySicbo, 2);
	self.m_bySicbo=GameLogic.deepcopy(bySicbo)
	self.m_iSicboAnimIndex = iStartIndex

	-- 画骰子动画
	local nImageHeight=self.m_ImageSaizi:getContentSize().height
	local nImageWidth=self.m_ImageSaizi:getContentSize().width/21
	local sBall={}				--其实是二维
	--self.m_arBall.RemoveAll();
	self.m_arBall={}
	sBall.dbX = -35.1
	sBall.dbY = 30.4
	sBall.dbWidth = nImageWidth-1
	sBall.dbHeight = nImageHeight -1
	sBall.dbDx = 7.8 * ((0==math.random()%2) and 1 or -1)
	sBall.dbDy = 6.2 * ((0==math.random()%2) and 1 or -1)
	sBall.iIndex = math.random()%25
	--m_arBall.Add(sBall)
	table.insert(self.m_arBall,sBall)

	sBall.dbX = 20.3
	sBall.dbY = -23.4
	sBall.dbDx = 6.3 * ((0==math.random()%2) and 1 or -1)
	sBall.dbDy = 5.3 * ((0==math.random()%2) and 1 or -1)
	sBall.iIndex = math.random()%30
	table.insert(self.m_arBall,sBall)
	self._scene:F_GVSetTimer(GameViewLayer.IDI_SIBO_PLAY,100)
	self:RefreshGameView()
	if iStartIndex<20 then
		self._scene:PlaySound(cmd.RES_PATH.."mahjong/sezi.wav")
	end
end

--更新视图
function GameViewLayer:RefreshGameView()
	--mark
	-- CRect rect;
	-- GetClientRect(&rect);
	-- InvalidGameView(rect.left,rect.top,rect.Width(),rect.Height());

	return
end

function GameViewLayer:StopSicboAnim()
	self._scene:F_GVKillTimer(GameViewLayer.IDI_SIBO_PLAY)
	self.m_iSicboAnimIndex = -1
	self:RefreshGameView()
end

--绘画数字
function GameViewLayer:DrawNumberString(pDC,lNumber,nXPos,nYPos,bMeScore)
	--加载资源

	local cx=self.m_ImageNumber:getContentSize().width/10
	local cy=self.m_ImageNumber:getContentSize().height

	--计算数目
	local lNumberCount=0
	local lNumberTemp=lNumber

	lNumberCount=lNumberCount+1
	lNumberTemp=lNumberTemp/10
	if lNumberTemp>0 then
		lNumberCount=lNumberCount+1
		lNumberTemp=lNumberTemp/10
	end

	--位置定义
	local nYDrawPos=nYPos-cy/2
	local nXDrawPos=nXPos+lNumberCount*cx/2-cx

	--绘画桌号
	for i=0,lNumberCount-1,1 do
		--绘画号码
		local lCellNumber=lNumber%10
		if bMeScore and bMeScore~=0 then
-- makr  数字图片 待处理
			self.m_ImageNumber:setPosition(nXDrawPos,nYDrawPos)
				:setColor(cc.c3b(255, 0, 255))
				:setVisible(true)
			-- self.m_ImageNumber
			-- TransDrawImage(pDC,nXDrawPos,nYDrawPos,cx,cy,
			-- 	lCellNumber*cx,0,RGB(255,0,255));
		else
			-- self.m_ImageNumber
			-- TransDrawImage(pDC,nXDrawPos,nYDrawPos,cx,cy,
			-- 	lCellNumber*cx,0,RGB(255,0,255));
		end

		--设置变量
		lNumber=lNumber/10
		nXDrawPos=nXDrawPos-cx
	end
	return
end

-- function GameViewLayer:PreTranslateMessage(pMsg)
-- 	return CGameFrameView::PreTranslateMessage(pMsg);
-- end

return GameViewLayer
