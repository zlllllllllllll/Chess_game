--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")
local CardControl = class("CardControl", function(scene)
	local CardControl = display.newLayer()
	return CardControl
end)
local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")

--扑克图片
local CCardListImage = class("CCardListImage", cc.Layer)
--扑克资源
local CCardResource = class("CCardResource", cc.Layer)
--堆立扑克
local CHeapCard = class("CHeapCard", cc.Layer)
--组合扑克
local CWeaveCard = class("CWeaveCard", cc.Layer)
--用户扑克
local CUserCard = class("CUserCard", cc.Layer)
--丢弃扑克
local CDiscardCard = class("CDiscardCard", cc.Layer)
--桌面扑克
local CTableCard = class("CTableCard", cc.Layer)
--扑克控件
local CCardControl = class("CCardControl", cc.Layer)

CardControl.HEAP_FULL_COUNT		= 34								--开始按钮
--公共定义
CardControl.POS_SHOOT					= 5									--弹起象素
CardControl.POS_SPACE					= 16								--分隔间隔
CardControl.ITEM_COUNT				=	43								--子项数目
CardControl.INVALID_ITEM			=	0xFFFF						--无效索引

--扑克大小
CardControl.CARD_WIDTH				=	45								--扑克宽度 39
CardControl.CARD_HEIGHT				=	69								--扑克高度  64

--枚举
--X 排列方式
CardControl.enXLeft						="enXLeft"					--左对齐
CardControl.enXCenter					="enXCenter"				--中对齐
CardControl.enXRight					="enXRight"					--右对齐
--Y 排列方式
CardControl.enYTop						="enYTop"									--左对齐
CardControl.enYCenter					="enYCenter"							--中对齐
CardControl.enYBottom					="enYBottom"							--右对齐

CardControl.Direction_East		="Direction_East"					--东向
CardControl.Direction_South		="Direction_South"				--南向
CardControl.Direction_West		="Direction_West"					--西向
CardControl.Direction_North		="Direction_North"				--北向

function CardControl:ctor(scene)
	self._scene = scene
	self:onInitData()
	local this = self
end

function CardControl:onInitData()
end

function CardControl:onResetData()
end

function CardControl:Draw3dRect(x, y, cx, cy,	clrTopLeft, clrBottomRight)
	self:FillSolidRect(x, y, cx - 1, 1, clrTopLeft)
	self:FillSolidRect(x, y, 1, cy - 1, clrTopLeft)
	self:FillSolidRect(x + cx, y, -1, cy, clrBottomRight)
	self:FillSolidRect(x, y + cy, cx, -1, clrBottomRight)
end
function CardControl:FillSolidRect(x, y, cx, cy, color)
    local dr=cc.DrawNode:create()
	        :setPosition(cc.p(x+cx/2,y+cy/2))
	        :drawSolidRect(cc.p(x,y), cc.p(x+cx,y+cy), color)
					:setAnchorPoint(cc.p(0.5,0.5))
					:addTo(self)
		return dr
end

--扑克图片
function CardControl:create_CCardListImage(base)
    return CCardListImage:create(base):addTo(base)
end
--扑克资源
function CardControl:create_CCardResource(base)
    return CCardResource:create(base):addTo(base)
end
--堆立扑克
function CardControl:create_CHeapCard(base)
    return CHeapCard:create(base):addTo(base)
end
--组合扑克
function CardControl:create_CWeaveCard(base)
    return CWeaveCard:create(base):addTo(base)
end
--用户扑克
function CardControl:create_CUserCard(base)
    return CUserCard:create(base):addTo(base)
end
--丢弃扑克
function CardControl:create_CDiscardCard(base)
    return CDiscardCard:create(base):addTo(base)
end
--桌面扑克
function CardControl:create_CTableCard(base)
    return CTableCard:create(base):addTo(base)
end
--扑克控件
function CardControl:create_CCardControl(base)
    return CCardControl:create(base):addTo(base)
end

--===================================================================
CardControl.CCardList				=	{}	--CCardListImage 多个CCardListImage类
--扑克图片
function CCardListImage:ctor(scene)
	--位置变量
	--可能不需要
	CCardListImage.m_nItemWidth=0
	CCardListImage.m_nItemHeight=0
	CCardListImage.m_nViewWidth=0
	CCardListImage.m_nViewHeight=0
	return
end
function CCardListImage:Cfound(id)
	CardControl.CCardList[id]={}
	--位置变量
	CardControl.CCardList[id].m_nItemWidth=0
	CardControl.CCardList[id].m_nItemHeight=0
	CardControl.CCardList[id].m_nViewWidth=0
	CardControl.CCardList[id].m_nViewHeight=0
end
--加载资源
function CCardListImage:LoadResource(id,uResourceID,nViewWidth,nViewHeight)
	--加载资源
	if false == cc.FileUtils:getInstance():isFileExist(uResourceID) then
		uResourceID = "CARD_USER_BOTTOM"
	end
	CardControl.CCardList[id].m_CardListImage=display.newSprite("res/game/"..uResourceID..".png"):setVisible(false):addTo(self)
	CardControl.CCardList[id].m_csFlag=display.newSprite("res/game/CS_FLAG.png"):setVisible(false):addTo(self)
	CardControl.CCardList[id].m_CardBack=display.newSprite("res/game/CARD_BACK.png"):setVisible(false):addTo(self)
	--设置变量
	CardControl.CCardList[id].m_nViewWidth=nViewWidth
	CardControl.CCardList[id].m_nViewHeight=nViewHeight
	CardControl.CCardList[id].m_nItemHeight=CardControl.CCardList[id].m_CardListImage:getContentSize().height
	CardControl.CCardList[id].m_nItemWidth=CardControl.CCardList[id].m_CardListImage:getContentSize().width/CardControl.ITEM_COUNT

	return true
end

--释放资源
function CCardListImage:DestroyResource(id)
	--设置变量
	CardControl.CCardList[id].m_nItemWidth=nil
	CardControl.CCardList[id].m_nItemHeight=nil

	--释放资源
	CardControl.CCardList[id]:m_CardListImage:removeFromParent()

	return true
end

--获取位置
function CCardListImage:GetImageIndex(cbCardData)
	--背景判断
	if cbCardData==0 then return 0 end

	--计算位置
	local cbValue=bit:_and(cbCardData, GameLogic.MASK_VALUE)
	local cbColor=bit:_rshift(bit:_and(cbCardData, GameLogic.MASK_COLOR),4)
	return (cbColor>= 0x03) and (cbValue+27) or (cbColor*9+cbValue)
end

--绘画扑克
function CCardListImage:DrawCardItem(id,pDestDC,cbCardData,xDest,yDest,cbGodsData,bDrawBack,nItemWidth,nItemHeight)
	if bDrawBack then
		CardControl.CCardList[id].m_CardBack:setPosition(xDest-8,yDest-8)
			:setColor(cc.c3b(255, 0, 255))
			:setVisible(true)
	end

	local nDrawWidth=CardControl.CCardList[id].m_nItemWidth
	local nDrawHeight=CardControl.CCardList[id].m_nItemHeight
	if nItemHeight>0 then nDrawHeight=nItemHeight	end
	if nItemWidth>0 then nDrawWidth=nItemWidth	end
	--绘画子项
	if cbCardData<=GameLogic.BAIBAN_CARD_DATA then
		local nImageXPos=CCardListImage:GetImageIndex(cbCardData)*CardControl.CCardList[id].m_nItemWidth
		if nDrawWidth==CardControl.CCardList[id].m_nItemWidth and nDrawHeight==CardControl.CCardList[id].m_nItemHeight then
			--self.m_CardListImage.TransDrawImage(pDestDC,xDest,yDest,nDrawWidth,nDrawHeight,nImageXPos,0,RGB(255,0,255))
			CardControl.CCardList[id].m_CardListImage:setPosition(xDest,yDest)
				:setColor(cc.c3b(255, 0, 255))
				:setVisible(true)
		else
			--self.m_CardListImage.StretchBlt(pDestDC->GetSafeHdc(),xDest,yDest,nDrawWidth,nDrawHeight,nImageXPos,0,m_nItemWidth,m_nItemHeight,SRCCOPY)
			CardControl.CCardList[id].m_CardListImage:setPosition(xDest,yDest)
				--:setColor(cc.c3b(255, 0, 255))
				:setVisible(true)
		end
	end
	if cbGodsData~=0 and cbGodsData==cbCardData then
		CardControl.CCardList[id].m_csFlag:setPosition(xDest+3,yDest)
			:setColor(cc.c3b(255, 0, 255))
			:setVisible(true)
	end

	return true
end
--===================================================================
--扑克资源
function CCardResource:ctor()
	CCardListImage:Cfound("m_ImageUserTop")
	CCardListImage:Cfound("m_ImageUserLeft")
	CCardListImage:Cfound("m_ImageUserRight")
	CCardListImage:Cfound("m_ImageUserBottom")
	CCardListImage:Cfound("m_ImageWaveBottom")
	CCardListImage:Cfound("m_ImageTableTop")
	CCardListImage:Cfound("m_ImageTableLeft")
	CCardListImage:Cfound("m_ImageTableRight")
	CCardListImage:Cfound("m_ImageTableBottom")
	CCardListImage:Cfound("m_ImageBackH")
	CCardListImage:Cfound("m_ImageBackV")
	CCardListImage:Cfound("m_ImageHeapSingleV")
	CCardListImage:Cfound("m_ImageHeapSingleH")
	CCardListImage:Cfound("m_ImageHeapDoubleV")
	CCardListImage:Cfound("m_ImageHeapDoubleH")
end

--加载资源
function CCardResource:LoadResource()
	--用户扑克
	self.m_ImageUserTop=display.newSprite("res/game/CARD_USER_TOP.png"):setVisible(false):addTo(self)
	self.m_ImageUserLeft=display.newSprite("res/game/CARD_USER_LEFT.png"):setVisible(false):addTo(self)
	self.m_ImageUserRight=display.newSprite("res/game/CARD_USER_RIGHT.png"):setVisible(false):addTo(self)
	CCardListImage:LoadResource("m_ImageUserBottom","CARD_USER_BOTTOM",CardControl.CARD_WIDTH,CardControl.CARD_HEIGHT)
	CCardListImage:LoadResource("m_ImageWaveBottom","CARD_WAVE_BOTTOM",CardControl.CARD_WIDTH,CardControl.CARD_HEIGHT)
	--桌子扑克
	CCardListImage:LoadResource("m_ImageTableTop","CARD_TABLE_TOP",24,35)
	CCardListImage:LoadResource("m_ImageTableLeft","CARD_TABLE_LEFT",32,28)
	CCardListImage:LoadResource("m_ImageTableRight","CARD_TABLE_RIGHT",32,28)
	CCardListImage:LoadResource("m_ImageTableBottom","CARD_TABLE_BOTTOM",24,35)

	--牌堆扑克
	self.m_ImageBackH=display.newSprite("res/game/CARD_BACK_H.png"):setVisible(false):addTo(self)
	self.m_ImageBackV=display.newSprite("res/game/CARD_BACK_V.png"):setVisible(false):addTo(self)
	self.m_ImageHeapSingleV=display.newSprite("res/game/CARD_HEAP_SINGLE_V.png"):setVisible(false):addTo(self)
	self.m_ImageHeapSingleH=display.newSprite("res/game/CARD_HEAP_SINGLE_H.png"):setVisible(false):addTo(self)
	self.m_ImageHeapDoubleV=display.newSprite("res/game/CARD_HEAP_DOUBLE_V.png"):setVisible(false):addTo(self)
	self.m_ImageHeapDoubleH=display.newSprite("res/game/CARD_HEAP_DOUBLE_H.png"):setVisible(false):addTo(self)

	return true
end

--消耗资源
function CCardResource:DestroyResource()
	--用户扑克
	self.m_ImageUserTop:removeFromParent()
	self.m_ImageUserLeft:removeFromParent()
	self.m_ImageUserRight:removeFromParent()
 	CCardListImage:DestroyResource("m_ImageUserBottom")
	--少个 m_ImageWaveBottom

	--桌子扑克
 	CCardListImage:DestroyResource("m_ImageTableTop")
 	CCardListImage:DestroyResource("m_ImageTableLeft")
 	CCardListImage:DestroyResource("m_ImageTableRight")
 	CCardListImage:DestroyResource("m_ImageTableBottom")

	--牌堆扑克
	self.m_ImageBackH:removeFromParent()
	self.m_ImageBackV:removeFromParent()
	self.m_ImageHeapSingleV:removeFromParent()
	self.m_ImageHeapSingleH:removeFromParent()
	self.m_ImageHeapDoubleV:removeFromParent()
	self.m_ImageHeapDoubleH:removeFromParent()

	return true
end
--===================================================================
--堆立扑克
function CHeapCard:ctor()
	self.m_ControlPoint = cc.p(0, 0)
	self.m_CardDirection=CardControl.Direction_East

	--扑克变量
	self.m_wFullCount=0
	self.m_wMinusHeadCount=0
	self.m_wMinusLastCount=0

	self.m_byShowCard= 0x00  	 -- 显示的牌
	self.m_byIndex= 0x00	     -- 显示的位置
	self.m_byMinusLastShowCard = 0x00
	return
end

function CHeapCard:DrawCardControl(pDC,s)
	if self.m_CardDirection==CardControl.Direction_East then				--东向
		--绘画扑克
		if (self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount)>0 then
				--变量定义
				local nXPos,nYPos=0,0
				local wHeapIndex=self.m_wMinusHeadCount/2
				local wDoubleHeap=(self.m_wMinusHeadCount+1)/2
				local wDoubleLast=(self.m_wFullCount-self.m_wMinusLastCount)/2
				local wFinallyIndex=(self.m_wFullCount-self.m_wMinusLastCount)/2

				local wShowCardPos = self.m_wFullCount - self.m_byIndex - self.m_byMinusLastShowCard + 1

				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+wHeapIndex*15+9
					CCardResource.m_ImageHeapSingleV:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
					end
				end

				--中间扑克
				for i=wDoubleHeap,wFinallyIndex-1,1 do
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+i*15
					CCardResource.m_ImageHeapDoubleV:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
					end
				end

				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+wFinallyIndex*15+9
					CCardResource.m_ImageHeapSingleV:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(m_ControlPoint.x,m_ControlPoint.y)
		--	:setTextColor(cc.c4b(255,255,255,255))
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		--绘画扑克
		if (self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount)>0 then
				--变量定义
				local nXPos,nYPos=0,0
				local wHeapIndex=self.m_wMinusLastCount/2
				local wDoubleHeap=(self.m_wMinusLastCount+1)/2
				local wDoubleLast=(self.m_wFullCount-self.m_wMinusHeadCount)/2
				local wFinallyIndex=(self.m_wFullCount-self.m_wMinusHeadCount)/2

				local wShowCardPos = self.m_byIndex + self.m_byMinusLastShowCard

				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
					nYPos=m_ControlPoint.y+6
					nXPos=m_ControlPoint.x+wHeapIndex*18
					CCardResource.m_ImageHeapSingleH:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableBottom",pDC,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
					end
				end

				--中间扑克
				for i=wDoubleHeap,wFinallyIndex-1,1 do
					nYPos=m_ControlPoint.y
					nXPos=m_ControlPoint.x+i*18
					CCardResource.m_ImageHeapDoubleH:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableBottom",pDC,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
					end
				end

				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
					nYPos=m_ControlPoint.y+6
					nXPos=m_ControlPoint.x+wFinallyIndex*18
					CCardResource.m_ImageHeapSingleH:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableBottom",pDC,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(m_ControlPoint.x,m_ControlPoint.y)
		--	:setTextColor(cc.c4b(255,255,255,255))
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		if (self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount)>0 then
				--变量定义
				local nXPos,nYPos=0,0
				local wHeapIndex=self.m_wMinusLastCount/2
				local wDoubleHeap=(self.m_wMinusLastCount+1)/2
				local wDoubleLast=(self.m_wFullCount-self.m_wMinusHeadCount)/2
				local wFinallyIndex=(self.m_wFullCount-self.m_wMinusHeadCount)/2

				local wShowCardPos = self.m_byIndex + self.m_byMinusLastShowCard
				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
					nXPos=m_ControlPoint.x
					nYPos=m_ControlPoint.y+wHeapIndex*15+9
					CCardResource.m_ImageHeapSingleV:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
					end
				end
				--中间扑克
				for i=wDoubleHeap,wFinallyIndex-1,1 do
					nXPos=m_ControlPoint.x
					nYPos=m_ControlPoint.y+i*15
					CCardResource.m_ImageHeapDoubleV:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
					end
				end
				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
					nXPos=m_ControlPoint.x
					nYPos=m_ControlPoint.y+wFinallyIndex*15+9
					CCardResource.m_ImageHeapSingleV:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(m_ControlPoint.x,m_ControlPoint.y)
		--	:setTextColor(cc.c4b(255,255,255,255))
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		if (self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount)>0 then
				--变量定义
				local nXPos,nYPos=0,0
				local wHeapIndex=self.m_wMinusHeadCount/2
				local wDoubleHeap=(self.m_wMinusHeadCount+1)/2
				local wDoubleLast=(self.m_wFullCount-self.m_wMinusLastCount)/2
				local wFinallyIndex=(self.m_wFullCount-self.m_wMinusLastCount)/2
				local wShowCardPos = self.m_wFullCount - self.m_byIndex - self.m_byMinusLastShowCard + 1

				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
					nYPos=m_ControlPoint.y+6
					nXPos=m_ControlPoint.x+wHeapIndex*18
					CCardResource.m_ImageHeapSingleH:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
					end
				end
				--中间扑克
				for i=wDoubleHeap,wFinallyIndex-1,1 do
					nYPos=m_ControlPoint.y
					nXPos=m_ControlPoint.x+i*18
					CCardResource.m_ImageHeapDoubleH:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
					end
				end
				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
					nYPos=m_ControlPoint.y+6
					nXPos=m_ControlPoint.x+wFinallyIndex*18
					CCardResource.m_ImageHeapSingleH:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(m_ControlPoint.x,m_ControlPoint.y)
		--	:setTextColor(cc.c4b(255,255,255,255))
	end
	return
end

--设置扑克
function CHeapCard:SetCardData(wMinusHeadCount,wMinusLastCount,wFullCount)
	--设置变量
	self.m_wFullCount=wFullCount
	self.m_wMinusHeadCount=wMinusHeadCount
	self.m_wMinusLastCount=wMinusLastCount
	if 0 == wFullCount then
		self.m_byShowCard = 0
	end
	return true
end

function CHeapCard:SetGodsCard(byCard,byIndex,byMinusLastShowCard)
	self.m_byShowCard = byCard
	self.m_byIndex = byIndex
	self.m_byMinusLastShowCard = byMinusLastShowCard
end
--设置方向
function CHeapCard:SetDirection(Direction)
	self.m_CardDirection=Direction
end
--基准位置
function CHeapCard:SetControlPoint(nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end

--===================================================================
--组合扑克
function CWeaveCard:ctor()
	--状态变量
	self.m_bDisplayItem=false
	self.m_ControlPoint = cc.p(0, 0)
	self.m_CardDirection=CardControl.Direction_South
	self.m_cbDirectionCardPos = 1

	--扑克数据
	self.m_wCardCount=0
	self.m_cbCardData={}
	self.m_cbWikCard=0
	return
end

function CWeaveCard.DrawCardControl(...)
	local arg={...}
	local len=#arg
	if len==1 then	CWeaveCard:DrawCardControl_1(arg[1])
	elseif len==3 then	CWeaveCard:DrawCardControl_3(arg[1],arg[2],arg[3])
	else	print("DrawCardControl 参数个数不符")
	end
end
--绘画扑克
function CWeaveCard:DrawCardControl_1(pDC)
	--显示判断
	if self.m_wCardCount==0 then return end
	--变量定义
	local nXScreenPos,nYScreenPos=0,0
	local nItemWidth,nItemHeight,nItemWidthEx,nItemHeightEx=0,0,0,0

	--绘画扑克
	if self.m_CardDirection==CardControl.Direction_East then				--东向
		--绘画扑克
		for i=0,3-1,1 do
				--local nXScreenPos=self.m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=m_ControlPoint.y+i*CardControl.CCardList["m_ImageTableRight"].m_nViewHeight-8*i
				CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self:GetCardData(2-i),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=m_ControlPoint.y-8+CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		--绘画扑克
		for i=0,3-1,1 do
				local nXScreenPos=self.m_ControlPoint.x+i*39
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageWaveBottom"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageWaveBottom",pDC,self:GetCardData(i),nXScreenPos,nYScreenPos)
				if self.m_cbWikCard~=0 and self.m_cbWikCard==self:GetCardData(i) then
					CardControl:Draw3dRect(nXScreenPos+3,nYScreenPos+3,34,45,cc.c4f(1,0,0,1),cc.c4f(1,0,0,1))
				end
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x+CardControl.CCardList["m_ImageWaveBottom"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageWaveBottom"].m_nViewHeight-5*2
				CCardListImage:DrawCardItem("m_ImageWaveBottom",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		for i=0,3-1,1 do
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+i*CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight-8*i
				CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self:GetCardData(i),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight-8
				CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		for i=0,3-1,1 do
				local nYScreenPos=self.m_ControlPoint.y
				local nXScreenPos=self.m_ControlPoint.x-(i+1)*24
				CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self:GetCardData(2-i),nXScreenPos,nYScreenPos)
				if self.m_cbWikCard!=0 and self.m_cbWikCard==self:GetCardData(2-i) then
					CardControl:Draw3dRect(nXScreenPos+1,nYScreenPos+2,21,27,cc.c4f(1,0,0,1),cc.c4f(1,0,0,1))
				end
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nYScreenPos=self.m_ControlPoint.y-5
				local nXScreenPos=self.m_ControlPoint.x-2*24
				CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	end
	return
end

--设置扑克
function CWeaveCard:SetCardData(cbCardData,wCardCount,cbWikCard)
	if wCardCount>GameLogic.table_leng(self.m_cbCardData) return false end

	--设置扑克
	self.m_wCardCount=wCardCount
	self.m_cbCardData=GameLogic.deepcopy(cbCardData)
	--CopyMemory(m_cbCardData,cbCardData,sizeof(BYTE)*wCardCount);

	self.m_cbWikCard=cbWikCard
	return true
end

--获取扑克
function CWeaveCard:GetCardData(wIndex)
	return ((self.m_bDisplayItem==true) or (wIndex==3)) and self.m_cbCardData[wIndex] or 0
end

--绘画扑克
function CWeaveCard:DrawCardControl_3(pDC,nXPos,nYPos)
	--设置位置
	self:SetControlPoint(nXPos,nYPos)
	--显示判断
	if self.m_wCardCount==0 then return end
	--变量定义
	local nXScreenPos,nYScreenPos=0,0
	local nItemWidth,nItemHeight,nItemWidthEx,nItemHeightEx=0,0,0,0

	--绘画扑克
	if self.m_CardDirection==CardControl.Direction_East then				--东向
		--绘画扑克
		for i=0,3-1,1 do
				--local nXScreenPos=self.m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=m_ControlPoint.y+i*CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self:GetCardData(2-i),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=m_ControlPoint.y-5+CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableRight",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		--绘画扑克
		for i=0,3-1,1 do
				local nXScreenPos=self.m_ControlPoint.x+i*CardControl.CCardList["m_ImageTableBottom"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageTableBottom"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableBottom",pDC,self:GetCardData(i),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x+CardControl.CCardList["m_ImageTableBottom"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageTableBottom"].m_nViewHeight-5*2
				CCardListImage:DrawCardItem("m_ImageTableBottom",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		for i=0,3-1,1 do
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+i*CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self:GetCardData(i),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight-5
				CCardListImage:DrawCardItem("m_ImageTableLeft",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		for i=0,3-1,1 do
				local nYScreenPos=self.m_ControlPoint.y
				local nXScreenPos=self.m_ControlPoint.x-(i+1)*CardControl.CCardList["m_ImageTableTop"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self:GetCardData(2-i),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nYScreenPos=self.m_ControlPoint.y-5
				local nXScreenPos=self.m_ControlPoint.x-2*CardControl.CCardList["m_ImageTableTop"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableTop",pDC,self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	end
	return
end
--设置显示
function CWeaveCard:SetDisplayItem(bDisplayItem)
	self.m_bDisplayItem=bDisplayItem
end
--设置方向
function CWeaveCard:SetDirection(Direction)
	self.m_CardDirection=Direction
end
--基准位置
function CWeaveCard:SetControlPoint(nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end
--方向牌
function CWeaveCard:SetDirectionCardPos(cbPos)
	self.m_cbDirectionCardPos = cbPos
end
function CWeaveCard:GetCardCount()	return self.m_wCardCount end
function CWeaveCard:GetControlXPos()	return self.m_ControlPoint.x end
function CWeaveCard:GetControlYPox()	return self.m_ControlPoint.y end
--===================================================================
--用户扑克
function CUserCard:ctor()
	--扑克数据
	self.m_wCardCount=0
	self.m_bCurrentCard=false

	--控制变量
	self.m_ControlPoint = cc.p(0, 0)
	self.m_CardDirection=CardControl.Direction_East

	return
end

--绘画扑克
function CUserCard:DrawCardControl(pDC)
	if self.m_CardDirection==CardControl.Direction_East then				--东向
			--当前扑克
			if self.m_bCurrentCard==true then
				local nXPos=self.m_ControlPoint.x
				local nYPos=self.m_ControlPoint.y
				CCardResource.m_ImageUserRight:setPosition(nXPos,nYPos)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end

			--正常扑克
			if self.m_wCardCount>0 then
				local nXPos,nYPos=0,0
				for i=0,self.m_wCardCount-1,1 do
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+i*22+40
					CCardResource.m_ImageUserRight:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
				end
			end

	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
			--正常扑克
			if self.m_wCardCount>0 then
				local nXPos,nYPos=0,0
				for i=0,self.m_wCardCount-1,1 do
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y-(self.m_wCardCount-i-1)*22-92
					CCardResource.m_ImageUserLeft:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
				end
			end

			--当前扑克
			if self.m_bCurrentCard==true then
				local nXPos=self:m_ControlPoint.x
				local nYPos=self:m_ControlPoint.y-49
				CCardResource.m_ImageUserLeft:setPosition(nXPos,nYPos)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
			--当前扑克
			if self.m_bCurrentCard==true then
				local nXPos=self.m_ControlPoint.x
				local nYPos=self.m_ControlPoint.y
				CCardResource.m_ImageUserTop:setPosition(nXPos,nYPos)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end

			--正常扑克
			if self.m_wCardCount> then
				local nXPos,nYPos=0,0
				for i=0,self.m_wCardCount-1,1 do
					nYPos=self.m_ControlPoint.y
					nXPos=self.m_ControlPoint.x+i*24+40
					CCardResource.m_ImageUserTop:setPosition(nXPos,nYPos)
						:setColor(cc.c3b(255, 0, 255))
						:setVisible(true)
				end
			end
	end
	return
end

--设置扑克
function CUserCard:SetCurrentCard(bCurrentCard)
	--设置变量
	self.m_bCurrentCard=bCurrentCard

	return true
end

--设置扑克
function CUserCard:SetCardData(wCardCount,bCurrentCard)
	--设置变量
	self.m_wCardCount=wCardCount
	self.m_bCurrentCard=bCurrentCard

	return true
end

--设置方向
function CUserCard:SetDirection(Direction)
	self.m_CardDirection=Direction
end
--基准位置
function CUserCard:SetControlPoint(nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end
--===================================================================
--丢弃扑克
function CDiscardCard:ctor()
	--
	-- here  2017年12月9日18:12:45
	--
	--
end

--设置方向
function CDiscardCard:SetDirection(Direction)
	self.m_CardDirection=Direction
end
--基准位置
function CDiscardCard:SetControlPoint(nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end
--===================================================================
--桌面扑克
function CTableCard:ctor()
end

--设置方向
function CTableCard:SetDirection(Direction)
	self.m_CardDirection=Direction
end
--基准位置
function CTableCard:SetControlPoint(nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end
--===================================================================
--扑克控件
function CCardControl:ctor()
end

--获取扑克
function CCardControl:GetCurrentCard() return self.m_CurrentCard.cbCardData end
--设置响应
function CCardControl:SetPositively(bPositively)
	 self.m_bPositively=bPositively
end
--设置显示
function CCardControl:SetDisplayItem(bDisplayItem)
	self.m_bDisplayItem=bDisplayItem
end

--------------------------------------------------------------

return CardControl
