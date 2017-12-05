local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")

local GameViewLayer = class("GameViewLayer",function(scene)
	--local gameViewLayer =  cc.CSLoader:createNode(cmd.RES_PATH.."game/GameScene.csb")
	local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

--require("client/src/plaza/models/yl")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local CardLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardLayer")
local ResultLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ResultLayer")
local SetLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.SetLayer")
local GameChatLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayer")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")

local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local ScoreControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ScoreControl")
local ControlWnd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.ControlWnd")
--按钮标识

GameViewLayer.IDC_START									100								--开始按钮
GameViewLayer.IDC_TRUSTEE_CONTROL				104								--托管控制
GameViewLayer.IDC_MAI_DI				        105								-- 买底
GameViewLayer.IDC_DING_DI				        106								-- 顶底
GameViewLayer.IDC_MAI_CANCEL				    107								--托管控制
GameViewLayer.IDC_DING_CANCEL						108

--动作标识
GameViewLayer.IDI_BOMB_EFFECT						101								--动作标识
GameViewLayer.IDI_TIP_SINGLE						102
GameViewLayer.IDI_SIBO_PLAY       	    220
--动作数目
GameViewLayer.BOMB_EFFECT_COUNT					12								--动作数目
GameViewLayer.DISC_EFFECT_COUNT					8									--丢弃效果

GameViewLayer.IDI_DISC_EFFECT						102								--丢弃效果     重复了什么情况

local  btcallback = function(ref, type)
  if type == ccui.TouchEventType.ended then
   	this:onButtonClickedEvent(ref:getTag(),ref)
  end
end
local this

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
	self.m_szCenterText={}

	--加载位图
	--[[
	HINSTANCE hInstance=AfxGetInstanceHandle();
	m_ImageWait.LoadFromResource(hInstance,IDB_WAIT_TIP);
	m_ImageBack.LoadFromResource(hInstance,IDB_VIEW_BACK);
	m_ImageUserFlag.LoadFromResource(hInstance,IDB_USER_FLAG);
	//m_ImageOutCard.LoadFromResource(IDB_OUT_CARD_TIP,hInstance);
	m_ImageUserAction.LoadFromResource(hInstance,IDB_USER_ACTION);
	m_ImageActionBack.LoadFromResource(hInstance,IDB_ACTION_BACK);
	m_ImageCS.LoadFromResource(hInstance,IDB_CS_BACK);
	m_ImageHuangZhuang.LoadFromResource(hInstance,IDB_HUANG_ZHUANG);
	m_ImageListenStatusH.LoadFromResource(hInstance,IDB_LISTEN_FLAG_H);
	m_ImageListenStatusV.LoadFromResource(hInstance,IDB_LISTEN_FLAG_V);
	m_ImageTrustee.LoadImage(hInstance,TEXT("TRUSTEE"));
	m_ImageActionAni.LoadImage(AfxGetInstanceHandle(),TEXT("ActionAni"));
	//m_ImageDisc.LoadImage(AfxGetInstanceHandle(),TEXT("DISC"));
	m_ImageArrow.LoadImage(AfxGetInstanceHandle(),TEXT("ARROW"));
	m_ImageCenter.LoadFromResource(hInstance,IDB_VIEW_CENTER);
	m_ImageSaizi.LoadFromResource(hInstance,IDB_ANIM_SAIZI);

	m_ImageTipSingle.LoadFromResource(hInstance,IDB_TIP_SINGLE);

	ImageTimeBack.LoadFromResource(hInstance,IDB_TIME_BACK);
	ImageTimeNumber.LoadFromResource(hInstance,IDB_TIME_NUMBER);

	m_ImageDingMai.LoadFromResource(hInstance,IDB_DINGMAI);;						// 顶买
	m_ImageDingMaiFrame.LoadFromResource(hInstance,IDB_DINGMAI_FRAME);			// 顶买框
	m_ImageNumber.LoadFromResource(hInstance,IDB_NUMBER);;				        // 数字

	m_ImageReady.LoadFromResource(hInstance,IDB_READY);							//准备
	--]]

	self.m_byGodsData = 0x00
	--m_pGameClientDlg=CONTAINING_RECORD(this,CGameClientEngine,m_GameClientView);  父指针
	--self.m_arBall.RemoveAll(); typedef struct tagBall
	self.m_arBall={}
	self.m_iSicboAnimIndex = -1                                                 -- 骰子动画当前
	self.m_bySicbo={}
	self.m_byDingMai={}
	--self.m_SicboAnimPoint = CPoint(0,0);
	self.m_SicboAnimPoint = cc.p(0, 0)

	self.m_bTipSingle=false
	self.m_bBankerCount = 1
	return
end

--批量创建
function GameViewLayer:batchCreate(num,type)   --改长度需要使用 GameLogic.table_leng 不能使用 # 起始值不同 （此处键名不中断）
		a={}
		if type=="CHeapCard" then
			for i=0,num-1,1 do
				a[i]=CardControl:create_CHeapCard(self)				end
		elseif type=="CTableCard" then
			for i=0,num-1,1 do
				a[i]=CardControl:create_CTableCard(self)			end
		elseif type=="CDiscardCard" then
			for i=0,num-1,1 do
				a[i]=CardControl:create_CDiscardCard(self)		end
		elseif type=="CWeaveCard" then
			for i=0,num-1,1 do
				a[i]=CardControl:create_CWeaveCard(self)		end
		elseif type=="CUserCard" then
			for i=0,num-1,1 do
				a[i]=CardControl:create_CUserCard(self)		end
		elseif type=="" then
			--待补充
		end
		return a
end

function GameViewLayer:preloadUI()
		--变量定义
		self.Direction={CardControl.enDirection.Direction_North,CardControl.enDirection.Direction_East,CardControl.enDirection.Direction_South,CardControl.enDirection.Direction_West};
		--用户扑克
		self.m_HeapCard=self:batchCreate(4,"CHeapCard")

		self.m_HeapCard[0]:SetDirection(self.Direction[0])
		self.m_HeapCard[0]:SetGodsCard(0,0,0)
		--用户扑克
		self.m_HeapCard[1]:SetDirection(self.Direction[1])
		self.m_HeapCard[1]:SetGodsCard(0,0,0)
		--用户扑克
		self.m_HeapCard[2]:SetDirection(self.Direction[2])
		self.m_HeapCard[2]:SetGodsCard(0,0,0)
		--用户扑克
		self.m_HeapCard[3]:SetDirection(self.Direction[3])
		self.m_HeapCard[3]:SetGodsCard(0,0,0)

		--设置控件
		self.m_TableCard=self:batchCreate(cmd.GAME_PLAYER,"CTableCard")
		self.m_DiscardCard=self:batchCreate(cmd.GAME_PLAYER,"CDiscardCard")
		for i=0,cmd.GAME_PLAYER-1,1 do
			self.m_WeaveCard=self:batchCreate(cmd.MAX_WEAVE,"CWeaveCard")
		end
		for i=0,cmd.GAME_PLAYER-1,1 do
			--用户扑克
			self.m_TableCard[i]:SetDirection(self.Direction[i*2])
			self.m_DiscardCard[i]:SetDirection(self.Direction[i*2])

			--组合扑克
			self.m_WeaveCard[i][0]:SetDisplayItem(true)
			self.m_WeaveCard[i][1]:SetDisplayItem(true)
			self.m_WeaveCard[i][2]:SetDisplayItem(true)
			self.m_WeaveCard[i][3]:SetDisplayItem(true)
			self.m_WeaveCard[i][4]:SetDisplayItem(true)
			self.m_WeaveCard[i][0]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][1]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][2]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][3]:SetDirection(self.Direction[i*2])
			self.m_WeaveCard[i][4]:SetDirection(self.Direction[i*2])
		end

		--设置控件
		self.m_UserCard=self:batchCreate(cmd.GAME_PLAYER,"CUserCard")
		self.m_UserCard[0]:SetDirection(CardControl.enDirection.Direction_North)
		self.m_UserCard[1]:SetDirection(CardControl.enDirection.Direction_East)


		--创建控件
		--CRect rcCreate(0,0,0,0);  mark 可能不显示
		--m_ScoreControl.Create(NULL,NULL,WS_CHILD|WS_CLIPCHILDREN|WS_CLIPSIBLINGS,rcCreate,this,200);
		self.m_ScoreControl=ScoreControl:create_CScoreControl(self)
		self.m_ScoreControl:setTag(200)
		self.m_ScoreControl:move(0,0)
		self.m_ControlWnd=ControlWnd:create_CControlWnd(self)
		self.m_ControlWnd:setTag(10)
		self.m_ControlWnd:move(0,0)
		--m_ControlWnd.m_cardControl=&m_HandCardControl;
		self.m_HandCardControl=CardControl:create_CCardControl(self)
		self.m_ControlWnd.m_cardControl=self.m_HandCardControl
		--用户扑克
		--self.m_ControlWnd:SetSinkWindow(AfxGetMainWnd());  --mark
		--创建控件
		self.m_btStart=ccui.Button:create("res/game/BT_START.png","res/game/BT_START.png")
			:move(0,0)
			:setTag(GameViewLayer.IDC_START)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)

		--托管按钮
		self.m_btStusteeControl=ccui.Button:create("res/game/BT_START_TRUSTEE.png","res/game/BT_START_TRUSTEE.png")
			:move(0,0)
			:setTag(GameViewLayer.IDC_TRUSTEE_CONTROL)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btMaiDi=ccui.Button:create("res/game/maidi.png","res/game/maidi.png")
			:move(0,0)
			:setTag(GameViewLayer.IDC_MAI_DI)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btDingDi=ccui.Button:create("res/game/mai_dingdi.png","res/game/mai_dingdi.png")
			:move(0,0)
			:setTag(GameViewLayer.IDC_DING_DI)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btMaiCancel=ccui.Button:create("res/game/mai_cancel.png","res/game/mai_cancel.png")
			:move(0,0)
			:setTag(GameViewLayer.IDC_MAI_CANCEL)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btDingCancel=ccui.Button:create("res/game/di_cancel.png","res/game/di_cancel.png")
			:move(0,0)
			:setTag(GameViewLayer.IDC_DING_CANCEL)
			:setScale(1)
			:addTo(self)
			:addTouchEventListener(btcallback)
		self.m_btMaiDi:setVisible(false)
		self.m_btDingDi:setVisible(false)
		self.m_btMaiCancel:setVisible(false)
		self.m_btDingCancel:setVisible(false)

		self.m_HandCardControl.pWnd=self
end

--重置界面     --有用到么？
function GameViewLayer:ResetGameView()
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
	self.m_szCenterText={}

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
	self:m_UserCard[0]:SetCardData(0,false)
	self:m_UserCard[1]:SetCardData(0,false)
	self:m_HandCardControl:SetPositively(false)
	self:m_HandCardControl:SetDisplayItem(false)
	self:m_HandCardControl:SetCardData(nil,0,0)

	for i=0,cmd.GAME_PLAYER-1,1 do          --创建的时候为 4个呀  GAME_PLAYER才2
		self.m_HeapCard[i]:SetCardData(0,0,0)
		self.m_HeapCard[i]:SetGodsCard(0,0,0)
	end

	--扑克设置
	for i=0,cmd.GAME_PLAYER-1,1 do
		self.m_TableCard[i]:SetCardData(nil,0)
		self.m_DiscardCard[i]:SetCardData(nil,0)
		self.m_WeaveCard[i][0]:SetCardData(nil,0)
		self.m_WeaveCard[i][1]:SetCardData(nil,0)
		self.m_WeaveCard[i][2]:SetCardData(nil,0)
		self.m_WeaveCard[i][3]:SetCardData(nil,0)
		self.m_WeaveCard[i][4]:SetCardData(nil,0)
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
	self.m_iSavedWidth=nWidth
	self.m_iSavedHeight=nHeight
	--设置坐标
	--CGameFrameView CPoint		m_ptReady[MAX_CHAIR];			//准备位置  MAX_CHAIR 100
	self.m_ptReady=self._scene:ergodicList(100)
	self.m_ptReady[0].x=nWidth/2-33
	self.m_ptReady[0].y=70
	self.m_ptReady[1].x=nWidth/2-33
	self.m_ptReady[1].y=nHeight-100
	--CPoint							m_ptAvatar[MAX_CHAIR];				//头像位置
	self.m_ptAvatar=self._scene:ergodicList(100)
	self.m_ptAvatar[0].x=nWidth/2-self.m_nXFace
	self.m_ptAvatar[0].y=5+self.m_nYBorder
	--CPoint							m_ptNickName[MAX_CHAIR];			//昵称位置
	self.m_ptNickName=self._scene:ergodicList(100)
	self.m_ptNickName[0].x=nWidth/2-50
	self.m_ptNickName[0].y=20+self.m_nYBorder
	--CPoint							m_ptClock[MAX_CHAIR];					//时间位置
	self.m_ptClock=self._scene:ergodicList(100)
	self.m_ptClock[0].x=nWidth/2-self.m_nXFace-self.m_nXTimer-2
	self.m_ptClock[0].y=17+self.m_nYBorder

	self.m_UserFlagPos=self._scene:ergodicList(cmd.GAME_PLAYER)
	self.m_UserFlagPos[0].x=self.m_ptNickName[0].x+100										--nWidth/2-m_nXFace-m_nXTimer-32;
	self.m_UserFlagPos[0].y=5+self.m_nYBorder
	self.m_UserListenPos=self._scene:ergodicList(cmd.GAME_PLAYER)
	self.m_UserListenPos[0].x=nWidth/2
	self.m_UserListenPos[0].y=self.m_nYBorder+100
	self.m_PointTrustee=self._scene:ergodicList(cmd.GAME_PLAYER)
	self.m_PointTrustee[0].x=nWidth/2-self.m_nXFace-20-self.m_nXFace/2
	self.m_PointTrustee[0].y=5+self.m_nYBorder
	self.m_ptDingMai=self._scene:ergodicList(cmd.GAME_PLAYER)
	self.m_ptDingMai[0].x =self.m_ptNickName[0].x+160											-- nWidth/2-m_nXFace-m_nXTimer + 40;
	self.m_ptDingMai[0].y = 21+self.m_nYBorder

	self.m_ptAvatar[1].x=nWidth/2-self.m_nXFace
	self.m_ptAvatar[1].y=nHeight-self.m_nYBorder-self.m_nYFace-5
	self.m_ptNickName[1].x=nWidth/2-50																		--+5+self.m_nXFace/2
	self.m_ptNickName[1].y=nHeight-self.m_nYBorder-self.m_nYFace+8
	self.m_ptClock[1].x=nWidth/2-self.m_nXFace/2-self.m_nXTimer-2
	self.m_ptClock[1].y=nHeight-self.m_nYBorder-self.m_nYTimer-8+40
	self.m_UserFlagPos[1].x=self.m_ptNickName[1].x+100										--nWidth/2-self.m_nXFace-self.m_nXTimer-32
	self.m_UserFlagPos[1].y=nHeight-self.m_nYBorder-35
	self.m_UserListenPos[1].x=nWidth/2
	self.m_UserListenPos[1].y=nHeight-self.m_nYBorder-123
	self.m_PointTrustee[1].x=nWidth/2-self.m_nXFace-20-self.m_nXFace/2
	self.m_PointTrustee[1].y=nHeight-self.m_nYBorder-self.m_nYFace-5
	self.m_ptDingMai[1].x = self.m_ptNickName[1].x+160										--nWidth/2-self.m_nXFace-self.m_nXTimer+40
	self.m_ptDingMai[1].y = nHeight-self.m_nYBorder-20

	self.m_SicboAnimPoint = cc.p(nWidth/2,nHeight/2)

	--对方在游戏过程中，手中的牌
	self.m_UserCard[0]:SetControlPoint(nWidth/2-210,self.m_nYBorder+self.m_nYFace+20)
	--自己在游戏过程中，手中的牌
	self.m_HandCardControl:SetBenchmarkPos(nWidth/2-20,nHeight-self.m_nYFace-self.m_nYBorder-20,CardControl.enXCollocateMode.enXCenter,CardControl.enYCollocateMode.enYBottom)

	--桌面扑克，即游戏结束后显示的牌
	self.m_TableCard[0]:SetControlPoint(nWidth/2-179,self.m_nYBorder+self.m_nYFace+20)							--对方的
	self.m_TableCard[1]:SetControlPoint(nWidth/2+330,nHeight-self.m_nYFace-self.m_nYBorder-20)	 		--自己的

	--组合扑克
	self.m_WeaveCard[0][0]:SetControlPoint(nWidth/2+230,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[0][1]:SetControlPoint(nWidth/2+155,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[0][2]:SetControlPoint(nWidth/2+80,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[0][3]:SetControlPoint(nWidth/2+5,self.m_nYBorder+self.m_nYFace+20)
	self.m_WeaveCard[0][4]:SetControlPoint(nWidth/2-60,self.m_nYBorder+self.m_nYFace+20)

	--组合扑克
	self.m_WeaveCard[1][0]:SetControlPoint(nWidth/2-380,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[1][1]:SetControlPoint(nWidth/2-260,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[1][2]:SetControlPoint(nWidth/2-140,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[1][3]:SetControlPoint(nWidth/2-20,nHeight-self.m_nYFace-self.m_nYBorder-20)
	self.m_WeaveCard[1][4]:SetControlPoint(nWidth/2+100,nHeight-self.m_nYFace-self.m_nYBorder-20)

	--堆积扑克
	local nXCenter=nWidth/2
	local nYCenter=nHeight/2-40

	self.m_HeapCard[0]:SetControlPoint(nXCenter-152,nYCenter-207)
	self.m_HeapCard[1]:SetControlPoint(nXCenter+256,nYCenter-95)
	self.m_HeapCard[2]:SetControlPoint(nXCenter-152,nYCenter+207)
	self.m_HeapCard[3]:SetControlPoint(nXCenter-251,nYCenter-95)

	--丢弃扑克
	self.m_DiscardCard[0]:SetControlPoint(nXCenter-158,nYCenter-100)
	self.m_DiscardCard[1]:SetControlPoint(nXCenter+158,nYCenter+102)


	--控制窗口
	self.m_ControlWnd.SetBenchmarkPos(nWidth-10,nHeight-self.m_nYBorder-180)

	--移动按钮
	CRect rcButton;
	HDWP hDwp=BeginDeferWindowPos(6);
	m_btStart.GetWindowRect(&rcButton);
	const UINT uFlags=SWP_NOACTIVATE|SWP_NOZORDER|SWP_NOCOPYBITS|SWP_NOSIZE;

	//移动调整
	DeferWindowPos(hDwp,m_btStart,NULL,(nWidth-rcButton.Width())/2,nHeight-120-m_nYBorder,0,0,uFlags);
	//移动调整
	DeferWindowPos(hDwp,m_btStusteeControl,NULL,nWidth-m_nXBorder-(rcButton.Width()+5),nHeight-m_nYBorder-rcButton.Height()+5,0,0,uFlags);
	//移动成绩
	CRect rcScoreControl;
	m_ScoreControl.GetWindowRect(&rcScoreControl);
	DeferWindowPos(hDwp,m_ScoreControl,NULL,(nWidth-rcScoreControl.Width())/2,(nHeight-rcScoreControl.Height())*2/5,0,0,uFlags);

	m_btMaiDi.GetWindowRect(&rcButton);
	DeferWindowPos(hDwp,m_btMaiDi,NULL,(nWidth/2-rcButton.Width()-10),nHeight-120-m_nYBorder,0,0,uFlags);
	DeferWindowPos(hDwp,m_btDingDi,NULL,(nWidth/2-rcButton.Width()-10),nHeight-120-m_nYBorder,0,0,uFlags);
	DeferWindowPos(hDwp,m_btMaiCancel,NULL,(nWidth/2 + 10),nHeight-120-m_nYBorder,0,0,uFlags);
	DeferWindowPos(hDwp,m_btDingCancel,NULL,(nWidth/2 + 10),nHeight-120-m_nYBorder,0,0,uFlags);
	//视频窗口
//	CRect rcAVDlg;
//	m_DlgVedioService[0].GetWindowRect(&rcAVDlg);
//	DeferWindowPos(hDwp,m_DlgVedioService[1],NULL,nWidth-m_nXBorder-5-rcAVDlg.Width(),nHeight/2+30,0,0,uFlags);
//	DeferWindowPos(hDwp,m_DlgVedioService[3],NULL,m_nXBorder+5,nHeight/2+30,0,0,uFlags);
//	DeferWindowPos(hDwp,m_DlgVedioService[0],NULL,nWidth-m_nXBorder-5-rcAVDlg.Width(),5,0,0,uFlags);
//	m_DlgVedioService[2].GetWindowRect(&rcAVDlg);
//	DeferWindowPos(hDwp,m_DlgVedioService[2],NULL,m_nXBorder+5,nHeight-m_nYBorder-3-rcAVDlg.Height(),0,0,uFlags);

	--结束移动
	EndDeferWindowPos(hDwp);
	return
end

------------------------------------------------------------------------------------------------------------------

function GameViewLayer:onInitData()
	self.cbActionCard = 0
	self.cbOutCardTemp = 0
	self.chatDetails = {}
	self.cbAppearCardIndex = {}
	self.m_bNormalState = {}
	--房卡需要
	self.m_sparrowUserItem = {}
end

function GameViewLayer:onResetData()
	self._cardLayer:onResetData()

	self.spListenBg:removeAllChildren()
	self.spListenBg:setVisible(false)
	self.cbOutCardTemp = 0
	self.cbAppearCardIndex = {}
	local spFlag = self:getChildByTag(GameViewLayer.SP_OPERATFLAG)
	if spFlag then
		spFlag:removeFromParent()
	end
	self.spCardPlate:setVisible(false)
	self.spTrusteeCover:setVisible(false)
	for i = 1, cmd.GAME_PLAYER do
		self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_TRUSTEE):setVisible(false)
		self.nodePlayer[i]:getChildByTag(GameViewLayer.SP_BANKER):setVisible(false)
	end
	self:setRemainCardNum(112)
	self.spGameBtn:getChildByTag(GameViewLayer.BT_PASS):setEnabled(true):setColor(cc.c3b(255, 255, 255))
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("gameScene.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("gameScene.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end



function GameViewLayer:initButtons()
	--按钮回调
	local btnCallback = function(ref, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(ref:getTag(), ref)
		elseif eventType == ccui.TouchEventType.began and ref:getTag() == GameViewLayer.BT_VOICE then
			self:onButtonClickedEvent(GameViewLayer.BT_VOICEOPEN, ref)
		end
	end

	--桌子操作按钮屏蔽层
	local callbackShield = function(ref)
		local pos = ref:getTouchEndPosition()
        local rectBg = self.spTableBtBg:getBoundingBox()
        if not cc.rectContainsPoint(rectBg, pos)then
        	self:showTableBt(false)
        end
	end
	self.layoutShield = ccui.Layout:create()
		:setContentSize(cc.size(display.width, display.height))
		:setTouchEnabled(false)
		:addTo(self, 5)
	self.layoutShield:addClickEventListener(callbackShield)
	--桌子操作按钮
	self.spTableBtBg = self:getChildByTag(GameViewLayer.SP_TABLE_BT_BG)
		:setLocalZOrder(5)
		:move(1486, 706)
		:setVisible(false)
	local btSet = self.spTableBtBg:getChildByTag(GameViewLayer.BT_SET)
	--btSet:setSelected(not bAble)
	btSet:addTouchEventListener(btnCallback)
	local btChat = self.spTableBtBg:getChildByTag(GameViewLayer.BT_CHAT)	--聊天
	btChat:addTouchEventListener(btnCallback)
	local btExit = self.spTableBtBg:getChildByTag(GameViewLayer.BT_EXIT)	--退出
	btExit:addTouchEventListener(btnCallback)
	local btTrustee = self.spTableBtBg:getChildByTag(GameViewLayer.BT_TRUSTEE)	--托管
	btTrustee:addTouchEventListener(btnCallback)
	if GlobalUserItem.bPrivateRoom then
		btTrustee:setEnabled(false)
		btTrustee:setColor(cc.c3b(158, 112, 8))
	end
	local btHowPlay = self.spTableBtBg:getChildByTag(GameViewLayer.BT_HOWPLAY)	--玩法
	btHowPlay:addTouchEventListener(btnCallback)

	--桌子按钮开关
	self.btSwitch = self:getChildByTag(GameViewLayer.BT_SWITCH)
		:setLocalZOrder(2)
	self.btSwitch:addTouchEventListener(btnCallback)
	--开始
	self.btStart = self:getChildByTag(GameViewLayer.BT_START)
		:setLocalZOrder(2)
		:setVisible(false)
	self.btStart:addTouchEventListener(btnCallback)
	--语音
	local btVoice = self:getChildByTag(GameViewLayer.BT_VOICE)
	btVoice:setLocalZOrder(2)
	btVoice:setVisible(false)
	btVoice:addTouchEventListener(btnCallback)

	--游戏操作按钮
	self.spGameBtn = self:getChildByTag(GameViewLayer.SP_GAMEBTN)
		:setLocalZOrder(3)
		:setVisible(false)
	local btBump = self.spGameBtn:getChildByTag(GameViewLayer.BT_BUMP) 	--碰
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btBump:addTouchEventListener(btnCallback)
	local btBrigde = self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE) 		--杠
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btBrigde:addTouchEventListener(btnCallback)
	local btWin = self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)		--胡
		:setEnabled(false)
		:setColor(cc.c3b(158, 112, 8))
	btWin:addTouchEventListener(btnCallback)
	local btPass = self.spGameBtn:getChildByTag(GameViewLayer.BT_PASS)		--过
	btPass:addTouchEventListener(btnCallback)
end

function GameViewLayer:showTableBt(bVisible)
	if self.spTableBtBg:isVisible() == bVisible then
		return false
	end

	local fSpacing = 334
	if bVisible == true then
        self.layoutShield:setTouchEnabled(true)
		self.btSwitch:setVisible(false)
		self.spTableBtBg:setVisible(true)
		self.spTableBtBg:runAction(cc.MoveBy:create(0.3, cc.p(-fSpacing, 0)))
	else
        self.layoutShield:setTouchEnabled(false)
		self.spTableBtBg:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(fSpacing, 0)),
			cc.CallFunc:create(function(ref)
				self.btSwitch:setVisible(true)
				self.spTableBtBg:setVisible(false)
			end)))
	end

	return true
end

--更新用户显示
function GameViewLayer:OnUpdateUser(viewId, userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		print("OnUpdateUser viewId is nil")
		return
	end

	self.m_sparrowUserItem[viewId] = userItem
	--头像
	local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_HEAD)
	if not userItem then
		self.nodePlayer[viewId]:setVisible(false)
		if head then
			head:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_READY):setVisible(userItem.cbUserStatus == yl.US_READY)
		--头像
		if not head then
			head = PopupInfoHead:createNormal(userItem, 82)
			head:setPosition(1, 12)			--初始位置
			head:enableHeadFrame(false)
			head:enableInfoPop(true, posHead[viewId], anchorPointHead[viewId])			--点击弹出的位置0
			head:setTag(GameViewLayer.SP_HEAD)
			self.nodePlayer[viewId]:addChild(head)
		else
			head:updateHead(userItem)
			--掉线头像变灰
			if userItem.cbUserStatus == yl.US_OFFLINE then
				if self.m_bNormalState[viewId] then
					convertToGraySprite(head.m_head.m_spRender)
				end
				self.m_bNormalState[viewId] = false
			else
				if not self.m_bNormalState[viewId] then
					convertToNormalSprite(head.m_head.m_spRender)
				end
				self.m_bNormalState[viewId] = true
			end
		end
		head:setVisible(true)
		--金币
		local score = userItem.lScore
		if userItem.lScore < 0 then
			score = -score
		end
		local strScore = self:numInsertPoint(score)
		if userItem.lScore < 0 then
			strScore = "."..strScore
		end
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.ASLAB_SCORE):setString(strScore)
		--昵称
		local strNickname = string.EllipsisByConfig(userItem.szNickName, 90, string.getConfig("fonts/round_body.ttf", 14))
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.TEXT_NICKNAME):setString(strNickname)
	end
end

--用户聊天
function GameViewLayer:userChat(wViewChairId, chatString)
	if chatString and #chatString > 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

		--创建label
		local limWidth = 24*12
		local labCountLength = cc.Label:createWithTTF(chatString,"fonts/round_body.ttf", 24)
		if labCountLength:getContentSize().width > limWidth then
			self.chatDetails[wViewChairId] = cc.Label:createWithTTF(chatString,"fonts/round_body.ttf", 24, cc.size(limWidth, 0))
		else
			self.chatDetails[wViewChairId] = cc.Label:createWithTTF(chatString,"fonts/round_body.ttf", 24)
		end
		self.chatDetails[wViewChairId]:setColor(cc.c3b(0, 0, 0))
		self.chatDetails[wViewChairId]:move(posChat[wViewChairId].x, posChat[wViewChairId].y + 15)
		self.chatDetails[wViewChairId]:setAnchorPoint(cc.p(0.5, 0.5))
		self.chatDetails[wViewChairId]:addTo(self, 3)

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(self.chatDetails[wViewChairId]:getContentSize().width+38, self.chatDetails[wViewChairId]:getContentSize().height + 54)
			:setVisible(true)
		--动作
	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--用户表情
function GameViewLayer:userExpression(wViewChairId, wItemIndex)
	if wItemIndex and wItemIndex >= 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

	    local strName = string.format("e(%d).png", wItemIndex)
	    self.chatDetails[wViewChairId] = cc.Sprite:createWithSpriteFrameName(strName)
	        :move(posChat[wViewChairId].x, posChat[wViewChairId].y + 15)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self, 3)
	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(90,100)
			:setVisible(true)

	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

function GameViewLayer:onUserVoiceStart(viewId)
	--取消上次
	if self.chatDetails[viewId] then
		self.chatDetails[viewId]:stopAllActions()
		self.chatDetails[viewId]:removeFromParent()
		self.chatDetails[viewId] = nil
	end
     -- 语音动画
    local param = AnimationMgr.getAnimationParam()
    param.m_fDelay = 0.1
    param.m_strName = cmd.VOICE_ANIMATION_KEY
    local animate = AnimationMgr.getAnimate(param)
    self.m_actVoiceAni = cc.RepeatForever:create(animate)

    self.chatDetails[viewId] = display.newSprite("#blank.png")
    	:move(posChat[viewId].x, posChat[viewId].y + 15)
		:setAnchorPoint(cc.p(0.5, 0.5))
		:addTo(self, 3)
	if viewId == 2 or viewId == 3 then
		self.chatDetails[viewId]:setRotation(180)
	end
	self.chatDetails[viewId]:runAction(self.m_actVoiceAni)

    --改变气泡大小
	self.chatBubble[viewId]:setContentSize(90,100)
		:setVisible(true)
end

function GameViewLayer:onUserVoiceEnded(viewId)
	if self.chatDetails[viewId] then
	    self.chatDetails[viewId]:removeFromParent()
	    self.chatDetails[viewId] = nil
	    self.chatBubble[viewId]:setVisible(false)
	end
end

function GameViewLayer:onButtonClickedEvent(tag, ref)
	if tag == GameViewLayer.BT_START then
		print("红中麻将开始！")
		self.btStart:setVisible(false)
		self._scene:sendGameStart()
	elseif tag == GameViewLayer.BT_SWITCH then
		print("按钮开关")
		self:showTableBt(true)
	elseif tag == GameViewLayer.BT_CHAT then
		print("聊天！")
		self._chatLayer:showGameChat(true)
		self:showTableBt(false)
	elseif tag == GameViewLayer.BT_SET then
		print("设置开关")
		self:showTableBt(false)
		self._setLayer:showLayer()
		local data2 = {0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x11, 0x12, 0x14, 0x17, 0x19, 0x19, 0x25,
					0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x11, 0x12, 0x14, 0x17, 0x19, 0x19, 0x25}
		--self:setListeningCard(data2)
	elseif tag == GameViewLayer.BT_HOWPLAY then
		print("玩法！")
        self._scene._scene:popHelpLayer(yl.HTTP_URL .. "/Mobile/Introduce.aspx?kindid=389&typeid=0")
	elseif tag == GameViewLayer.BT_EXIT then
		print("退出！")
		-- self._cardLayer:bumpOrBridgeCard(1, {1, 1, 1}, GameLogic.SHOW_PENG)
		-- self._cardLayer:bumpOrBridgeCard(2, {1, 1, 1, 1}, GameLogic.SHOW_PENG)
		--self._cardLayer:bumpOrBridgeCard(3, {1, 1, 1, 1}, GameLogic.SHOW_AN_GANG)
		-- self._cardLayer:bumpOrBridgeCard(4, {1, 1, 1, 1}, GameLogic.SHOW_FANG_GANG)
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_TRUSTEE then
		print("托管")
		self._scene:sendUserTrustee()
	elseif tag == GameViewLayer.BT_VOICE then
		print("语音关闭！")
		local data1 = {0x11, 0x08, 0x06, 0x09, 0x08, 0x02, 0x02, 0x07}
		local data2 = {0x02, 0x03, 0x04, 0x04, 0x05, 0x06, 0x11, 0x12, 0x14, 0x17, 0x19, 0x19, 0x25, 0x36}
		local data3 = {0x22, 0x22, 0x22, 0x19, 0x19}
		local data4 = {0x01, 0x03, 0x05, 0x15, 0x16, 0x17, 0x24, 0x24, 0x25, 0x25, 0x25, 0x27, 0x36, 0x29}
		local data5 = {1, 1, 1, 6, 7, 8, 9, 18, 19, 20, 33, 34, 35, 53}
		for i = 1, cmd.GAME_PLAYER do
			self._cardLayer:setHandCard(i, 14, data5)
		end
	elseif tag == GameViewLayer.BT_VOICEOPEN then
		print("语音开启！")
	elseif tag == GameViewLayer.BT_BUMP then
		print("碰！")

		--发送碰牌
		local cbOperateCard = {self.cbActionCard, self.cbActionCard, self.cbActionCard}
		self._scene:sendOperateCard(GameLogic.WIK_PENG, cbOperateCard)

		self:HideGameBtn()
	elseif tag == GameViewLayer.BT_BRIGDE then
		print("杠！")
		local cbGangCard = self._cardLayer:getGangCard(self.cbActionCard)
		local cbOperateCard = {cbGangCard, cbGangCard, cbGangCard}
		self._scene:sendOperateCard(GameLogic.WIK_GANG, cbOperateCard)

		self:HideGameBtn()
	elseif tag == GameViewLayer.BT_WIN then
		print("胡！")

		local cbOperateCard = {self.cbActionCard, 0, 0}
		self._scene:sendOperateCard(GameLogic.WIK_CHI_HU, cbOperateCard)

		self:HideGameBtn()
	elseif tag == GameViewLayer.BT_PASS then
		print("过！")
		local cbOperateCard = {0, 0, 0}
		self._scene:sendOperateCard(GameLogic.WIK_NULL, cbOperateCard)

		self:HideGameBtn()
	else
		print("default")
	end
end

--计时器刷新
function GameViewLayer:OnUpdataClockView(viewId, time)
	if not viewId or viewId == yl.INVALID_CHAIR or not time then
		--self.spClock:setVisible(false)
		self.asLabTime:setString(0)
	else
		--self.spClock:setVisible(true)
		local res = string.format("sp_clock_%d.png", viewId)
		self.spClock:setSpriteFrame(res)
		self.asLabTime:setString(time)
	end
end

--开始
function GameViewLayer:gameStart(startViewId, wHeapHead, cbCardData, cbCardCount, cbSiceCount1, cbSiceCount2)
	--self:runSiceAnimate(cbSiceCount1, cbSiceCount2, function()
		self._cardLayer:sendCard(cbCardData, cbCardCount)
	--end)
end
--用户出牌
function GameViewLayer:gameOutCard(viewId, card)
	self:showCardPlate(viewId, card)
	self._cardLayer:removeHandCard(viewId, {card}, true)

	self.cbOutCardTemp = card
	self.cbOutUserTemp = viewId
	--self._cardLayer:discard(viewId, card)
end
--用户抓牌
function GameViewLayer:gameSendCard(viewId, card, bTail)
	--把上一个人打出的牌丢入弃牌堆
	if self.cbOutCardTemp ~= 0 then
		self._cardLayer:discard(self.cbOutUserTemp, self.cbOutCardTemp)
		self.cbOutUserTemp = nil
		self.cbOutCardTemp = 0
	end

	--清理之前的出牌
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self:showCardPlate(nil)
			self:showOperateFlag(nil)
		end)))

	--当前的人抓牌
	self._cardLayer:catchCard(viewId, card, bTail)
end
--摇骰子
function GameViewLayer:runSiceAnimate(cbSiceCount1, cbSiceCount2, callback)
	local str1 = string.format("sice_red_%d", cbSiceCount1)
	local str2 = string.format("sice_white_%d", cbSiceCount2)
	local siceX1 = 667 - 320 + math.random(640) - 35
	local siceY1 = 375 - 120 + math.random(240) + 43
	local siceX2 = 667 - 320 + math.random(640) - 35
	local siceY2 = 375 - 120 + math.random(240) + 43
	display.newSprite()
		:move(siceX1, siceY1)
		:setTag(GameViewLayer.SP_SICE1)
		:addTo(self, 0)
		:runAction(cc.Sequence:create(
			self:getAnimate(str1),
			cc.DelayTime:create(1),
			cc.CallFunc:create(function(ref)
				--ref:removeFromParent()
			end)))
	display.newSprite()
		:move(siceX2, siceY2)
		:setTag(GameViewLayer.SP_SICE2)
		:addTo(self, 0)
		:runAction(cc.Sequence:create(
			self:getAnimate(str2),
			cc.DelayTime:create(1),
			cc.CallFunc:create(function(ref)
				--ref:removeFromParent()
				if callback then
					callback()
				end
			end)))
	self._scene:PlaySound(cmd.RES_PATH.."sound/DRAW_SICE.wav")
end

function GameViewLayer:sendCardFinish()
	local spSice1 = self:getChildByTag(GameViewLayer.SP_SICE1)
	if spSice1 then
		spSice1:removeFromParent()
	end
	local spSice2 = self:getChildByTag(GameViewLayer.SP_SICE2)
	if spSice2 then
		spSice2:removeFromParent()
	end
	self._scene:sendCardFinish()
end

function GameViewLayer:gameConclude()
    for i = 1, cmd.GAME_PLAYER do
		self:setUserTrustee(i, false)
	end
	self._cardLayer:gameEnded()
end

function GameViewLayer:HideGameBtn()
	for i = GameViewLayer.BT_BUMP, GameViewLayer.BT_WIN do
		local bt = self.spGameBtn:getChildByTag(i)
		if bt then
			bt:setEnabled(false)
			bt:setColor(cc.c3b(158, 112, 8))
		end
	end
	self.spGameBtn:setVisible(false)
end

--识别动作掩码
function GameViewLayer:recognizecbActionMask(cbActionMask, cbCardData)
	print("收到提示操作：", cbActionMask, cbCardData)
	if cbActionMask == GameLogic.WIK_NULL or cbActionMask == 32 then
		assert("false")
		return false
	end

	if self._cardLayer:isUserMustWin() then
		--必须胡牌的情况
		self.spGameBtn:getChildByTag(GameViewLayer.BT_PASS)
			:setEnabled(false)
			:setColor(cc.c3b(158, 112, 8))
		-- self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)
		-- 	:setEnabled(true)
		-- 	:setColor(cc.c3b(255, 255, 255))
		-- self.spGameBtn:setVisible(true)
		-- self._scene:SetGameOperateClock()
		-- return true
	end

	if cbCardData then
		self.cbActionCard = cbCardData
	end
	if cbActionMask >= 128 then 				--放炮
		cbActionMask = cbActionMask - 128
		self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 64 then 					--胡
		cbActionMask = cbActionMask - 64
		self.spGameBtn:getChildByTag(GameViewLayer.BT_WIN)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 32 then 					--听
		cbActionMask = cbActionMask - 32
	end
	if cbActionMask >= 16 then 					--杠
		cbActionMask = cbActionMask - 16
		self.spGameBtn:getChildByTag(GameViewLayer.BT_BRIGDE)
			:setEnabled(true)
			:setColor(cc.c3b(255, 255, 255))
	end
	if cbActionMask >= 8 then 					--碰
		cbActionMask = cbActionMask - 8
		if self._cardLayer:isUserCanBump() then
			self.spGameBtn:getChildByTag(GameViewLayer.BT_BUMP)
				:setEnabled(true)
				:setColor(cc.c3b(255, 255, 255))
		end
	end
	self.spGameBtn:setVisible(true)
	self._scene:SetGameOperateClock()

	return true
end

function GameViewLayer:getAnimate(name, bEndRemove)
	local animation = cc.AnimationCache:getInstance():getAnimation(name)
	local animate = cc.Animate:create(animation)

	if bEndRemove then
		animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end))
	end

	return animate
end
--设置听牌提示
function GameViewLayer:setListeningCard(cbCardData)
	if cbCardData == nil then
		self.spListenBg:setVisible(false)
		return
	end
	assert(type(cbCardData) == "table")
	self.spListenBg:removeAllChildren()
	self.spListenBg:setVisible(true)

	local cbCardCount = #cbCardData
	local bTooMany = (cbCardCount >= 16)
	--拼接块
	local width = 44
	local height = 67
	local posX = 327
	local fSpacing = 100
	if not bTooMany then
		for i = 1, fSpacing*cbCardCount do
			display.newSprite("#sp_listenBg_2.png")
				:move(posX, 46.5)
				:setAnchorPoint(cc.p(0, 0.5))
				:addTo(self.spListenBg)
			posX = posX + 1
			if i > 700 then
				break
			end
		end
	end
	--尾块
	display.newSprite("#sp_listenBg_3.png")
		:move(posX, 46.5)
		:setAnchorPoint(cc.p(0, 0.5))
		:addTo(self.spListenBg)
	--可胡牌过多，屏幕摆不下
	if bTooMany then
		local cardBack = display.newSprite("game/font_small/card_down.png")
			:move(183 + 40, 46)
			:addTo(self.spListenBg)
		local cardFont = display.newSprite("game/font_small/font_3_5.png")
			:move(width/2, height/2 + 8)
			:addTo(cardBack)

		local strFilePrompt = ""
		local spListenCount = nil
		if cbCardCount == 28 then 		--所有牌
			strFilePrompt = "#389_sp_listen_anyCard.png"
		else
			strFilePrompt = "#389_sp_listen_manyCard.png"
			spListenCount = cc.Label:createWithTTF(cbCardCount.."", "fonts/round_body.ttf", 30)
		end

		local spPrompt = display.newSprite(strFilePrompt)
			:move(183 + 110, 46)
			:setAnchorPoint(cc.p(0, 0.5))
			:addTo(self.spListenBg)
		if spListenCount then
			spListenCount:move(70, 12):addTo(spPrompt)
		end

		-- cc.Label:createWithTTF("厉害了word哥！你可以胡的牌太多，摆不下了....", "fonts/round_body.ttf", 50)
		-- 	:move(260, 40)
		-- 	:setAnchorPoint(cc.p(0, 0.5))
		-- 	:setColor(cc.c3b(0, 0, 0))
		-- 	:addTo(self.spListenBg, 1)
	end
	--牌、番、数
	self.cbAppearCardIndex = GameLogic.DataToCardIndex(self._scene.cbAppearCardData)
	for i = 1, cbCardCount do
		if bTooMany then
			break
		end
		local tempX = fSpacing*(i - 1)
		--local rectX = self._cardLayer:switchToCardRectX(cbCardData[i])
		local cbCardIndex = GameLogic.SwitchToCardIndex(cbCardData[i])
		local nLeaveCardNum = 4 - self.cbAppearCardIndex[cbCardIndex]
		--牌底
		local card = display.newSprite("game/font_small/card_down.png")
			--:setTextureRect(cc.rect(width*rectX, 0, width, height))
			:move(183 + tempX, 46)
			:addTo(self.spListenBg)
		--字体
		local nValue = math.mod(cbCardData[i], 16)
		local nColor = math.floor(cbCardData[i]/16)
		local strFile = "game/font_small/font_"..nColor.."_"..nValue..".png"
		local cardFont = display.newSprite(strFile)
			:move(width/2, height/2 + 8)
			:addTo(card)
		cc.Label:createWithTTF("1", "fonts/round_body.ttf", 16)		--番数
			:move(220 + tempX, 61)
			:setColor(cc.c3b(254, 246, 165))
			:addTo(self.spListenBg)
		display.newSprite("#sp_listenTimes.png")
			:move(244 + tempX, 61)
			:addTo(self.spListenBg)
		cc.Label:createWithTTF(nLeaveCardNum.."", "fonts/round_body.ttf", 16) 		--剩几张
			:move(220 + tempX, 31)
			:setColor(cc.c3b(254, 246, 165))
			:setTag(cbCardIndex)
			:addTo(self.spListenBg)
		display.newSprite("#sp_listenNum.png")
			:move(244 + tempX, 31)
			:addTo(self.spListenBg)
	end
end

--减少可听牌数
function GameViewLayer:reduceListenCardNum(cbCardData)
	local cbCardIndex = GameLogic.SwitchToCardIndex(cbCardData)
	if #self.cbAppearCardIndex == 0 then
		self.cbAppearCardIndex = GameLogic.DataToCardIndex(self._scene.cbAppearCardData)
	end
	self.cbAppearCardIndex[cbCardIndex] = self.cbAppearCardIndex[cbCardIndex] + 1
	local labelLeaveNum = self.spListenBg:getChildByTag(cbCardIndex)
	if labelLeaveNum then
		local nLeaveCardNum = 4 - self.cbAppearCardIndex[cbCardIndex]
		labelLeaveNum:setString(nLeaveCardNum.."")
	end
end

function GameViewLayer:setBanker(viewId)
	if viewId < 1 or viewId > cmd.GAME_PLAYER then
		print("chair id is error!")
		return false
	end
	local spBanker = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_BANKER)
	spBanker:setVisible(true)

	return true
end

function GameViewLayer:setUserTrustee(viewId, bTrustee)
	self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SP_TRUSTEE):setVisible(bTrustee)
	if viewId == cmd.MY_VIEWID then
		self.spTrusteeCover:setVisible(bTrustee)
	end
end

--设置房间信息
function GameViewLayer:setRoomInfo(tableId, chairId)
end

function GameViewLayer:onTrusteeTouchCallback(event, x, y)
	if not self.spTrusteeCover:isVisible() then
		return false
	end

	local rect = self.spTrusteeCover:getChildByTag(GameViewLayer.SP_TRUSTEEBG):getBoundingBox()
	if cc.rectContainsPoint(rect, cc.p(x, y)) then
		return true
	else
		return false
	end
end
--设置剩余牌
function GameViewLayer:setRemainCardNum(num)
	local strRemianNum = string.format("剩%d张", num)
	local textNum = self:getChildByTag(GameViewLayer.TEXT_REMAINNUM)
	textNum:setString(strRemianNum)
	-- if num == 112 then
	-- 	text:setVisible(false)
	-- else
	-- 	text:setVisible(true)
	-- end
end
--牌托
function GameViewLayer:showCardPlate(viewId, cbCardData)
	if nil == viewId then
		self.spCardPlate:setVisible(false)
		return
	end
	--local rectX = self._cardLayer:switchToCardRectX(cbCardData)
	local nValue = math.mod(cbCardData, 16)
	local nColor = math.floor(cbCardData/16)
	local strFile = "game/font_middle/font_"..nColor.."_"..nValue..".png"
	self.spCardPlate:getChildByTag(GameViewLayer.SP_PLATECARD):setTexture(strFile)
	self.spCardPlate:move(posPlate[viewId]):setVisible(true)
end
--操作效果
function GameViewLayer:showOperateFlag(viewId, operateCode)
	local spFlag = self:getChildByTag(GameViewLayer.SP_OPERATFLAG)
	if spFlag then
		spFlag:removeFromParent()
	end
	if nil == viewId then
		return false
	end
	local strFile = "#"
	if operateCode == GameLogic.WIK_NULL then
		return false
	elseif operateCode == GameLogic.WIK_CHI_HU then
		strFile = "#sp_flag_win.png"
	elseif operateCode == GameLogic.WIK_LISTEN then
		strFile = "#sp_flag_listen.png"
	elseif operateCode == GameLogic.WIK_GANG then
		strFile = "#sp_flag_bridge.png"
	elseif operateCode == GameLogic.WIK_PENG then
		strFile = "#sp_flag_bump.png"
	elseif operateCode <= GameLogic.WIK_RIGHT then
		strFile = "#sp_flag_eat.png"
	end
	display.newSprite(strFile)
		:setTag(GameViewLayer.SP_OPERATFLAG)
		:move(posPlate[viewId])
		:addTo(self, 2)

	return true
end

--数字中插入点
function GameViewLayer:numInsertPoint(lScore)
	assert(lScore >= 0)
	local strRes = ""
	local str = string.format("%d", lScore)
	local len = string.len(str)

	local times = math.floor(len/3)
	local remain = math.mod(len, 3)
	strRes = strRes..string.sub(str, 1, remain)
	for i = 1, times do
		if strRes ~= "" then
			strRes = strRes.."/"
		end
		local index = (i - 1)*3 + remain + 1	--截取起始位置
		strRes = strRes..string.sub(str, index, index + 2)
	end

	return strRes
end

return GameViewLayer
