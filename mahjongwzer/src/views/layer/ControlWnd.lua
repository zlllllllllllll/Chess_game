--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local CControlWnd = class("CControlWnd", function(scene)
	local CControlWnd = display.newLayer()
	return CControlWnd
end)

--按钮标识
CControlWnd.IDC_CHIHU			=		100									--吃胡按钮
CControlWnd.IDC_LISTEN			=		101									--听牌按钮
CControlWnd.IDC_GIVEUP			=		102									--放弃按钮
CControlWnd.IDC_CHI_SHANG		=		103
CControlWnd.IDC_CHI_ZHONG		=		104
CControlWnd.IDC_CHI_XIA			=		105
CControlWnd.IDC_PENG			=		106
CControlWnd.IDC_GANG			=		107

--位置标识
CControlWnd.ITEM_WIDTH			=		90									--子项宽度
CControlWnd.ITEM_HEIGHT			=		44									--子项高度

CControlWnd.CONTROL_TOP 		=		35									--控制高度
CControlWnd.CONTROL_WIDTH		=		173									--控制宽度
CControlWnd.CONTROL_HEIGHT		=		47									--控制高度

function CControlWnd:ctor(scene)
	self._scene = scene
	local this = self

	--配置变量
	--内部数据
	self.m_pSinkWindow=nil
	self.m_cbActionMask=0
	self.m_cbCenterCard=0
	self.m_PointBenchmark=cc.p(922, 465)
	self.m_cbGangCard={}

	--状态变量
	self.m_cbItemCount=0
	self.m_cbCurrentItem= 0xFF

	--加载资源
	self.m_ImageActionExplain=display.newSprite("res/game/ACTION_EXPLAIN.png"):setVisible(false):addTo(self)
	self.m_ImageControlTop=display.newSprite("res/game/CONTROL_TOP.png"):setVisible(false):addTo(self)
	self.m_ImageControlMid=display.newSprite("res/game/CONTROL_MID.png"):setVisible(false):addTo(self)
	self.m_ImageControlButtom=display.newSprite("res/game/CONTROL_BOTTOM.png"):setVisible(false):addTo(self)

	--m_cardControl=NULL
	self.m_cardControl=nil
	self.m_cardControl=CardControl:create_CCardControl(self)   --是否需要注释


	--if (__super::OnCreate(lpCreateStruct)==-1) return -1;
	--OnCreate
	--创建按钮

	local  btcallback = function(ref, type)
	  if type == ccui.TouchEventType.ended then
	   	this:onButtonClickedEvent(ref:getTag(),ref)
	  end
	end

	--设置位图
	ccui.Button:create("res/game/BT_HU.png")
		:setName("m_btChiHu")
		:move(yl.WIDTH/3,70)
		:setTag(CControlWnd.IDC_CHIHU)
    --:setEnabled(false)
		:addTo(self)
    :addTouchEventListener(btcallback)
	self.m_btChiHu=self:getChildByName("m_btChiHu")

	ccui.Button:create("res/game/BT_QU_XIAO.png")
		:setName("m_btGiveUp")
		:move(yl.WIDTH/3,50)
		:setTag(CControlWnd.IDC_GIVEUP)
    --:setEnabled(false)
		:addTo(self)
    	:addTouchEventListener(btcallback)
	self.m_btGiveUp=self:getChildByName("m_btGiveUp")

	ccui.Button:create("res/game/BT_CHI_SHANG.png")
		:setName("m_btChiShang")
		:move(yl.WIDTH/3,30)
		:setTag(CControlWnd.IDC_CHI_SHANG)
		--:setEnabled(false)
		:addTo(self)
		:addTouchEventListener(btcallback)
	self.m_btChiShang=self:getChildByName("m_btChiShang")

	ccui.Button:create("res/game/BT_CHI_ZHONG.png")
		:setName("m_btChiZhong")
		:move(yl.WIDTH/3,10)
		:setTag(CControlWnd.IDC_CHI_ZHONG)
    	--:setEnabled(false)
		:addTo(self)
    	:addTouchEventListener(btcallback)
	self.m_btChiZhong=self:getChildByName("m_btChiZhong")

	ccui.Button:create("res/game/BT_CHI_XIA.png")
		:setName("m_btChiXia")
		:move(yl.WIDTH/3*2,60)
		:setTag(CControlWnd.IDC_CHI_XIA)
    	--:setEnabled(false)
		:addTo(self)
    	:addTouchEventListener(btcallback)
	self.m_btChiXia=self:getChildByName("m_btChiXia")

	ccui.Button:create("res/game/BT_PENG.png")
		:setName("m_btPeng")
		:move(yl.WIDTH/3*2,40)
		:setTag(CControlWnd.IDC_PENG)
    	--:setEnabled(false)
		:addTo(self)
    	:addTouchEventListener(btcallback)
	self.m_btPeng=self:getChildByName("m_btPeng")

	ccui.Button:create("res/game/BT_GANG.png")
		:setName("m_btGang")
		:move(yl.WIDTH/3*2,20)
		:setTag(CControlWnd.IDC_GANG)
    	--:setEnabled(false)
		:addTo(self)
    	:addTouchEventListener(btcallback)
	self.m_btGang=self:getChildByName("m_btGang")

	return
end

function CControlWnd:onButtonClickedEvent(tag, ref)
print("CControlWnd:onButtonClickedEvent",tag)
	if tag == CControlWnd.IDC_CHIHU then
		self:OnChiHu()
	elseif tag == CControlWnd.IDC_LISTEN then
		self:OnListen()
	elseif tag == CControlWnd.IDC_GIVEUP then
		self:OnGiveUp()
	elseif tag == CControlWnd.IDC_CHI_SHANG then
		self:OnChiShang()
	elseif tag == CControlWnd.IDC_CHI_ZHONG then
		self:OnChiZhong()
	elseif tag == CControlWnd.IDC_CHI_XIA then
		self:OnChiXia()
	elseif tag == CControlWnd.IDC_PENG then
		self:OnPeng()
	elseif tag == CControlWnd.IDC_GANG then
		self:OnGang()
	else
		print("default")
	end
end

--基准位置
function CControlWnd:SetBenchmarkPos(nXPos, nYPos)
print("基准位置 CControlWnd:SetBenchmarkPos",nXPos, nYPos)
	--位置变量
	self.m_PointBenchmark=cc.p(nXPos, nYPos)
	self.m_cbGangCard={}

	--调整控件
	self:RectifyControl()

	return
end

--设置窗口
function CControlWnd:SetSinkWindow(pSinkWindow)
print("设置窗口")
	--设置变量
	self.m_pSinkWindow=pSinkWindow

	return
end

--设置扑克
function CControlWnd:SetControlInfo(cbCenterCard, cbActionMask, GangCardResult)
print("设置扑克 CControlWnd:SetControlInfo",cbCenterCard, cbActionMask, GangCardResult)
dump(GangCardResult,"CControlWnd GangCardResult",6)
	--设置变量
	self.m_cbItemCount=0
	self.m_cbCurrentItem= 0xFF
	self.m_cbActionMask=cbActionMask
	self.m_cbCenterCard=cbCenterCard

	--杠牌信息
	self.m_cbGangCard={}
	for i=1,GangCardResult.cbCardCount,1 do
		self.m_cbItemCount=self.m_cbItemCount+1
		self.m_cbGangCard[i]=GangCardResult.cbCardData[i]
	end

	--计算数目
	local cbItemKind={GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT,GameLogic.WIK_PENG}

	for i=1,GameLogic:table_leng(cbItemKind),1 do
		if (bit:_and(self.m_cbActionMask, cbItemKind[i]))~=0 then
			self.m_cbItemCount=self.m_cbItemCount+1
		end
	end

	--按钮控制
    print(bit:_and(self.m_cbActionMask, GameLogic.WIK_CHI_HU),(bit:_and(self.m_cbActionMask, GameLogic.WIK_CHI_HU)~=0))
	local cBoolean = ((bit:_and(self.m_cbActionMask, GameLogic.WIK_CHI_HU)~=0) and true or false)
	self.m_btChiHu:setEnabled(cBoolean)

	--调整控件
	self:RectifyControl()
	GameLogic.WIK_LISTEN=bit:_not(GameLogic.WIK_LISTEN)
	if GameLogic.WIK_NULL ~= (bit:_and(cbActionMask, GameLogic.WIK_LISTEN)) then
		--显示窗口
		--ShowWindow(SW_SHOW);
		self:setVisible(true)
	end
	return
end

--调整控件
function CControlWnd:RectifyControl()
print("CControlWnd:RectifyControl")
	--设置位置
	--CRect rcRect;
	local rcRect={}
	rcRect.right=self.m_PointBenchmark.x
	rcRect.bottom=self.m_PointBenchmark.y
	rcRect.left=self.m_PointBenchmark.x-CControlWnd.CONTROL_WIDTH
	rcRect.top=self.m_PointBenchmark.y-CControlWnd.ITEM_HEIGHT*self.m_cbItemCount-CControlWnd.CONTROL_HEIGHT-CControlWnd.CONTROL_TOP

	--移动窗口
	--MoveWindow(rcRect);
	self:move((rcRect.left+rcRect.right/2),(rcRect.bottom+rcRect.top)/2)

  --调整按钮
	--mark
	local rcButton=self.m_btChiHu:getContentSize()
	local nYPos=rcRect.top-rcRect.bottom-rcButton.height-7
	--m_btChiHu.SetWindowPos(NULL,rcRect.Width()-70-rcButton.Width()-2,nYPos,0,0,SWP_NOZORDER|SWP_NOSIZE);
	--m_btGiveUp.SetWindowPos(NULL,rcRect.Width()-70,nYPos+3,0,0,SWP_NOZORDER|SWP_NOSIZE);
	self.m_btChiHu:move(rcRect.right-rcRect.left-70-rcButton.width-2,nYPos)
	self.m_btGiveUp:move(rcRect.right-rcRect.left-70,nYPos+3)
dump(rcRect,"rcRect",6)
	return
end

--吃胡按钮
function CControlWnd:OnChiHu()
	self._scene:OnCardOperate( GameLogic.WIK_CHI_HU,0 )
	return
end
--吃胡按钮
function CControlWnd:OnListen()
	self._scene:OnListenCard( 0,0 )
	return
end

function CControlWnd:OnChiShang()
	self._scene:OnCardOperate( GameLogic.WIK_LEFT,self.m_cbCenterCard )
	return
end

function CControlWnd:OnChiZhong()
	if bit:_and(self.m_cbActionMask, GameLogic.WIK_CENTER) ~= 0 then
		self._scene:OnCardOperate( GameLogic.WIK_CENTER,self.m_cbCenterCard )
		return
	end
	return
end

function CControlWnd:OnChiXia()
	if bit:_and(self.m_cbActionMask, GameLogic.WIK_RIGHT) ~= 0 then
		self._scene:OnCardOperate( GameLogic.WIK_RIGHT,self.m_cbCenterCard )
		return
	end
	return
end

function CControlWnd:OnPeng()
	if bit:_and(self.m_cbActionMask, GameLogic.WIK_PENG) ~= 0 then
		self._scene:OnCardOperate( GameLogic.WIK_PENG,self.m_cbCenterCard )
		return
	end
	return
end

function CControlWnd:OnGang()
	for i=1,GameLogic:table_leng(self.m_cbGangCard),1 do
		if self.m_cbGangCard[i]~=0 then
			self._scene:OnCardOperate( GameLogic.WIK_GANG,self.m_cbGangCard[i] )
			return
		end
	end
	return
end

--放弃按钮
function CControlWnd:OnGiveUp()
	self._scene:OnCardOperate( GameLogic.WIK_NULL,0 )
	return
end

--重画函数
function CControlWnd:OnPaint()
print("CControlWnd:OnPaint")
	--当前窗体
	--CPaintDC dc(this);

	--获取位置
	-- CRect rcClient;
	-- GetClientRect(&rcClient);
	--mark
	local rcClient={}
	rcClient.left=0
	rcClient.top=100
	rcClient.right=100
	rcClient.bottom=0
	rcClient.width=rcClient.right-rcClient.left
	rcClient.height=rcClient.top-rcClient.bottom

	--创建缓冲
	-- CDC BufferDC;
	-- CBitmap BufferImage;
	-- BufferDC.CreateCompatibleDC(&dc);
	-- BufferImage.CreateCompatibleBitmap(&dc,rcClient.Width(),rcClient.Height());
	-- BufferDC.SelectObject(&BufferImage);

  --填充背景
  --BufferDC.FillSolidRect(rcClient,RGB(0,96,124));

	GameLogic:FillSolidRect(rcClient.width/2, rcClient.height/2, rcClient.width, rcClient.height, cc.c4f(0,96/255,124/255,1),self)

	--绘画背景
	self.m_ImageControlTop:setPosition(0,0)
		:setColor(cc.c3b(255, 0, 255))
		:setVisible(true)
	for nImageYPos=self.m_ImageControlTop:getContentSize().height,rcClient.height-1,self.m_ImageControlMid:getContentSize().height do
		--self.m_ImageControlMid.BitBlt(BufferDC,0,nImageYPos)
		--makr 新建还是显示
		self.m_ImageControlMid:setPosition(0,nImageYPos)
			:setVisible(true)
	end
	self.m_ImageControlButtom:setPosition(0,rcClient.height-self.m_ImageControlButtom:getContentSize().height)
		:setColor(cc.c3b(255, 0, 255))
		:setVisible(true)

	--变量定义
	local nYPos=35
	local cbCurrentItem=0
	local cbExcursion={0,1,2}
	local cbItemKind={GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT,GameLogic.WIK_PENG}

print("===",GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT,GameLogic.WIK_PENG)
dump(cbItemKind,"cbItemKind",6)
	--绘画扑克
	for i=1,GameLogic:table_leng(cbItemKind),1 do
print(bit:_and(self.m_cbActionMask,cbItemKind[i]))
		if bit:_and(self.m_cbActionMask,cbItemKind[i]) ~=0 then
			--绘画扑克
			for j=1,3,1 do
				local cbCardData=self.m_cbCenterCard
				if i<GameLogic:table_leng(cbExcursion) then			-- 吃牌
					if (GameLogic.BAIBAN_CARD_DATA == self.m_cbCenterCard) and (CardControl.m_byGodsData>0) then
						cbCardData = CCardControl.m_byGodsData
					end
					cbCardData=cbCardData+j-cbExcursion[i]

					-- 白板本身需要还原
					if cbCardData == CCardControl.m_byGodsData then
						cbCardData = GameLogic.BAIBAN_CARD_DATA
					end
				end
				--g_CardResource.m_ImageTableBottom.DrawCardItem(&BufferDC,cbCardData,j*26+12,nYPos+5);
				self.g_CardResource=CardControl:create_CCardListImage(self)
				self.g_CardResource:DrawCardItem("m_ImageTableBottom","CControlWnd_cbItemKind"..i,cbCardData,j*26+12,nYPos+5)
			end

			--计算位置
			local nXImagePos=0
			local nItemWidth=self.m_ImageActionExplain:getContentSize().width/7
			if bit:_and(bit:_and(self.m_cbActionMask,cbItemKind[i]) , GameLogic.WIK_PENG) then
				nXImagePos=nItemWidth
			end

			--绘画标志
			local nItemHeight=self.m_ImageActionExplain:getContentSize().height
			self.m_ImageActionExplain:setPosition(126+nItemWidth/2,nYPos+5+nItemHeight/2)
				--:setColor(cc.c3b(255, 0, 255))
				:setVisible(true)
			--m_ImageActionExplain.BitBlt(BufferDC,126,nYPos+5,nItemWidth,nItemHeight,nXImagePos,0);

			--绘画边框
			if cbCurrentItem==self.m_cbCurrentItem then
				GameLogic:Draw3dRect(5,nYPos,rcClient.width-5*2,CControlWnd.ITEM_HEIGHT,cc.c4f(1,1,0,1),cc.c4f(1,1,0,1),self)
			end

			--设置变量
			cbCurrentItem=cbCurrentItem+1
			nYPos=nYPos+CControlWnd.ITEM_HEIGHT
		end
	end

	--杠牌扑克
	while true do
		for i=1,GameLogic:table_leng(self.m_cbGangCard),1 do
			if self.m_cbGangCard[i]~=0 then
				--m_btGang.EnableWindow(TRUE);
				--绘画扑克
				for j=1,4,1 do
					self.g_CardResource=CardControl:create_CCardListImage(self)
					self.g_CardResource:DrawCardItem("m_ImageTableBottom","CControlWnd_cbGangCard"..i,m_cbGangCard[i],(j-1)*26+12,nYPos+5)
				end

				--绘画边框
				if cbCurrentItem==self.m_cbCurrentItem then
					GameLogic:Draw3dRect(5,nYPos,rcClient.width-5*2,CControlWnd.ITEM_HEIGHT,cc.c4f(1,1,0,1),cc.c4f(1,1,0,1),self)
				end

				--绘画标志
				local nItemWidth=self.m_ImageActionExplain:getContentSize().width/7
				local nItemHeight=self.m_ImageActionExplain:getContentSize().height
				--m_ImageActionExplain.BitBlt(BufferDC,126,nYPos+5,nItemWidth,nItemHeight,nItemWidth*3,0);
				self.m_ImageActionExplain:setPosition(126+nItemWidth/2,nYPos+5+nItemHeight/2)
					--:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)

				--设置变量
				cbCurrentItem=cbCurrentItem+1
				nYPos=nYPos+CControlWnd.ITEM_HEIGHT
			else
				break
			end
		end
	break end

	--绘画界面
	--dc.BitBlt(0,0,rcClient.Width(),rcClient.Height(),&BufferDC,0,0,SRCCOPY);

	--清理资源
	-- BufferDC.DeleteDC();
	-- BufferImage.DeleteObject();

	return
end

--鼠标消息
function CControlWnd:OnLButtonDown(nFlags,Point)

	--索引判断
	if self.m_cbCurrentItem ~= 0xFF then
		--变量定义
		local cbIndex=0
		local cbItemKind={GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT,GameLogic.WIK_PENG}

		--类型子项
		for i=1,GameLogic:table_leng(cbItemKind),1 do
			cbIndex = cbIndex + 1 
			if (bit:_and(self.m_cbActionMask,cbItemKind[i])~=0) and (self.m_cbCurrentItem==cbIndex) then
				self._scene:OnCardOperate( cbItemKind[i],self.m_cbCenterCard )
				return
			end
		end

		--杠牌子项
		for i=1,GameLogic:table_leng(self.m_cbGangCard),1 do
			cbIndex = cbIndex + 1 
			if (self.m_cbGangCard[i]~=0) and (self.m_cbCurrentItem==cbIndex) then
				self._scene:OnCardOperate( GameLogic.WIK_GANG,self.m_cbGangCard[i] )
				return
			end
		end
	end

	return
end

--光标消息   该区域 mark
function CControlWnd:OnSetCursor(pWnd,nHitTest,uMessage)
	--位置测试
	-- if self.m_cbItemCount~=0 then
	-- 	--获取位置
	-- 	CRect rcClient;
	-- 	CPoint MousePoint;
	-- 	GetClientRect(&rcClient);
	-- 	GetCursorPos(&MousePoint);
	-- 	ScreenToClient(&MousePoint);
	--
	-- 	--计算索引
	-- 	BYTE bCurrentItem=0xFF;
	-- 	CRect rcItem(5,CONTROL_TOP,rcClient.Width()-5*2,ITEM_HEIGHT*m_cbItemCount+CONTROL_TOP);
	--
	-- 	if (rcItem.PtInRect(MousePoint))
	-- 		bCurrentItem=(BYTE)((MousePoint.y-CONTROL_TOP)/ITEM_HEIGHT);
	--
	-- 	--设置索引
	-- 	if (m_cbCurrentItem!=bCurrentItem)
	-- 	{
	-- 		Invalidate();
	-- 		m_cbCurrentItem=bCurrentItem;
	-- 	}
	--
	-- 	--设置光标
	-- 	if (m_cbCurrentItem!=0xFF)
	-- 	{
	-- 		SetCursor(LoadCursor(AfxGetInstanceHandle(),MAKEINTRESOURCE(IDC_CARD_CUR)));
	-- 		return TRUE;
	-- 	}
	-- end

	return
	--return __super::OnSetCursor(pWnd,nHitTest,uMessage);
end

function CControlWnd:OnCtlColor( pDC,  pWnd, nCtlColor)
	-- HBRUSH hbr = CWnd::OnCtlColor(pDC, pWnd, nCtlColor);
	--
	-- -- TODO:  如果默认的不是所需画笔，则返回另一个画笔
	-- return hbr;
end

function CControlWnd:BitmapToRegion(hBmp, cTransparentColor, cTolerance)
		--
		--		mark
		--
end

function CControlWnd:PreTranslateMessage(pMsg)
	-- if(pMsg->message==WM_USER+10000)
	-- {
	if self.m_cardControl then			--离开某个按钮
		self.m_cardControl:SetShootCard()
	end
	--CSkinButton *pButton=(CSkinButton *)pMsg->wParam;//按钮对象
	local pButton=pMsg.wParam;--按钮对象  mark

	local cbCard={0,0,0}
	if pMsg.lParam ==1 and self.m_cardControl then
		local cbExcursion={0,1,2}
		local cbItemKind={GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT}
		local pBtChi={self.m_btChiShang,self.m_btChiZhong,self.m_btChiXia}

		--绘画扑克
		for i=1,GameLogic:table_leng(cbItemKind),1 do
			cbCard[1],cbCard[2],cbCard[4]=0,0,0   
			local p=0
			if bit:_and(self.m_cbActionMask,cbItemKind[i])~=0 then
				--绘画扑克
				for j=1,3,1 do
					local cbCardData=self.m_cbCenterCard
					if (GameLogic.BAIBAN_CARD_DATA == self.m_cbCenterCard) and (CCardControl.m_byGodsData>0) then
						cbCardData = CCardControl.m_byGodsData
					end
					cbCardData=cbCardData+j-cbExcursion[i]

					-- 白板本身需要还原
					if cbCardData == CCardControl.m_byGodsData then
						cbCardData = GameLogic.BAIBAN_CARD_DATA
					end
					if cbCardData~=self.m_cbCenterCar then
						p=p+1
						cbCard[p]=cbCardData
					end
				end

				if pButton==pBtChi[i] then
					self.m_cardControl:SetShootCard(cbCard[1],cbCard[2])
				end
			end
		end
	end
	return true
	-- }
	-- return CWnd::PreTranslateMessage(pMsg);
end

return CControlWnd
