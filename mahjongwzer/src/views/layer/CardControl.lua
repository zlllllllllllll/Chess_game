--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")
local CardControl = class("CardControl", function(scene)
	local CardControl = display.newLayer()
	return CardControl
end)
--local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
--local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.GameViewLayer")

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

CardControl.HEAP_FULL_COUNT			= 	34							--堆立全牌
--公共定义
CardControl.POS_SHOOT				=	 5							--弹起象素
CardControl.POS_SPACE				= 	16							--分隔间隔
CardControl.ITEM_COUNT				=	43							--子项数目
CardControl.INVALID_ITEM			=	0xFFFF						--无效索引

--扑克大小
CardControl.CARD_WIDTH				=	45							--扑克宽度 39
CardControl.CARD_HEIGHT				=	69							--扑克高度  64

--枚举
--X 排列方式
CardControl.enXLeft						="enXLeft"					--左对齐
CardControl.enXCenter					="enXCenter"				--中对齐
CardControl.enXRight					="enXRight"					--右对齐
--Y 排列方式
CardControl.enYTop						="enYTop"					--左对齐
CardControl.enYCenter					="enYCenter"				--中对齐
CardControl.enYBottom					="enYBottom"				--右对齐

CardControl.Direction_East		="Direction_East"					--东向
CardControl.Direction_South		="Direction_South"					--南向
CardControl.Direction_West		="Direction_West"					--西向
CardControl.Direction_North		="Direction_North"					--北向

function CardControl:ctor(scene)
	self._scene = scene
	self:onInitData()
	local this = self
end

function CardControl:onInitData()
end

function CardControl:onResetData()
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
function CCardListImage:LoadResource(Parent,id,uResourceID,nViewWidth,nViewHeight)
	--加载资源
	if false == cc.FileUtils:getInstance():isFileExist(uResourceID) then
		uResourceID = "CARD_USER_BOTTOM"
	end
	CardControl.CCardList[id].m_CardListImage=display.newSprite("res/game/"..uResourceID..".png"):setVisible(false):addTo(Parent)
	CardControl.CCardList[id].m_csFlag="res/game/CS_FLAG.png"
	CardControl.CCardList[id].m_CardBack="res/game/CARD_BACK.png"
	CardControl.CCardList[id].n_ImageResource="res/game/"..uResourceID..".png"
	CardControl.CCardList[id].n_List={}
	CardControl.CCardList[id].Parent=Parent
	--设置变量
	CardControl.CCardList[id].m_nViewWidth=nViewWidth
	CardControl.CCardList[id].m_nViewHeight=nViewHeight
	CardControl.CCardList[id].m_nItemHeight=CardControl.CCardList[id].m_CardListImage:getContentSize().height
	CardControl.CCardList[id].m_nItemWidth=CardControl.CCardList[id].m_CardListImage:getContentSize().width/CardControl.ITEM_COUNT
	--取得宽高后清除样本 防止重复添加
	CardControl.CCardList[id].m_CardListImage:removeFromParent()
	CardControl.CCardList[id].m_CardListImage=nil
	return true
end

--释放资源
function CCardListImage:DestroyResource(id)
	--设置变量
	CardControl.CCardList[id].m_nItemWidth=nil
	CardControl.CCardList[id].m_nItemHeight=nil

	--释放资源
	--CardControl.CCardList[id].m_CardListImage:removeFromParent()
	--CardControl.CCardList[id].m_CardListImage=nil
	--释放资源 集
	CCardResource:clearnResource(CardControl.CCardList[id].n_List)
	CardControl.CCardList[id].n_ImageResource=nil
	CardControl.CCardList[id].n_List={}

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
function CCardListImage:DrawCardItem(id,index,cbCardData,xDest,yDest,cbGodsData,bDrawBack,nItemWidth,nItemHeight)
print("CCardListImage:DrawCardItem 绘画扑克====","id-",id,"index-",index,"cbCardData-",cbCardData,"xDest-",xDest,"yDest-",yDest)
print("cbGodsData-..",cbGodsData,"bDrawBack-",bDrawBack,"nItemWidth-",nItemWidth,"nItemHeight-",nItemHeight)
	if cbCardData <=0 then	print("无数据 ",cbCardData ) return end
	if bDrawBack then
		CardControl.CCardList[id].n_List[index.."m_CardBack"]=display.newSprite(CardControl.CCardList[id].m_CardBack)
			:setPosition(xDest-0,yDest-0)
			:addTo(CardControl.CCardList[id].Parent)
	end

	local nDrawWidth=CardControl.CCardList[id].m_nItemWidth
	local nDrawHeight=CardControl.CCardList[id].m_nItemHeight
	if nItemHeight and nItemHeight>0 then nDrawHeight=nItemHeight	end
	if nItemWidth and nItemWidth>0 then nDrawWidth=nItemWidth	end
	--绘画子项
	if cbCardData<=GameLogic.BAIBAN_CARD_DATA then
		local imgIndex=CCardListImage:GetImageIndex(cbCardData)
		local nImageXPos=imgIndex*CardControl.CCardList[id].m_nItemWidth
		-- CardControl.CCardList[id].m_CardListImage:setPosition(xDest,yDest)
		-- 	:setVisible(true)
print(imgIndex,CardControl.CCardList[id].m_nItemWidth)
print("===nImageXPos ",nImageXPos,nDrawWidth,nDrawHeight)
		local mResource=CardControl.CCardList[id].n_ImageResource

		CardControl.CCardList[id].n_List[index]=GameLogic:Clipp9S(mResource,nDrawWidth,nDrawHeight)
			:move(xDest,yDest)
			:addTo(CardControl.CCardList[id].Parent)
		CardControl.CCardList[id].n_List[index]:getChildByTag(1):move(-nDrawWidth/2-nImageXPos,0)
		
		if index and index ~= "" and index ~= "CCardControl_OutData" and index ~= "CCardControl_V_byGodsData" then
			--出牌按钮
			local btcallback = function(ref, type)
			if type == ccui.TouchEventType.ended then
				CCardControl:GetOutCard(ref:getTag(),ref)
			end
			end
			ccui.Button:create("res/game/mjBtn.png","res/game/mjBtn.png")
				:move(xDest,yDest)
				-- :setTitleText(cbCardData)
				-- :setTitleFontSize(20)
				-- :setTitleColor(cc.c4b(255, 0, 255,180))
				:setName(index)
				--:setTag(cbCardData)
				:setTag(imgIndex)
				:setScale(1)
				:addTo(CardControl.CCardList[id].Parent)
				:addTouchEventListener(btcallback)
		end	
	end
	--财神标记
	if cbGodsData~=0 and cbGodsData==cbCardData then
		CardControl.CCardList[id].n_List[index.."csFalg"]=display.newSprite(CardControl.CCardList[id].m_csFlag)
			:setPosition(xDest,yDest+10)
			:addTo(CardControl.CCardList[id].Parent)
	end

	return CardControl.CCardList[id].n_List[index]
end
--===================================================================
--扑克资源
function CCardResource:ctor()
	CCardListImage:Cfound("m_ImageUserBottom")
	CCardListImage:Cfound("m_ImageWaveBottom")
	CCardListImage:Cfound("m_ImageTableTop")
	CCardListImage:Cfound("m_ImageTableLeft")
	CCardListImage:Cfound("m_ImageTableRight")
	CCardListImage:Cfound("m_ImageTableBottom")
end

--加载资源
function CCardResource:LoadResource(Parent)
	--用户扑克
print("CCardResource:LoadResource", parent,self)
	CCardResource.m_ImageUserTop={}
	CCardResource.m_ImageUserLeft={}
	CCardResource.m_ImageUserRight={}
	CCardListImage:LoadResource(Parent,"m_ImageUserBottom","CARD_USER_BOTTOM",CardControl.CARD_WIDTH,CardControl.CARD_HEIGHT)
	CCardListImage:LoadResource(Parent,"m_ImageWaveBottom","CARD_WAVE_BOTTOM",CardControl.CARD_WIDTH,CardControl.CARD_HEIGHT)
	--桌子扑克
	CCardListImage:LoadResource(Parent,"m_ImageTableTop","CARD_TABLE_TOP",24,35)
	CCardListImage:LoadResource(Parent,"m_ImageTableLeft","CARD_TABLE_LEFT",32,28)
	CCardListImage:LoadResource(Parent,"m_ImageTableRight","CARD_TABLE_RIGHT",32,28)
	CCardListImage:LoadResource(Parent,"m_ImageTableBottom","CARD_TABLE_BOTTOM",24,35)

	--牌堆扑克
	--CCardResource.m_ImageBackH=display.newSprite("res/game/CARD_BACK_H.png"):setVisible(false) :addTo(Parent)
	--CCardResource.m_ImageBackV=display.newSprite("res/game/CARD_BACK_V.png"):setVisible(false) :addTo(Parent)
	CCardResource.m_ImageHeapSingleV={} 
	CCardResource.m_ImageHeapSingleH={}
	CCardResource.m_ImageHeapDoubleV={}
	CCardResource.m_ImageHeapDoubleV["east"]={}
	CCardResource.m_ImageHeapDoubleV["west"]={}
	CCardResource.m_ImageHeapDoubleH={}
	CCardResource.m_ImageHeapDoubleH["south"]={}
	CCardResource.m_ImageHeapDoubleH["north"]={}

	return true
end

--消耗资源
function CCardResource:DestroyResource()
	--用户扑克
	CCardResource:clearnResource(CCardResource.m_ImageUserTop)
	CCardResource:clearnResource(CCardResource.m_ImageUserLeft)
	CCardResource:clearnResource(CCardResource.m_ImageUserRight)
 	CCardListImage:DestroyResource("m_ImageUserBottom")
	--少个 m_ImageWaveBottom

	--桌子扑克
 	CCardListImage:DestroyResource("m_ImageTableTop")
 	CCardListImage:DestroyResource("m_ImageTableLeft")
 	CCardListImage:DestroyResource("m_ImageTableRight")
 	CCardListImage:DestroyResource("m_ImageTableBottom")

	--牌堆扑克
	--CCardResource.m_ImageBackH:removeFromParent()
	--CCardResource.m_ImageBackV:removeFromParent()
	CCardResource:clearnResource(CCardResource.m_ImageHeapSingleH)
	CCardResource:clearnResource(CCardResource.m_ImageHeapSingleV)
	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleV["east"])
	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleV["west"])
	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleH["south"])
	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleH["north"])
	--CCardResource.m_ImageBackH=nil
	--CCardResource.m_ImageBackV=nil

	return true
end

--
function CCardResource:clearnResource(param)
	if type(param) ~= "table" then priunt("== ! clearnResource param no table") return end
dump(param,"param",6)
	for k, v in pairs(param) do
		print("== ",k,v)
		if v then
			v:removeFromParent()
			v=nil
		end
	end
end 

--===================================================================
--堆立扑克
function CHeapCard:ctor()
	CHeapCard.m_ControlPoint = cc.p(0, 0)
	CHeapCard.m_CardDirection=CardControl.Direction_East

	--扑克变量
	CHeapCard.m_wFullCount=0
	CHeapCard.m_wMinusHeadCount=0
	CHeapCard.m_wMinusLastCount=0

	CHeapCard.m_byShowCard= 0x00  	 -- 显示的牌
	CHeapCard.m_byIndex= 0x00	     -- 显示的位置
	CHeapCard.m_byMinusLastShowCard = 0x00
	return
end

--清除
function CHeapCard:DrawClearn()
	--牌堆扑克
-- print("m_ImageHeapSingleH")
-- 	CCardResource:clearnResource(CCardResource.m_ImageHeapSingleH)
-- print("m_ImageHeapSingleV")
-- 	CCardResource:clearnResource(CCardResource.m_ImageHeapSingleV)
-- print("m_ImageHeapDoubleV east ")
-- 	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleV["east"])
-- print("m_ImageHeapDoubleV west ")
-- 	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleV["west"])
-- print("m_ImageHeapDoubleH south ")
-- 	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleH["south"])
-- print("m_ImageHeapDoubleH north ")
-- 	CCardResource:clearnResource(CCardResource.m_ImageHeapDoubleH["north"])
print("DrawClearn 清除",self.m_CardDirection)
	self:removeAllChildren()
end

function CHeapCard:DrawCardControl(s)
print("CHeapCard:DrawCardControl  self.m_CardDirection", self.m_CardDirection)
print(self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount,self.m_wFullCount,self.m_wMinusHeadCount,self.m_wMinusLastCount)
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

				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
print("东向尾部")
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+wFinallyIndex*15+9
					CCardResource.m_ImageHeapSingleV["eastTail"]=display.newSprite("res/game/CARD_HEAP_SINGLE_V.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableRight","CHeapCard_eastTail",self.m_byShowCard,nXPos,nYPos,0,false,25,19)
print("m_ImageTableRight",nXPos,nYPos)
					end
				end

				--中间扑克
	print(wDoubleHeap,wFinallyIndex)
				for i=wFinallyIndex-0.1,wDoubleHeap,-1 do
	--print("东向 中间扑克 ",i,wDoubleHeap,wFinallyIndex)
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+i*15
					CCardResource.m_ImageHeapDoubleV["east"][i]=display.newSprite("res/game/CARD_HEAP_DOUBLE_V.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableRight","CHeapCard_east_"..i,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
print("m_ImageTableRight",nXPos,nYPos)
					end
				end

				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
print("东向头部")
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+wHeapIndex*15+6
					CCardResource.m_ImageHeapSingleV["eastHead"]=display.newSprite("res/game/CARD_HEAP_SINGLE_V.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableRight","CHeapCard_eastHead",self.m_byShowCard,nXPos,nYPos,0,false,25,19)
print("m_ImageTableRight",nXPos,nYPos)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(self.m_ControlPoint.x,self.m_ControlPoint.y)
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

				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
print("南向头部")
					nYPos=self.m_ControlPoint.y-3
					nXPos=self.m_ControlPoint.x+wFinallyIndex*18
					CCardResource.m_ImageHeapSingleH["southHead"]=display.newSprite("res/game/CARD_HEAP_SINGLE_H.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableBottom","CHeapCard_southHead",self.m_byShowCard,nXPos,nYPos,0,false,18,28)
print("m_ImageTableBottom",nXPos,nYPos)
					end
				end

				--中间扑克
	print(wDoubleHeap,wFinallyIndex)
				for i=wDoubleHeap,wFinallyIndex-0.1,1 do
	--print("南向 中间扑克 ",i,wDoubleHeap,wFinallyIndex)
					nYPos=self.m_ControlPoint.y
					nXPos=self.m_ControlPoint.x+i*18
					CCardResource.m_ImageHeapDoubleH["south"][i]=display.newSprite("res/game/CARD_HEAP_DOUBLE_H.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableBottom","CHeapCard_south_"..i,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
print("m_ImageTableBottom",nXPos,nYPos)
					end
				end
				
				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
print("南向尾部")
					nYPos=self.m_ControlPoint.y-3
					nXPos=self.m_ControlPoint.x+wHeapIndex*18
					CCardResource.m_ImageHeapSingleH["southTail"]=display.newSprite("res/game/CARD_HEAP_SINGLE_H.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableBottom","CHeapCard_southTail",self.m_byShowCard,nXPos,nYPos,0,false,18,28)
print("m_ImageTableBottom",nXPos,nYPos)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(self.m_ControlPoint.x,self.m_ControlPoint.y)
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
print("西向尾部")
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+wHeapIndex*15+9
					CCardResource.m_ImageHeapSingleV["weatTail"]=display.newSprite("res/game/CARD_HEAP_SINGLE_V.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableLeft","CHeapCard_weatTail",self.m_byShowCard,nXPos,nYPos,0,false,25,19)
print("m_ImageTableLeft",nXPos,nYPos)
					end
				end
				--中间扑克
	print(wDoubleHeap,wFinallyIndex)
				for i=wFinallyIndex-0.1,wDoubleHeap,-1 do
	--print("西向 中间扑克 ",i,wDoubleHeap,wFinallyIndex)
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+i*15
					CCardResource.m_ImageHeapDoubleV["west"][i]=display.newSprite("res/game/CARD_HEAP_DOUBLE_V.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableLeft","CHeapCard_west_"..i,self.m_byShowCard,nXPos,nYPos,0,false,25,19)
print("m_ImageTableLeft",nXPos,nYPos)
					end
				end
				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
print("西向头部")
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+wFinallyIndex*15+6
					CCardResource.m_ImageHeapSingleV["westHead"]=display.newSprite("res/game/CARD_HEAP_SINGLE_V.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableLeft","CHeapCard_westHead",self.m_byShowCard,nXPos,nYPos,0,false,25,19)
print("m_ImageTableLeft",nXPos,nYPos)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(self.m_ControlPoint.x,self.m_ControlPoint.y)
		--	:setTextColor(cc.c4b(255,255,255,255))
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		--if (self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount)>0 then
		if (self.m_wFullCount-self.m_wMinusHeadCount-self.m_wMinusLastCount)>=0 then
				--变量定义
				local nXPos,nYPos=0,0
				local wHeapIndex=self.m_wMinusHeadCount/2
				local wDoubleHeap=(self.m_wMinusHeadCount+1)/2
				local wDoubleLast=(self.m_wFullCount-self.m_wMinusLastCount)/2
				local wFinallyIndex=(self.m_wFullCount-self.m_wMinusLastCount)/2
				local wShowCardPos = self.m_wFullCount - self.m_byIndex - self.m_byMinusLastShowCard + 1

				--头部扑克
				if self.m_wMinusHeadCount%2~=0 then
print("北向头部")
					nYPos=self.m_ControlPoint.y-3
					nXPos=self.m_ControlPoint.x+wHeapIndex*18
					CCardResource.m_ImageHeapSingleH["northHead"]=display.newSprite("res/game/CARD_HEAP_SINGLE_H.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wHeapIndex + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableTop","CHeapCard_northHead",self.m_byShowCard,nXPos,nYPos,0,false,18,28)
print("m_ImageTableTop",nXPos,nYPos)
					end
				end
				--中间扑克
	print(wDoubleHeap,wFinallyIndex)
				for i=wDoubleHeap,wFinallyIndex-0.1,1 do
	--print("北向 中间扑克 ",i,wDoubleHeap,wFinallyIndex)
					nYPos=self.m_ControlPoint.y
					nXPos=self.m_ControlPoint.x+i*18
					CCardResource.m_ImageHeapDoubleH["north"][i]=display.newSprite("res/game/CARD_HEAP_DOUBLE_H.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((i + 1) == (wShowCardPos+1)/2) and (self.m_byShowCard>0) then
						CCardListImage:DrawCardItem("m_ImageTableTop","CHeapCard_north_"..i,self.m_byShowCard,nXPos,nYPos,0,false,18,28)
print("m_ImageTableTop",nXPos,nYPos)
					end
				end
				--尾部扑克
				if self.m_wMinusLastCount%2~=0 then
print("北向尾部")
					nYPos=self.m_ControlPoint.y-3
					nXPos=self.m_ControlPoint.x+wFinallyIndex*18
					CCardResource.m_ImageHeapSingleH["northTail"]=display.newSprite("res/game/CARD_HEAP_SINGLE_H.png")
						:setPosition(nXPos,nYPos)
						:setVisible(true)
						:addTo(self)
					if ((wFinallyIndex + 1) == (wShowCardPos+1)/2) and (m_byShowCard>0) and (0 == wShowCardPos%2) then
						CCardListImage:DrawCardItem("m_ImageTableTop","CHeapCard_northTail",self.m_byShowCard,nXPos,nYPos,0,false,18,28)
print("m_ImageTableTop",nXPos,nYPos)
					end
				end
		end
		cc.Label:createWithTTF(s,"fonts/round_body.ttf", 24)
			:move(self.m_ControlPoint.x,self.m_ControlPoint.y)
		--	:setTextColor(cc.c4b(255,255,255,255))
print("createWithTTF",s,self.m_ControlPoint.x,self.m_ControlPoint.y)
	end
	return
end

--设置扑克
function CHeapCard:SetCardData(wMinusHeadCount,wMinusLastCount,wFullCount)
print("设置扑克 CHeapCard",self.m_CardDirection,wMinusHeadCount,wMinusLastCount,wFullCount)
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
	CWeaveCard.m_bDisplayItem=false
	CWeaveCard.m_ControlPoint = cc.p(0, 0)
	CWeaveCard.m_CardDirection=CardControl.Direction_South
	CWeaveCard.m_cbDirectionCardPos = 1

	--扑克数据
	CWeaveCard.m_wCardCount=0
	--CWeaveCard.m_cbCardData={0,0,0,0}
	CWeaveCard.m_cbCardData="sign invalid"
	CWeaveCard.m_cbWikCard=0
	return
end

function CWeaveCard:DrawCardControl(...)
	local arg={...}
	local len=#arg
	if len==0 then	return CWeaveCard:DrawCardControl_1()
	elseif len==2 then	return CWeaveCard:DrawCardControl_3(arg[1],arg[2])
	else	print("CWeaveCard DrawCardControl 参数个数不符 len",len)
	end
end
--绘画扑克
function CWeaveCard:DrawCardControl_1()
print("CWeaveCard:DrawCardControl_1")
	--显示判断
	if self.m_wCardCount==0 then return end
	--变量定义
	local nXScreenPos,nYScreenPos=0,0
	local nItemWidth,nItemHeight,nItemWidthEx,nItemHeightEx=0,0,0,0

	--绘画扑克
	if self.m_CardDirection==CardControl.Direction_East then				--东向
		--绘画扑克
		for i=1,3,1 do
				--local nXScreenPos=self.m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y+(i-1)*CardControl.CCardList["m_ImageTableRight"].m_nViewHeight-8*(i-1)
				CCardListImage:DrawCardItem("m_ImageTableRight","CWeaveCard_"..i,self:GetCardData(2-i+1),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-8+CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableRight","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		--绘画扑克
		for i=1,3,1 do
				local nXScreenPos=self.m_ControlPoint.x+(i-1)*39
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageWaveBottom"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageWaveBottom","CWeaveCard_"..i,self:GetCardData(i-1),nXScreenPos,nYScreenPos)
				if self.m_cbWikCard~=0 and self.m_cbWikCard==self:GetCardData(i-1) then
					GameLogic:Draw3dRect(nXScreenPos+3,nYScreenPos+3,34,45,cc.c4f(1,0,0,1),cc.c4f(1,0,0,1))
				end
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x+CardControl.CCardList["m_ImageWaveBottom"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageWaveBottom"].m_nViewHeight-5*2
				CCardListImage:DrawCardItem("m_ImageWaveBottom","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		for i=-1,3,1 do
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+(i-1)*CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight-8*(i-1)
				CCardListImage:DrawCardItem("m_ImageTableLeft","CWeaveCard_"..i,self:GetCardData(i-1),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight-8
				CCardListImage:DrawCardItem("m_ImageTableLeft","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		for i=1,3,1 do
				local nYScreenPos=self.m_ControlPoint.y
				local nXScreenPos=self.m_ControlPoint.x-(i+1-1)*24
				CCardListImage:DrawCardItem("m_ImageTableTop","CWeaveCard_"..i,self:GetCardData(2-i-1),nXScreenPos,nYScreenPos)
				if self.m_cbWikCard~=0 and self.m_cbWikCard==self:GetCardData(2-i-1) then
					GameLogic:Draw3dRect(nXScreenPos+1,nYScreenPos+2,21,27,cc.c4f(1,0,0,1),cc.c4f(1,0,0,1))
				end
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nYScreenPos=self.m_ControlPoint.y-5
				local nXScreenPos=self.m_ControlPoint.x-2*24
				CCardListImage:DrawCardItem("m_ImageTableTop","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	end
	return
end

--设置扑克
function CWeaveCard:SetCardData(cbCardData,wCardCount,cbWikCard)
    --测试添加
    if nil==wCardCount or nil==cbCardData then return end
	if wCardCount>GameLogic:table_leng(self.m_cbCardData) then return false end

	--设置扑克
	self.m_wCardCount=wCardCount
	self.m_cbCardData=GameLogic:deepcopy(cbCardData)
	--CopyMemory(m_cbCardData,cbCardData,sizeof(BYTE)*wCardCount);

	self.m_cbWikCard=cbWikCard
	return true
end

--获取扑克
function CWeaveCard:GetCardData(wIndex)
	return ((self.m_bDisplayItem==true) or (wIndex==3)) and self.m_cbCardData[wIndex] or 0
end

--绘画扑克
function CWeaveCard:DrawCardControl_3(nXPos,nYPos)
print("CWeaveCard:DrawCardControl_3")
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
		for i=1,3,1 do
				--local nXScreenPos=self.m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y+(i-1)*CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableRight","CWeaveCard_"..i,self:GetCardData(2-i-1),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x-CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-5+CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableRight","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		--绘画扑克
		for i=1,3,1 do
				local nXScreenPos=self.m_ControlPoint.x+(i-1)*CardControl.CCardList["m_ImageTableBottom"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageTableBottom"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableBottom","CWeaveCard_"..i,self:GetCardData(i-1),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x+CardControl.CCardList["m_ImageTableBottom"].m_nViewWidth
				local nYScreenPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageTableBottom"].m_nViewHeight-5*2
				CCardListImage:DrawCardItem("m_ImageTableBottom","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		for i=1,3,1 do
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+(i-1)*CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableLeft","CWeaveCard_"..i,self:GetCardData(i-1),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nXScreenPos=self.m_ControlPoint.x
				local nYScreenPos=self.m_ControlPoint.y+CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight-5
				CCardListImage:DrawCardItem("m_ImageTableLeft","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		for i=1,3,1 do
				local nYScreenPos=self.m_ControlPoint.y
				local nXScreenPos=self.m_ControlPoint.x-(i+1-1)*CardControl.CCardList["m_ImageTableTop"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableTop","CWeaveCard_"..i,self:GetCardData(2-i-1),nXScreenPos,nYScreenPos)
		end

		--第四扑克
		if self.m_wCardCount==4 then
				local nYScreenPos=self.m_ControlPoint.y-5
				local nXScreenPos=self.m_ControlPoint.x-2*CardControl.CCardList["m_ImageTableTop"].m_nViewHeight
				CCardListImage:DrawCardItem("m_ImageTableTop","CWeaveCard_4",self:GetCardData(3),nXScreenPos,nYScreenPos)
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
	CUserCard.m_wCardCount=0
	CUserCard.m_bCurrentCard=false

	--控制变量
	CUserCard.m_ControlPoint = cc.p(0, 0)
	CUserCard.m_CardDirection=CardControl.Direction_East

	return
end

--清除
function CUserCard:DrawClearn()
print("CUserCard 清除")
	self:removeAllChildren()
end

--绘画扑克
function CUserCard:DrawCardControl()
print("CUserCard:DrawCardControl",self.m_CardDirection,self.m_wCardCount)
	if self.m_CardDirection==CardControl.Direction_East then				--东向
			--当前扑克
			if self.m_bCurrentCard==true then
				local nXPos=self.m_ControlPoint.x
				local nYPos=self.m_ControlPoint.y
				CCardResource.m_ImageUserRight["m_bCurrentCard"]=display.newSprite("res/game/CARD_USER_RIGHT.png")
					:setPosition(nXPos,nYPos)
					:addTo(self)
			end

			--正常扑克
			if self.m_wCardCount>0 then
				local nXPos,nYPos=0,0
				for i=1,self.m_wCardCount+0,1 do
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y+(i-1)*22+40
					CCardResource.m_ImageUserRight[i]=display.newSprite("res/game/CARD_USER_RIGHT.png")
						:setPosition(nXPos,nYPos)
						:addTo(self)
				end
			end

	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
			--正常扑克
			if self.m_wCardCount>0 then
				local nXPos,nYPos=0,0
				for i=1,self.m_wCardCount+0,1 do
					nXPos=self.m_ControlPoint.x
					nYPos=self.m_ControlPoint.y-(self.m_wCardCount-i-1-1)*22-92
					CCardResource.m_ImageUserLeft[i]=display.newSprite("res/game/CARD_USER_LEFT.png")
						:setPosition(nXPos,nYPos)
						:addTo(self)
				end
			end

			--当前扑克
			if self.m_bCurrentCard==true then
				local nXPos=self.m_ControlPoint.x
				local nYPos=self.m_ControlPoint.y-49
				CCardResource.m_ImageUserLeft["m_bCurrentCard"]=display.newSprite("res/game/CARD_USER_LEFT.png")
					:setPosition(nXPos,nYPos)
					:addTo(self)
			end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
			--当前扑克
			if self.m_bCurrentCard==true then
		print("当前扑克 CCardResource.m_ImageUserTop")
				local nXPos=self.m_ControlPoint.x
				local nYPos=self.m_ControlPoint.y
				CCardResource.m_ImageUserTop["m_bCurrentCard"]=display.newSprite("res/game/CARD_USER_TOP.png")
					:setPosition(nXPos,nYPos)
					:addTo(self)
			end

			--正常扑克
			if self.m_wCardCount>0 then
		print("正常扑克 CCardResource.m_ImageUserTop")
				local nXPos,nYPos=0,0
				for i=1,self.m_wCardCount+0,1 do
					nYPos=self.m_ControlPoint.y
					nXPos=self.m_ControlPoint.x+(i-1)*24+40
			print("m_ImageUserTop x",nXPos,nYPos)
					CCardResource.m_ImageUserTop[i]=display.newSprite("res/game/CARD_USER_TOP.png")
						:setPosition(nXPos,600)
						--:setPosition(nXPos,nYPos)
						:addTo(self)

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
print("CUserCard:SetCardData",wCardCount,bCurrentCard)
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
	--扑克数据
	CDiscardCard.m_wCardCount=0
	--辅助需要在外部使用表中重新赋值 此处的无法符合逻辑指向的都是同一个
	--CDiscardCard.m_cbCardData={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	CDiscardCard.m_cbCardData="sign invalid"

	--控制变量
	CDiscardCard.m_ControlPoint = cc.p(0, 0)
	CDiscardCard.m_CardDirection=CardControl.Direction_East
	return
end

--绘画扑克
function CDiscardCard:DrawCardControl()
print("CDiscardCard:DrawCardControl",self.m_CardDirection,self.m_wCardCount)
dump(self.m_cbCardData,"cbCardData",6)
	--绘画控制
	if self.m_CardDirection==CardControl.Direction_East then				--东向
		--绘画扑克
		for i=1,self.m_wCardCount+0,1 do
			local nXPos=self.m_ControlPoint.x+math.floor((i-1)/8)*32
			local nYPos=self.m_ControlPoint.y+((i-1)%8)*20
		print("东向",i,nXPos,nYPos)
			CCardListImage:DrawCardItem("m_ImageTableRight","CDiscardCard_"..i,self.m_cbCardData[i],nXPos,nYPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		for i=1,self.m_wCardCount+0,1 do
			local nXPos=self.m_ControlPoint.x-math.floor((self.m_wCardCount-1-i-1)/8)*32
			local nYPos=self.m_ControlPoint.y-((self.m_wCardCount-1-i-1)%8)*20
		print("西向",i,nXPos,nYPos)
			CCardListImage:DrawCardItem("m_ImageTableLeft","CDiscardCard_"..i,self.m_cbCardData[self.m_wCardCount-i+1],nXPos,nYPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		for i=1,self.m_wCardCount+0,1 do
			local nXPos=self.m_ControlPoint.x-((i-1)%14)*24
			local nYPos=self.m_ControlPoint.y+math.floor((i-1)/14)*38
		print("南向",i,nXPos,nYPos)
			CCardListImage:DrawCardItem("m_ImageTableBottom","CDiscardCard_"..i,self.m_cbCardData[i],nXPos,nYPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		for i=1,self.m_wCardCount+0,1 do
			--local nXPos=self.m_ControlPoint.x+((self.m_wCardCount-1-i-1)%14)*24
			local nXPos=self.m_ControlPoint.x+((self.m_wCardCount-1-i-1)%14)*45
			local nYPos=self.m_ControlPoint.y-math.floor((self.m_wCardCount-1-i-1)/14)*38-11
		print("北向",i,nXPos,nYPos)
			--CCardListImage:DrawCardItem("m_ImageTableTop","CDiscardCard_"..i,self.m_cbCardData[self.m_wCardCount-i+2],nXPos,nYPos)
			CCardListImage:DrawCardItem("m_ImageTableTop","CDiscardCard_"..i,self.m_cbCardData[self.m_wCardCount-i+1],nXPos,nYPos)
		end
	end
end

--增加扑克
function CDiscardCard:AddCardItem(cbCardData)
print("CDiscardCard:AddCardItem",cbCardData,self.m_wCardCount,GameLogic:table_leng(self.m_cbCardData))
	--清理扑克	向上移动一位挤掉第一位值
	if self.m_wCardCount>=GameLogic:table_leng(self.m_cbCardData) then
print("向上移动清理扑克")
		self.m_wCardCount=self.m_wCardCount-1
		--MoveMemory(m_cbCardData,m_cbCardData+1,CountArray(m_cbCardData)-1);  --遍历有限制
		local tempData={}
		for i=1,#self.m_cbCardData-1,1 do
			tempData[i]=self.m_cbCardData[i+1]
		end
		self.m_cbCardData=tempData
	end

	--设置扑克
	self.m_wCardCount=self.m_wCardCount+1
dump(self.m_cbCardData,"self.m_cbCardData AddCardItem",6)
	self.m_cbCardData[self.m_wCardCount]=cbCardData
dump(self.m_cbCardData,"self.m_cbCardData AddCardItem",6)
print(self.m_wCardCount)

	return true
end

--设置扑克
function CDiscardCard:SetCardData(cbCardData,wCardCount)
print("CDiscardCard:SetCardData",cbCardData,wCardCount)
dump(cbCardData,"cbCardData",6)
	if wCardCount>GameLogic:table_leng(self.m_cbCardData)  then
		wCardCount=GameLogic:table_leng(self.m_cbCardData)-1 --拷贝后面的数据
	end
	--设置扑克
	self.m_wCardCount=wCardCount
	--CopyMemory(m_cbCardData,cbCardData,sizeof(m_cbCardData[0])*wCardCount);
	--self.m_cbCardData=GameLogic:deepcopy(cbCardData) self.m_cbCardData 28个
	if nil ~= cbCardData then
	for i=1,28,1 do
		if nil ~= cbCardData[i] then
			self.m_cbCardData[i]=cbCardData[i]
		end
	end
	end
dump(self.m_cbCardData,"cbCardData",6)

	return true
end

--获取位置
function CDiscardCard:GetLastCardPosition()
print("CDiscardCard:GetLastCardPosition", self.m_CardDirection)
	--绘画控制
	if self.m_CardDirection==CardControl.Direction_East then				--东向
			--变量定义
			local nCellWidth=CardControl.CCardList["m_ImageTableRight"].m_nViewWidth
			local nCellHeight=CardControl.CCardList["m_ImageTableRight"].m_nViewHeight
			local nXPos=self.m_ControlPoint.x+((self.m_wCardCount-1)/8)*30+5
			local nYPos=self.m_ControlPoint.y+((self.m_wCardCount-1)%8)*20-15

			return cc.p(nXPos,nYPos)
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
			--变量定义
			local nCellWidth=CardControl.CCardList["m_ImageTableLeft"].m_nViewWidth
			local nCellHeight=CardControl.CCardList["m_ImageTableLeft"].m_nViewHeight
			local nXPos=self.m_ControlPoint.x-((self.m_wCardCount-1)/8)*30
			local nYPos=self.m_ControlPoint.y-((self.m_wCardCount-1)%8)*20-18
			return CPoint(nXPos,nYPos)
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
			--变量定义
			local nCellWidth=CardControl.CCardList["m_ImageTableBottom"].m_nViewWidth
			local nCellHeight=CardControl.CCardList["m_ImageTableBottom"].m_nViewHeight
			local nXPos=self.m_ControlPoint.x-((self.m_wCardCount-1)%14)*24-5
			local nYPos=self.m_ControlPoint.y+((self.m_wCardCount-1)/14)*38-8

			return CPoint(nXPos,nYPos)
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
			--变量定义
			local nCellWidth=CardControl.CCardList["m_ImageTableTop"].m_nViewWidth
			local nCellHeight=CardControl.CCardList["m_ImageTableTop"].m_nViewHeight
			local nXPos=self.m_ControlPoint.x+((self.m_wCardCount-1)%14)*24
			local nYPos=self.m_ControlPoint.y+((-self.m_wCardCount+1)/14)*38-21
			return CPoint(nXPos,nYPos)
	end
	return cc.p(0,0)
end

--设置方向
function CDiscardCard:SetDirection(Direction)
print("设置方向 CDiscardCard:SetDirection",Direction)
	self.m_CardDirection=Direction
end
--基准位置
function CDiscardCard:SetControlPoint(nXPos,nYPos)
print("基准位置 CDiscardCard:SetControlPoint",nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end
--===================================================================
--桌面扑克
function CTableCard:ctor()
	--扑克数据
	CTableCard.m_wCardCount=0
	--CTableCard.m_cbCardData={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	CTableCard.m_cbCardData="sign invalid"

	--控制变量
	CTableCard.m_ControlPoint = cc.p(0, 0)
	CTableCard.m_CardDirection=CardControl.Direction_East

	return
end

--绘画扑克
function CTableCard:DrawCardControl()
print("CTableCard:DrawCardControl")
dump(self.m_cbCardData,"self.m_cbCardData",6)
print("self.m_wCardCount",self.m_wCardCount,self.m_CardDirection)
	--绘画控制
	if self.m_CardDirection==CardControl.Direction_East then				--东向
		--绘画扑克
		for i=1,self.m_wCardCount+0,1 do
			local nXPos=self.m_ControlPoint.x-33
			local nYPos=self.m_ControlPoint.y+(i-1)*21
			CCardListImage:DrawCardItem("m_ImageTableRight","CTableCard_"..i,self.m_cbCardData[self.m_wCardCount-i+2],nXPos,nYPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_West then		--西向
		--绘画扑克
		for i=1,self.m_wCardCount+0,1 do
			local nXPos=self.m_ControlPoint.x
			local nYPos=self.m_ControlPoint.y-(self.m_wCardCount-i-1)*21
			CCardListImage:DrawCardItem("m_ImageTableLeft","CTableCard_"..i,self.m_cbCardData[i],nXPos,nYPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_South then		--南向
		--绘画扑克
		for i=1,self.m_wCardCount+0,1 do
			local nYPos=self.m_ControlPoint.y-CardControl.CCardList["m_ImageWaveBottom"].m_nViewHeight
			local nXPos=self.m_ControlPoint.x-(self.m_wCardCount-i-1)*39
			CCardListImage:DrawCardItem("m_ImageWaveBottom","CTableCard_"..i,self.m_cbCardData[i],nXPos,nYPos)
		end
	elseif self.m_CardDirection==CardControl.Direction_North then		--北向
		--绘画扑克
		for i=1,self.m_wCardCount+0,1 do
			local nYPos=self.m_ControlPoint.y
			local nXPos=self.m_ControlPoint.x+(i-1)*24
			CCardListImage:DrawCardItem("m_ImageTableTop","CTableCard_"..i,self.m_cbCardData[self.m_wCardCount-i+2],nXPos,nYPos)
		end
	end
	return
end

--设置扑克
function CTableCard:SetCardData(cbCardData,wCardCount)
print("CTableCard:SetCardData",cbCardData,wCardCount)
dump(self.m_cbCardData,"1",6)
dump(cbCardData,"2",6)
	if wCardCount>GameLogic:table_leng(self.m_cbCardData) then return false	end

	--设置扑克
	self.m_wCardCount=wCardCount
	if nil==cbCardData then
		self.m_cbCardData=GameLogic:sizeM(17)
	else
		self.m_cbCardData=GameLogic:deepcopy(cbCardData)
	end
	--CopyMemory(m_cbCardData,cbCardData,sizeof(m_cbCardData[0])*wCardCount);
dump(self.m_cbCardData,"self.m_cbCardData",6)
print(self.m_wCardCount)
	return true
end

--设置方向
function CTableCard:SetDirection(Direction)
print("设置方向 CTableCard:SetDirection",Direction)
dump(self.m_cbCardData)
	self.m_CardDirection=Direction
end
--基准位置
function CTableCard:SetControlPoint(nXPos,nYPos)
	self.m_ControlPoint=cc.p(nXPos,nYPos)
end
--===================================================================
--扑克控件
function CCardControl:ctor(base)
	CCardControl._base = base
	CCardControl.m_byGodsData= 0x00
	--状态变量
	CCardControl.m_bPositively=false
	CCardControl.m_bDisplayItem=false
--print("===================================123",CCardControl.m_bPositively,self.m_bPositively)
	--位置变量
	CCardControl.m_XCollocateMode=CardControl.enXCenter
	CCardControl.m_YCollocateMode=CardControl.enYCenter
	CCardControl.m_BenchmarkPos = cc.p(0, 0)

	--扑克数据
	CCardControl.m_wCardCount=0
	CCardControl.m_wHoverItem=CardControl.INVALID_ITEM
	CCardControl.m_CurrentCard=GameLogic:sizeM(2)
  	CCardControl.m_CardItemArray=GameLogic:ergodicList(cmd.MAX_COUNT)

	--加载设置
	CCardControl.m_ControlPoint=cc.p(0, 0)
	CCardControl.m_ControlSize={}
	CCardControl.m_ControlSize.cy=CardControl.CARD_HEIGHT+CardControl.POS_SHOOT
	CCardControl.m_ControlSize.cx=(GameLogic:table_leng(CCardControl.m_CardItemArray)+1)*CardControl.CARD_WIDTH+CardControl.POS_SPACE
	CCardControl.m_cbOutCardIndex=GameLogic:sizeM(cmd.MAX_INDEX) 
	CCardControl.m_bCardDisable=GameLogic:sizeF(cmd.MAX_INDEX)
	CCardControl.m_bShowDisable = false
	CCardControl.pWnd=nil
	--HINSTANCE hInstance=AfxGetInstanceHandle()
	return
end

--清除
function CCardControl:DrawClearn()
print("CCardControl 清除  未处理")
end

function CCardControl:SetBenchmarkPos(...)
	local arg={...}
	local len=#arg
	if len==3 then	return CCardControl:SetBenchmarkPos_3(arg[1],arg[2],arg[3])
	elseif len==4 then	return CCardControl:SetBenchmarkPos_4(arg[1],arg[2],arg[3],arg[4])
	else	print("SetBenchmarkPos 参数个数不符 len",len)
	end
end
--基准位置
function CCardControl:SetBenchmarkPos_4(nXPos,nYPos,XCollocateMode,YCollocateMode)
	--设置变量
	self.m_BenchmarkPos.x=nXPos
	self.m_BenchmarkPos.y=nYPos
	self.m_XCollocateMode=XCollocateMode
	self.m_YCollocateMode=YCollocateMode

	--横向位置
	if self.m_XCollocateMode==CardControl.enXLeft then
		self.m_ControlPoint.x=self.m_BenchmarkPos.x
	elseif self.m_XCollocateMode==CardControl.enXCenter then
		self.m_ControlPoint.x=self.m_BenchmarkPos.x-self.m_ControlSize.cx/2
	elseif self.m_XCollocateMode==CardControl.enXRight then
		self.m_ControlPoint.x=self.m_BenchmarkPos.x-self.m_ControlSize.cx
	end

	--竖向位置
	if self.m_YCollocateMode==CardControl.enYTop then
		self.m_ControlPoint.y=self.m_BenchmarkPos.y
	elseif self.m_YCollocateMode==CardControl.enYCenter then
		self.m_ControlPoint.y=self.m_BenchmarkPos.y-self.m_ControlSize.cy/2
	elseif self.m_YCollocateMode==CardControl.enYBottom then
		self.m_ControlPoint.y=self.m_BenchmarkPos.y-self.m_ControlSize.cy
	end
	return
end

--获取扑克
function CCardControl:SetBenchmarkPos_3(BenchmarkPos,XCollocateMode,YCollocateMode)
	--设置变量
	self.m_BenchmarkPos=BenchmarkPos
	self.m_BenchmarkPos.y=nYPos
	self.m_XCollocateMode=XCollocateMode
	self.m_YCollocateMode=YCollocateMode

	--横向位置
	if self.m_XCollocateMode==CardControl.enXLeft then
		self.m_ControlPoint.x=self.m_BenchmarkPos.x
	elseif self.m_XCollocateMode==CardControl.enXCenter then
		self.m_ControlPoint.x=self.m_BenchmarkPos.x-self.m_ControlSize.cx/2
	elseif self.m_XCollocateMode==CardControl.enXRight then
		self.m_ControlPoint.x=self.m_BenchmarkPos.x-self.m_ControlSize.cx
	end

	--竖向位置
	if self.m_YCollocateMode==CardControl.enYTop then
		self.m_ControlPoint.y=self.m_BenchmarkPos.y
	elseif self.m_YCollocateMode==CardControl.enYCenter then
		self.m_ControlPoint.y=self.m_BenchmarkPos.y-self.m_ControlSize.cy/2
	elseif self.m_YCollocateMode==CardControl.enYBottom then
		self.m_ControlPoint.y=self.m_BenchmarkPos.y-self.m_ControlSize.cy
	end
	return
end
--获取扑克
function CCardControl:GetHoverCard()
	--获取扑克
print("获取悬停 扑克")
	-- local byCardData = 0x00
	-- if self.m_wHoverItem~=CardControl.INVALID_ITEM then
	-- 	if self.m_wHoverItem==#self.m_CardItemArray then
	-- 		byCardData =  self.m_CurrentCard.cbCardData
	-- 	else
	-- 		byCardData = self.m_CardItemArray[self.m_wHoverItem].cbCardData
	-- 	end

	-- 	GameLogic:SetGodsCard(self.m_byGodsData)
	-- 	local byIndex = GameLogic:SwitchToCardIndex(byCardData)+1
	-- 	if self.m_bCardDisable[byIndex] then
	-- 		byCardData = 0x00
	-- 	end

	-- 	if byCardData == self.m_byGodsData then
	-- 		local bAllGods = true
	-- 		if self.m_CurrentCard.cbCardData ~= self.m_byGodsData then
	-- 			bAllGods = false
	-- 		end
	-- 		if bAllGods then
	-- 			while true do
	-- 				for i=1,self.m_wCardCount+0,1 do
	-- 					if self.m_CardItemArray[i].cbCardData ~= self.m_byGodsData then
	-- 						bAllGods = false
	-- 					break	end
	-- 				end
	-- 			break end
	-- 		end
	-- 		if not bAllGods then
	-- 			byCardData = 0x00
	-- 		end
	-- 	end
	-- end

	-- return byCardData
end
--获取出牌扑克
function CCardControl:GetOutCard(byCardData)
	m_GodsData=CCardControl.m_byGodsData
print("获取出牌扑克 ",byCardData,m_GodsData,CCardControl.m_byGodsData)
	if nil==byCardData or ""==byCardData then return end
	GameLogic:SetGodsCard(m_GodsData)
	local byIndex = GameLogic:SwitchToCardIndex(byCardData)+1
	if self.m_bCardDisable[byIndex] then
		byCardData = 0x00
	end

	if byCardData == m_GodsData then
		local bAllGods = true
		if self.m_CurrentCard.cbCardData ~= m_GodsData then
			bAllGods = false
		end
		if bAllGods then
			while true do
				for i=1,self.m_wCardCount+0,1 do
					if self.m_CardItemArray[i].cbCardData ~= m_GodsData then
						bAllGods = false
					break	end
				end
			break end
		end
		if not bAllGods then
			byCardData = 0x00
		end
	end
print(byCardData)
	--请出单字牌  ~=0 ？
	if condition ~=0 then
		self._base:VOnOutCard(byCardData)
	else
		self._base:VOnOutInvalidCard()
	end
end

--设置扑克
function CCardControl:SetCurrentCard(cbCardData)
print("设置当前扑克 CCardControl:SetCurrentCard",cbCardData)
	if nil~=cbCardData and type(cbCardData)=="table" then
		--设置变量
		self.m_CurrentCard.bShoot=cbCardData.bShoot
		self.m_CurrentCard.cbCardData=cbCardData.cbCardData
		return true
	elseif nil~=cbCardData then
		--设置变量
		self.m_CurrentCard.bShoot=false
		self.m_CurrentCard.cbCardData=cbCardData
		return true
	end
end

--设置扑克
function CCardControl:SetCardData(cbCardData,wCardCount,cbCurrentCard)
print("设置扑克 CCardControl:SetCardData ",cbCardData,wCardCount,cbCurrentCard)
	if wCardCount>GameLogic:table_leng(self.m_CardItemArray) then
		return false
	end

	--当前扑克
	self.m_CurrentCard.bShoot=false
	self.m_CurrentCard.cbCardData=cbCurrentCard

	--设置扑克
	self.m_wCardCount=wCardCount
	for i=1,self.m_wCardCount+0,1 do
		self.m_CardItemArray[i].bShoot=false
		local tempD=0
		if cbCardData then	tempD= cbCardData[i] end
		self.m_CardItemArray[i].cbCardData=tempD 
	end
dump(cbCardData,"cbCardData",6)
dump(self.m_CardItemArray,"self.m_CardItemArray",6)
	return true
end

--设置扑克 没用到
function CCardControl:SetCardItem(CardItemArray,wCardCount)
print("设置扑克 CCardControl:SetCardItem ",CardItemArray,wCardCount)
	if wCardCount>GameLogic:table_leng(self.m_CardItemArray) then
		return false
	end

	--设置扑克
	self.m_wCardCount=wCardCount
	for i=1,self.m_wCardCount+0,1 do
		self.m_CardItemArray[i].bShoot=CardItemArray[i].bShoot
		self.m_CardItemArray[i].cbCardData=CardItemArray[i].cbCardData
	end
	return true
end

function CCardControl:SetOutCardData(...)
	local arg={...}
	local len=#arg
	if len==1 then	return CCardControl:SetOutCardData_1(arg[1])
	elseif len==2 then	return CCardControl:SetOutCardData_2(arg[1],arg[2])
	else	print("SetOutCardData 参数个数不符 len",len)
	end
end
function CCardControl:SetOutCardData_2(cbCardDataIndex,wCardCount)
print("CCardControl:SetOutCardData_2",cbCardDataIndex,wCardCount)
	self.m_cbOutCardIndex=GameLogic:sizeM(cmd.MAX_INDEX) 
	if nil ~= cbCardDataIndex then
		--CopyMemory(m_cbOutCardIndex, cbCardDataIndex, wCardCount);
		self.m_cbOutCardIndex=GameLogic:deepcopy(cbCardDataIndex)
	end
end

function CCardControl:SetOutCardData_1(cbCardDataIndex)
print("CCardControl:SetOutCardData_1",cbCardDataIndex)
	--if cbCardDataIndex>(#self.m_cbOutCardIndex/#self.m_cbOutCardIndex[1]) then
	if cbCardDataIndex>(#self.m_cbOutCardIndex) then
		return
	end
	self.m_cbOutCardIndex[cbCardDataIndex]=self.m_cbOutCardIndex[cbCardDataIndex]+1
end

--设置
function CCardControl:SetGodsCard(cbCardData)
print("设置财神 CCardControl:SetGodsCard",cbCardData)
	self.m_byGodsData = cbCardData
	CCardControl.m_byGodsData = cbCardData
print(self.m_byGodsData,CCardControl.m_byGodsData)
end

function CCardControl:UpdateCardDisable(bShowDisable)
print("CCardControl:UpdateCardDisable",bShowDisable)
	self.m_bCardDisable=GameLogic:sizeF(cmd.MAX_INDEX) 
	self.m_bShowDisable = bShowDisable
	if not bShowDisable then	return end
	GameLogic:SetGodsCard(self.m_byGodsData)

	-- 只要有单张的风， 所有的数字牌都要变灰
	local bHaveSingle = false
	local byIndexCount=GameLogic:sizeM(cmd.MAX_INDEX)  -- 牌的张数
	if 0x00 == self.m_byGodsData then	return	end
	local byGodsIndex = GameLogic:SwitchToCardIndex(self.m_byGodsData)+1
dump(self.m_CardItemArray,"m_CardItemArray",6)
	for i=1,self.m_wCardCount+0,1 do
		local cbCardData=(self.m_bDisplayItem==true) and self.m_CardItemArray[i].cbCardData or 0
print(self.m_CardItemArray[i].cbCardData,cbCardData,self.m_byGodsData,byGodsIndex)
		if ( 0x00 ~= cbCardData) and (self.m_byGodsData ~= cbCardData) then
			local byIndex = GameLogic:SwitchToCardIndex(cbCardData)+1
print("byIndex-",byIndex)
			byIndexCount[byIndex]=byIndexCount[byIndex]+1
		end
	end

print("self.m_CurrentCard.cbCardData",self.m_CurrentCard.cbCardData)
	if self.m_CurrentCard.cbCardData~=0 then
		local cbCardData=(self.m_bDisplayItem==true) and self.m_CurrentCard.cbCardData or 0
		if ( 0x00 ~= cbCardData) and (self.m_byGodsData ~= cbCardData) then
			local byIndex = GameLogic:SwitchToCardIndex(cbCardData)+1
			byIndexCount[byIndex]=byIndexCount[byIndex]+1
		end
	end

	-- 单张风 风不是只有东南西北 么？
dump(byIndexCount,"byIndexCount 单张风",6)
	while true do
	for i=27+1,cmd.MAX_INDEX-0,1 do
print(i)
		if (1 == byIndexCount[i]) and (byGodsIndex ~= i) then
			bHaveSingle = true
		break	end
	end
	break end
print(bHaveSingle)
	if not bHaveSingle then  --没有单张的风,所有牌可以出
		self.m_bCardDisable=GameLogic:sizeF(cmd.MAX_INDEX)
		return
	end

	-- 先把所有的牌都初始化为不可以出
	bHaveSingle = false  -- 是否存在单牌已经出过
	local bHaveDouble = false
	for i=1,cmd.MAX_INDEX,1 do
	while true do
		self.m_bCardDisable[i] = true
		if (i<27+1) or (byGodsIndex == (i+1)) then break end

		-- 在已经出牌中找到此牌
		if self.m_cbOutCardIndex[i]>0 then		--已经出过
			bHaveDouble = true
			self.m_bCardDisable[i]=false
			if 1 == byIndexCount[i] then
				bHaveSingle = true
			end
		end
	break end
	end
dump(self.m_bCardDisable,"111 m_bCardDisable",6)
print(bHaveSingle,bHaveDouble)
	-- 所有的单牌都可以出
	if not bHaveSingle then
		for i=27,cmd.MAX_INDEX-1,1 do
		while true do
			if byGodsIndex == i then break end
print(i , byIndexCount[i])
			if (1 == byIndexCount[i]) or ((not bHaveDouble) and byIndexCount[i]>0) then
				self.m_bCardDisable[i]=false
			end
		break end
		end
	end
dump(self.m_bCardDisable,"222 m_bCardDisable",6)
print("CCardControl:UpdateCardDisable END !")
end

--绘画扑克
function CCardControl:DrawCardControl(is_wOutCardUser)
print("CCardControl:DrawCardControl",self.m_wCardCount,is_wOutCardUser)
	--绘画准备
	local nXExcursion=self.m_ControlPoint.x+(GameLogic:table_leng(self.m_CardItemArray)-self.m_wCardCount)*CardControl.CARD_WIDTH

	GameLogic:SetGodsCard(self.m_byGodsData)
	--绘画扑克
	for i=1,self.m_wCardCount+0,1 do
		--计算位置
		local nXScreenPos=nXExcursion+CardControl.CARD_WIDTH*(i-1)
		local nYScreenPos=self.m_ControlPoint.y+(((self.m_CardItemArray[i].bShoot==false) and (self.m_wHoverItem~=(i-1))) and CardControl.POS_SHOOT or 0)

		--绘画扑克
		local cbCardData=(self.m_bDisplayItem==true) and self.m_CardItemArray[i].cbCardData or 0
print(i,cbCardData,self.m_bShowDisable,nXScreenPos,nYScreenPos)
		if (0 ~= cbCardData) and self.m_bShowDisable then
			local byIndex = GameLogic:SwitchToCardIndex(cbCardData)+1
			CCardListImage:DrawCardItem("m_ImageUserBottom","CCardControl_"..i,cbCardData,nXScreenPos,nYScreenPos,self.m_byGodsData)
		else
			CCardListImage:DrawCardItem("m_ImageUserBottom","CCardControl_"..i,cbCardData,nXScreenPos,nYScreenPos,self.m_byGodsData)
		end
	end

	--当前扑克
	if self.m_CurrentCard.cbCardData~=0 then
		--计算位置
		local nXScreenPos=self.m_ControlPoint.x+self.m_ControlSize.cx-CardControl.CARD_WIDTH
		local nYScreenPos=self.m_ControlPoint.y+(((self.m_CurrentCard.bShoot==false) and (self.m_wHoverItem~=GameLogic:table_leng(self.m_CardItemArray))) and CardControl.POS_SHOOT or 0)

		--绘画扑克
		local cbCardData=(self.m_bDisplayItem==true) and self.m_CurrentCard.cbCardData or 0
	print("!!! 当前",self.m_CurrentCard.cbCardData,cbCardData,self.m_bShowDisable)
	--mark self.m_CurrentCard.cbCardData 暂时替换i 先显示
		if is_wOutCardUser then
		--添加 不是出牌用户不显示当前牌
			if (0 ~= cbCardData) and self.m_bShowDisable then
				local byIndex = GameLogic:SwitchToCardIndex(cbCardData)+1
				CCardListImage:DrawCardItem("m_ImageUserBottom","CCardControl_Current",cbCardData,nXScreenPos,nYScreenPos,self.m_byGodsData,true)
			else
				CCardListImage:DrawCardItem("m_ImageUserBottom","CCardControl_Current",cbCardData,nXScreenPos,nYScreenPos,self.m_byGodsData,true)
			end
		end
	end

	return
end

--索引切换
function CCardControl:SwitchCardPoint(MousePoint)
	--基准位置
	local nXPos=MousePoint.x-self.m_ControlPoint.x
	local nYPos=MousePoint.y-self.m_ControlPoint.y

	--范围判断
	if (nXPos<0) or (nXPos>self.m_ControlSize.cx) then return CardControl.INVALID_ITEM	end
	if (nYPos<CardControl.POS_SHOOT) or (nYPos>self.m_ControlSize.cy) then return CardControl.INVALID_ITEM	end

	--牌列子项
	if nXPos<CardControl.CARD_WIDTH*GameLogic:table_leng(self.m_CardItemArray) then
		local wViewIndex=(nXPos/CardControl.CARD_WIDTH)+self.m_wCardCount
		if wViewIndex>=GameLogic:table_leng(self.m_CardItemArray) then
			return wViewIndex-GameLogic:table_leng(self.m_CardItemArray)
		end
		return CardControl.INVALID_ITEM
	end

	--当前子项
	if (self.m_CurrentCard.cbCardData~=0) and (nXPos>=(self.m_ControlSize.cx-CardControl.CARD_WIDTH)) then
		return GameLogic:table_leng(self.m_CardItemArray)
	end

	return CardControl.INVALID_ITEM
end

--光标消息
function CCardControl:OnEventSetCursor(Point,bRePaint)
	--获取索引
	local wHoverItem=self:SwitchCardPoint(Point)

	--响应判断
	if (self.m_bPositively==false) and (self.m_wHoverItem~=CardControl.INVALID_ITEM) then
		bRePaint=true
		self.m_wHoverItem=CardControl.INVALID_ITEM
	end

	--更新判断
	if (wHoverItem ~= self.m_wHoverItem) and (self.m_bPositively==true) then
		bRePaint=true
		self.m_wHoverItem=wHoverItem
		--SetCursor(LoadCursor(AfxGetInstanceHandle(),MAKEINTRESOURCE(IDC_CARD_CUR)));  手机端无光标
	end

	return (wHoverItem~=CardControl.INVALID_ITEM)
end

function CCardControl:GetMeOutCard()
	GameLogic:SetGodsCard(self.m_byGodsData)

	local iIndex = GameLogic:SwitchToCardIndex(self.m_CurrentCard.cbCardData)+1
	if not self.m_bCardDisable[iIndex] and (self.m_CurrentCard.cbCardData ~= self.m_byGodsData) then
		return self.m_CurrentCard.cbCardData
	end

	for i=1,self.m_wCardCount+0,1 do
		local cbCardData=self.m_CardItemArray[i].cbCardData
		iIndex = GameLogic:SwitchToCardIndex(cbCardData)+1
		if not self.m_bCardDisable[iIndex] and (cbCardData ~= self.m_byGodsData) then
			return cbCardData
		end
	end
	if self.m_wCardCount>0 then
		local cbCardData=self.m_CardItemArray[1].cbCardData
		return cbCardData
	end
	return 0x00
end

function CCardControl:SetShootCard(cbCard1,cbCard2,cbCard3)
	--先全部放下
	if cbCard1==0 and cbCard2==0 and cbCard3==0 then
		for i=1,self.m_wCardCount+0,1 do
			self.m_CardItemArray[i].bShoot=false
		end
	end
	local b1,b2,b3=false,false,false
	for i=1,self.m_wCardCount+0,1 do
		if self.m_CardItemArray[i].cbCardData==cbCard1 and not b1 then
			self.m_CardItemArray[i].bShoot=true
			b1=true
		end
		if self.m_CardItemArray[i].cbCardData==cbCard2 and not b2 then
			self.m_CardItemArray[i].bShoot=true
			b2=true
		end
		if self.m_CardItemArray[i].cbCardData==cbCard3 and not b3 then
			self.m_CardItemArray[i].bShoot=true
			b3=true
		end

	end
	GameViewLayer:RefreshGameView()
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
